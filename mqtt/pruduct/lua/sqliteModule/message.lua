Message = class();

Message.ctor = function (self, tab)
    if tab ~= nil and type(tab) == "table" then
        for k, v in pairs(tab) do
            self[k] = v;
        end
    end
end

Message.dtor = function (self)
    
end

Message.TABLE               = "\"MESSAGE\"";
Message.ID                  = "\"_id\"";-- 0: id
Message.TEXT_MESSAGE_BODY   = "\"TEXT_MESSAGE_BODY\"";-- 1: textMessageBody
Message.TYPE                = "\"TYPE\"";-- 2: type
Message.DIRECT              = "\"DIRECT\"";-- 3: direct
Message.STATUS              = "\"STATUS\"";-- 4: status
Message.MSG_TIME            = "\"MSG_TIME\"";-- 5: msgTime
Message.VOICE_LENGTH        = "\"VOICE_LENGTH\"";-- 6: voiceLength
Message.URI                 = "\"URI\"";-- 7: uri
Message.FROM                = "\"FROM\"";-- 8: from
Message.TO                  = "\"TO\"";-- 9: to

property(Message,"_id","Id",true,true);--number
property(Message,"TEXT_MESSAGE_BODY","TextMessageBody",true,true);--string
property(Message,"TYPE","Type",true,true);--number
property(Message,"DIRECT","Direct",true,true);--number
property(Message,"STATUS","Status",true,true);--number
property(Message,"MSG_TIME","MsgTime",true,true);--number
property(Message,"VOICE_LENGTH","VoiceLength",true,true);--number
property(Message,"URI","Uri",true,true);--string
property(Message,"FROM","From",true,true);--string not null
property(Message,"TO","To",true,true);--string not null


Message.TestData = 
{
    ["TEXT_MESSAGE_BODY"] = "1231231231dfsgfgdfdh";
    ["TYPE"]            = 1;
    ["DIRECT"]          = 1;
    ["STATUS"]          = 0;
    ["MSG_TIME"]         = 11;
    ["VOICE_LENGTH"]     = 12552;
    ["URI"]             = "http:\\sdsfjsdjfjs;dfsdlfjsdj";
    ["FROM"]            = "f";
    ["TO"]              = "t";
}