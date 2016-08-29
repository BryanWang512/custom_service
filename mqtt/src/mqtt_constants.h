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
* VIP用户值,1 - service, 2 - client, 3 - vipclient
*/
const static string VIP = "3";

/**
* QOS目前固定为1
*/
const static int QOS = 1;

/**
* retain = false
*/
const static bool RETAIN = false;

/**
* 定义聊天交互的TOPIC常量
*/

/** 客户端订阅gid/siteid/stationid/msg/+ */
const static string SUBSCRIBE_TOPIC_SUFFIX = "/msg/+";
/** 客户端发布LoginRequest到gid/siteid/stationid/act/login */
const static string LOGIN_REQUEST_TOPIC_SUFFIX = "/act/login";
/** server发布LoginResponse到gid/siteid/stationid/msg/loginresp */
const static string LOGIN_RESPONSE_TOPIC_SUFFIX = "/msg/loginresp";
/** 客户端发布LogoutRequest到gid/siteid/stationid/act/logout 登出 */
const static string LOGOUT_REQUEST_TOPIC_SUFFIX = "/act/logout";
/**
* Client:收到loginresp,如果成功，则向service_gid/service_site_id/service_station_id/
* msg/chatready
*/
const static string CHAT_READY_REQUEST_TOPIC_SUFFIX = "/msg/chatready";
/**
* Service: 收到chatready
* request,显示在在线服务列表中，状态为"New"，因为没有聊过天发布ChatReadyResponse到gid
* /siteid/stationid/msg/chatreadyresp
*/
const static string CHAT_READY_RESPONSE_TOPIC_SUFFIX = "/msg/chatreadyresp";
/**
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息：service_gid/service_site_id/
* service_station_id/msg/chat;客户端接收消息：gid/siteid/stationid/msg/chat
*/
const static string CHAT_MESSAGE_TOPIC_SUFFIX = "/msg/chat";
/** 客户端收到ChatMessage后，向来源fid/act/chatack发送ChatMessageAck */
const static string CHAT_MESSAGE_ACK_TOPIC_SUFFIX = "/act/chatack";
/**
* 功能消息.客户端发送消息：service_gid/service_site_id/service_station_id/msg/function;
* 客户端接收消息：gid/siteid/stationid/msg/functionresp
*/
const static string Function_MESSAGE_TOPIC_SUFFIX = "/msg/function";
/** 功能消息服务端回复 */
const static string FUNCTION_MESSAGE_RESPONSE_TOPIC_SUFFIX = "/msg/functionresp";

/** 机器人消息的service id目前固定为1 */
const static string ROBOT_MESSAGE_SERVICE_ID = "1";

/** logout结束类型标识 */
const static string LOGOUT_END_TYPE = "end_type";

/** logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
const static int LOGOUT_TYPE_USER = 1;
/** logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
const static int LOGOUT_TYPE_OFFLINE = 2;
/** logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
const static int LOGOUT_TYPE_TIMEOUT = 3;
/** logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
const static int LOGOUT_TYPE_KEFU = 4;

/**
* 定义client info字段
*/
/** 昵称 */
const static string NICKNAME = "nickname";
/** 头像 */
const static string AVATAR_URI = "avatarUri";
/** VIP等级 */
const static string VIP_LEVEL = "vipLevel";
/** 游戏名称 */
const static string GAME_NAME = "gameName";
/** 账号类型 */
const static string ACCOUNT_TYPE = "accountType";
/** 客户端 */
const static string CLIENT = "client";
/** 用户ID */
const static string USER_ID = "userID";
/** 设备类型 */
const static string DEVICE_TYPE = "deviceType";
/** 联网方式,wifi、2g、3g、4g */
const static string CONNECTIVITY = "connectivity";
/** 游戏版本 */
const static string GAME_VERSION = "gameVersion";
/** 设备详情 */
const static string DEVICE_DETAIL = "deviceDetail";
/** MAC地址 */
const static string MAC = "mac";
/** IP地址 */
const static string IP = "ip";
/** 浏览器 */
const static string BROWSER = "browser";
/** 屏幕分辨率 */
const static string SCREEN = "screen";
/** 系统版本 */
const static string OS_VERSION = "OSVersion";
/** 是否越狱 */
const static string JAILBREAK = "jailbreak";
/** 运营商 */
const static string OPERATOR = "operator";

/** 获取stationId **/
const static string STATION_ID = "12345678";

/**
* 定义机器人消息JSON字符串的KEY
*/
const static string ROBOT_MESSAGE_HEAD = "head";
const static string ROBOT_MESSAGE_LINKS = "links";
const static string ROBOT_MESSAGE_LINKS_ITEM_TYPE = "type";
const static string ROBOT_MESSAGE_LINKS_ITEM_VALUE = "value";
const static string ROBOT_MESSAGE_LINKS_ITEM_TEXT = "text";
const static string ROBOT_MESSAGE_FOOT = "foot";

/*************************** tcp 链接相关 ************************************/
const static string CONNECT_TCP_HOST = "cs-test.oa.com";
const static string CONNECT_TCP_HOST_TEST = "cs-test.oa.com";
const static string HTTP_URL_PREFIX = "http://cs-cn.boyaagame.com:1323/";
const static string CONNECT_TCP_PORT = "3333";
const static string CONNECT_HTTP_PORT = "1323";

/*************************** http 链接相关 ************************************/

/*************************** 文件上传 ************************************/
const static string VOICE_SESSION_ID = "123456789012345";
const static string FILE_UPLOAD_INPUTNAME = "file";
const static string FILE_UPLOAD_URI = HTTP_URL_PREFIX + "upload";
const static string FILE_UPLOAD_HOST = HTTP_URL_PREFIX;

// 获取离线消息数目
const static string HTTP_OBTAIN_OFFLINE_MESSAGES = HTTP_URL_PREFIX + "offmsgnum";
// 提交用户评分数据
const static string HTTP_SUBMIT_RATING_URI = HTTP_URL_PREFIX + "rating";
// 提交用户投诉相关事情
const static string HTTP_SUBMIT_APPEAL_URI = HTTP_URL_PREFIX + "appeal";
// 提交用户举报相关事情
const static string HTTP_SUBMIT_REPORT_URI = HTTP_URL_PREFIX + "report";
// 提交用户留言相关事情
const static string HTTP_SUBMIT_ADVISE_URI = HTTP_URL_PREFIX + "advise";
// 获取用户投诉解决历史记录
const static string HTTP_SUBMIT_APPEAL_HISTORY_URI = HTTP_URL_PREFIX + "appeal/history";
// 获取用户举报相关解决历史记录
const static string HTTP_SUBMIT_REPORT_HISTORY_URI = HTTP_URL_PREFIX + "report/history";
// 获取用户留言相关解决历史记录
const static string HTTP_SUBMIT_ADVISE_HISTORY_URI = HTTP_URL_PREFIX + "advise/history";
// 获取网络历史消息记录
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

/** 数据库最大保存消息条目数 */
const static int DB_MESSAGE_MAX_NUM = 100;
/** 每次网络加载消息的消息条目数 */
const static int NETWORK_MESSAGE_LIMIT = 10;
#endif