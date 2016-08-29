#ifndef _MESSAGE_H
#define _MESSAGE_H

#include <string>
#include "config.h"
using namespace std;

class LUA_LoginResponse {
public:
	int	code = 0;               // 1 - 成功；2 - 失败；3 - 无人在线; 4 - 排队等待; 5 - 已在会话中
	string session_id;          // Server分配, for client
	string role;                // for both, 携带role
	string return_msg;          // for both
	string service_gid;         // for client
	string service_site_id;     // for client
	string service_station_id;  // for client
	int	wait_count = 0;			// for client, 等待队列长度
	//serve_apps for service 不传给lua
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
	int archive_class = 0;    // 类别：1 - 投诉， 2 - 咨询， 3 - 建议
	int archive_category = 0; // 归档项(id)
	int session_upgraded = 0; // 1 - 会话已升级， 0 - 会话未升级
	int session_invalid = 0;  // 1 - 会话无效， 0 - 会话归档
	int end_type = 0;        // 1-用户；2-离线；3-超时；4-客服

};

class LUA_ChatReadyResponse {
public:
	string session_id;
	int code = 0;  // 1 - OK; 2 - 拒绝；3 - 已在会话中
	string service_info;  //JSON

};

class LUA_ChatMessage {
public:
	string session_id;
	_long seq_id = 0;  // 用于区分同一个station的各条消息，由Client/Service端分配，相同seq_id的视为同一消息，建议使用unixstamp nano（不把它当作时间，仅作为顺序id使用）
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
	int end_type = 0;  // 1-用户；2-离线；3-超时；4-客服
	string extra;   //用于扩展，暂不使用
};

class MqttEvent {
public:
	int cmd = 0;
	int id = 0;
	int extera = 0;
};


#endif