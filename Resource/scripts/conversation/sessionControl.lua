local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
local HTTP2 = require("network.http2")
local kefuCommon = require(string.format('%skefuCommon', KefuRootPath))

local timeOutTask = nil
local endSessionTask = nil


sessionControl = {}

--设置会话超时Task
sessionControl.scheduleSessionTask = function(view)
	if timeOutTask then
		timeOutTask:cancel()
		timeOutTask = nil
	end

	if endSessionTask then
		endSessionTask:cancel()
		endSessionTask = nil
	end

	--如果不是人工服务，则不需要超时task
	if not SessionControl.isHumanService() then return end

	local data = UserData.getStatusData() or {}

	timeOutTask = Clock.instance():schedule_once(function ()
		view:addLeftMsg(ConstString.hint_timeout)
	end, DELAY_TIMEOUT)

	endSessionTask = Clock.instance():schedule_once(function ()
		view:addLeftMsg(ConstString.hint_end_session)

		data.logoutType = LOGOUT_TYPE_TIMEOUT
		UserData.setStatusData(data)
		--需要记下状态，点击返回按钮需要考虑状态
		if sessionControl.isShouldGrade() then
			view:showEvalutePage(function ()
				SessionControl.logout()
			end)
		else
			SessionControl.logout()
		end

	end, DELAY_END_SESSION)         
end


sessionControl.clearAllTask = function ()
	if timeOutTask then
		timeOutTask:cancel()
		timeOutTask = nil
	end

	if endSessionTask then
		endSessionTask:cancel()
		endSessionTask = nil
	end

end

--是否是人工服务
sessionControl.isHumanService = function (serviceSiteId)
	
	if not serviceSiteId then
		local data = UserData.getStatusData()
		serviceSiteId = data.serviceSiteId
	end

	if serviceSiteId == "0" then
		return true
	else
		return false
	end
end

--判读是否当前是由人工转到机器人
sessionControl.isShiftToRobot = function (oldSid, newSid)
	if sessionControl.isHumanService(oldSid) then
		return not sessionControl.isHumanService(newSid)
	else
		return false
	end
end

--获取客服端的fid
sessionControl.getCurrentServiceFid = function ()
	local data = UserData.getStatusData()
	local fid = "null"
	if data and data.serviceGid and data.serviceSiteId and data.serviceStationId then
		fid = string.format("%s/%s/%s", data.serviceGid, data.serviceSiteId, data.serviceStationId)
	end

	return fid
end

--是否需要评分
sessionControl.isShouldGrade = function ()
	local dd = UserData.getStatusData() or {}
	--只有登录情况下才需要评分
	if dd.loginCode ~= 1 then return false end 


	local data = UserData.getChatViewData() or {}
	if data.couples and data.couples[1] and data.couples[2] then
		return true
	end
	return false
end

--记录下双方至少经过一次聊天
sessionControl.incChatRecord = function (isService)
	if not sessionControl.isHumanService then return end

	local data = UserData.getChatViewData() or {}
	data.couples = data.couples or {}

	if isService then
		data.couples[1] = true
	else
		data.couples[2] = true
	end

	UserData.setChatViewData(data)

end

--处理发送消息, 序列化在本地
sessionControl.dealwithSendMsg = function (message, fullPath)
	sessionControl.incChatRecord()
	--插入历史消息队列
	UserData.insertNewMessage(message)

	local data = UserData.getStatusData()

	local view = nil
	if data.isVip then
		view = ViewManager.getVipChatView()
	else
		view = ViewManager.getNormalChatView()
	end


	if message.types == 1 then				--文本消息
		sessionControl.showTimeTips(view)
		view:sendTxtMsg(message.msg)
		local msg = message:unicode2Emoji()
		NetWorkControl.sendProtocol("sendChatMsg", msg, MessageType_Map.TXT)
	elseif message.types == 2 then			--图片
		--message.msg 表示图片路径,不是全路径
		sessionControl.showTimeTips(view)
		local wgImg = view:addImage(message.msg)
		wgImg.sendingIcon.show()

		--上传图片, fullPath为图片全路径，相当于本地url
		NetWorkControl.upLoadFile(fullPath, function (rsp)
			wgImg.sendingIcon.hide()
			--发送失败
			if rsp.errmsg or rsp.code ~= 200 then
				Log.v("upLoadFile" ,"发送图片失败!");
				wgImg.failBtn.visible = true
				return 
			end

			local content = rsp.content
			local tb = json.decode(content)
			if tb.code == 0 then
				wgImg.failBtn.visible = false
				Log.v("upLoadFile" ,"发送图片成功!");
				print_string("upLoadFile:"..tb.file)

				local msgTb = {}
				msgTb.localUri = fullPath
				msgTb.remoteUrl = FILE_UPLOAD_HOST..tb.file
				msgTb.voiceLength = 0

				local jsonMsg = json.encode(msgTb)
				NetWorkControl.sendProtocol("sendChatMsg", jsonMsg, MessageType_Map.IMG)
			else
				wgImg.failBtn.visible = true
				Log.v("upLoadFile" ,"发送图片失败!");
			end
		end,MessageFileType_Map.JPG)

	elseif message.types == 3 then			--声音
		sessionControl.showTimeTips(view)
		local voiceItem = view:sendVoice(message.time, message.msg)
		voiceItem.sendingIcon.show()
		--上传语音
		NetWorkControl.upLoadFile(fullPath, function (rsp)
			voiceItem.sendingIcon.hide()

			--发送失败
			if rsp.errmsg or rsp.code ~= 200 then
				Log.v("upLoadFile" ,"发送语音失败!");
				voiceItem.failBtn.visible = true
				return 
			end

			local content = rsp.content
			local tb = json.decode(content)
			if tb.code == 0 then
				Log.v("upLoadFile" ,"发送语音成功!");
				voiceItem.failBtn.visible = false
				local msgTb = {}
				msgTb.localUri = fullPath
				msgTb.remoteUrl = FILE_UPLOAD_HOST..tb.file
				msgTb.voiceLength = message.time

				local jsonMsg = json.encode(msgTb)
				NetWorkControl.sendProtocol("sendChatMsg", jsonMsg, MessageType_Map.VOICE)
			else
				Log.v("upLoadFile" ,"发送语音失败!");
				voiceItem.failBtn.visible = true
			end
		end,MessageFileType_Map.MP3)
	end

	SessionControl.scheduleSessionTask(view)

	--序列化在本地
	message:saveToDict(true)
	
end

--根据接收消息刷新界面, 序列化在本地
sessionControl.dealwithChatMsg = function (message)
	
	UserData.insertNewMessage(message)
	print("===========message.types",message.types)
	local data = UserData.getStatusData()

	local view = nil
	if data.isVip then
		view = ViewManager.getVipChatView()
	else
		view = ViewManager.getNormalChatView()
	end

	if not data.connectCallbackStatus then
		view:hideExceptionTips()
		data.connectCallbackStatus = true
	end
	UserData.setStatusData(data)

	if message.types == 1 then				--文本消息
		message:faceChar2UnicodeChar()
		sessionControl.incChatRecord(true)
		sessionControl.showTimeTips(view)
		view:addLeftMsg(message.msg)

	elseif message.types == 2 then			--图片
		sessionControl.incChatRecord(true)
		--下载图片
		local fileName = string.format("%simg.png", seqId)
		local filePath = string.format("%s%s", System.getStorageImagePath(), fileName)
		local url = message.msg
		message.msg = fileName


		NetWorkControl.downLoadFile(url, filePath, function ()
			message.msg = fileName
            if view and os.isexist(filePath) then
            	sessionControl.showTimeTips(view)
                view:addImage(fileName, true)
            elseif view then
            	Log.v("os.isexist", "图片资源不存在")
            end

        end)

	elseif message.types == 3 then			--客服声音待定
		sessionControl.incChatRecord(true)

		local fileName = "audio_" ..tostring(Clock.now())
        local filePath = string.format("%s%s", System.getStorageUserPath(), fileName)

		NetWorkControl.downLoadFile(message.msg, filePath, function ()
			message.msg = filePath

            -- if view then
            -- 	sessionControl.showTimeTips(view)
            --     view:addVoice(filePath, true)
            -- end

        end)
	elseif message.types == 4 then			--机器人文本消息，带超链接形式
		local msgTb = json.decode(message.msg)
		sessionControl.showTimeTips(view)
		view:addRobotMsg(msgTb.head or msgTb.foot, msgTb.links)
	end

	SessionControl.scheduleSessionTask(view)

	message:saveToDict(true)

end

--显示时间tips
sessionControl.showTimeTips = function (view)
	local tips = UserData.getNewMsgTimeTips()
	if tips then
		view:addTimeTips(tips)
	end

end

--是否有新的留言回复
sessionControl.hasNewLeaveReport = function (callback)
	local leaveData = UserData.getLeaveMessageViewData() or {}
	local dictData = leaveData.dictData or {}
	leaveData.hasNewReport = nil

	NetWorkControl.obtainUserTabHistroy(0, 50, HTTP_SUBMIT_ADVISE_HISTORY_URI, function (content)
		local tb = json.decode(content)
		

		if tb.code == 0 and tb.data then
			table.sort(tb.data, function (v1,v2)
                if v1.id > v2.id then
                    return true
                end
                return false
            end)

            
            local replyData = {}
            local newLeaveMsg = nil
			for i, v in ipairs(tb.data) do

				--说明是新提交的消息
				if not dictData[v.id] then
					dictData[v.id] = {}
					dictData[v.id].reportContent = ConstString.replay_default					
					dictData[v.id].hasNewReport = HasNewReport.no
					dictData[v.id].id = v.id
					UserData.insertLeaveMsg(dictData[v.id])
					newLeaveMsg = true
				end


				if v.replies then
					local replyNum = #v.replies
         			if dictData[v.id].reportContent ~= v.replies[replyNum].reply then
         				dictData[v.id].hasNewReport = HasNewReport.yes
         				dictData[v.id].reportContent = v.replies[replyNum].reply
						leaveData.hasNewReport = true
						UserData.updateLeaveMsg(dictData[v.id])
         			end
            	end

            	local data = {}
                data.title = v.content
                data.time = v.clock
                data.id = v.id
                data.mail = v.mail
                data.phone = v.phone
                data.hasNewReport = dictData[v.id].hasNewReport
                if v.replies then
                	local replyNum = #v.replies
                    data.reply = v.replies[replyNum].reply
                else
                    data.reply = ConstString.replay_default
                end

                table.insert(replyData, data)
            end

            UserData.saveLeaveMsg()
            leaveData.historyData = replyData
		else          
            Log.w("hasNewLeaveReport", "留言内容获取失败")
		end

		UserData.setLeaveMessageViewData(leaveData)
		if callback then
			callback(leaveData.hasNewReport)
		end

	end)

end

--是否有新的举报回复
sessionControl.hasNewHackReport = function ()
	
end



--登出后的数据状态重置
sessionControl.logout = function ()
	local data = UserData.getStatusData() or {}
    data.isOut = true
    data.logoutType = LOGOUT_TYPE_USER
    UserData.setStatusData(data)
    
    Record.getInstance():stopTrack()
    Record.releaseInstance()
    UserData.resaveHistoryData()
    
    kefuCommon.deleteSendingItems()

    ViewManager.showStartView(View_Anim_Type.LTOR)
    --ViewManager.deleteAllView()
    NetWorkControl.cancelPollLoginTask()
    --只有已经登录才需要发logout消息

    if data.conversationStatus and 
    	(data.conversationStatus == ConversationStatus_Map.LOGINED 
    	or data.conversationStatus == ConversationStatus_Map.SESSION) then
    	NetWorkControl.sendProtocol("logout", LOGOUT_TYPE_USER)
    end

    NetWorkControl.sendProtocol("disconnect")
    NetWorkControl.destroy()
    UserData.clearAllData()
end




return sessionControl