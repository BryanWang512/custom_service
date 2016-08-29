local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local Am = require('animation')
local class, mixin, super = unpack(require('byui/class'))
local UserData = require("conversation/sessionData")


local MyCheckBox = class('MyCheckBox', UI.ToggleButton, {
	on_touch_up = function(self, p, t)
      
        if self:point_in(p) then
            self.checked = true
            if self.callback then
            	self.callback()
            end
        end

    end,

})

local evalutePage
evalutePage = class('evalutePage', nil, {
	__init__ = function (self, root, callBack)
		self.m_root = root

		self.m_callback = callBack
		self.m_container = Widget()
		self.m_container.background_color = Colorf(1.0, 1.0, 1.0, 1.0)
		self.m_height = 530
		self.m_root:add(self.m_container)
		self.m_container:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_height),
			AL.left:eq(0),
		}

		self.m_container.y = self.m_root.height
		self.m_container.visible = false

		self.m_topCn = Widget()
		self.m_container:add(self.m_topCn)
		self.m_topCn:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(90),
		}
		self.m_topCn.background_color = Colorf(230/255,230/255,230/255, 1.0)
		local title = Label()
		title.absolute_align = ALIGN.CENTER
		title:set_rich_text("<font color=#000000 bg=#00000000 size=34>满意度评价</font>")
		self.m_topCn:add(title)

-----------响应速度
		local bw, bh = 44*1.1, 36*1.1
		local startY = 128
		local space = 38
		self.m_speedWg = Widget()
		self.m_speedWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY),
			AL.left:eq(50),
		}
		self.m_container:add(self.m_speedWg)

		local txtSpeed = Label()
		self.m_speedWg:add(txtSpeed)
		txtSpeed.absolute_align = ALIGN.LEFT
		txtSpeed:set_rich_text("<font color=#000000 bg=#00000000 size=34>客服响应速度</font>")
		txtSpeed:update()


		self.m_speedBoxs = {}
		for i=1, 5 do
			self.m_speedBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_speedWg:add(self.m_speedBoxs[i])
	        self.m_speedBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-txtSpeed.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}
	    	self.m_speedBoxs[i]:set_pick_ext(5,10,5,10)
		
		end
		self.m_speedGrade = 0
		for i=1, 5 do
			self.m_speedBoxs[i].callback = function ()
				self.m_speedGrade = i
				for j=i+1, 5 do
	    			self.m_speedBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_speedBoxs[n].checked = false
	    		end
			end
			
		end


----------------服务态度
		self.m_serviceWg = Widget()
		self.m_serviceWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY+bh+space),
			AL.left:eq(50),
		}

		self.m_container:add(self.m_serviceWg)

		local txtService = Label()
		self.m_serviceWg:add(txtService)
		txtService.absolute_align = ALIGN.LEFT
		txtService:set_rich_text("<font color=#000000 bg=#00000000 size=34>客服服务态度</font>")
		txtService:update()

		self.m_serviceBoxs = {}

		for i=1, 5 do
			self.m_serviceBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_serviceWg:add(self.m_serviceBoxs[i])
	        self.m_serviceBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-txtService.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}

	    	self.m_serviceBoxs[i]:set_pick_ext(5,10,5,10)
			
		end

		self.m_serviceGrade = 0
		for i=1, 5 do
			self.m_serviceBoxs[i].callback = function ()
				self.m_serviceGrade = i
				for j=i+1, 5 do
	    			self.m_serviceBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_serviceBoxs[n].checked = false
	    		end
			end
			
		end


-------------体验
		self.m_experienceWg = Widget()
		self.m_experienceWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY+(bh+space)*2),
			AL.left:eq(50),
		}

		self.m_container:add(self.m_experienceWg)

		local txtExperience = Label()
		self.m_experienceWg:add(txtExperience)
		txtExperience.absolute_align = ALIGN.LEFT
		txtExperience:set_rich_text("<font color=#000000 bg=#00000000 size=34>客服服务态度</font>")
		txtExperience:update()
		self.m_experienceBoxs = {}

		for i=1, 5 do
			self.m_experienceBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_experienceWg:add(self.m_experienceBoxs[i])
	        self.m_experienceBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-txtService.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}

	    	self.m_experienceBoxs[i]:set_pick_ext(5,10,5,10)
			
		end

		self.m_experienceGrade = 0
		for i=1, 5 do
			self.m_experienceBoxs[i].callback = function ()
				self.m_experienceGrade = i
				for j=i+1, 5 do
	    			self.m_experienceBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_experienceBoxs[n].checked = false
	    		end
			end
			
		end


---------------------
		--提示文字
		local txtWg = Widget()
		self.m_container:add(txtWg)
		txtWg:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(30),
			AL.left:eq(0),
			AL.bottom:eq(AL.parent('height')-150),
		}

		local txt = Label()
		txtWg:add(txt)
		txt:set_rich_text("<font color=#9B9B9B bg=#00000000 size=25>您的评价对于改善我们的服务有重大意思</font>")
		txt.absolute_align = ALIGN.CENTER


		self.m_submitBtn = UI.Button{
            image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatSendBtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatSendBtnDw)),
            },
            border = true,
            text = "<font color=#FEFEFE bg=#00000000 size=40>提交</font>",

        }

        self.m_submitBtn:add_rules{
        	AL.width:eq(AL.parent('width')-60),
        	AL.height:eq(100),
        	AL.left:eq(30),
        	AL.bottom:eq(AL.parent('height')-30),
    	}
    	self.m_container:add(self.m_submitBtn)

    	self.m_submitBtn.on_click = function ()

    		
    		local data = UserData.getStatusData() 
    		local tb = {}
    		tb.gid = mqtt_client_config.gameId
    		tb.site_id = mqtt_client_config.siteId
    		tb.client_id = mqtt_client_config.stationId
    		tb.session_id = tostring(data.sessionId)
    		tb.service_fid = SessionControl.getCurrentServiceFid()

    		tb.respond_rating = self.m_speedGrade
    		tb.attitude_rating = self.m_serviceGrade
    		tb.experience_rating = self.m_experienceGrade

    		local str = json.encode(tb)
    		netWorkControl.postString(HTTP_SUBMIT_RATING_URI, str, function (rsp)
    			local content = rsp.content
    			local contentTb = json.decode(content)
    			print_string("postString: "..content)

    		end)
    		self:hide()

    		if self.m_callback then
    			self.m_callback()
    		end

    	end

	end,

	update = function (self, callback)
		self.m_callback = callback
		self.m_speedGrade = 5
		self.m_serviceGrade = 5
		self.m_experienceGrade = 5

		for i=1, 5 do
			self.m_experienceBoxs[i].checked = true
			self.m_speedBoxs[i].checked = true
			self.m_serviceBoxs[i].checked = true
		end

	end,

	show = function (self)
		self.m_container.visible = true
		local ac = Am.value(self.m_root.height, self.m_root.height - self.m_height)

        Am.Animator(Am.timing(Am.linear, Am.duration(0.2,ac)), function (v)
            self.m_container.y = v
        end):start()

	end,

	hide = function (self)
        self.m_container.y = self.m_root.height
        self.m_container.visible = false
	end,

	isVisible = function (self)
		return self.m_container.visible
	end,

})


return evalutePage