#ifndef _CONSTANTS_H
#define _CONSTANTS_H
#include <string>
using namespace std;


const static string NEW_FRIENDS_USERNAME = "item_new_friends";
const static string GROUP_USERNAME = "item_groups";
const static string CHAT_ROOM = "item_chatroom";
const static string MESSAGE_ATTR_IS_VOICE_CALL = "is_voice_call";
const static string MESSAGE_ATTR_IS_VIDEO_CALL = "is_video_call";
const static string ACCOUNT_REMOVED = "account_removed";
const static string CHAT_ROBOT = "item_robots";
const static string MESSAGE_ATTR_ROBOT_MSGTYPE = "msgtype";
/**
* VIP�û�ֵ,1 - service, 2 - client, 3 - vipclient
*/
const static string VIP = "3";

/**
* QOSĿǰ�̶�Ϊ1
*/
const static int QOS = 1;

/**
* retain = false
*/
const static bool RETAIN = false;

/**
* �������콻����TOPIC����
*/

/** �ͻ��˶���gid/siteid/stationid/msg/+ */
const static string SUBSCRIBE_TOPIC_SUFFIX = "/msg/+";
/** �ͻ��˷���LoginRequest��gid/siteid/stationid/act/login */
const static string LOGIN_REQUEST_TOPIC_SUFFIX = "/act/login";
/** server����LoginResponse��gid/siteid/stationid/msg/loginresp */
const static string LOGIN_RESPONSE_TOPIC_SUFFIX = "/msg/loginresp";
/** �ͻ��˷���LogoutRequest��gid/siteid/stationid/act/logout �ǳ� */
const static string LOGOUT_REQUEST_TOPIC_SUFFIX = "/act/logout";
/**
* Client:�յ�loginresp,����ɹ�������service_gid/service_site_id/service_station_id/
* msg/chatready
*/
const static string CHAT_READY_REQUEST_TOPIC_SUFFIX = "/msg/chatready";
/**
* Service: �յ�chatready
* request,��ʾ�����߷����б��У�״̬Ϊ"New"����Ϊû���Ĺ��췢��ChatReadyResponse��gid
* /siteid/stationid/msg/chatreadyresp
*/
const static string CHAT_READY_RESPONSE_TOPIC_SUFFIX = "/msg/chatreadyresp";
/**
* ��ʱ,��ҿ��Կ�ʼ������Ϣ���ҿ����յ����Կͷ�����Ϣ��.���쿪ʼ��.�ͻ��˷�����Ϣ��service_gid/service_site_id/
* service_station_id/msg/chat;�ͻ��˽�����Ϣ��gid/siteid/stationid/msg/chat
*/
const static string CHAT_MESSAGE_TOPIC_SUFFIX = "/msg/chat";
/** �ͻ����յ�ChatMessage������Դfid/act/chatack����ChatMessageAck */
const static string CHAT_MESSAGE_ACK_TOPIC_SUFFIX = "/act/chatack";
/**
* ������Ϣ.�ͻ��˷�����Ϣ��service_gid/service_site_id/service_station_id/msg/function;
* �ͻ��˽�����Ϣ��gid/siteid/stationid/msg/functionresp
*/
const static string Function_MESSAGE_TOPIC_SUFFIX = "/msg/function";
/** ������Ϣ����˻ظ� */
const static string FUNCTION_MESSAGE_RESPONSE_TOPIC_SUFFIX = "/msg/functionresp";

/** ��������Ϣ��service idĿǰ�̶�Ϊ1 */
const static string ROBOT_MESSAGE_SERVICE_ID = "1";

/** logout�������ͱ�ʶ */
const static string LOGOUT_END_TYPE = "end_type";

/** logout�Ľ�������,1-�û���2-���ߣ�3-��ʱ��4-�ͷ� */
const static int LOGOUT_TYPE_USER = 1;
/** logout�Ľ�������,1-�û���2-���ߣ�3-��ʱ��4-�ͷ� */
const static int LOGOUT_TYPE_OFFLINE = 2;
/** logout�Ľ�������,1-�û���2-���ߣ�3-��ʱ��4-�ͷ� */
const static int LOGOUT_TYPE_TIMEOUT = 3;
/** logout�Ľ�������,1-�û���2-���ߣ�3-��ʱ��4-�ͷ� */
const static int LOGOUT_TYPE_KEFU = 4;

/**
* ����client info�ֶ�
*/
/** �ǳ� */
const static string NICKNAME = "nickname";
/** ͷ�� */
const static string AVATAR_URI = "avatarUri";
/** VIP�ȼ� */
const static string VIP_LEVEL = "vipLevel";
/** ��Ϸ���� */
const static string GAME_NAME = "gameName";
/** �˺����� */
const static string ACCOUNT_TYPE = "accountType";
/** �ͻ��� */
const static string CLIENT = "client";
/** �û�ID */
const static string USER_ID = "userID";
/** �豸���� */
const static string DEVICE_TYPE = "deviceType";
/** ������ʽ,wifi��2g��3g��4g */
const static string CONNECTIVITY = "connectivity";
/** ��Ϸ�汾 */
const static string GAME_VERSION = "gameVersion";
/** �豸���� */
const static string DEVICE_DETAIL = "deviceDetail";
/** MAC��ַ */
const static string MAC = "mac";
/** IP��ַ */
const static string IP = "ip";
/** ����� */
const static string BROWSER = "browser";
/** ��Ļ�ֱ��� */
const static string SCREEN = "screen";
/** ϵͳ�汾 */
const static string OS_VERSION = "OSVersion";
/** �Ƿ�Խ�� */
const static string JAILBREAK = "jailbreak";
/** ��Ӫ�� */
const static string OPERATOR = "operator";

/** ��ȡstationId **/
const static string STATION_ID = "12345678";

/**
* �����������ϢJSON�ַ�����KEY
*/
const static string ROBOT_MESSAGE_HEAD = "head";
const static string ROBOT_MESSAGE_LINKS = "links";
const static string ROBOT_MESSAGE_LINKS_ITEM_TYPE = "type";
const static string ROBOT_MESSAGE_LINKS_ITEM_VALUE = "value";
const static string ROBOT_MESSAGE_LINKS_ITEM_TEXT = "text";
const static string ROBOT_MESSAGE_FOOT = "foot";

/*************************** tcp ������� ************************************/
const static string CONNECT_TCP_HOST = "cs-test.oa.com";
const static string CONNECT_TCP_HOST_TEST = "cs-test.oa.com";
const static string HTTP_URL_PREFIX = "http://cs-cn.boyaagame.com:1323/";
const static string CONNECT_TCP_PORT = "3333";
const static string CONNECT_HTTP_PORT = "1323";

/*************************** http ������� ************************************/

/*************************** �ļ��ϴ� ************************************/
const static string VOICE_SESSION_ID = "123456789012345";
const static string FILE_UPLOAD_INPUTNAME = "file";
const static string FILE_UPLOAD_URI = HTTP_URL_PREFIX + "upload";
const static string FILE_UPLOAD_HOST = HTTP_URL_PREFIX;

// ��ȡ������Ϣ��Ŀ
const static string HTTP_OBTAIN_OFFLINE_MESSAGES = HTTP_URL_PREFIX + "offmsgnum";
// �ύ�û���������
const static string HTTP_SUBMIT_RATING_URI = HTTP_URL_PREFIX + "rating";
// �ύ�û�Ͷ���������
const static string HTTP_SUBMIT_APPEAL_URI = HTTP_URL_PREFIX + "appeal";
// �ύ�û��ٱ��������
const static string HTTP_SUBMIT_REPORT_URI = HTTP_URL_PREFIX + "report";
// �ύ�û������������
const static string HTTP_SUBMIT_ADVISE_URI = HTTP_URL_PREFIX + "advise";
// ��ȡ�û�Ͷ�߽����ʷ��¼
const static string HTTP_SUBMIT_APPEAL_HISTORY_URI = HTTP_URL_PREFIX + "appeal/history";
// ��ȡ�û��ٱ���ؽ����ʷ��¼
const static string HTTP_SUBMIT_REPORT_HISTORY_URI = HTTP_URL_PREFIX + "report/history";
// ��ȡ�û�������ؽ����ʷ��¼
const static string HTTP_SUBMIT_ADVISE_HISTORY_URI = HTTP_URL_PREFIX + "advise/history";
// ��ȡ������ʷ��Ϣ��¼
const static string HTTP_NETWORK_HISTORY_MESSAGE_URI = HTTP_URL_PREFIX + "chat/history";

/*************************** client config column ***********************************/
const static string COLUMN_HOST_CONFIG = "host";
const static string COLUMN_PROT_CONFIG = "port";
const static string COLUMN_GID_CONFIG = "gameId";
const static string COLUMN_SID_CONFIG = "siteId";
const static string COLUMN_STATIONID_CONFIG = "stationId";
const static string COLUMN_SSL_CONFIG = "ssl";
const static string COLUMN_SSLKEY_CONFIG = "sslKey";
const static string COLUMN_QOS_CONFIG = "qos";
const static string COLUMN_SESSIONID_CONFIG = "sessionId";
const static string COLUMN_ROLE_CONFIG = "role";
const static string COLUMN_UNAME_CONFIG = "userName";
const static string COLUMN_UPWD_CONFIG = "userPwd";
const static string COLUMN_UNICKNAME_CONFIG = "nickName";
const static string COLUMN_UAVATAR_CONFIG = "avatarUri";
const static string COLUMN_CLEANSESSION_CONFIG = "cleanSession";
const static string COLUMN_TIMEOUT_CONFIG = "timeout";
const static string COLUMN_KEEPALIVE_CONFIG = "keepalive";
const static string COLUMN_RETAIN_CONFIG = "retain";
const static string COLUMN_DEBUG_CONFIG = "debug";

/*************************** device config ***********************************/
const static int M_DEVICE_TYPE = 2;
const static string M_DEVICE_IP = "daiding";

/** ���ݿ���󱣴���Ϣ��Ŀ�� */
const static int DB_MESSAGE_MAX_NUM = 100;
/** ÿ�����������Ϣ����Ϣ��Ŀ�� */
const static int NETWORK_MESSAGE_LIMIT = 10;
#endif