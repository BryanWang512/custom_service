require("mqttModule/mqttMaps");
require("mqttModule/clientConfig");
require("mqttModule/dataUtils");
require("mqttModule/mqttConstants");
require("libs/json_wrap");

BoyaaConversation = class();

BoyaaConversation.s_conversations = {};

BoyaaConversation.ctor = function (self, configTable, infoTable)
    self.handlerId = Clock.now();
    BoyaaConversation.s_conversations[self.handlerId] = self;
    self.sessionId = "";
    self.destServiceFid = "";-- 转接的人工service封id
    self.conversationStatus = ConversationStatus_Map.DISCONNECTED; -- 会话状态
    self.isVip = false;
    self.requestUri = "";
    self.couples = {}; -- 该参数用于标记 在人工客服 前提下，用户和客服都至少要有一次聊天记录
    self:init(configTable, infoTable);
    self.offsMsg = {};
    self.reconnectTimes = 0;
end

BoyaaConversation.dtor = function (self)
    self.offsMsg = nil;
    self:destroyMqtt();
    self.mqtt = nil;
end

--config是 ClientConfig
BoyaaConversation.init = function (self, configTable, infoTable)
    self.userConfig = new(ClientConfig, configTable);
    self.userConfig:setClientInfo(infoTable);
    self.isVip = (self.userConfig:getRole() == Role_Map.VIPCLIENT);
    if package.preload['mqtt'] ~= nil then
		self.mqtt = require "mqtt";
    end
    self:createMqtt();
end

BoyaaConversation.addOffMsg = function (self, seq_id)
    table.insert(self.offsMsg, seq_id);
end

BoyaaConversation.clearOffMsg = function (self)
    self.offsMsg = {};
end

BoyaaConversation.getHandlerId = function (self)
    return self.handlerId;
end

BoyaaConversation.isVip = function (self)
    return self.isVip;
end

BoyaaConversation.getConversationStatus = function (self)
    return self.conversationStatus;
end

BoyaaConversation.setConversationStatus = function (self, status)
    self.conversationStatus = status;
end

BoyaaConversation.incChatRecord = function (self, isService)
    if self:isHumanService() then
        return;
    end
    if isService then
        self.couples[1] = true;
    else
        self.couples[2] = true;
    end
end

BoyaaConversation.isShouldGrade = function (self)
    return self.couples[1] and self.couples[2];
end

BoyaaConversation.getAvatarDownloadUri = function (self, avatar)
    local downloadUri = "";
	local uri = self.userConfig:getAvatarDownloadUri();
	if uri ~= "" then
		local md5 = md5_string(avatar);
		downloadUri = DataUtils.getInstance():getAvatarUri(md5);
	end
	return downloadUri;
end

BoyaaConversation.generateClientInfo = function (self, avatarUri)
    local info = {};
    info[NICKNAME] = self.userConfig[NICKNAME];
	info[AVATAR_URI] = avatarUri;
	info[VIP_LEVEL] = self.userConfig[VIP_LEVEL];
	info[GAME_NAME] = self.userConfig[GAME_NAME];
	info[ACCOUNT_TYPE] = self.userConfig[ACCOUNT_TYPE];
	info[CLIENT] = self.userConfig[CLIENT];
	info[USER_ID] = self.userConfig[USER_ID];
	info[DEVICE_TYPE] = self.userConfig[DEVICE_TYPE];
	info[CONNECTIVITY] = self.userConfig[CONNECTIVITY];
	info[GAME_VERSION] = self.userConfig[GAME_VERSION];
	info[DEVICE_DETAIL] = self.userConfig[DEVICE_DETAIL];
	info[MAC] = self.userConfig[MAC];
	info[IP] = self.userConfig[IP];
	info[BROWSER] = self.userConfig[BROWSER];
	info[SCREEN] = self.userConfig[SCREEN];
	info[OS_VERSION] = self.userConfig[OS_VERSION];
	info[JAILBREAK] = self.userConfig[JAILBREAK];
	info[OPERATOR] = self.userConfig[OPERATOR];
    local str = json.encode(info);
    print_string("generateClientInfo:" .. str);
    return str;
end

BoyaaConversation.getRequestUri = function(self)
	if self.requestUri == nil or self.requestUri == "" then
		local host = self.userConfig:getHost();
		local port = self.userConfig:getPort();
		local ssl = self.userConfig:getSsl();
        if ssl then
		    self.requestUri = "ssl://";
	    else
		    self.requestUri = "tcp://";
	    end
	    self.requestUri = self.requestUri .. host .. ":" .. port;
    end
	return self.requestUri;
end

-- handle fo the Connection,暂定为 uri + clientId
BoyaaConversation.generateClientHandler = function (self)
	return self:getRequestUri() .. self:getCurrentClientId();
end

BoyaaConversation.getClientHandle = function (self)
	if clientHandle == "" then
		self:setClientHandle(self:generateClientHandler());
	end
	return self.clientHandle;
end

BoyaaConversation.setClientHandle = function (self, handle)
	self.clientHandle = handle;
end

-- 获取当前mqtt用户端唯一标示， 暂定为：gid/site_id/mid
BoyaaConversation.getCurrentClientId = function (self)
    return self.userConfig:getGameId() .. "/" .. self.userConfig:getSiteId().. "/" .. self.userConfig:getStationId();
end

--[[
* 用于获取优选service fid，用于登录使用，默认获取上一次使用的 service fid
* 
* @return
*/--]]
BoyaaConversation.getPreferServiceFid = function (self)
	return DataUtils.getInstance():getCurrentServiceFid();
end

BoyaaConversation.getCurrentServiceFid = function (self)
	local stationId = self.userConfig:getService_stationId();
	if stationId == nil or self.stationId == "" then
		return "";
	end
    return self.userConfig:getService_gid() .. "/" .. self.userConfig:getService_sid() .. "/" .. self.userConfig:getService_stationId();
end

BoyaaConversation.saveLatelyServiceFid = function (self)
    DataUtils.getInstance():saveCurrentServiceFid(self:getCurrentServiceFid());
end

BoyaaConversation.getDestServiceFid = function (self)
	return self.destServiceFid;
end

BoyaaConversation.setDestServiceFid = function (self, dsfid)
	self.destServiceFid = dsfid;
end

BoyaaConversation.getCurrentUserConfig = function (self)
	return self.userConfig;
end

BoyaaConversation.getSessionId = function (self)
	return self.sessionId;
end

BoyaaConversation.setSessionId = function (self, id)
	self.sessionId = id;
end

--[[
* 当前是否人工客服服务,是则返回true,否则返回false
* 
* @return
*/--]]
BoyaaConversation.isHumanService = function (self)
    -- 0/1/XXX是机器人，0/0/XXX是人工客服
	return "0" == self.userConfig:getService_sid();
end

BoyaaConversation.isHumanService = function (self, s_sid)
	return "0" == s_sid;
end

BoyaaConversation.generateMqttConfig = function (self)
    local info = {};
    info[COLUMN_HOST_CONFIG] = self.userConfig[COLUMN_HOST_CONFIG];
	info[COLUMN_PROT_CONFIG] = self.userConfig[COLUMN_PROT_CONFIG];
	info[COLUMN_GID_CONFIG] = self.userConfig[COLUMN_GID_CONFIG];
	info[COLUMN_SID_CONFIG] = self.userConfig[COLUMN_SID_CONFIG];
	info[COLUMN_ROLE_CONFIG] = self.userConfig[COLUMN_ROLE_CONFIG];
	info[COLUMN_STATIONID_CONFIG] = self.userConfig[COLUMN_STATIONID_CONFIG];
	info[COLUMN_UAVATAR_CONFIG] = self.userConfig[COLUMN_UAVATAR_CONFIG];
	info[COLUMN_QOS_CONFIG] = self.userConfig[COLUMN_QOS_CONFIG];
	info[COLUMN_CLEANSESSION_CONFIG] = self.userConfig[COLUMN_CLEANSESSION_CONFIG];
	info[COLUMN_KEEPALIVE_CONFIG] = self.userConfig[COLUMN_KEEPALIVE_CONFIG];
	info[COLUMN_TIMEOUT_CONFIG] = self.userConfig[COLUMN_TIMEOUT_CONFIG];
	info[COLUMN_RETAIN_CONFIG] = self.userConfig[COLUMN_RETAIN_CONFIG];
	info[COLUMN_SSL_CONFIG] = self.userConfig[COLUMN_SSL_CONFIG];
	info[COLUMN_SSLKEY_CONFIG] = self.userConfig[COLUMN_SSLKEY_CONFIG];
	info[COLUMN_UNAME_CONFIG] = self.userConfig[COLUMN_UNAME_CONFIG];
	info[COLUMN_UPWD_CONFIG] = self.userConfig[COLUMN_UPWD_CONFIG];
    local str = json.encode(info);
    print_string("generateMqttConfig:" .. str);
    return str;
end

--[[
* 判读是否当前是由人工转到机器人
* 
* @param new_s_sid
* @return
*/--]]
BoyaaConversation.isShiftToRobot = function (self, new_s_sid)
	if self:isHumanService() then
		return not self:isHumanService(new_s_sid);
	end
	return false;
end

--[[
* {"nickname":"军爷","avatarUri":
* "http://mvussppk02.ifere.com/images/service/1512/d72b1e1f.png","ext":""}
* 
* @param serviceInfo
*            :客服端相关信息
--]]
BoyaaConversation.dealWithServiceInfo = function (self, serviceInfo)
	print_string("dealWithServiceInfo serviceInfo:" .. serviceInfo);
	if serviceInfo == "" then
		return;
	end
	local tab = json.decode(serviceInfo);
	local nickname  = tab["nickname"];
	local avatarUri = tab["avatarUri"];
	local ext       = tab["ext"];
    self.userConfig:setService_nickName(nickname);
	self.userConfig:setService_avatarDownloadUri(avatarUri);
	self.userConfig:setService_ext(ext);
end

--已经成功登录，准备发起聊天请求，请求ok则可以正式进入聊天
BoyaaConversation.prepareChat = function (self)
    local avatar = self:getCurrentUserConfig():getAvatarUri();
	print_string("uploadAvatarImage prepareChat avatar:" .. avatar);
	local clientInfo = "";
    if avatar == "" then
        clientInfo = self:generateClientInfo("");
		self:sendChatReadyMsg(clientInfo);
    else
        local avatarUri = self:getAvatarDownloadUri(avatar);
		print_string("uploadAvatarImage cache avatarUri:" .. avatarUri);
        if avatarUri ~= "" then
			clientInfo = self:generateClientInfo(avatarUri);
			self:sendChatReadyMsg(clientInfo);
		else 
            -- 用户头像是网络图片时
            local md5 = md5_string(avatar);
            self:getCurrentUserConfig():setAvatarDownloadUri(avatar);
			DataUtils.getInstance():saveAvatarUri(md5, avatar);
			clientInfo = self:generateClientInfo(avatar);
			self:sendChatReadyMsg(clientInfo);
            --TODO:~~~~~~~~~~~~~~
            --剩下的逻辑参考java
            --如果Url不是合法的(是本地文件路径)
            --如果文件不存在 构造clientInfo， sendChatReadyMsg
            --如果文件存在，上传头像文件,构造clientInfo， sendChatReadyMsg
        end
    end
end

BoyaaConversation.parseLoginResponse = function (self, session_id, service_gid, service_site_id, service_station_id)
	self:setSessionId(session_id);
	self:getCurrentUserConfig():setService_gid(service_gid);
	self:getCurrentUserConfig():setService_sid(service_site_id);
	self:getCurrentUserConfig():setService_stationId(service_station_id);
	self:saveLatelyServiceFid();
    if self:isShiftToRobot(service_site_id) then
		--[[
			* 判断用户之前是否有连接人工客服，如果用户在普通用户的时候上次联系过人工客服，或者在VIP情况下转到机器人，
			* 给出人工客服到机器人的提示
			*/--]]
		--TODO: 界面逻辑
	end
end

BoyaaConversation.dealwithChatMsg  = function (self, seq_id, types, msg)
    --message.setPullmsgTime(seq_id);
	--message.setDirect(Direct.RECEIVE);
	--message.setType(messageType);// 暂时固定为文本消息，用于调试
	--if (!message.isOffline()) {
	--	message.setMsgTime(System.currentTimeMillis());// 是以下载完成的时间为准呢，还是以接收到消息的时间为准，目前该值为接收到消息的时间
	--} else {
	--	message.setMsgTime(seq_id);
	--}
    if types == MessageType_Map.ROBOT then
        --TODO: 界面逻辑
    elseif types == MessageType_Map.TXT then
        --TODO: 界面逻辑
    elseif types == MessageType_Map.IMAGE then
        --TODO: 界面逻辑
        --下载图片， msg是url
    elseif types == MessageType_Map.VOICE then
        --TODO: 界面逻辑
        --下载文件， msg是url
    end
end


-------------------------------------分割线-----------------------------------------
--以下是mqtt协议接口
-- step1:创建MQTT Client 
BoyaaConversation.createMqtt = function (self)
    self.mqtt.create(self:generateMqttConfig(), self.handlerId);
end

--step2:连接服务器，连接时设置遗嘱消息为 LogoutMessage
BoyaaConversation.connect = function (self)
    local ret = self.mqtt.connect(self:getLogoutTopic());
    return ret;
end

--step3:订阅主题
BoyaaConversation.subscribe = function (self)
    local ret = self.mqtt.subscribe(self:getSubscribeTopic());
    return ret;
end

--step4:登录
BoyaaConversation.login = function (self)
    if not self:isConnected() then
		return;
    end
    return self:sendMessage(ActionType_Map.LOGIN);
end

--step4:发送准备聊天的消息，携带clientinfo
BoyaaConversation.sendChatReadyMsg = function (self, clientinfo)
    return self.mqtt.sendChatReadyMsg(clientinfo, self:getSessionId(), self:getPrepareChatTopic());
end

--step5:发送消息
--@param message 消息内容
--@param types   消息类型，MessageType_Map
BoyaaConversation.sendChatMsg = function (self, message, types)
    return self.mqtt.sendChatMsg(message, types, self:getSessionId(), self:getChatTopic());
end

--step6:登出
--@param types   结束类型，LogoutEndType_Map
BoyaaConversation.logout = function (self, end_type)
    local status = self:getConversationStatus();
	if (not self:isConnected()) or status < ConversationStatus_Map.CONNECTED then
		self:destroyMqtt();
		return;
	end
    return self:sendMessage(ActionType_Map.LOGOUT, end_type);
end

--断开服务器
BoyaaConversation.disconnect = function (self)
    self.mqtt.disconnect();
end

--判断是否跟服务器链接
BoyaaConversation.isConnected = function (self)
    return self.mqtt.isConnected();
end

--销毁
BoyaaConversation.destroyMqtt = function (self)
    return self.mqtt.destroy();
end

--发送消息
--@param types   动作类型，ActionType_Map,  end_type是给logoutMessage用的
BoyaaConversation.sendMessage = function (self, types, end_type)
    local result;
    if types == ActionType_Map.LOGIN then
        local s_fid = self:getPreferServiceFid();
        local s_dest_fid = self:getCurrentServiceFid();
        result = self.mqtt.sendMessage(types, s_fid, s_dest_fid, self:getLoginTopic());
	elseif types == ActionType_Map.RELOGIN then
        local cur_sfid = self:getCurrentServiceFid();
        result = self.mqtt.sendMessage(types, cur_sfid, self:getLoginTopic());
    elseif types == ActionType_Map.SHIFT then
        local ss_fid = self:getCurrentServiceFid();
		local ss_dest_fid = self:getDestServiceFid();
		if ss_dest_fid ~= "" then
			self:setDestServiceFid("");
		end
        result = self.mqtt.sendMessage(types, ss_fid, ss_dest_fid, self:getLoginTopic());
    elseif types == ActionType_Map.LOGOUT then
        if end_type then
            result = self.mqtt.sendMessage(types, end_type, self:getLogoutTopic());
        else
            result = self.mqtt.sendMessage(types, LogoutEndType_Map.USER, self:getLogoutTopic());
        end
    elseif types == ActionType_Map.PREPARE_CHAT then
        local clientinfo = self:generateClientInfo("");
        local session_id = self:getSessionId();
        result = self.mqtt.sendMessage(types, clientinfo, session_id, self:getPrepareChatTopic());
    elseif types == ActionType_Map.ACT_SERVER then
        --暂时没用
    end
    print_string("BoyaaConversation.sendMessage result: " .. result);
    return result;
end

--发送消息，所有离线消息已收到
BoyaaConversation.sendOffMessageAck = function (self)
    if #self.offsMsg == 0 then return; end
    local result = self.mqtt.sendOffMessageAck(self.offsMsg, self:getSessionId(), self:getMessageAckTopic());
    if result == 0 then --成功以后clear
        self.offsMsg = {};
    end
    return result;
end


--发送消息，消息收到
BoyaaConversation.sendMessageAck = function (self, seq_id)
    return self.mqtt.sendMessageAck(seq_id, self:getSessionId(), self:getMessageAckTopic());
end

--生成毫秒时间戳，13位
BoyaaConversation.clock = function (self)
    return self.mqtt.clock();
end


-----------------------------------------分割线------------------------------------------
--[[
* 客户端发布LogoutMessage到topic为gid/site_id/station_id/act/logout
* @return 
*/--]]
BoyaaConversation.getLogoutTopic = function(self)
	local topic = self:getCurrentClientId() .. LOGOUT_REQUEST_TOPIC_SUFFIX;
	print_string("getLogoutTopic : ".. topic);
	return topic;
end

--[[
* 客户端发布LoginRequest到gid/siteid/stationid/act/login
*
* @return
*/--]]
BoyaaConversation.getLoginTopic = function(self)
	local topic = self:getCurrentClientId() .. LOGIN_REQUEST_TOPIC_SUFFIX;
	print_string("getLoginTopic : ".. topic);
	return topic;
end

--[[
* 客户端订阅gid/siteid/stationid/msg/+
*
* @return
*/--]]
BoyaaConversation.getSubscribeTopic = function(self)
	local topic = self:getCurrentClientId() .. SUBSCRIBE_TOPIC_SUFFIX;
	print_string("getSubscribeTopic : ".. topic);
	return topic;
end

--[[
* Client:收到loginresp,如果成功，则向service_gid/service_site_id/service_station_id/
* msg/chatready
*
* @return
*/--]]
BoyaaConversation.getPrepareChatTopic = function(self)
	local topic = self:getCurrentServiceFid() .. CHAT_READY_REQUEST_TOPIC_SUFFIX;
	print_string("getPrepareChatTopic : ".. topic);
	return topic;
end

--[[
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息：
*
* @return
*/--]]
BoyaaConversation.getMessageAckTopic = function(self)
	local topic = self:getCurrentClientId() .. CHAT_MESSAGE_ACK_TOPIC_SUFFIX;
	print_string("getMessageAckTopic : ".. topic);
	return topic;
end

--[[
* 此时,玩家可以开始发送消息并且可以收到来自客服的消息了.聊天开始了.客户端发送消息： service_gid/service_site_id/
* service_station_id/msg/chat;客户端接收消息：gid/siteid/stationid/msg/chat
*
* @return
*/--]]
BoyaaConversation.getChatTopic = function(self)
	local topic = self:getCurrentServiceFid() .. CHAT_MESSAGE_TOPIC_SUFFIX;
	print_string("getChatTopic : ".. topic);
	return topic;
end


--------------------------------分割线------------------------------------------
--以下是c回调lua的函数，不要主动调用

--接收服务器推送的消息
function mqtt_message_arrived(handlerId, tag, ...)
    local args = {...};
    local conversation = BoyaaConversation.s_conversations[handlerId];
    print_string("message_arrived handlerId: ".. handlerId);
	print_string("message_arrived tag: ".. tag);
    print_string("message_arrived args num: ".. #args);
    --login response
	if tag == "loginresp" then
		local loginCode = args[1];
		local loginMsg = args[2];
        local session_id = args[3];
		local service_gid = args[4];
        local service_site_id = args[5];
		local service_station_id = args[6];
        local wait_count = args[7];

        if loginCode == 1 then --登录成功
            conversation:setConversationStatus(ConversationStatus_Map.LOGINED);
            conversation:parseLoginResponse(session_id, service_gid, service_site_id, service_station_id);
			conversation:prepareChat();
        elseif loginCode == 2 then --登录失败
            --TODO:界面逻辑
            --((BaseActivity) context).showExceptionTips(0);
        elseif loginCode == 3 then --无人在线
            --TODO:界面逻辑
            --((BaseActivity) context).schedulePollLoginTask();
        elseif loginCode == 4 then --排队等待
            if not DataUtils.getInstance():obtainConnectCallbackStatus() then
				DataUtils.getInstance():setConnectCallbackStatus(true);
                --TODO:界面逻辑
				--((BaseActivity) context).removeDelayConnectedCallbacks();
				--((BaseActivity) context).dismissNetworkExceptionTip();
			end
            if wait_count > 0 then
				--TODO:界面逻辑
                --参照JAVA
			elseif wait_count == 0 then
				--TODO:界面逻辑
                --参照JAVA
			end
        elseif loginCode == 5 then --会话已建立，重复登录了
            conversation:setConversationStatus(ConversationStatus_Map.SESSION);
			--((BaseActivity) context).removeDelayConnectedCallbacks();
			--((BaseActivity) context).dismissNetworkExceptionTip();
			conversation:parseLoginResponse(session_id, service_gid, service_site_id, service_station_id);
			conversation:prepareChat();
        end
	elseif tag == "shift" then
        local sShiftToFid = args[1];
		local session_id  = args[2];
        conversation:setDestServiceFid(sShiftToFid);
        local result = conversation:sendMessage(ActionType_Map.SHIFT);
        if result then
            print_string("shift login message");
            conversation:setConversationStatus(ConversationStatus_Map.SHIFTED);
        end
    -- 发送目的：client_fid/msg/end
	-- 归档、升级、无效：这三个功能都通过EndSession消息实现
	-- 归档：必须设置archive_class和archive_category
	-- 升级：必须设置archive_class和archive_category，以及设置session_upgraded为1
	-- （升级之前PC客户端需提交工单到工单系统成功）
	-- 无效：设置session_invalid为1（其他字段不设置）
	-- Client收到EndSession后，取消订阅，断开连接，并且提示用户本次会话已经结束，请返回
	-- Server收到EndSession后，将session归档信息插入归档表（mysql）, 删除session_id
	elseif tag == "end" then
        conversation:setConversationStatus(ConversationStatus_Map.FINSHED);
		local sessionId         = args[1];
		local client_gid        = args[2];
		local client_site_id    = args[3];
		local client_station_id = args[4];
		local archive_class     = args[5];
		local archive_category  = args[6];
		local session_upgraded  = args[7];
		local session_invalid   = args[8];
		local end_type          = args[9];
		--[[
		* 收到server发的endsession后还要判断下 里面的session_id
		* 跟当前会话session_id是否相同，相同才断开会话
		*/--]]
		if sessionId == conversation:getSessionId() then
			--TODO:界面逻辑
            --参照JAVA
			conversation:logout(end_type);
        end
	elseif tag == "chatreadyresp" then
        local code          = args[1];
        local session_id    = args[2];
        local service_info  = args[3];
        if code == 1 or code == 3 then-- 1 - OK; 2 - 拒绝；3 - 已在会话中
	        print_string("chatreadyresp");
	        conversation:setConversationStatus(ConversationStatus_Map.SESSION);
	        conversation:dealWithServiceInfo(service_info);
	        if conversation:isHumanService() then
		        --lua根据code显示不同的 hintText 
		        --1:客服%1$s很高兴为您服务
		        --3:您已返回与客服%1$s进行对话
		        --TODO:界面逻辑
                --参照JAVA
	        end
        end

	elseif tag == "chat" then
        local seq_id    = args[1];
        local types     = args[2];
        local msg       = args[3];
        local session_id = args[4];
        print_string("chatMsg seqid: ".. seq_id);
        print_string("chatMsg type = ".. types);
        print_string("chatMsg msg = ".. msg);
        print_string("chatMsg session_id = ".. session_id);
        conversation:incChatRecord(true);
        conversation:sendOffMessageAck();
        conversation:sendMessageAck(seq_id);
        conversation:dealwithChatMsg(seq_id, types, msg);
        -- 会话状态和离线消息
	elseif tag == "chatoff" then
        local seq_id = args[1];
        local types = args[2];
        local msg = args[3];
        local session_id = args[4];
        print_string("chatOffMsg seqid: ".. seq_id);
        print_string("chatOffMsg type = ".. types);
        print_string("chatOffMsg msg = ".. msg);
        print_string("chatOffMsg session_id = ".. session_id);
        conversation:dealwithChatMsg(seq_id, types, msg);
        conversation:addOffMsg(seq_id);
	--[[
	* 对于用户来说，这两种情况（1. 客服离线，2.
	* 自己断线）是一样的，用户得到一个提示：你已经断开与客服的连接，是否”重连“，点击重连，就重新login。
	*/--]]
	elseif tag == "logout" then
		local session_id = args[1];
		local service_gid = args[2];
		local service_site_id = args[3];
		local service_station_id = args[4];
		local clock = args[5];
		local end_type = args[6];
		local extra = args[7];
        --TODO:界面逻辑
        print_string("logout args: session_id = " ..session_id ..", service_gid = "..service_gid
        ..", service_site_id = " ..service_site_id..", service_station_id = " ..service_station_id
        ..", clock = " ..clock..", end_type = " ..end_type..", extra = "..extra);
    end
end

--code 是失败代码 
function mqtt_event_callback(handlerId, event, code)
    local conversation = BoyaaConversation.s_conversations[handlerId];
    print_string("mqtt_event_callback handlerId: ".. handlerId);
	print_string("mqtt_event_callback event: " .. event);
    if event == MqttEvent_Map.MQTT_CONNECT_SUCCESS then
        conversation:subscribe();
    elseif event == MqttEvent_Map.MQTT_CONNECT_FAILURE then
        print_string("MQTT_CONNECT_FAILURE code: " .. code);
        if conversation.reconnectTimes and conversation.reconnectTimes < 5 then
            conversation.reconnectTimes = conversation.reconnectTimes + 1;
            print_string("reconnect times: " .. conversation.reconnectTimes);
            conversation:connect();
        else 
            conversation.reconnectTimes = 0;
        end
    elseif event == MqttEvent_Map.MQTT_SUBSCRIBE_SUCCESS then
        conversation:login();
    elseif event == MqttEvent_Map.MQTT_SUBSCRIBE_FAILURE then
        print_string("MQTT_SUBSCRIBE_FAILURE code: " .. code);
    elseif event == MqttEvent_Map.MQTT_SEND_MSG_SUCCESS then
        print_string("MQTT_SEND_MSG_SUCCESS");
    elseif event == MqttEvent_Map.MQTT_SEND_MSG_FAILURE then
        print_string("MQTT_SEND_MSG_FAILURE code: " .. code);
    elseif event == MqttEvent_Map.MQTT_CONNECT_LOST then
        print_string("Connection lost, cause: " .. code);
    elseif event == MqttEvent_Map.MQTT_DELIVERY_COMPLETED then
        print_string("Message with token value : " .. code);
    end
end