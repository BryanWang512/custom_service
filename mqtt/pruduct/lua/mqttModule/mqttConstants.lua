
NEW_FRIENDS_USERNAME = "item_new_friends";
GROUP_USERNAME = "item_groups";
CHAT_ROOM = "item_chatroom";
MESSAGE_ATTR_IS_VOICE_CALL = "is_voice_call";
MESSAGE_ATTR_IS_VIDEO_CALL = "is_video_call";
ACCOUNT_REMOVED = "account_removed";
CHAT_ROBOT = "item_robots";
MESSAGE_ATTR_ROBOT_MSGTYPE = "msgtype";


--VIP用户值,1 - service, 2 - client, 3 - vipclient
VIP = "3";


--QOS目前固定为1
QOS = 1;


--retain = false
RETAIN = false;
--[[
/**
* 定义聊天交互的TOPIC常量
*/--]]

-- 客户端订阅gid/siteid/stationid/msg/+ 
SUBSCRIBE_TOPIC_SUFFIX = "/msg/+";
--客户端发布LoginRequest到gid/siteid/stationid/act/login */
LOGIN_REQUEST_TOPIC_SUFFIX = "/act/login";
--server发布LoginResponse到gid/siteid/stationid/msg/loginresp */
LOGIN_RESPONSE_TOPIC_SUFFIX = "/msg/loginresp";
--客户端发布LogoutRequest到gid/siteid/stationid/act/logout 登出 */
LOGOUT_REQUEST_TOPIC_SUFFIX = "/act/logout";
--[[
* Client:收到loginresp,如果成功，则向service_gid/service_site_id/service_station_id/
* msg/chatready
*/--]]
CHAT_READY_REQUEST_TOPIC_SUFFIX = "/msg/chatready";
--[[
* Service: 收到chatready
* request,显示在在线服务列表中，状态为"New"，因为没有聊过天发布ChatReadyResponse到gid
* /siteid/stationid/msg/chatreadyresp
*/--]]
CHAT_READY_RESPONSE_TOPIC_SUFFIX = "/msg/chatreadyresp";
--[[
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息：service_gid/service_site_id/
* service_station_id/msg/chat;客户端接收消息：gid/siteid/stationid/msg/chat
*/--]]
CHAT_MESSAGE_TOPIC_SUFFIX = "/msg/chat";
-- 客户端收到ChatMessage后，向来源fid/act/chatack发送ChatMessageAck */
CHAT_MESSAGE_ACK_TOPIC_SUFFIX = "/act/chatack";
--[[
* 功能消息.客户端发送消息：service_gid/service_site_id/service_station_id/msg/function;
* 客户端接收消息：gid/siteid/stationid/msg/functionresp
*/--]]
Function_MESSAGE_TOPIC_SUFFIX = "/msg/function";
-- 功能消息服务端回复 */
FUNCTION_MESSAGE_RESPONSE_TOPIC_SUFFIX = "/msg/functionresp";

-- 机器人消息的service id目前固定为1 */
ROBOT_MESSAGE_SERVICE_ID = "1";

--logout结束类型标识 */
LOGOUT_END_TYPE = "end_type";

--[[
* 定义client info字段
*/--]]
-- 昵称 */
NICKNAME = "nickname";
-- 头像 */
AVATAR_URI = "avatarUri";
-- VIP等级 */
VIP_LEVEL = "vipLevel";
-- 游戏名称 */
GAME_NAME = "gameName";
-- 账号类型 */
ACCOUNT_TYPE = "accountType";
-- 客户端 */
CLIENT = "client";
-- 用户ID */
USER_ID = "userID";
-- 设备类型 */
DEVICE_TYPE = "deviceType";
-- 联网方式,wifi、2g、3g、4g */
CONNECTIVITY = "connectivity";
-- 游戏版本 */
GAME_VERSION = "gameVersion";
-- 设备详情 */
DEVICE_DETAIL = "deviceDetail";
-- MAC地址 */
MAC = "mac";
-- IP地址 */
IP = "ip";
-- 浏览器 */
BROWSER = "browser";
-- 屏幕分辨率 */
SCREEN = "screen";
-- 系统版本 */
OS_VERSION = "OSVersion";
-- 是否越狱 */
JAILBREAK = "jailbreak";
-- 运营商 */
OPERATOR = "operator";

-- 获取stationId **/
STATION_ID = "12345678";

--[[
* 定义机器人消息JSON字符串的KEY
*/--]]
ROBOT_MESSAGE_HEAD = "head";
ROBOT_MESSAGE_LINKS = "links";
ROBOT_MESSAGE_LINKS_ITEM_TYPE = "type";
ROBOT_MESSAGE_LINKS_ITEM_VALUE = "value";
ROBOT_MESSAGE_LINKS_ITEM_TEXT = "text";
ROBOT_MESSAGE_FOOT = "foot";

--************************* tcp 链接相关 ************************************/
CONNECT_TCP_HOST = "cs-test.oa.com";
CONNECT_TCP_HOST_TEST = "cs-test.oa.com";
HTTP_URL_PREFIX = "http://cs-cn.boyaagame.com:1323/";
CONNECT_TCP_PORT = "3333";
CONNECT_HTTP_PORT = "1323";

--************************* http 链接相关 ************************************/

--************************* 文件上传 ************************************/
VOICE_SESSION_ID = "123456789012345";
FILE_UPLOAD_INPUTNAME = "file";
FILE_UPLOAD_URI = HTTP_URL_PREFIX .. "upload";
FILE_UPLOAD_HOST = HTTP_URL_PREFIX;

-- 获取离线消息数目
HTTP_OBTAIN_OFFLINE_MESSAGES = HTTP_URL_PREFIX .. "offmsgnum";
-- 提交用户评分数据
HTTP_SUBMIT_RATING_URI = HTTP_URL_PREFIX .. "rating";
-- 提交用户投诉相关事情
HTTP_SUBMIT_APPEAL_URI = HTTP_URL_PREFIX .. "appeal";
-- 提交用户举报相关事情
HTTP_SUBMIT_REPORT_URI = HTTP_URL_PREFIX .. "report";
-- 提交用户留言相关事情
HTTP_SUBMIT_ADVISE_URI = HTTP_URL_PREFIX .. "advise";
-- 获取用户投诉解决历史记录
HTTP_SUBMIT_APPEAL_HISTORY_URI = HTTP_URL_PREFIX .. "appeal/history";
-- 获取用户举报相关解决历史记录
HTTP_SUBMIT_REPORT_HISTORY_URI = HTTP_URL_PREFIX .. "report/history";
-- 获取用户留言相关解决历史记录
HTTP_SUBMIT_ADVISE_HISTORY_URI = HTTP_URL_PREFIX .. "advise/history";
-- 获取网络历史消息记录
HTTP_NETWORK_HISTORY_MESSAGE_URI = HTTP_URL_PREFIX .. "chat/history";

--************************* client config column ***********************************/
COLUMN_HOST_CONFIG = "host";
COLUMN_PROT_CONFIG = "port";
COLUMN_GID_CONFIG = "gameId";
COLUMN_SID_CONFIG = "siteId";
COLUMN_STATIONID_CONFIG = "stationId";
COLUMN_SSL_CONFIG = "ssl";
COLUMN_SSLKEY_CONFIG = "sslKey";
COLUMN_QOS_CONFIG = "qos";
COLUMN_SESSIONID_CONFIG = "sessionId";
COLUMN_ROLE_CONFIG = "role";
COLUMN_UNAME_CONFIG = "userName";
COLUMN_UPWD_CONFIG = "userPwd";
COLUMN_UNICKNAME_CONFIG = "nickName";
COLUMN_UAVATAR_CONFIG = "avatarUri";
COLUMN_CLEANSESSION_CONFIG = "cleanSession";
COLUMN_TIMEOUT_CONFIG = "timeout";
COLUMN_KEEPALIVE_CONFIG = "keepalive";
COLUMN_RETAIN_CONFIG = "retain";
COLUMN_DEBUG_CONFIG = "debug";

--************************* device config ***********************************/
M_DEVICE_TYPE = 2;
M_DEVICE_IP = "daiding";

-- 数据库最大保存消息条目数 */
DB_MESSAGE_MAX_NUM = 100;
-- 每次网络加载消息的消息条目数 */
NETWORK_MESSAGE_LIMIT = 10;