local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local baseView = require(string.format('%sview/baseView', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
local startView

startView = class('startView', baseView, {
    __init__ = function (self)
    	super(startView,self).__init__(self)

        local label = Label()
        label:set_rich_text("<font color=#000000 size=36>StationId:</font>")
        self.m_root:add(label)
        label:add_rules{
            AL.top:eq(210),
            AL.left:eq(10),
        }

        self.m_edit = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            align_v = Label.MIDDLE,
            text = string.format('<font color=#000000 size=%d>%s</font>',36,""),
            hint_text = string.format('<font color=#9b9b9b size=%d>请输入StationId(如00485)</font>',36),
        }

        self.m_edit:add_rules{
            AL.width:eq(AL.parent('width')-100),
            AL.height:eq(80),
            AL.top:eq(200),
            AL.left:eq(200),
        }

        self.m_root:add(self.m_edit)

    	local str = string.format("<font color=#000000 size=%d>vip聊天</font>", 36)
    	self.m_vipBtn = UI.Button{
            image ={
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnDw)),
            },
                          
            border = false,
            text = str,
        }

        self.m_root:add(self.m_vipBtn)
        self.m_vipBtn:add_rules{
            AL.width:eq(AL.parent('width')-20),
            AL.height:eq(80),
            AL.top:eq(400),
            AL.left:eq(10),
        }

        self.m_vipBtn.on_click = function ()
            local data = UserData.getStatusData() or {}
            data.isOut = false
            data.isVip = true
            data.connectCallbackStatus = false
            UserData.setStatusData(data)
            mqtt_client_config.role = "3"
            mqtt_client_config.stationId = self.m_edit.text~="" and self.m_edit.text or mqtt_client_config.stationId
            NetWorkControl.init()
            --显示界面后再connect
            local view = ViewManager.showVipChatView()
            if view then          
                view:showExceptionTips(DELAY_CONNECT_DEADLINE)
                view:resetBottom()
                view:contentPreUpdate()
            end
            
        end

        str = string.format("<font color=#000000 size=%d>普通用户聊天</font>", 36)
        self.m_customBtn = UI.Button{
            image ={
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnDw)),
            },
                          
            border = false,
            text = str,
        }

        self.m_customBtn.on_click = function ()
            local data = UserData.getStatusData() or {}
            data.isOut = false
            data.isVip = false
            data.connectCallbackStatus = false
            UserData.setStatusData(data)
            mqtt_client_config.role = "2"
            mqtt_client_config.stationId = self.m_edit.text~="" and self.m_edit.text or mqtt_client_config.stationId
            NetWorkControl.init()

            local view = ViewManager.showNormalChatView()
            if view then
                view:showExceptionTips(DELAY_CONNECT_DEADLINE)
                view:resetBottom()
                view:contentPreUpdate()
            end
        end

        self.m_root:add(self.m_customBtn)


        self.m_customBtn:add_rules{
            AL.width:eq(AL.parent('width')-20),
            AL.height:eq(80),
            AL.top:eq(600),
            AL.left:eq(10),
        }

    end,

    setBtnStatus = function (self, enable)
        self.m_customBtn.enabled = enable
        self.m_vipBtn.enabled = enable
    end,

    --需要重载该函数
    onUpdate = function (self, ...)
    	-- body
    end,

})


return startView