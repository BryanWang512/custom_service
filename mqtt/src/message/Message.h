#ifndef _MESSAGE_H
#define _MESSAGE_H

#include <string>
#include "config.h"
using namespace std;

class LUA_LoginResponse {
public:
	int	code = 0;               // 1 - �ɹ���2 - ʧ�ܣ�3 - ��������; 4 - �Ŷӵȴ�; 5 - ���ڻỰ��
	string session_id;          // Server����, for client
	string role;                // for both, Я��role
	string return_msg;          // for both
	string service_gid;         // for client
	string service_site_id;     // for client
	string service_station_id;  // for client
	int	wait_count = 0;			// for client, �ȴ����г���
	//serve_apps for service ������lua
};

class LUA_ShiftSession {
public:
	string session_id;
	string shift_to_fid;

};

class LUA_EndSession {
public:
	string session_id;
	string client_gid;
	string client_site_id;
	string client_station_id;
	int archive_class = 0;    // ���1 - Ͷ�ߣ� 2 - ��ѯ�� 3 - ����
	int archive_category = 0; // �鵵��(id)
	int session_upgraded = 0; // 1 - �Ự�������� 0 - �Ựδ����
	int session_invalid = 0;  // 1 - �Ự��Ч�� 0 - �Ự�鵵
	int end_type = 0;        // 1-�û���2-���ߣ�3-��ʱ��4-�ͷ�

};

class LUA_ChatReadyResponse {
public:
	string session_id;
	int code = 0;  // 1 - OK; 2 - �ܾ���3 - ���ڻỰ��
	string service_info;  //JSON

};

class LUA_ChatMessage {
public:
	string session_id;
	_long seq_id = 0;  // ��������ͬһ��station�ĸ�����Ϣ����Client/Service�˷��䣬��ͬseq_id����Ϊͬһ��Ϣ������ʹ��unixstamp nano������������ʱ�䣬����Ϊ˳��idʹ�ã�
	string type;   // 1 - text, 2 - picture, 3 - voice, 4 - bot message
	string msg;
};

class LUA_LogoutMessage {
public:
	string session_id;
	_long clock = 0;  //Unixstamp, seconds
	string service_gid;
	string service_site_id;
	string service_station_id;
	int end_type = 0;  // 1-�û���2-���ߣ�3-��ʱ��4-�ͷ�
	string extra;   //������չ���ݲ�ʹ��
};

class MqttEvent {
public:
	int cmd = 0;
	int id = 0;
	int extera = 0;
};


#endif