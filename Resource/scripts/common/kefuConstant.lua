--设计分辨率
DESIGNWIDTH = 720 
DESIGNHEIGHT = 1280
DESIGNSCALE = 1.0

local function setDesign()
	local sW = System.getScreenWidth()
	local sH = System.getScreenHeight()

	local xScale = sW / DESIGNWIDTH
	local yScale = sH / DESIGNHEIGHT

	--按height计算
	if xScale > yScale then
		if sH - DESIGNHEIGHT > 1000 then
			DESIGNSCALE = 1.25
		elseif sH - DESIGNHEIGHT > 800 then
			DESIGNSCALE = 1.2
		elseif sH - DESIGNHEIGHT > 600 then
			DESIGNSCALE = 1.15
		elseif sH - DESIGNHEIGHT > 400 then
			DESIGNSCALE = 1.1
		elseif sH - DESIGNHEIGHT > 200 then
			DESIGNSCALE = 1.05
		end 
	else  
	--按width计算
		if sW - DESIGNWIDTH > 1000 then
			DESIGNSCALE = 1.25
		elseif sW - DESIGNWIDTH > 800 then
			DESIGNSCALE = 1.2
		elseif sH - DESIGNWIDTH > 600 then
			DESIGNSCALE = 1.15
		elseif sH - DESIGNWIDTH > 400 then
			DESIGNSCALE = 1.1
		elseif sH - DESIGNWIDTH > 200 then
			DESIGNSCALE = 1.05
		end

	end

	System.setLayoutWidth(DESIGNWIDTH * DESIGNSCALE)
	System.setLayoutHeight(DESIGNHEIGHT * DESIGNSCALE)
	System.updateLayout()
	
end

setDesign()

SCREENWIDTH = System.getScreenScaleWidth()
SCREENHEIGHT = System.getScreenScaleHeight()



ConstString = {
	login_failed = "<font color=#665959 bg=#00000000 size=30>当前网络较差，请检查您的网络设置，或联系热线客服：</font><font color=#0000ff bg=#00000000 size=30>400-663-1888</font>",
	waiting_tips = "正在排队中,前面还有%d人，请稍等",
	end_tips_str = "与客服%s的会话已经结束",
	servicer_tips = "客服%s为您解决问题",
	hint_timeout = "温馨提示:由于您已经长时间未响应，为了不影响其他玩家的正常接入，系统将会在2分钟后自动结束服务，若您在游戏中遇到问题，还请您描述。",
	hint_end_session = "温馨提示:非常抱歉，由于您已经长时间未响应。为了不影响其他玩家的正常接入，系统已结束本次服务，若您还有其他问题，可再次联系我们，感谢您对游戏的支持！",
	shift_robot = "当前客服繁忙，转接到机器人为您服务",
	hint_tips_repeat = "您已恢复与客服%s的会话",
	hint_logout_tips = "你已经断开与客服的连接，是否",
	replay_default = "客服人员正在处理中，将在三个工作日内给予答复，如果情况紧急，您可以联系语音客服400-663-1888反馈此问题，或联系在线客服反馈此问题",
}

--时间常量
DELAY_CONNECT_DEADLINE = 8
DELAY_POLL_LOGIN = 60
DELAY_TIMEOUT = 3*60
DELAY_END_SESSION = 5*60


--logout的结束类型,1-用户；2-离线；3-超时；4-客服 
LOGOUT_TYPE_USER = 1
LOGOUT_TYPE_OFFLINE = 2;
LOGOUT_TYPE_TIMEOUT = 3;
LOGOUT_TYPE_KEFU = 4;


INTERVAL_IN_MILLISECONDS = 60*1000

HTMLTB = {
	["&quot"] = [["]],	
}

_DEBUG = true;
ISTEST = true

--每次显示的历史消息条数
PAGE_SIZE = 18


---历史消息文件名
HISTORY_MSG_PATH = "kefu_historymsg"

--语音采样值
SAMPLE_RATE_IN_HZ = 8000

KefuEvent = {
	voice = "kefu_audio_event",
	mqttReceive = "kefu_mqtt_receive",
	connectLost = "kefu_connect_lost",
}

--------------------client 配置信息--------------------------- 
mqtt_client_info = {
["nickName"]		= "Bryan",
["avatarUri"]		= "default",
["vipLevel"]		= "3",
["gameName"]		= "德州扑克",
["accountType"]	= "安卓豌豆荚联运",
["client"]		    = "安卓新浪简体",
["userID"]		    = "12345678",
["deviceType"]	    = "安卓4.0",
["connectivity"]	= "wifi",
["gameVersion"]	= "2.1.1",
["deviceDetail"]	= "MI2S",
["mac"]			= "B0:83:FE:94:58:F3",
["ip"]			    = "135.454.55.22",
["browser"]		= "UC",
["screen"]		    = "1280x720",
["OSVersion"]		= "6.0.1",
["jailbreak"]		= false,
["operator"]		= "1",
}


mqtt_client_config = {
["host"]			= "cs-test.oa.com",
["port"]			= "3333",
["gameId"]		    = "1",
["siteId"]		    = "117",
["role"]			= "2",
["stationId"]		= "00428",
["avatarUri"]		= "default",
["qos"]			= 1,
["cleanSession"]	= true,
["keepalive"]		= 60,
["timeout"]		= 1,
["retain"]		    = false,
["ssl"]			= false,
["sslKey"]		    = "",
["userName"]		= "username",
["userPwd"]		= "123456",
}


--emoji开始的unicode值
EmojiStartIdx = 0x1F201

EmojiName = {
	"一脸懵逼",
	"不开心",
	"亲亲",
	"亲亲2",
	"亲亲3",
	"亲亲4",
	"受伤",
	"可爱",
	"可爱2",
	"吐舌头",
	"吐舌头2",
	"吐舌头3",
	"咧嘴",
	"哦",
	"哦2",
	"哭",
	"哭笑不得",
	"哼",
	"嘻嘻",
	"嘿嘿",
	"困",
	"困2",
	"墨镜",
	"大笑",
	"天使",
	"害怕",
	"小恶魔",
	"开心",
	"开心2",
	"开心3",
	"怒",
	"怒2",
	"怒3",
	"感冒",
	"扮鬼",
	"拍手",
	"无奈",
	"无奈2",
	"无奈3",
	"无奈地笑",
	"无表情",
	"无语",
	"无语2",
	"无语3",
	"无语4",
	"无语5",
	"无语6",
	"晕",
	"晕2",
	"汗",
	"汗2",
	"温馨",
	"爱心脸",
	"白脸",
	"眨眼",
	"翻白眼",
	"肚子疼",
	"胜利",
	"见钱眼开",
	"见鬼了",
	"鄙视脸",
	"难过2",
	"馋",
	"黑脸",
	"鼻涕",
	"拜托",
	"爱心",
	"赞",
	"亲亲猫",
	"侧脸猫",
	"哭笑不得猫",
	"嘿嘿猫",
	"大笑猫",
	"开心猫",
	"惊讶猫",
	"色眯眯猫",
	"鼻涕猫",
	"兔子",
	"小鸡",
	"熊",
	"熊猫",
	"狗",
	"狗2",
	"猪",
	"猫",
	"猴子",
	"老虎",
	"老鼠",
	"青蛙",
	"马",
}

EmojiNum = #EmojiName

EmojiNameToId = {}

for i, v in ipairs(EmojiName) do
	v = string.format("e%s", v)
	EmojiNameToId[v] = EmojiStartIdx + i - 1
end



--------------------- require --------------------
require(string.format('%slibs/json_wrap', KefuRootPath))
require(string.format('%scommon/log', KefuRootPath))
KefuResMap = require(string.format('%sqn_res_alias_map', KefuRootPath))
NetWorkControl = require(string.format('%sconversation/netWorkControl', KefuRootPath))
SessionControl = require(string.format('%sconversation/sessionControl', KefuRootPath))
ViewManager = require(string.format('%sviewManager', KefuRootPath))
Record = require(string.format('%sconversation/record', KefuRootPath))
ChatMessage = require(string.format('%sconversation/chatMessage', KefuRootPath))


