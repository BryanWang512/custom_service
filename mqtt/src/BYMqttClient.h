#ifndef _BYMQTT_CLIENT_H
#define _BYMQTT_CLIENT_H
#include "MQTTAsync.h"
#include "ClientConfig.h"
#include "messageFactory.h"
#include "mqtt_global.h"
#include "MessageContainer.h"
#include <thread>

enum ActionType
{
	TYPE_LOGIN = 0,
	TYPE_SHIFT = 1,
	TYPE_LOGOUT = 2,
	TYPE_PREPARE_CHAT = 3,
	TYPE_ACT_SERVER = 4,
	TYPE_CHAT = 5,
	TYPE_RELOGIN = 6
};
static const ActionType ActionType_Value[] = { TYPE_LOGIN, TYPE_SHIFT, TYPE_LOGOUT,
TYPE_PREPARE_CHAT, TYPE_ACT_SERVER, TYPE_CHAT, TYPE_RELOGIN };


enum ConversationStatus
{
	STATUS_DISCONNECTED = 0,// MQTTδ�����Ϸ�����
	STATUS_CONNECTING = 1,// ��������broker
	STATUS_CONNECTED = 2,// �ɹ�������MQTT������broker
	STATUS_LOGINED = 3,// �ѳɹ���¼,�����֤ok
	STATUS_SHIFTED = 4,// ת��
	STATUS_SESSION = 5,// �Ự״̬
	STATUS_FINSHED = 6// �Ự����
};
static const int ConversationStatus_Value[] = { 0, 1, 2, 3, 4, 5, 6 };

enum MessageType
{
	MESSAGE_TXT = 1,// text
	MESSAGE_IMG = 2,// picture
	MESSAGE_VOICE = 3,// voice
	MESSAGE_ROBOT = 4,// bot message
};

static const MessageType MessageType_Value[] = { MESSAGE_TXT, MESSAGE_TXT, MESSAGE_IMG, MESSAGE_VOICE, MESSAGE_ROBOT };


class BYMqttClient{
public:
	~BYMqttClient();
	BYMqttClient(ClientConfig* config, long id);
	int connect(string topicName);
	void reconnect();
	int subscribe(string topicName);
	int unsubscribe();

	int disconnect();
	void destroy();
	bool isConnected();

	int sendChatReadyMsg(string clientInfo, string sessionId, string topicName);
	int sendChatMsg(string msg, string type, string sessionId, string topicName);
	int sendMessageAck(_long seq_id, string sessionId, string topicName);
	int sendOffMessageAck(vector<_long>, string sessionId, string topicName);
	int sendMessage(lua_State* L);

	MQTTAsync_token token = -1;
	inline ClientConfig* getClientConfig()
	{
		return config;
	}
	inline long getId()
	{
		return this->id;
	}
	inline MessageContainer* getContainer()
	{
		return msgContainer;
	}
	inline bool isDestorying()
	{
		return destroying;
	}
private:
	BYMqttClient();
	MQTTAsync client = NULL;
	string uri;
	ClientConfig* config = NULL;
	mutex m_offMsgs_mutex;
	int end_type;
	long id;
	int publish(string topicName, const char* payload, size_t size);
	MessageContainer* msgContainer = NULL;
	bool destroying = false;
};

BYMqttClient::BYMqttClient(ClientConfig* config, long id)
{
	this->config = config;
	this->id = id;
	this->uri = config->getRequestUri();
	msgContainer = new MessageContainer();
	if (config->get_ssl())
	{
#ifndef OPENSSL
#define OPENSSL
#endif
	}
	MQTTAsync_create(&client, uri.c_str(), config->getCurrentClientId().c_str(), MQTTCLIENT_PERSISTENCE_NONE, NULL);
}

BYMqttClient::~BYMqttClient()
{
	destroying = true;
	delete config;
	config = NULL;
	delete msgContainer;
	msgContainer = NULL;
	disconnect();
	destroy();
}

void BYMqttClient::destroy()
{
	if (client == NULL)
		return;
	MQTTAsync_destroy(&client);
	client = NULL;
}

int BYMqttClient::disconnect()
{
	if (!isConnected())
		return -1;
	MQTTAsync_disconnectOptions opts = MQTTAsync_disconnectOptions_initializer;
	opts.onSuccess = onDisconnect;
	opts.onFailure = onDisconnectFailure;
	int result = MQTTAsync_disconnect(client, &opts);
	if (result != MQTTASYNC_SUCCESS)
	{
		print_log_debug(TAG, "disconnect error~~~~~~~~~~");
	}
	return result;
}

int BYMqttClient::connect(string topicName)
{
	if (client == NULL)
		return -1;
	MQTTAsync_setCallbacks(client, NULL, conn_lost, message_arrived, delivery_completed);
	MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
	opts.keepAliveInterval = config->get_keepalive();
	opts.cleansession = config->get_cleanSession(); // bool int ����֤
	opts.connectTimeout = config->get_timeout();
	opts.username = config->get_userName().c_str();
	opts.password = config->get_userPwd().c_str();
	opts.onSuccess = onConnect;
	opts.onFailure = onConnectFailure;
	opts.maxInflight = 10;
	opts.retryInterval = 1;
	opts.automaticReconnect = 1;
	MQTTAsync_willOptions will_opts = MQTTAsync_willOptions_initializer;
	will_opts.qos = config->get_qos();
	will_opts.retained = config->get_retain();// bool int ����֤
	will_opts.topicName = topicName.c_str();
	//������Ϣ
	LogoutMessage msg;
	char buffer[BUFFER_SIZE];
	//��������Ϣ����endtype:2
	size_t size = 0;
	fill_logout_message(config->getAllocatedHeader(), &msg, buffer, LOGOUT_TYPE_OFFLINE, &size);
	will_opts.message = buffer;
	opts.will = &will_opts;
	if (config->get_ssl() && !config->get_sslKey().empty())
	{
		MQTTAsync_SSLOptions ssl_opts = MQTTAsync_SSLOptions_initializer;
		ssl_opts.enableServerCertAuth = 0;
		ssl_opts.keyStore = config->get_sslKey().c_str();
		ssl_opts.privateKeyPassword = "mqtttest";
		//ssl
		opts.ssl = &ssl_opts;
	}
	int result = MQTTAsync_connect(client, &opts);
	print_log_debug(TAG, "mqtt_connect result:%d", result);
	if (result != MQTTASYNC_SUCCESS)
	{
		print_log_debug(TAG, "connect error!!!!!!!!!!!!!!!!!!!!!!!!!!");
	}
	return result;
}

void BYMqttClient::reconnect()
{
	if (client == NULL)
		return;
	//MQTTAsync_connect(client, &conn_opts);
}

bool BYMqttClient::isConnected()
{
	if (client == NULL)
		return false;
	return MQTTAsync_isConnected(client);
}


int BYMqttClient::subscribe(string topicName)
{
	if (client == NULL)
		return -1;
	MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
	opts.onSuccess = onSubscribe;
	opts.onFailure = onSubscribeFailure;
	int result = MQTTAsync_subscribe(client, topicName.c_str(), config->get_qos(), &opts);
	if (result != MQTTASYNC_SUCCESS)
	{
		print_log_debug(TAG, "subscribe error!!!!!!!!!!!!!!!!!!!!!!!!!!");
	}
	return result;
}

int BYMqttClient::unsubscribe()
{
	if (client == NULL)
		return -1;
	return MQTTAsync_unsubscribe(client, "", NULL);
}

int BYMqttClient::publish(string topicName, const char* payload, size_t size)
{
	if (client == NULL)
		return -1;
	MQTTAsync_message pubmsg = MQTTAsync_message_initializer;
	pubmsg.payload = (void *)payload;
	pubmsg.payloadlen = size;
	pubmsg.qos = config->get_qos();
	pubmsg.retained = config->get_retain(); //bool int ����֤
	MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
	opts.onSuccess = onPublish;
	opts.onFailure = onPublishFailure;
	int result = MQTTAsync_sendMessage(client, topicName.c_str(), &pubmsg, &opts);
	if (result != MQTTASYNC_SUCCESS)
	{
		print_log_debug(TAG, "publish error!!!!!!!!!!!!!!!!!!!!!!!!!!");
	}
	print_log_debug(TAG, "MQTTAsync_publishMessage code:%d", result);
	return result;
}

// ack, chat
int BYMqttClient::sendMessage(lua_State* L)
{
	ActionType type = ActionType_Value[luaL_checkinteger(L, 1)];
	char buffer[BUFFER_SIZE];
	size_t size = 0;
	string topicName;
	if (type == TYPE_LOGIN)
	{
		string s_fid = luaL_checkstring(L, 2);
		string s_dest_fid = luaL_checkstring(L, 3);
		topicName = luaL_checkstring(L, 4);
		LoginRequest request;
		fill_login_request(config->getAllocatedHeader(), &request, "", s_dest_fid, s_fid, buffer, &size);
	}
	else if (type == TYPE_RELOGIN)
	{
		string cur_sfid = luaL_checkstring(L, 2);
		topicName = luaL_checkstring(L, 3);
		LoginRequest request;
		fill_login_request(config->getAllocatedHeader(), &request, "", cur_sfid, "", buffer, &size);
	}
	else if (type == TYPE_SHIFT)
	{
		LoginRequest request;
		string ss_fid = luaL_checkstring(L, 2);
		string ss_dest_fid = luaL_checkstring(L, 3);
		topicName = luaL_checkstring(L, 4);
		fill_login_request(config->getAllocatedHeader(), &request, ss_fid, ss_dest_fid, "", buffer, &size);
	}
	else if (type == TYPE_LOGOUT)
	{
		LogoutMessage message;
		int end_type = luaL_checkinteger(L, 2);
		topicName = luaL_checkstring(L, 3);
		fill_logout_message(config->getAllocatedHeader(), &message, buffer, end_type, &size);
	}
	return publish(topicName, buffer, size);
}


/*
-----------------------
�����Ƿ��͵���Ϣ
*/
int BYMqttClient::sendChatMsg(string msg, string type, string sessionId, string topicName)
{
	ChatMessage message;
	char buffer[BUFFER_SIZE];
	size_t size = 0;
	fill_chat_message(config->getAllocatedHeader(), &message, msg, sessionId, type, buffer, &size);
	return publish(topicName, buffer, size);
}


/**
* �ǳ�������MQTTЭ�����ڲ��Ķ��ε�¼(Ӧ�ò��)��������MQTTЭ��ʱ�����ӵǳ�
* �ͻ����յ�EndSession�󷢳���logout��end_typeΪ4 1-�û���2-���ߣ�3-��ʱ��4-�ͷ� logic: �˳������
*
* 1.���жϵ�ǰ�Ƿ�����
*
* 2.�����������logout��Ϣ����������ӣ���ֱ��release
*
* 3.����״̬�£�logout��Ϣ���ͳɹ�֮�󣬵���disconnect ��� ����,������disconnect�ص��� release ��Դ
*
* 4.�����ǰ�Ự״̬ʱendsession��ʱ�����յ� endsession֮��logout��ʱ��Ӧ����send
* logout��Ϣ��Ȼ����disconnect broker��
* disconnect�ɹ�֮�󣬴�ʱc.isConnectΪfalse����ʱ����release��Դ��
*
* 5.��endsession״̬�£���disconnect֮�󣬸��û�hint��ʾ�������û������˳���������������֮��Ȼ��release��Դ��
*
*/

int BYMqttClient::sendChatReadyMsg(string clientInfo, string sessionId, string topicName)
{
	ChatReadyRequest request;
	char buffer[BUFFER_SIZE];
	size_t size = 0;
	fill_chat_ready_request(config->getAllocatedHeader(), &request, clientInfo, sessionId, buffer, &size);
	return publish(topicName, buffer, size);
}

//��ÿһ��chat Message�ظ�ACK,�������յ�����Ŷ�Ӧ����Ϣ
int BYMqttClient::sendMessageAck(_long seq_id, string sessionId, string topicName)
{
	ChatMessageAck ack;
	char buffer[BUFFER_SIZE];
	size_t size = 0;
	fill_chat_message_ack(config->getAllocatedHeader(), &ack, seq_id, sessionId, buffer, &size);
	return publish(topicName, buffer, size);
}

int BYMqttClient::sendOffMessageAck(vector<_long> offsMsg, string sessionId, string topicName)
{
	lock_guard<mutex> lock(m_offMsgs_mutex);
	//�첽
	if (offsMsg.size() > 0)
	{
		print_log_debug(TAG, "doSendOffMessageAck, size:%d", offsMsg.size());
		ChatMessageAck ack;
		char buffer[BUFFER_SIZE];
		size_t size = 0;
		fill_chat_messages_ack(config->getAllocatedHeader(), &ack, offsMsg, sessionId, buffer, &size);
		return publish(topicName, buffer, size);
	}
	return -1;
}

#endif
