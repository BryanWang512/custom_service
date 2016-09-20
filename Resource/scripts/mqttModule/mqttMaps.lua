Role_Map = 
{
    ["SERVICE"]     = "1",
    ["CLIENT"]      = "2",
    ["VIPCLIENT"]   = "3",
};

ConversationStatus_Map = 
{
    ["DISCONNECTED"]    = 0, --未链接
    ["CONNECTING"]      = 1, --正在连接
    ["CONNECTED"]       = 2, --已连接
    ["LOGINED"]         = 3, --已登录
    ["SHIFTED"]         = 4, --转接
    ["SESSION"]         = 5, --会话状态
    ["FINSHED"]         = 6, --会话结束
    ["LOGOUT"]          = 7, --已连接，但已登出，需要重新login
};

--发送以下类型的消息
ActionType_Map =
{
    ["LOGIN"]           = 0,  
    ["SHIFT"]           = 1, 
    ["LOGOUT"]          = 2, 
    ["PREPARE_CHAT"]    = 3,  --不支持
    ["ACT_SERVER"]      = 4,  --不支持
    ["CHAT"]            = 5,  --不支持
    ["RELOGIN"]         = 6,
};

MessageType_Map =
{
	["TXT"]     = "1",-- text
	["IMG"]     = "2",-- picture
	["VOICE"]   = "3",-- voice
	["ROBOT"]   = "4",-- bot message
};

-- logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
LogoutEndType_Map =
{
	["USER"]        = 1,-- 用户
	["OFFLINE"]     = 2,-- 离线
	["TIMEOUT"]     = 3,-- 超时
	["KEFU"]        = 4,-- 客服
};

-- logout的结束类型,1-用户；2-离线；3-超时；4-客服 */
MqttEvent_Map =
{
	["MQTT_CONNECT_SUCCESS"]    = 1,-- 连接成功
	["MQTT_CONNECT_FAILURE"]    = 2,-- 连接失败
	["MQTT_SUBSCRIBE_SUCCESS"]  = 3,-- 订阅成功
	["MQTT_SUBSCRIBE_FAILURE"]  = 4,-- 订阅失败
    ["MQTT_SEND_MSG_SUCCESS"]   = 5,-- 发送成功
	["MQTT_SEND_MSG_FAILURE"]   = 6,-- 发送失败
    ["MQTT_CONNECT_LOST"]       = 7,-- 
	["MQTT_DELIVERY_COMPLETED"] = 8,--
    ["MQTT_DISCONNECT_SUCCESS"] = 9,
    ["MQTT_DISCONNECT_FAILURE"] = 10, 
};

--文件类型
MessageFileType_Map =
{
    ["TXT"]     = "text/plain",-- text
    ["JPG"]     = "image/jpeg",-- picture
    ["MP3"]   = "audio/mp3",-- voice
};
