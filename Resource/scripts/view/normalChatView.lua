local baseView = require('view/baseView')
local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local Am = require('animation')
local BottomCp = require('view/bottomComponent')
local class, mixin, super = unpack(require('byui/class'))
local kefuCommon = require("kefuCommon")
local vipChatView = require('view/vipChatView')

local UserData = require("conversation/sessionData")

local normalChatView
normalChatView = class('normalChatView', vipChatView, {
	__init__ = function (self)
		super(normalChatView,self).__init__(self)
		self.m_topBg.background_color = Colorf(0.0, 0.0, 0.0,1.0)
		self.m_title:set_rich_text("<font color=#ffffff bg=#00000000 size=34 weight=3>博雅客服中心</font>")
		self.m_backBtn.text = "<font color=#ffffff bg=#00000000 size=28>返回</font>"
		self.m_backImg.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))

		self.m_backBtn.on_click = function ()

            SessionControl.logout()			
		end

		self.m_bottomCp:setVoiceUnvisible()

	end,

	onBackEvent = function (self)
		SessionControl.logout()
	end,
})

return normalChatView