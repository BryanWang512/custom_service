local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require(string.format('%sanimation', KefuRootPath))
local baseView = require(string.format('%sview/baseView', KefuRootPath))
local kefuCommon = require(string.format('%skefuCommon', KefuRootPath))
local vipChatView = require(string.format('%sview/vipChatView', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
local LogOutPage = require(string.format('%sview/logoutTipsPage', KefuRootPath))

local normalChatView
normalChatView = class('normalChatView', vipChatView, {
	__init__ = function (self)
		super(normalChatView,self).__init__(self)
		self.m_topBg.background_color = Colorf(0.0, 0.0, 0.0,1.0)
		self.m_title:set_rich_text("<font color=#ffffff bg=#00000000 size=34 weight=3>博雅客服中心</font>")
		self.m_backBtn.text = "<font color=#ffffff bg=#00000000 size=28>返回</font>"
		self.m_backImg.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))

		self.m_backBtn.on_click = function ()
			self:onBackEvent()		
		end

	end,

	onBackEvent = function (self)
		--人工服务需要评分
		if SessionControl.isHumanService() then
			if self.m_evalutePage and self.m_evalutePage:isVisible() then           
	            --表示已经处在评论界面，这时再点击按钮就直接退出了
	            self:hideEvalutePage()
	            SessionControl.logout()
	        else
	            if not self.m_logOutTips then
	                self.m_logOutTips = LogOutPage(self.m_root)
	            end
	            self.m_logOutTips:show(function ()
	                if SessionControl.isShouldGrade() then
	                    self:showEvalutePage(function ()
	                        self:hideEvalutePage()
	                        SessionControl.logout()
	                    end)
	                else
	                    SessionControl.logout()
	                end
	                
	            end)
	        end
		else
			SessionControl.logout()
		end
	end,
})

return normalChatView