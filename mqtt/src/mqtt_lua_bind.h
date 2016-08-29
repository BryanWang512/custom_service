#ifndef _LUA_BIND_H
#define _LUA_BIND_H

int mqtt_create(lua_State* L);
int mqtt_destroy(lua_State* L);

int mqtt_connect(lua_State* L);
int mqtt_is_connected(lua_State* L);
int mqtt_disconnect(lua_State* L);
int mqtt_reconnect(lua_State* L);

int mqtt_subscribe(lua_State* L);
int mqtt_unsubscribe(lua_State* L);

int mqtt_send_chat_ready_msg(lua_State* L);
int mqtt_send_chat_msg(lua_State* L);
int mqtt_send_msg(lua_State* L);
int mqtt_send_msg_ack(lua_State* L);
int mqtt_send_offmsg_ack(lua_State* L);

int mqtt_clock(lua_State* L);


static const struct luaL_Reg func[] = {
	{ "mqtt_create", mqtt_create },
	{ "mqtt_destroy", mqtt_destroy },

	{ "connect", mqtt_connect },
	{ "isConnected", mqtt_is_connected },
	{ "disconnect", mqtt_disconnect },
	{ "reconnect", mqtt_reconnect },

	{ "sendChatReadyMsg", mqtt_send_chat_ready_msg },
	{ "sendChatMsg", mqtt_send_chat_msg },
	{ "sendMessage", mqtt_send_msg },
	{ "sendMessageAck", mqtt_send_msg_ack },
	{ "sendOffMessageAck", mqtt_send_offmsg_ack },

	{ "subscribe", mqtt_subscribe },
	{ "unsubscribe", mqtt_unsubscribe },

	{ "clock", mqtt_clock },
	{ NULL, NULL }
};

static int mqtt_register_funcs(lua_State* L)
{
	// 创建一个新的元表
	luaL_register(L, "mqtt", func);
	return 1;
}

#endif