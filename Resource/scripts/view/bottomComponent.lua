local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require(string.format('%sanimation', KefuRootPath))
local FaceView  = require(string.format('%sview/face/faceView', KefuRootPath))
local AddView = require(string.format('%sview/currency/currency', KefuRootPath))
local VoiceUpPage = require(string.format('%sview/voice/voiceUpPage', KefuRootPath))
local VoiceCancelPage = require(string.format('%sview/voice/voiceCancelPage', KefuRootPath))
local VoiceLeavePage = require(string.format('%sview/voice/voiceLeavePage', KefuRootPath))
local kefuCommon = require(string.format('%skefuCommon', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))

local LongButton
LongButton = class('LongButton', UI.Button, {
    on_touch_up = function(self, p, t)
        if self.upCallBack then
        	self.upCallBack()
        end

        if os.time() - self.m_time < 1 and self.tooSmallCallback then
        	self.tooSmallCallback()
        end

        super(LongButton,self).on_touch_up(self,p,t)
    end,

    on_touch_move = function(self, p, t)

        if self.moveCallback then
        	self.moveCallback(self:point_in(p))
        end

        super(LongButton,self).on_touch_move(self,p,t)
    end,

    on_touch_down = function(self, p, t)

        self.m_time = os.time()
        super(LongButton,self).on_touch_down(self,p,t)

        if self.downCallback then
        	self.downCallback()
        end
    end,

})


local bottomControl
bottomControl = class('bottomControl', nil, {
	__init__ = function (self, root, data, delegate)
		self.m_root = root
		self.m_data = data
		self.m_delegate = delegate
		self.m_scrollView = delegate.m_scrollView

		--记录每次输入的表情字符
		self.m_faceChars = {}
		self.m_topHeight = delegate.m_topHeight
		self.keyboard_height = 0

		self.m_realLineH = 1
		local layoutScale = System.getLayoutScale()
    	if layoutScale < 1 then      
        	self.m_realLineH = 1/layoutScale
    	end


		self:createSelectComponent()
		self:createChatComponent()
		--self.m_selectPage.visible = false
		self.m_chatPage.visible = false

		self:createFacePage()
		self:createTakePhotoPage()
		self:updatePageStatus()
		self.m_delegate:setScrollViewBtnEvent(function ()
			self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint		
			self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
			self.m_showAddPage = false
			self.m_showBehavierPage = false
			self:updatePageStatus()
		end)
	end,

	--创建表形page
	createFacePage = function (self)
		self.m_faceWg = Widget()
		self.m_faceWg.background_color = Colorf(243/255, 243/255, 243/255,1.0)
		self.m_faceWg:add_rules{
			AL.width:eq(AL.parent("width")),
			AL.height:eq(370),
			AL.left:eq(0),
			AL.bottom:eq(AL.parent("height")),
		}

		self.m_root:add(self.m_faceWg)
		local faceView = FaceView(self.m_faceWg)
		self.m_showBehavierPage = false

		local line = Widget()
		line:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_realLineH),
		}
		line.background_color = Colorf(224/255,224/255,224/255,1.0)		
		self.m_faceWg:add(line)

		local str = ""
		faceView:setIconEvent(function (idx)
			
			local r = kefuCommon.unicodeToChar(EmojiStartIdx+idx-1)
			UI.share_keyboard_controller():insert(r)
			table.insert(self.m_faceChars, r)
		end)

		faceView:setDelIconEvent(function ()
			UI.share_keyboard_controller():delete()
		end)

	end,

	--创建拍照和上传图片page
	createTakePhotoPage = function (self)
		self.m_photoWg = Widget()
		self.m_photoWg.background_color = Colorf(243/255, 243/255, 243/255,1.0)
		self.m_photoWg:add_rules{
			AL.width:eq(AL.parent("width")),
			AL.height:eq(180),
			AL.left:eq(0),
			AL.bottom:eq(AL.parent("height")),
		}

		self.m_root:add(self.m_photoWg)
		self.m_showAddPage = false
		AddView(self.m_photoWg)

		local line = Widget()
		line:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_realLineH),
		}
		line.background_color = Colorf(224/255,224/255,224/255,1.0)
		self.m_photoWg:add(line)
	end,

	createChatComponent = function (self)
		self.m_editSHeight = 64
		self.m_pageSHeight = 100

		--聊天输入容器
		self.m_chatPage = Widget()
		self.m_chatPage.background_color = Colorf(0.956, 0.956, 0.956, 1.0)
		self.m_root:add(self.m_chatPage)
		self.m_chatPage:add_rules{
			AL.width:eq(AL.parent('width')),
			--AL.height:eq(100),
			AL.left:eq(0),
		}
		--设置了AL_MASK_TOP, AL.top就不起作用了，需要指定初始化y坐标点
		self.m_chatPage.autolayout_mask = Widget.AL_MASK_TOP
		--设置了height_hint就不能设置AL.height:eq
        self.m_chatPage.height_hint = self.m_pageSHeight

		
		self.m_changeBg = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_change)))
		self.m_chatPage:add(self.m_changeBg)
		self.m_changeBg:add_rules{
			AL.width:eq(44),
			AL.height:eq(48),
			--AL.bottom:eq(AL.parent("height")-20),
		    AL.top:eq(32),
			AL.left:eq(28),
		}

		--转换按钮
		self.m_changeBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,1.0,0.0,0.0),
                down = Colorf(0.6,0.6,0.6,0.3),
            },
           	border = false,
            text = "",
           	radius = 1,
		}
		self.m_chatPage:add(self.m_changeBtn)
		self.m_changeBtn:add_rules{
			AL.width:eq(100),
			AL.height:eq(AL.parent('height')),
			AL.top:eq(0),
			AL.left:eq(0),
		}

		--语音按钮
		self.m_yuyinBtn = UI.Button{
			image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoiceBgUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoiceBgDown)),
            },
           	border = false,
            text = "",
           	radius = 0,
		}

		self.m_yuyinBtn:add_rules{
			AL.width:eq(56),
			AL.height:eq(56),
			AL.top:eq(24),
			--AL.bottom:eq(AL.parent("height")-20),
			AL.left:eq(120),
		}

		self.m_chatPage:add(self.m_yuyinBtn)

		self.m_yuyinBtn.on_click = function ()
			self.m_editText:detach_ime()

			self.m_keyBoardBtn.visible = true
			self.m_voiceBtn.visible = true
			self.m_yuyinBtn.visible = false
			self.m_editText.visible = false
			self.m_behavierBtn.visible = false

			--点击语音按钮需要把表情和add page隐藏，chatPage位置回初始化点
			--m_scrollView高度需要改变
			self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
			self.m_chatPage.y = self.m_scrollView.height+self.m_topHeight
			self.m_showBehavierPage = false
			self.m_showAddPage = false
			self:updatePageStatus()

		end

		--键盘按钮
		self.m_keyBoardBtn = UI.Button{
			image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatKeyboardBgUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatKeyboardBgDw)),
            },
           	border = false,
            text = "",
           	radius = 0,
		}	

		self.m_keyBoardBtn:add_rules{
			AL.width:eq(56),
			AL.height:eq(56),
			AL.top:eq(24),
			--AL.bottom:eq(AL.parent("height")-20),
			AL.left:eq(120),
		}

		self.m_chatPage:add(self.m_keyBoardBtn)

		self.m_keyBoardBtn.on_click = function ()
			self.m_keyBoardBtn.visible = false
			self.m_voiceBtn.visible = false
			self.m_yuyinBtn.visible = true
			self.m_editText.visible = true
			self.m_behavierBtn.visible = true

			
		end

		self.m_keyBoardBtn.visible = false

		--语音按钮
		self.m_voiceBtn = LongButton{
			image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnDw)),
            },
            border = true,
            text = "",
           	radius = 0,
           	v_border = {30,30,30,30},
           	t_border = {30,30,30,30},
		}

		--语音长按按钮
		self.m_voiceBtn:add_rules{
			AL.width:eq(AL.parent("width") - 100-20-56-20-40-56),
			AL.height:eq(72),
			AL.top:eq(15),
			--AL.bottom:eq(AL.parent("height")-13),
			AL.left:eq(120+56+20),
		}

		--按下说话按钮
		self.m_voiceBtn.downCallback = function ()
			if not self.m_voiceUpPage then
				self.m_voiceUpPage = VoiceUpPage(self.m_root)
			end
			self.m_voiceUpPage:show()

			if self.m_voiceCancelPage then
				self.m_voiceCancelPage:hide()
			end

			if self.m_voiceLeavePage then
				self.m_voiceLeavePage:hide()
			end
			local fileName = "audio_"..tostring(Clock.now())..".mp3"; --录制语音文件
			self.m_fullPath = System.getStorageUserPath()..fileName; --录制语音文件全路径
			Record.getInstance():startRecord(self.m_fullPath); --开始录制

		end
		--说话太短
		self.m_voiceBtn.tooSmallCallback = function ()
			Record.getInstance():stopRecord();--录制完毕
			if not self.m_voiceLeavePage then
				self.m_voiceLeavePage = VoiceLeavePage(self.m_root)
			end

			self.m_voiceLeavePage:show()

			if self.m_voiceCancelPage then
				self.m_voiceCancelPage:hide()
			end

			if self.m_voiceUpPage then
				self.m_voiceUpPage:hide()
			end

		end

		--移动回调
		self.m_voiceBtn.moveCallback = function (isIn)
			if isIn then
				if not self.m_voiceUpPage then
					self.m_voiceUpPage = VoiceUpPage(self.m_root)
				end
				self.m_voiceUpPage:show()

				if self.m_voiceCancelPage then
					self.m_voiceCancelPage:hide()
				end

				if self.m_voiceLeavePage then
					self.m_voiceLeavePage:hide()
				end
			else
				if not self.m_voiceCancelPage then
					self.m_voiceCancelPage = VoiceCancelPage(self.m_root)
				end
				self.m_voiceCancelPage:show()

				if self.m_voiceLeavePage then
					self.m_voiceLeavePage:hide()
				end

				if self.m_voiceUpPage then
					self.m_voiceUpPage:hide()
				end

			end
		end

		--松开说话按钮
		self.m_voiceBtn.upCallBack = function ()

			Record.getInstance():stopRecord();--录制完毕
			if self.m_voiceLeavePage then
				self.m_voiceLeavePage:hide()
			end

			if self.m_voiceCancelPage then
				self.m_voiceCancelPage:hide()
			end

			if self.m_voiceUpPage then
				self.m_voiceUpPage:hide()
			end
		end


		--发送语音
		self.m_voiceBtn.on_click = function ()
			Record.getInstance():stopRecord();--录制完毕
			if self.m_voiceCancelPage then
				self.m_voiceCancelPage:hide()
			end

			if self.m_voiceUpPage then
				self.m_voiceUpPage:hide()
			end

			local time = os.time() - self.m_voiceBtn.m_time
			if time > 0 then
			
				local data = UserData.getStatusData() or {}
    			local seqId = tonumber(os.time())*1000
    			local message = ChatMessage(seqId, MessageType_Map.VOICE, self.m_fullPath, data.sessionId or 1, 1)
    			message.time = time
    			SessionControl.dealwithSendMsg(message, self.m_fullPath)
			end
		end


		self.m_chatPage:add(self.m_voiceBtn)

		self.m_voiceTxt = Label()
		self.m_voiceTxt:set_rich_text("<font color=#000000 bg=#00000000 size=30 weight=1>按住 说话</font>")
		self.m_voiceBtn:add(self.m_voiceTxt)
		self.m_voiceTxt.absolute_align = ALIGN.CENTER

		self.m_voiceBtn.visible = false
		
		--输入框
		self.m_editText = UI.MultilineEditBox {
            align_v = Label.MIDDLE,
            border = 1,
          	expect_height = self.m_editSHeight,
          	margin = {10,15,10,5},
        }

        local data = UserData.getStatusData()

        if data.isVip then
	        self.m_editText:add_rules{
	            AL.width:eq(AL.parent("width") - 100-20-56-20-40-56-18-54),
	        	AL.top:eq((self.m_pageSHeight-self.m_editSHeight)/2),
				AL.left:eq(120+56+20),
	        }
	    else
	    	self.m_editText:add_rules{
            	AL.width:eq(AL.parent("width") - 100-20-40-56-18-54),
            	AL.top:eq((self.m_pageSHeight-self.m_editSHeight)/2),
				AL.left:eq(120),
        	}
        	self.m_yuyinBtn.visible = false
	    end

        self.m_editText.height_hint = self.m_editSHeight
        self.m_editText.max_height = 170
        self.m_editText.hint_text = "<font size=30 color=#c3c3c3>请输入您的问题</font>"
        self.m_chatPage:add(self.m_editText)


        --表情按钮
        self.m_behavierBtn = UI.Button{
			image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatBehavierBtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatBehavierBtnDw)),
            },
            border = false,
            text = "",
           	radius = 0,          	
		}

		self.m_behavierBtn.focus = false

		self.m_behavierBtn:add_rules{
			AL.width:eq(54),
			AL.height:eq(54),
			AL.top:eq(24),
			--AL.bottom:eq(AL.parent("height")-21),
			AL.right:eq(AL.parent("width")-20-56-19),
		}
		self.m_chatPage:add(self.m_behavierBtn)

        -- +按钮
        self.m_addBtn = UI.Button{
			image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatAddBtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatAddBtnDw)),
            },
            border = false,
            text = "",
           	radius = 0,          	
		}

		self.m_addBtn.focus = false
		
		self.m_addBtn:add_rules{
			AL.width:eq(56),
			AL.height:eq(56),
			AL.top:eq(23),
			--AL.bottom:eq(AL.parent('height') - 21),
			AL.right:eq(AL.parent("width")-20),
		}

		self.m_chatPage:add(self.m_addBtn)

		--发送文字按钮
		self.m_sendBtn = UI.Button{
            image ={

                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatSendBtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatSendBtnDw)),
            },
                          
            border = false,
            text = "<font color=#ffffff size=26 weight=2>发送</font>",
            radius = 0,
        }

        self.m_sendBtn.focus = false

        self.m_sendBtn:add_rules{
        	AL.width:eq(65),
			AL.height:eq(60),
			AL.top:eq(21),
			--AL.bottom:eq(AL.parent('height') - 19),
			AL.right:eq(AL.parent("width")-17),
    	}
    	self.m_sendBtn.visible = false
    	self.m_chatPage:add(self.m_sendBtn)

    	--发送文本消息入口
    	self.m_sendBtn.on_click = function ()
    		local data = UserData.getStatusData()

    		--os.time是秒级,seqId是毫秒级
    		local seqId = tostring(tonumber(os.time())*1000)
    		local message = ChatMessage(seqId, MessageType_Map.TXT, self.m_editText.text, data.sessionId or 1, 1)
    		message.faceChars = self.m_faceChars
    		--处理消息的发送，存储在本地
    		SessionControl.dealwithSendMsg(message)

    		self.m_faceChars = {}
    		--界面展示
    		self.m_sendBtn.visible = false
    		self.m_editText:reset_text()
    	end


		-------------线
		self.m_topLine = Widget()
		self.m_topLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
		self.m_chatPage:add(self.m_topLine)
		self.m_topLine:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_realLineH),
			AL.top:eq(0),
			AL.left:eq(0),

		}
		self.m_leftLine = Widget()
		self.m_leftLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
		self.m_chatPage:add(self.m_leftLine)
		self.m_leftLine:add_rules{
			AL.width:eq(self.m_realLineH),
			AL.height:eq(AL.parent('height')),
			AL.top:eq(0),
			AL.left:eq(100),
		}

		--动画效果
		--需要考虑键盘打开的时候
		--需要考虑m_chatPage和scrollview大小变化
		self.m_changeBtn.focus = false
		self.m_changeBtn.on_click = function ()
			--记下selectPage的初始化y坐标
			self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP
			
			--关闭键盘
			self.m_editText:detach_ime()

			--改变状态
			self.m_showAddPage = false
			self.m_showBehavierPage = false
			self:updatePageStatus()

			self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_selectPage.height
			self.m_chatPage.y = self.m_root.height - self.m_chatPage.height_hint
			local ac = Am.value(self.m_chatPage.y, self.m_chatPage.y+self.m_chatPage.height_hint)
			local anim = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, ac)), function (v)
				self.m_chatPage.y = v
            end)
            anim:start()

            anim.on_stop = function ()
            	Clock.instance():schedule_once(function()
	            	self.m_chatPage.visible = false
	            	self.m_selectPage.visible = true

	            	local oc = Am.value(self.m_root.height , self.m_root.height - self.m_selectPage.height)
	            	local animOther = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, oc)), function (v)
						self.m_selectPage.y = v
	            	end)
	            	animOther:start()
            	end)
        	end

		end


		self.m_addBtn.on_click = function ()
			
			if not self.m_showAddPage then
				--记下selectPage的初始化y坐标
				self.m_delegate:removeBottomSpaceWg()
				self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP

				--如果这时打开了表情page，则需要隐藏该page，并且还原位置
				self.m_showBehavierPage = false		
				self.m_showAddPage = true

				--m_scrollView变小
				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint - self.m_photoWg.height
				
				local data = UserData.getStatusData()
				--还需要改变其他ui状态
				self.m_editText.visible = true
				if data.isVip then					
					self.m_yuyinBtn.visible = true
				end

				self.m_behavierBtn.visible = true
				self.m_keyBoardBtn.visible = false
				self.m_voiceBtn.visible = false

				Clock.instance():schedule_once(function ()
					Clock.instance():schedule_once(function ()	                
	                	self.m_scrollView:scroll_to_bottom(0.25)
	                end)
	            end)


			else
				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
				self.m_showAddPage = false
			end
			self.m_editText:detach_ime()
			self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
			self:updatePageStatus()
		end

		self.m_behavierBtn.on_click = function ()
			
			if not self.m_showBehavierPage then
				self.m_delegate:removeBottomSpaceWg()
				--记下selectPage的y坐标
				self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP

				--显示facePage
				self.m_showBehavierPage = true
				self.m_showAddPage = false
				
				--m_scrollView变小
				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_faceWg.height - self.m_chatPage.height_hint

				Clock.instance():schedule_once(function ()	                
                	self.m_scrollView:scroll_to_bottom(0.25)
                end)

				
			else
				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
				self.m_showBehavierPage = false

			end

			--移动m_chatPage
			self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
			self:updatePageStatus()
			--关闭软键盘
			self.m_editText:detach_ime()
			self.m_editText:registered_keyboard()

		end

		self.m_editText.on_content_size_change  = function ()
			--根据self.m_editText高度改变m_chatPage高度
            self.m_chatPage.height_hint = self.m_editText.height_hint+(100-self.m_editSHeight)
            self.m_chatPage:update_constraints()

            --m_scrollView高度计算方法
           
            if self.m_showAddPage then
            	self.m_scrollView.height = self.m_root.height - self.m_photoWg.height - self.m_chatPage.height_hint - self.m_topHeight
            elseif self.m_showBehavierPage then
            	self.m_scrollView.height = self.m_root.height - self.m_faceWg.height - self.m_chatPage.height_hint - self.m_topHeight            	
            else
            	self.m_scrollView.height = self.m_root.height - self.keyboard_height- self.m_chatPage.height_hint - self.m_topHeight
            end

            --m_chatPage的y坐标计算方法
            self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight



            Clock.instance():schedule_once(function ()
            	self.m_scrollView:scroll_to_bottom(0.0)            	
            end)

        end


        self.m_editText.on_keyboard_show = function (args)
        	--防止空白wg把聊天内容顶掉
        	self.m_delegate:removeBottomSpaceWg()
            local real_pos = Window.instance().drawing_root:from_world(Point(args.x,args.y))
            local x = real_pos.x
            local y = real_pos.y
            self.keyboard_height  = Window.instance().drawing_root.height - y
            self.m_scrollView.height = self.m_root.height - self.keyboard_height - self.m_chatPage.height_hint - self.m_topHeight   
           	self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
           	self.m_showBehavierPage = false
           	self.m_showAddPage = false
           	self:updatePageStatus()
            Clock.instance():schedule_once(function ()
                Clock.instance():schedule_once(function ()
                    self.m_scrollView:scroll_to_bottom(0.25)
                end)
            end)
        end
        
        self.m_editText.on_keyboard_hide = function (args)
            self.keyboard_height = 0

            --当表情和add page都没有显示时
            if not self.m_showBehavierPage and not self.m_showAddPage then
            	self.m_scrollView.height = self.m_root.height - self.keyboard_height- self.m_chatPage.height_hint - self.m_topHeight  
            	self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight            	
            end

            Clock.instance():schedule_once(function (  )
                Clock.instance():schedule_once(function (  )
                    self.m_scrollView:scroll_to_bottom(0.25)
                end)
            end)
        end


        self.m_editText.on_text_changed = function ()
            if self.m_editText.text == "" then
                self.m_sendBtn.visible = false
                self.m_faceChars = {}
            else
                self.m_sendBtn.visible = true
            end
        end

	end,

	createSelectComponent = function (self)
---------------------选择容器-----------------
		self.m_selectPage = Widget()
		self.m_selectPage.background_color = Colorf(0.956, 0.956, 0.956, 1.0)
		self.m_root:add(self.m_selectPage)
		self.m_selectPage:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(100),
			AL.bottom:eq(AL.parent('height')),
			AL.left:eq(0),
		}


		self.m_keyboardBg = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatKeyboardChange)))
		self.m_selectPage:add(self.m_keyboardBg)
		self.m_keyboardBg:add_rules{
			AL.width:eq(44),
			AL.height:eq(48),
			AL.top:eq(20),
			AL.left:eq(28),
		}

		--转换按钮
		self.m_keyboarChangeBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,1.0,0.0,0.0),
                down = Colorf(0.6,0.6,0.6,0.3),
            },
           	border = false,
            text = "",
           	radius = 1,
		}
		self.m_selectPage:add(self.m_keyboarChangeBtn)
		self.m_keyboarChangeBtn:add_rules{
			AL.width:eq(100),
			AL.height:eq(AL.parent('height')),
			AL.top:eq(0),
			AL.left:eq(0),
		}


		local num = #self.m_data
		self.m_selectItem = {}
		local space = (SCREENWIDTH-100)/num

		for i=1, num do
			self.m_selectItem[i] = UI.Button{
				image =
	            {
	                normal = Colorf(1.0,1.0,0.0,0.0),
	                down = Colorf(0.4,0.4,0.4,0.3),
	            },
	           	border = false,
	            text = string.format("<font color=#646464 bg=#00000000 size=30>%s</font>", self.m_data[i]),
	           	radius = 1,
			}
			
			
			self.m_selectItem[i]:add_rules{
				AL.width:eq(space-1),
				AL.height:eq(AL.parent('height')),
				AL.top:eq(0),
				AL.left:eq(100+space*(i-1)+1),
			}
			self.m_selectPage:add(self.m_selectItem[i])

			self.m_selectItem[i].on_click = function()
				if self.m_data[i] == "盗号申请" then
					Record.getInstance():stopTrack() 
	            	ViewManager.showPlayerReportView()
	            elseif self.m_data[i] == "玩家举报" then
	            	Record.getInstance():stopTrack()
	            	ViewManager.showHackAppealView()
	            elseif self.m_data[i] == "留言回复" then
	            	Record.getInstance():stopTrack()
	            	ViewManager.showLeaveMessageView()
	            end 
	        end
			
		end


		-------------线
		for i=1, num do
			local line = Widget()
			line.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
			self.m_selectPage:add(line)
			line:add_rules{
				AL.width:eq(self.m_realLineH),
				AL.height:eq(AL.parent('height')),
				AL.top:eq(0),
				AL.left:eq(100+space*(i-1)),

			}
			
		end


		local topLine = Widget()
		topLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
		self.m_selectPage:add(topLine)
		topLine:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_realLineH),
			AL.top:eq(0),
			AL.left:eq(0),

		}

		self.m_keyboarChangeBtn.on_click = function ()
			self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP
	
			local ac = Am.value(self.m_root.height - self.m_selectPage.height, self.m_root.height)
			local anim = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, ac)), function (v)
				self.m_selectPage.y = v
            end)
            anim:start()

            anim.on_stop = function ()
            	Clock.instance():schedule_once(function()
	            	self.m_chatPage.visible = true
	            	self.m_selectPage.visible = false

	            	local oc = Am.value(self.m_root.height, self.m_root.height - self.m_chatPage.height_hint)
	            	local animOther = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, oc)), function (v)
						self.m_chatPage.y = v
	            	end)
	            	animOther:start()
	            end)
        	end

		end

	end,

	--更新表情和照相page状态
	updatePageStatus = function (self)
		self.m_faceWg.visible = self.m_showBehavierPage
		self.m_photoWg.visible = self.m_showAddPage

		if self.m_showAddPage or self.m_showBehavierPage then
			self.m_delegate.m_scrollBtn.visible = true
		else
			self.m_delegate.m_scrollBtn.visible = false
		end 
	end,

	reset = function (self)
		self.m_scrollView.height = self.m_root.height - self.m_selectPage.height - self.m_topHeight  
        self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
        self.m_showAddPage = false
        self.m_showBehavierPage = false
        self:updatePageStatus()
        self.m_editText.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
       
	end,

	onResume = function (self)
		self.m_scrollView.height = self.m_root.height - self.m_selectPage.height - self.m_topHeight  
        self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
        self.m_showAddPage = false
        self.m_showBehavierPage = false
        self:updatePageStatus()
	end,

})


return bottomControl