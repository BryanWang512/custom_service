require("sqliteModule/message");

MessageUtil = {}

MessageUtil.DBMessage2MqttMessage = function (message)
    
end

MessageUtil.DBMessageList2MqttMessageList = function (messageList)
    local list = {};
    for _, message in ipairs(messageList) do
        table.insert(list, MessageUtil.DBMessage2MqttMessage(message));
    end
    return list;
end

MessageUtil.MqttMessage2DBMessage = function (mqttMessage)
-- MqttMessage待封装
    local message = new(Message);
	if mqttMessage:getDBId() ~= 0 then
		message:setId(mqttMessage:getDBId());
	end
	message:setDirect(mqttMessage:getDirect()); -- 枚举
	message:setMsgTime(mqttMessage:getMsgTime());
	message:setStatus(mqttMessage:getStatus());-- 枚举
	message:setTextMessageBody(mqttMessage:getTextMessageBody());
	message:setType(mqttMessage:getType());-- 枚举
	message:setUri(mqttMessage:getSourceUri() == nil  and "" or mqttMessage:getSourceUri());
	message:setVoiceLength(mqttMessage:getVoiceLength());
	message:setFrom("");-- 后续补充
	message:setTo("");-- 后续补充
	return message;
end

MessageUtil.MqttMessageList2DBMessageList = function (messageList)
    local list = {};
    for _, message in ipairs(messageList) do
        table.insert(list, MessageUtil.MqttMessage2DBMessage(message));
    end
    return list;
end