#ifndef _CLIENT_CONFIG_H
#define _CLIENT_CONFIG_H

#include "mqtt_constants.h"
#include "boyim.pb.h"
#include <string>
using namespace std;
using namespace boyim_proto;

class ClientConfig{
public:
	class ClientConfigBuilder {
	public:
		string gameId = "";
		string siteId = "";
		string stationId = "";
		string host = CONNECT_TCP_HOST;
		string port = CONNECT_TCP_PORT;
		bool ssl = false;
		string sslKey = "";
		int qos = 1;
		string avatarUri = "";
		string role = "2";
		string userName = "";
		string userPwd = "";
		bool cleanSession = true;
		int timeout = 30;
		int keepalive = 60;
		bool retain = false;

		ClientConfigBuilder(string host, string port)
		{
			this->host = host.empty() ? CONNECT_TCP_HOST : host;
			this->port = port.empty() ? CONNECT_TCP_PORT : port;
		};
		ClientConfig* build()
		{
			return new ClientConfig(this);
		};
		//setter ����Ҫinline �������Զ�inline
		inline ClientConfigBuilder* set_gameId(string gameId){ this->gameId = gameId; return this; };
		inline ClientConfigBuilder* set_siteId(string siteId){ this->siteId = siteId; return this; };
		inline ClientConfigBuilder* set_stationId(string stationId){ this->stationId = stationId;  return this; };
		inline ClientConfigBuilder* set_host(string host){ this->host = host;  return this; };
		inline ClientConfigBuilder* set_port(string port){ this->port = port;  return this; };
		inline ClientConfigBuilder* set_ssl(bool ssl){ this->ssl = ssl;  return this; };
		inline ClientConfigBuilder* set_sslKey(string sslKey){ this->sslKey = sslKey;  return this; };
		inline ClientConfigBuilder* set_qos(int qos){ this->qos = qos;  return this; };
		inline ClientConfigBuilder* set_role(string role){ this->role = role; return this; };
		inline ClientConfigBuilder* set_userName(string userName){ this->userName = userName; return this; };
		inline ClientConfigBuilder* set_userPwd(string userPwd){ this->userPwd = userPwd; return this; };
		inline ClientConfigBuilder* set_cleanSession(bool cleanSession){ this->cleanSession = cleanSession; return this; };
		inline ClientConfigBuilder* set_timeout(int timeout){ this->timeout = timeout; return this; };
		inline ClientConfigBuilder* set_keepalive(int keepalive){ this->keepalive = keepalive; return this; };
		inline ClientConfigBuilder* set_retain(bool retain){ this->retain = retain; return this; };
		inline ClientConfigBuilder* set_avatarUri(string avatarUri){ this->avatarUri = avatarUri; return this; };
	};



	ClientConfig(ClientConfigBuilder* b)
	{
		this->gameId = b->gameId;
		this->siteId = b->siteId;
		this->stationId = b->stationId;
		this->host = b->host;
		this->port = b->port;
		this->ssl = b->ssl;
		this->sslKey = b->sslKey;
		this->qos = b->qos;
		this->avatarUri = b->avatarUri;
		this->role = b->role;
		this->userName = b->userName;
		this->userPwd = b->userPwd;
		this->cleanSession = b->cleanSession;
		this->retain = b->retain;
		this->timeout = b->timeout;
		this->keepalive = b->keepalive;
	};

	~ClientConfig()
	{
	};
	//getter
	inline string get_gameId(){ return gameId; };
	inline string get_siteId(){ return siteId; };
	inline string get_stationId(){ return stationId; };
	inline string get_host(){ return host; };
	inline string get_port(){ return port; };
	inline bool get_ssl(){ return ssl; };
	inline string get_sslKey(){ return sslKey; };
	inline int get_qos(){ return qos; };
	inline string get_avatarUri(){ return avatarUri; };
	inline string get_role(){ return role; };
	inline string get_userName(){ return userName; };
	inline string get_userPwd(){ return userPwd; };
	inline bool get_cleanSession(){ return cleanSession; };
	inline int get_timeout(){ return timeout; };
	inline int get_keepalive(){ return keepalive; };
	inline bool get_retain(){ return retain; };

	//setter
	inline void set_avatarUri(string avatarUri){ this->avatarUri = avatarUri; };
	inline void set_role(string role){ this->role = role; };

	//other
	inline string getRequestUri();
	inline string getCurrentClientId();
	Header* getAllocatedHeader();
private:
	// Game ID����ϷID�����ݡ����������齫�ȣ���Ӧ�ͷ���̨���ݿ��gid��
	string gameId;
	// Site ID��վ��ID�����塢�������ȣ���Ӧ�ͷ���̨���ݿ��sid��
	string siteId;
	// Station ID���ն�ID����ǰ�ݶ�Ϊ��Ϸ�˺�
	// mid,ÿһ�����ӵ�Broker���ն˶���һ��Ψһ��ID������texas-de-701270��ipoker-th-guest-234323������APP
	// ID + mid������SDK�������ɡ�
	string stationId;
	// ����mqtt��������uri
	string host;
	// ����mqtt�������Ķ˿ں�
	string port;
	// �Ƿ�ȫ����
	bool ssl;
	// ��ȫ������Ҫ
	string sslKey;
	// ���������ȼ�
	int qos;

	string avatarUri;

	string role;

	string userName;

	string userPwd;
	// �Ƿ����Ự״̬�����������ӵ�ʱ�� set options,link:conOpt.setCleanSession(cleanSession);
	bool cleanSession;
	// defines the maximum time interval the client will wait for the network
	// connection to the MQTT server to be established, unit:second
	int timeout;
	// defines the maximum time interval between messages sent or received,
	// unit:second
	int keepalive;
	// whether or not the message should be retained
	bool retain;
};

inline string ClientConfig::getRequestUri() {
	string uri;
	if (ssl) {
		uri = "ssl://";
	}
	else {
		uri = "tcp://";
	}
	uri = uri + host + ":" + port;
	return uri;
}

// ��ȡ��ǰmqtt�û���Ψһ��ʾ�� �ݶ�Ϊ��gid/site_id/stationid
inline string ClientConfig::getCurrentClientId() {
	string clientid;
	clientid = get_gameId() + "/" + get_siteId() + "/" + get_stationId();
	return clientid;
}


// ��ȡHeader
Header* ClientConfig::getAllocatedHeader() {
	Header* header = new Header();
	header->set_gid(gameId);
	header->set_site_id(siteId);
	header->set_station_id(stationId);
	header->set_role(role);
	return header;
}

#endif