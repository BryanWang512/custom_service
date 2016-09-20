local dataInstance = {}
local historyDict = nil
local historyData = nil
local historyNum = 0
local data = {}
--标记显示过的历史消息索引
local showId = 0

local viewInfo = {
	"Status",				--状态数据
	"StartView",			--各个界面独有的数据
    "HackAppealView",
    "ChatView",
    "LeaveMessageView",
    "PlayerReportView",	
}


local function initData()
	for i, name in ipairs(viewInfo) do
		local setName = string.format("set%sData", name)
		dataInstance[setName] = function (dt)
			data[name] = dt
		end

		local getName = string.format("get%sData", name)

		dataInstance[getName] = function ()
			return data[name]
		end

		local clearName = string.format("clear%sData", name)
		dataInstance[clearName] = function ()
			 data[name] = nil
		end
	end


end

dataInstance.clearAllData = function ()
	data = {}
	historyData = nil
	historyNum = 0
	showId = 0
	if historyDict then
		delete(historyDict)
		historyDict = nil
	end

end

--当历史消息到达超过某个数量时，清理之,保存最新部分消息.
dataInstance.resaveHistoryData = function ()
	if historyDict and historyData and #historyData > 200 then
		historyDict:delete()
		historyNum = 0
		local num = 100
		for i=1, num do
			historyData[i]:saveToDict()
		end
		historyDict:setInt("msgNum", num)
		historyDict:save()
	end
end

--处理服务器发送过来的历史消息
--先记录在historyData中，之后saveToDict
dataInstance.addHistoryMsg = function (content)

	for i, v in ipairs(content) do
		local tb = ChatMessage(v.seq_id, v.msg_type, v.msg, v.session_id, v.from_client)

		--如果是图片，则msg存储的是部分路径
		if tb.types == 1 then
			tb:faceChar2UnicodeChar()
		elseif tb.types == 2 then
			v.msg = string.gsub(v.msg, [[\]],[[\\]])
			local msgTb = json.decode(v.msg)
			tb.msg = string.gsub(msgTb.localUri, System.getStorageImagePath(), "")

			tb.remoteUrl = msgTb.remoteUrl
		elseif tb.types == 3 then
			--如果是语音，msg保存全路径
			v.msg = string.gsub(v.msg, [[\]],[[\\]])
			local msgTb = json.decode(v.msg)
			tb.msg = msgTb.localUri
			tb.remoteUrl = msgTb.remoteUrl
			tb.voiceLength = msgTb.voiceLength
		end

		--todo:需要考虑图片和语音数据不存在本地的情况
		--这时候需要先拉去全部图片和语音数据后再更新界面

		table.insert(historyData, tb)
		tb:saveToDict()
	end

	historyDict:save()

end

--获取最早的消息时间
dataInstance.getLastMsgSeqId = function ()
	if not next(historyData) then
		return (os.time()-10)*1000
	end

	return historyData[#historyData].seqId
end


local initHistoryDict = function ()
	if not historyDict then
		historyData = historyData or {}
		local path = HISTORY_MSG_PATH..mqtt_client_config.stationId
		historyDict = new(Dict, path)
		historyDict:load()

		historyNum = historyDict:getInt("msgNum", 0)
		if historyNum > 0 then
			for i=1, historyNum do
				local key = string.format("k_%d", i)
				local v = historyDict:getString(key)
				if v ~= "" then
					local tb = json.decode(v)
					local msg = ChatMessage(tb.seqId, tb.types, tb.msg, 1, tb.isClient)
					table.insert(historyData, msg) 
				end
			end
		end

		--按消息时间降序排序
		table.sort(historyData, function (v1, v2)
			if v1.seqId > v2.seqId then
				return true
			end
			return false
		end)
	end
end

--获取本地历史 msg data
-- historyData 维护了历史消息队列(降序排序)，每次用户和客服人员发送的消息都需要插入到historyData 
dataInstance.getHistoryMsgFromDB = function ()
	initHistoryDict()

	if showId >= #historyData then return end 

	local data = {}
	local eIdx = showId+PAGE_SIZE < #historyData and showId+PAGE_SIZE or #historyData
	for i=showId+1, eIdx do
		table.insert(data, historyData[i])
	end

	showId = eIdx


	return data
end

--序列化一条历史消息, msg参数是json字符串, isSave 表示是否调用dict:save
dataInstance.insertHistoryMsg = function (msg, isSave)
	initHistoryDict()
	
	historyNum = historyNum + 1 
	local key = string.format("k_%d", historyNum)
	historyDict:setString(key, msg)
	historyDict:setInt("msgNum", historyNum)
	if isSave then
		historyDict:save()
	end

end

--插入一条最新的消息
dataInstance.insertNewMessage = function (message)
	historyData = historyData or {}
	table.insert(historyData, 1, message)
	--移动显示的消息id, 用于历史记录
	showId = showId + 1
end

--重置历史消息显示的索引
dataInstance.resetHistoryIndex = function ()
	showId = 0
end

--获取消息的时间tips，两条消息时间间隔超过1分钟才获取
dataInstance.getNewMsgTimeTips = function ()
	if not historyData then return nil end

	if #historyData == 1 then
		return historyData[1]:getStringTime()
	end

	if tonumber(historyData[1].seqId) - tonumber(historyData[2].seqId) > INTERVAL_IN_MILLISECONDS then
		return historyData[1]:getStringTime()
	end

	return nil
end

initData()

return dataInstance 
