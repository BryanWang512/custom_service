local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
local HTTP2 = require("network.http2")


local protocalFunc = {}

protocalFunc.loginresp = function (loginCode, loginMsg, sessionId, serviceGid, serviceSiteId, serviceStationId, waitCount)
	
	local data = UserData.getStatusData() or {}
    data.loginCode = loginCode
    UserData.setStatusData(data)


    print("=================loginCode",loginCode)
    local view = nil
    if data.isVip then
    	view = ViewManager.getVipChatView()
    else
    	view = ViewManager.getNormalChatView()
    end



	view:hideExceptionTips()

		
	--已经退出
	if not view or data.isOut then return end 

	if loginCode == 1 then      --登陆成功
		--更新数据
		data.conversationStatus = ConversationStatus_Map.LOGINED
		data.sessionId = sessionId
		data.serviceGid = serviceGid
		data.serviceSiteId = serviceSiteId
		data.serviceStationId = serviceStationId
		UserData.setStatusData(data)

		NetWorkControl.cancelPollLoginTask()

    elseif loginCode == 2 then      --登录失败
    	view:showExceptionTips(0)
        NetWorkControl.schedulePollLoginTask()
    elseif loginCode == 3 then      --无人在线
    	NetWorkControl.schedulePollLoginTask()
    elseif loginCode == 4 then      --排队等待
		
    	UserData.setStatusData(data)
		local str = string.format(ConstString.waiting_tips, waitCount)
		view:addTips(str)
        
    elseif loginCode == 5 then --会话已建立，重复登录了
    	
    	-- 	 判断用户之前是否有连接人工客服，如果用户在普通用户的时候上次联系过人工客服，或者在VIP情况下转到机器人，
		-- 	 给出人工客服到机器人的提示
    	if SessionControl.isShiftToRobot(data.serviceSiteId, serviceSiteId) then
			view:addLeftMsg(ConstString.shift_robot)
		end

		--更新数据
		data.conversationStatus = ConversationStatus_Map.LOGINED
		data.sessionId = sessionId
		data.serviceGid = serviceGid
		data.serviceSiteId = serviceSiteId
		data.serviceStationId = serviceStationId
		UserData.setStatusData(data)

		NetWorkControl.cancelPollLoginTask()
		SessionControl.scheduleSessionTask(view)

    end   
	
end

--转接, 主要功能已经在boyaaConversation中实现了
protocalFunc.shift= function (shiftToFid, sessionId)
	
end

protocalFunc.xend = function (sessionId, clientGid, clientSiteId, clientStationId, 
	                          archiveClass, archiveCategory, sessionUpgraded, sessionInvalid, endType)

	local data = UserData.getStatusData() or {}
	data.conversationStatus = ConversationStatus_Map.FINSHED
	UserData.setStatusData(data)

	--前后的会话Id相同才结束
	if sessionId == data.sessionId then
		local str = string.format(ConstString.end_tips_str, data.nickName)
		local view = nil

		if data.isVip then
			view = ViewManager.getVipChatView()
		else
			view = ViewManager.getNormalChatView()
		end

		view:addLeftMsg(str)
		--需要关掉所有task
		NetWorkControl.cancelPollLoginTask()
		SessionControl.clearAllTask()
		NetWorkControl:sendProtocol("logout", endType)
	end
end

protocalFunc.chatreadyresp = function (code, sessionId, serviceInfo)
	print_string("====================chatreadyresp code:"..code)
	code = tonumber(code)
	local data = UserData.getStatusData() or {}
	local tb = json.decode(serviceInfo)
	data.sessionId = sessionId
	data.nickName = tb.nickname
	data.servicerUrl = tb.avatarUri
	data.serviceHeadFinish = nil

	print_string("tb.avatarUri:"..tb.avatarUri)
	--下载客服头像
	if tb.avatarUri and tb.avatarUri ~= "" and string.find(tb.avatarUri, "http") then
		data.needUpdateIcons = {}
		local index = 1
		local urlLen = string.len(tb.avatarUri)
		for i = urlLen, 1, -1 do
			if string.sub(tb.avatarUri, i, i) == "/" then
				index = i
				break
			end
		end
		data.servicerHeadPath = string.sub(tb.avatarUri, index+1, urlLen)

		local filePath = string.format("%s%s", System.getStorageImagePath(), data.servicerHeadPath)

		local args = {
	      	url = tb.avatarUri, 
		    timeout = 10,                   
		    connecttimeout = 10,           
		    writer = {                   
			     type = 'file',              
			     filename = filePath,
			     mode = 'wb',
			},
		}

		HTTP2.request_async(args,
		    function(rsp)
		    	if rsp.errmsg then
		    		print_string("DownLoadFile Fail:"..rsp.errmsg)
		    	elseif rsp.code == 200 then
		    		data.serviceHeadFinish = true
			     	for i, v in ipairs(data.needUpdateIcons or {}) do
						v.unit = TextureUnit(TextureCache.instance():get(data.servicerHeadPath))
					end
			    end
			    data.needUpdateIcons = nil
			    UserData.setStatusData(data)
		    end
	    )
	end

	UserData.setStatusData(data)


	local view
	if data.isVip then
		view = ViewManager.getVipChatView()
	else
		view = ViewManager.getNormalChatView()
	end


	if code == 1 then        	--ok 登录成功且可以开始和客服聊天了
		data.conversationStatus = ConversationStatus_Map.SESSION
		
		if SessionControl.isHumanService(data.serviceSiteId) then
			local str = string.format(ConstString.servicer_tips, tb.nickname)
			view:addTips(str)
			SessionControl.scheduleSessionTask(view)				
		end
		
	elseif code == 2 then		--客服拒绝聊天
		view:addTips("抱歉，客服拒绝聊天")
	elseif code == 3 then		--已经在会话中
		data.conversationStatus = ConversationStatus_Map.SESSION
		if SessionControl.isHumanService(data.serviceSiteId) then
			local str = string.format(ConstString.hint_tips_repeat, tb.nickname)
			view:addLeftMsg(str)
			SessionControl.scheduleSessionTask(view)
		end
	end


	UserData.setStatusData(data)
end

protocalFunc.chat = function (seqId, types, msg, sessionId)
	print("chat msg = ", msg);

	local message = ChatMessage(seqId, types, msg, sessionId, 0)  	
	SessionControl.dealwithChatMsg(message)		
 
end

protocalFunc.chatoff = function (seqId, types, msg, sessionId)
	print("offline msg = ", msg);

	--离线消息
	local message = ChatMessage(seqId, types, msg, sessionId, 0)
	--离线  
	message.offline = true
	
	SessionControl.dealwithChatMsg(message)
	NetWorkControl.sendProtocol("sendMessageAck", message.seqId)
end


--Service Logout：向service_fid/act/logout发送LogoutMessage（只有header和clock字段）
--Server清除该service_fid对应的缓存，并向该service正在会话中的所有client转发LogoutMessage
--client收到LogoutMessage后，则需要重新login
protocalFunc.logout = function (sessionId, serviceGid, serviceSiteId, serviceStationId, clock, endType, extra)
	local data = UserData.getStatusData()
	data.conversationStatus = ConversationStatus_Map.LOGINED
	UserData.setStatusData(data)
	local view = nil
	if data.isVip then
		view = ViewManager.getVipChatView()
	else
		view = ViewManager.getNormalChatView()
	end

	view:addReloginMsg()
	SessionControl.clearAllTask()
end

return protocalFunc