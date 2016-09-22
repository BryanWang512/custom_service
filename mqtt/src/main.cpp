#include "Plugin.h"
#include "config.h"

//不同OS的配置
#include "stdio.h"
#include "stdarg.h"
#include <string>
#include <vector>
#include <time.h>
#include <sstream>

//引擎插件接口的声明
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
extern "C" {
#endif
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
}
#endif
#include "mqtt_lua_bind.h"
#include "mqtt_global.h"
#include "BYMqttClient.h"
#include "MessageContainer.h"

static int traceback(lua_State *);
static void handleLuaMessage();
static void handleLoginResponse();
static void handleShiftSession();
static void handleEndSession();
static void handleChatReadyResponse();
static void handleChatMessage();
static void handleChatOffMessage();
static void handleLogoutMessage();
static void handleMqttEvent();
static BYMqttClient* mqtt_client = NULL;

#define TRACE_BACK 	if (__DEBUG) lua_pushcfunction(L, traceback);

static bool should_return()
{
	return (mqtt_client == NULL) || (mqtt_client->isDestorying());
}

static int traceback(lua_State *L) {
    lua_getfield(L, LUA_GLOBALSINDEX, "debug");
    lua_getfield(L, -1, "traceback");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 2);
    lua_call(L, 2, 1);
	mqtt_print_log_debug(TAG, lua_tostring(L, -1));
    return 1;
}

static void call_lua(lua_State *L, int nargs, int nresults, int errfunc)
{
	if (L == NULL) return;
	lua_pcall(L, nargs, nresults, errfunc);
}

static luaL_Reg lualibs[] =
{
	{ "mqtt", mqtt_register_funcs },
	{ NULL, NULL }
};


static lua_State* GetLuaState()
{
	if (0 == g_EngineInterface) return 0;
	return (lua_State*)g_EngineInterface->GetLuaState();
}

static void registLuaLib(lua_State* L)
{
	luaL_Reg* libs = lualibs;
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	for (; libs->func; libs++){
		lua_pushcfunction(L, libs->func);
		lua_setfield(L, -2, libs->name);
	}
	lua_pop(L, 2);
}

//---------------------------------------------------------------
//每次LuaState被创建后立即调用(引擎运行期间,LuaState可能会重建,比如lua出错之后)

static void LuaInit(void* param1, void* param2)
{
	lua_State* L = GetLuaState();
	registLuaLib(L);
}


static void ViewInit(void* param1, void* param2)
{
	g_EngineInterface = (EngineInterface*)param1;
}

static void OnUpdate(long time)
{
	if (should_return()) return;
	handleLuaMessage();
}

static void OnClose()
{
	g_EngineInterface = NULL;
	if (should_return()) return;
	delete mqtt_client;
	mqtt_client = NULL;
}

static int MainProc(EPluginMsgType eMsgType, void* param1, void* param2)
{
	long* time;
	switch (eMsgType)
	{
	case EViewOnReady:
		ViewInit(param1, param2);
		break;
	case ELuaOnReady:
		LuaInit(param1, param2);
		break;
	case EFrameUpdate:
		time = (long*)param1;
		OnUpdate(*time);
		break;
	case EOnExit:
		OnClose();
		break;
	default:
		break;
	}

	return 0;
}

extern "C"
{
#if (TARGET_PLATFORM==PLATFORM_WIN32)
	//__declspec(dllexport) win32：导出dll的接口函数
	__declspec(dllexport) int plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
	int plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif

#if (TARGET_PLATFORM==PLATFORM_IOS)
	int mqtt_plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif
}

/*接收一个json 字符串
*mqtt_client_config = {
* host			= "192.168.1.1",
* port			= "1338",
* gameId		= "1",
* siteId		= "117",
* role			= "2",
* stationId		= "12345678",
* avatarUri		= "path",
* qos			= 1, (int)
* cleanSession	= true, (bool)
* keepalive		= 60, (int)
* timeout		= 1000, (int)
* retain		= false, (bool)
* ssl			= false, (bool)
* sslKey		= "",
* userName		= "username",
* userPwd		= "123456",
*｝
*以上16项是mqtt的参数
*/
int mqtt_create(lua_State* L)
{
	string params = luaL_checkstring(L, 1);
	mqtt_print_log_debug(TAG, "params : %s", params.c_str());
	long id = luaL_checklong(L, 2);
	mqtt_print_log_debug(TAG, "id : %d", id);
	Json::Value json;
	if (!string_to_json(params, json)){
		mqtt_print_log_debug(TAG, "parse json error!!!!!!!!!!!!");
		return 0;
	}
	string host = json[COLUMN_HOST_CONFIG].asString();
	string port = json[COLUMN_PROT_CONFIG].asString();
	string gameId = json[COLUMN_GID_CONFIG].asString();
	string siteId = json[COLUMN_SID_CONFIG].asString();
	string role = json[COLUMN_ROLE_CONFIG].asString();
	string stationId = json[COLUMN_STATIONID_CONFIG].asString();
	string avatarUri = json[COLUMN_UAVATAR_CONFIG].asString();
	int qos = json[COLUMN_QOS_CONFIG].asInt();
	bool cleanSession = json[COLUMN_CLEANSESSION_CONFIG].asBool();
	int keepalive = json[COLUMN_KEEPALIVE_CONFIG].asInt();
	int timeout = json[COLUMN_TIMEOUT_CONFIG].asInt();
	bool retain = json[COLUMN_RETAIN_CONFIG].asBool();
	bool ssl = json[COLUMN_SSL_CONFIG].asBool();
	string sslKey = json[COLUMN_SSLKEY_CONFIG].asString();
	string userName = json[COLUMN_UNAME_CONFIG].asString();
	string userPwd = json[COLUMN_UPWD_CONFIG].asString();


	ClientConfig::ClientConfigBuilder* builder = new ClientConfig::ClientConfigBuilder(host, port);
	ClientConfig* clientConfig = builder->set_gameId(gameId)->set_siteId(siteId)->set_stationId(stationId)
		->set_role(role)->set_qos(qos)->set_cleanSession(cleanSession)->set_keepalive(keepalive)
		->set_timeout(timeout)->set_retain(retain)->set_ssl(ssl)->set_sslKey(sslKey)
		->set_userName(userName)->set_userPwd(userPwd)->set_avatarUri(avatarUri)->build();
	mqtt_client = new BYMqttClient(clientConfig, id);
	delete builder;
	builder = NULL;
	return 1;
}

int mqtt_destroy(lua_State* L)
{
	mqtt_print_log_debug(TAG, "mqtt_destroy!!!!!!!!!!");
	delete mqtt_client;
	mqtt_client = NULL;
	return 1;
}

int mqtt_connect(lua_State* L)
{
	if (should_return())
		return 0;
	string topicName = luaL_checkstring(L, 1);
	lua_pushinteger(L, mqtt_client->connect(topicName));
	return 1;
}

int mqtt_is_connected(lua_State* L)
{
	if (should_return())
		return 0;
	lua_pushboolean(L, mqtt_client->isConnected());
	return 1;
}

int mqtt_disconnect(lua_State* L)
{
	if (should_return())
		return 0;
	mqtt_print_log_debug(TAG, "mqtt_disconnect!!!!!!!!!!");
	lua_pushinteger(L, mqtt_client->disconnect());
	return 1;
}

int mqtt_reconnect(lua_State* L)
{
	if (should_return())
		return 0;
	return 1;
}

int mqtt_subscribe(lua_State* L)
{
	if (should_return())
		return 0;
	string topicName = luaL_checkstring(L, 1);
	lua_pushinteger(L, mqtt_client->subscribe(topicName));
	return 1;
}

int mqtt_unsubscribe(lua_State* L)
{
	if (should_return())
		return 0;
	lua_pushinteger(L, mqtt_client->unsubscribe());
	return 1;
}

int mqtt_send_chat_ready_msg(lua_State* L)
{
	if (should_return())
		return 0;
	string clientInfo = luaL_checkstring(L, 1);
	string sessionId = luaL_checkstring(L, 2);
	string topicName = luaL_checkstring(L, 3);
	lua_pushinteger(L, mqtt_client->sendChatReadyMsg(clientInfo, sessionId, topicName));
	return 1;
}

int mqtt_send_chat_msg(lua_State* L)
{
	if (should_return())
		return 0;
	string msg = luaL_checkstring(L, 1);
	string type = luaL_checkstring(L, 2);
	string sessionId = luaL_checkstring(L, 3);
	string topicName = luaL_checkstring(L, 4);
	lua_pushinteger(L, mqtt_client->sendChatMsg(msg, type, sessionId, topicName));
	return 1;
}

int mqtt_send_msg(lua_State* L)
{
	if (should_return())
		return 0;
	lua_pushinteger(L, mqtt_client->sendMessage(L));
	return 1;
}

int mqtt_send_msg_ack(lua_State* L)
{
	if (should_return())
		return 0;
	_long seq_id = luaL_checknumber(L, 1);
	string sessionId = luaL_checkstring(L, 2);
	string topicName = luaL_checkstring(L, 3);
	lua_pushinteger(L, mqtt_client->sendMessageAck(seq_id, sessionId, topicName));
	return 1;
}

int mqtt_send_offmsg_ack(lua_State* L)
{
	if (should_return())
		return 0;
	//第一个参数是table
	luaL_checktype(L, 1, LUA_TTABLE);
	int len = lua_objlen(L, 1);
	mqtt_print_log_debug(TAG, "mqtt_send_offmsg_ack table len: %d", len);
	vector<_long> msgs;
	for (int i = 1; i <= len; ++i)
	{
		lua_rawgeti(L, 1, i);
		msgs.push_back(lua_tonumber(L, -1));
		lua_pop(L, 1);
	}
	string sessionId = luaL_checkstring(L, 2);
	string topicName = luaL_checkstring(L, 3);
	lua_pushinteger(L, mqtt_client->sendOffMessageAck(msgs, sessionId, topicName));
	return 1;
}

int mqtt_clock(lua_State* L)
{
	_long now = currentTimeMillis();
	lua_pushnumber(L, now);
	return 1;
}


/*-----------------------------------下面是mqtt回调函数-----------------------------------------*/
static void delivery_completed(void *context, MQTTAsync_token dt)
{
	mqtt_print_log_debug(TAG, "Message with token value %d delivery confirmed\n", dt);
	//do nothing
	if (should_return()) return;
	mqtt_client->token = dt;
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_DELIVERY_COMPLETED;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
	
}

//context 就是 BYMqttClient
static int message_arrived(void *context, char *topicName, int topicLen, MQTTAsync_message *message)
{
	if (should_return()) return 0;
	mqtt_print_log_debug(TAG, "message_arrived\n");
	mqtt_print_log_debug(TAG, "topic: %s\n", topicName);
	if (str_ends_with(topicName, "loginresp"))
	{
		LoginResponse response;
		response.ParseFromArray(message->payload, message->payloadlen);
		LUA_LoginResponse login;
		login.code = response.code();
		login.return_msg = response.return_msg();
		login.session_id = response.session_id();
		login.service_gid = response.service_gid();
		login.service_site_id = response.service_site_id();
		login.service_station_id = response.service_station_id();
		login.wait_count = response.wait_count();
		mqtt_client->getContainer()->pushLoginResponse(login);
	}

	else if (str_ends_with(topicName, "shift")) {
		ShiftSession shiftSession;
		shiftSession.ParseFromArray(message->payload, message->payloadlen);
		LUA_ShiftSession shift;
		shift.shift_to_fid = shiftSession.shift_to_fid();
		shift.session_id = shiftSession.session_id();
		mqtt_client->getContainer()->pushShiftSession(shift);
	}
	else if (str_ends_with(topicName, "end")) {
		EndSession endSession;
		endSession.ParseFromArray(message->payload, message->payloadlen);
		LUA_EndSession end;
		end.session_id = endSession.session_id();
		end.client_gid = endSession.client_gid();
		end.client_site_id = endSession.client_site_id();
		end.client_station_id = endSession.client_station_id();
		end.archive_class = endSession.archive_class();
		end.archive_category = endSession.archive_category();
		end.session_upgraded = endSession.session_upgraded();
		end.session_invalid = endSession.session_invalid();
		end.end_type = endSession.end_type();
		mqtt_client->getContainer()->pushEndSession(end);
	}
	else if (str_ends_with(topicName, "chatreadyresp"))
	{
		ChatReadyResponse response;
		response.ParseFromArray(message->payload, message->payloadlen);
		LUA_ChatReadyResponse chatready;
		chatready.code = response.code();
		chatready.session_id = response.session_id();
		chatready.service_info = response.service_info();
		mqtt_client->getContainer()->pushChatReadyResponse(chatready);
	}
	else if (str_ends_with(topicName, "chat"))
	{
		ChatMessage chatMessage;
		chatMessage.ParseFromArray(message->payload, message->payloadlen);
		LUA_ChatMessage chat;
		chat.seq_id = chatMessage.seq_id();
		chat.type = chatMessage.type();
		chat.msg = chatMessage.msg();
		chat.session_id = chatMessage.session_id();
		mqtt_client->getContainer()->pushChatMessage(chat);
	}
	// 会话状态和离线消息
	else if (str_ends_with(topicName, "chatoff"))
	{
		ChatMessage chatMessage;
		chatMessage.ParseFromArray(message->payload, message->payloadlen);
		LUA_ChatMessage chat;
		chat.seq_id = chatMessage.seq_id();
		chat.type = chatMessage.type();
		chat.msg = chatMessage.msg();
		chat.session_id = chatMessage.session_id();
		mqtt_client->getContainer()->pushChatOffMessage(chat);
	}
	else if (str_ends_with(topicName, "logout"))
	{
		LogoutMessage logoutMessage;
		logoutMessage.ParseFromArray(message->payload, message->payloadlen);
		LUA_LogoutMessage logout;
		logout.session_id = logoutMessage.session_id();
		logout.service_gid = logoutMessage.service_gid();
		logout.service_site_id = logoutMessage.service_site_id();
		logout.service_station_id = logoutMessage.service_station_id();
		logout.clock = logoutMessage.clock();
		logout.end_type = logoutMessage.end_type();
		logout.extra = logoutMessage.extra();
		mqtt_client->getContainer()->pushLogoutMessage(logout);
	}
	MQTTAsync_freeMessage(&message);
	MQTTAsync_free(topicName);
	return 1;
}

static void conn_lost(void *context, char *cause)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Connection lost, cause: %s\n", cause);
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_CONNECT_LOST;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onConnectFailure(void* context, MQTTAsync_failureData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Connect failed, rc %d\n", response ? response->code : 0);
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_CONNECT_FAILURE;
	event.extera = response ? response->code : 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onConnect(void* context, MQTTAsync_successData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Connect succeed !!!");
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_CONNECT_SUCCESS;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onSubscribe(void* context, MQTTAsync_successData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Subscribe succeed !!!");
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_SUBSCRIBE_SUCCESS;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onSubscribeFailure(void* context, MQTTAsync_failureData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Subscribe failed, rc %d\n", response ? response->code : 0);
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_SUBSCRIBE_FAILURE;
	event.extera = response ? response->code : 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onPublish(void* context, MQTTAsync_successData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Publish succeed !!!");
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_SEND_MSG_SUCCESS;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onPublishFailure(void* context, MQTTAsync_failureData* response)
{
	mqtt_print_log_debug(TAG, "Publish failed, rc %d\n", response ? response->code : 0);
	if (should_return()) return;
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_SEND_MSG_FAILURE;
	event.extera = response ? response->code : 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onDisconnect(void* context, MQTTAsync_successData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Disconnect succeed !!!");
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_DISCONNECT_SUCCESS;
	event.extera = 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void onDisconnectFailure(void* context, MQTTAsync_failureData* response)
{
	if (should_return()) return;
	mqtt_print_log_debug(TAG, "Disconnect failed, rc %d\n", response ? response->code : 0);
	MqttEvent event;
	event.id = mqtt_client->getId();
	event.cmd = MQTT_DISCONNECT_FAILURE;
	event.extera = response ? response->code : 0;
	mqtt_client->getContainer()->pushMqttEvent(event);
}

static void handleLoginResponse()
{
	if (mqtt_client->getContainer()->is_login_response_queue_empty()) return;
	LUA_LoginResponse item = mqtt_client->getContainer()->popLoginResponse();
	mqtt_print_log_debug(TAG, "handleLoginResponse");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "loginresp");
	lua_pushinteger(L, item.code);
	lua_pushstring(L, item.return_msg.c_str());
	lua_pushstring(L, item.session_id.c_str());
	lua_pushstring(L, item.service_gid.c_str());
	lua_pushstring(L, item.service_site_id.c_str());
	lua_pushstring(L, item.service_station_id.c_str());
	lua_pushinteger(L, item.wait_count);
	call_lua(L, 9, 0, lua_gettop(L) - 10);

}
static void handleShiftSession()
{
	if (mqtt_client->getContainer()->is_shift_session_queue_empty()) return;
	LUA_ShiftSession item = mqtt_client->getContainer()->popShiftSession();
	mqtt_print_log_debug(TAG, "handleShiftSession");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "shift");
	lua_pushstring(L, item.shift_to_fid.c_str());
	lua_pushstring(L, item.session_id.c_str());
	call_lua(L, 4, 0, lua_gettop(L) - 5);

}
static void handleEndSession()
{
	if (mqtt_client->getContainer()->is_end_session_queue_empty()) return;
	LUA_EndSession item = mqtt_client->getContainer()->popEndSession();
	mqtt_print_log_debug(TAG, "handleEndSession");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "end");
	lua_pushstring(L, item.session_id.c_str());
	lua_pushstring(L, item.client_gid.c_str());
	lua_pushstring(L, item.client_site_id.c_str());
	lua_pushstring(L, item.client_station_id.c_str());
	lua_pushinteger(L, item.archive_class);
	lua_pushinteger(L, item.archive_category);
	lua_pushinteger(L, item.session_upgraded);
	lua_pushinteger(L, item.session_invalid);
	lua_pushinteger(L, item.end_type);
	call_lua(L, 11, 0, lua_gettop(L) - 12);
}
static void handleChatReadyResponse()
{
	if (mqtt_client->getContainer()->is_chatready_response_queue_empty()) return;
	LUA_ChatReadyResponse item = mqtt_client->getContainer()->popChatReadyResponse();
	mqtt_print_log_debug(TAG, "handleChatReadyResponse");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "chatreadyresp");
	lua_pushinteger(L, item.code);
	lua_pushstring(L, item.session_id.c_str());
	lua_pushstring(L, item.service_info.c_str());
	call_lua(L, 5, 0, lua_gettop(L) - 6);
}
static void handleChatMessage()
{
	if (mqtt_client->getContainer()->is_chat_message_queue_empty()) return;
	LUA_ChatMessage item = mqtt_client->getContainer()->popChatMessage();
	mqtt_print_log_debug(TAG, "handleChatMessage");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "chat");
	lua_pushnumber(L, item.seq_id);
	lua_pushstring(L, item.type.c_str());
	lua_pushstring(L, item.msg.c_str());
	lua_pushstring(L, item.session_id.c_str());
	call_lua(L, 6, 0, lua_gettop(L) - 7);

}
static void handleChatOffMessage()
{
	if (mqtt_client->getContainer()->is_chatoff_message_queue_empty()) return;
	LUA_ChatMessage item = mqtt_client->getContainer()->popChatOffMessage();
	mqtt_print_log_debug(TAG, "handleChatOffMessage");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "chatoff");
	lua_pushnumber(L, item.seq_id);
	lua_pushstring(L, item.type.c_str());
	lua_pushstring(L, item.msg.c_str());
	lua_pushstring(L, item.session_id.c_str());
	call_lua(L, 6, 0, lua_gettop(L) - 7);
}
static void handleLogoutMessage()
{
	if (mqtt_client->getContainer()->is_logout_message_queue_empty()) return;
	LUA_LogoutMessage item = mqtt_client->getContainer()->popLogoutMessage();
	mqtt_print_log_debug(TAG, "handleLogoutMessage");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_MESSAGE_ARRIVED);
	lua_pushnumber(L, mqtt_client->getId());
	lua_pushstring(L, "logout");
	lua_pushstring(L, item.session_id.c_str());
	lua_pushstring(L, item.service_gid.c_str());
	lua_pushstring(L, item.service_site_id.c_str());
	lua_pushstring(L, item.service_station_id.c_str());
	lua_pushnumber(L, item.clock);
	lua_pushinteger(L, item.end_type);
	lua_pushstring(L, item.extra.c_str());
	call_lua(L, 9, 0, lua_gettop(L) - 10);

}

static void handleMqttEvent()
{
	if (mqtt_client->getContainer()->is_mqtt_event_queue_empty()) return;
	MqttEvent item = mqtt_client->getContainer()->popMqttEvent();
	mqtt_print_log_debug(TAG, "handleMqttEvent");
	lua_State* L = GetLuaState();
	TRACE_BACK
	lua_getglobal(L, MQTT_EVENT_CALLBACK);
	lua_pushnumber(L, item.id);
	lua_pushnumber(L, item.cmd);
	lua_pushnumber(L, item.extera);
	call_lua(L, 3, 0, lua_gettop(L) - 4);
}

/*
**处理回调lua的时间，回调lua只能在主线程中进行，即在onUpdate中进行
**/
static void handleLuaMessage()
{
	if (mqtt_client->getContainer()->is_lua_message_queue_empty()) return;
	LUA_MESSAGE_TYPE item = mqtt_client->getContainer()->popLuaMessage();
	switch (item)
	{
	case LOGIN_RESPONSE:
		handleLoginResponse();
		break;
	case SHIFT_SESSION:
		handleShiftSession();
		break;
	case END_SESSION:
		handleEndSession();
		break;
	case CHATREADY_RESPONSE:
		handleChatReadyResponse();
		break;
	case CHAT_MESSAGE:
		handleChatMessage();
		break;
	case CHATOFF_MESSAGE:
		handleChatOffMessage();
		break;
	case LOGOUT_MESSAGE:
		handleLogoutMessage();
		break;
	case MQTT_EVENT:
		handleMqttEvent();
		break;
	default:
		break;
	}
}