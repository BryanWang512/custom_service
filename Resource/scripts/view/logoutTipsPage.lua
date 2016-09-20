local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))


local logoutTipsPage
logoutTipsPage = class("logoutTipsPage", nil, {
	__init__ = function (self, root)
		self.m_root = root

		self.m_container = Widget()
		self.m_container.background_color = Colorf(0.3,0.3,0.3,0.6)
		self.m_root:add(self.m_container)
		
		self.m_container:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(AL.parent('height')),
		}

		local topWg = Widget()
		topWg:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq((AL.parent('height')-300)/2),
		}
		self.m_container:add(topWg)
		UI.init_simple_event(topWg, function ()
			self.m_container.visible = false
		end)

		local bWg = Widget()
		bWg:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq((AL.parent('height')-300)/2),
			AL.bottom:eq(AL.parent('height')),
		}
		self.m_container:add(bWg)
		UI.init_simple_event(bWg, function ()
			self.m_container.visible = false
		end)


		self.m_wg = Widget()
		self.m_wg:add_rules{
			AL.width:eq(AL.parent('width')-140),
			AL.height:eq(350),
			AL.top:eq((AL.parent('height')-300)/2),
			AL.left:eq(70),
		}
		self.m_wg.background_color = Colorf(255/255,255/255,255/255, 1.0)
		self.m_container:add(self.m_wg)


		local tips1 = Label()
		self.m_wg:add(tips1)
		tips1:set_rich_text("<font color=#000000 bg=#00000000 size=34>当您退出此界面时</font>")
		tips1:update() 
		tips1:add_rules{
			AL.left:eq((AL.parent('width')-tips1.width)/2),
			AL.top:eq(68),
		}
		--则表示确认结束此次对话
		local tips2 = Label()
		self.m_wg:add(tips2)
		tips2:set_rich_text("<font color=#000000 bg=#00000000 size=34>则表示确认结束此次对话</font>")
		tips2:update() 
		tips2:add_rules{
			AL.left:eq((AL.parent('width')-tips2.width)/2),
			AL.top:eq(112),
		}

		self.m_sureBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatSubmitUnclicked)))
		self.m_sureBg.v_border = {18,18,18,18}
     	self.m_sureBg.t_border = {18,18,18,18}
    	self.m_wg:add(self.m_sureBg)
    	self.m_sureBg:add_rules{
    		AL.width:eq(AL.parent('width')/2-75),
    		AL.height:eq(90),
    		AL.bottom:eq(AL.parent('height')-40),
    		AL.right:eq(AL.parent('width')-50),
    	}

    	self.m_sureBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.3,0.3,0.3,0.4)
            },
           	border = true,
            text = "<font color=#000000 bg=#00000000 size=35>确认</font>",

		}
		self.m_sureBg:add(self.m_sureBtn)
		self.m_sureBtn:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(AL.parent('height')),
		}

		


		self.m_cancelBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)))
		self.m_cancelBg.v_border = {18,18,18,18}
     	self.m_cancelBg.t_border = {18,18,18,18}
     	self.m_wg:add(self.m_cancelBg)

     	self.m_cancelBg:add_rules{
    		AL.width:eq(AL.parent('width')/2-75),
    		AL.height:eq(90),
    		AL.bottom:eq(AL.parent('height')-40),
    		AL.left:eq(50),
    	}

    	self.m_cancelBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.3,0.3,0.3,0.4)
            },
           	border = true,
            text = "<font color=#000000 bg=#00000000 size=35>取消</font>",

		}

		self.m_cancelBg:add(self.m_cancelBtn)
		self.m_cancelBtn:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(AL.parent('height')),
		}

		self.m_cancelBtn.on_click = function ()
			self.m_container.visible = false
		end



	end,

	show = function (self, callback)
		self.m_container.visible = true
		self.m_callback = callback
		self.m_sureBtn.on_click = function ()
			self.m_container.visible = false
			if self.m_callback then
				self.m_callback()
			end
		end
	end,
})


return logoutTipsPage