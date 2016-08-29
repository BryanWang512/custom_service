local baseView = require('view/baseView')
local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local Am = require('animation')
local BottomCp = require('view/bottomComponent')
local class, mixin, super = unpack(require('byui/class'))
local kefuCommon = require("kefuCommon")
local EPage = require("view/evaluatePage")
local LogOutPage = require("view/logoutTipsPage")
local UserData = require("conversation/sessionData")
require("libs/json_wrap");


local MyScrollView
MyScrollView = class('MyScrollView', UI.ScrollView, {
    on_touch_up = function(self, p, t)
        self.m_touchUp = true
        super(MyScrollView,self).on_touch_up(self,p,t)
    end,

    on_touch_down = function(self, p, t)
        self.m_touchUp = false
        self.m_autoMove = false
        super(MyScrollView,self).on_touch_down(self,p,t)
    end,

    on_touch_cancel = function(self, p, t)
        self.m_touchUp = true
        self.m_autoMove = true
        super(MyScrollView,self).on_touch_cancel(self,p,t)
    end,

})


local vipChatView
vipChatView = class('vipChatView', baseView, {
	__init__ = function (self)
		super(vipChatView,self).__init__(self)

        EventDispatcher.getInstance():register(Event.Resume, self, self.onResume)
        self.m_root.background_color = Colorf(242/255, 240/255, 235/255,1.0)
		self.m_topBg = Widget()
		self.m_topBg.background_color = Colorf(58/255, 48/255, 78/255,1.0)
		self.m_root:add(self.m_topBg)
		self.m_topHeight = 100
		local topHeight = self.m_topHeight
	
		self.m_topBg:add_rules {
			AL.width:eq(AL.parent('width')),
			AL.height:eq(topHeight),
			AL.top:eq(0),
			AL.left:eq(0),
		}

		self.m_title = Label()
		self.m_title:set_rich_text("<font color=#F4C392 bg=#00000000 size=34 weight=3>博雅在线客服</font>")
		self.m_topBg:add(self.m_title)

		self.m_title.absolute_align = ALIGN.CENTER



		self.m_backBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.6)
            },
           	border = true,
            text = "<font color=#F4C392 bg=#00000000 size=28>返回</font>",

		}
		self.m_backBtn:add_rules{
			AL.width:eq(160),
			AL.height:eq(AL.parent('height')),
			AL.top:eq(0),
			AL.left:eq(0),
		}
		self.m_topBg:add(self.m_backBtn)

		self.m_backBtn.on_click = function ()
            self:onBackEvent()  
		end

		self.m_backImg = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip)))
		self.m_backImg.color = Colorf(1.0,0.0,0.0,1.0),
		self.m_backBtn:add(self.m_backImg)
		self.m_backImg:add_rules{
			AL.width:eq(24),
			AL.height:eq(42),
			AL.top:eq(26),
			AL.left:eq(17),
		}

		self.m_scrollView = MyScrollView{
            dimension = kVertical,
        }
        --focus = true表示点击会关闭键盘, false表示不关闭键盘
        self.m_scrollView.focus = true  
        self.m_scrollView.viscosity = 0.05           --阻尼系数
        self.m_scrollView.velocity_factor = 3        --速度系数

        --高度需要动态改变
        self.m_scrollView:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.top:eq(topHeight),
            AL.left:eq(0),
        }

        self.m_scrollView.autolayout_mask = Widget.AL_MASK_HEIGHT
        self.m_scrollView.background_color = Colorf(242/255, 240/255, 235/255,1.0)

        self.m_spaceH = 0

        self.m_content = Layout.FloatLayout{
            spacing = Point(0,self.m_spaceH),
        }

        self.m_content:add_rules(AL.rules.fill_parent)
        self.m_realHeight = 0

        self.m_content.background_color = Colorf(242/255, 240/255, 235/255,1.0)
        self.m_content.relative = true
        self.m_scrollView.content = self.m_content
        self.m_root:add(self.m_scrollView)
        self.m_scrollView.shows_vertical_scroll_indicator = true
        

        self:createUpdateIcon()
        self:createScrollViewBtn()
		self.m_bottomCp = BottomCp(self.m_root, {"玩家举报","留言回复"}, self)
        self.m_updateItem = KefuCommon.createUpdateIcon()

	end,

    --从后台切换到前台回调
    onResume = function (self)
        self.m_bottomCp:onResume()
    end,

    showEvalutePage = function (self, callbcak)
        if not self.m_evalutePage then
            self.m_evalutePage = EPage(self.m_root)
        end

        self.m_scrollView.enabled = false
        self.m_evalutePage:update(callbcak)
        self.m_evalutePage:show()
    end,

    hideEvalutePage = function (self)
        if not self.m_evalutePage then
            self.m_evalutePage = EPage(self.m_root)
        end

        self.m_scrollView.enabled = true
        self.m_evalutePage:hide()
    end,

    createUpdateIcon = function (self)
        self.m_iconContain = Widget()
        self.m_iconContain.background_color = Colorf(242/255, 240/255, 235/255,1.0)
        self.m_iconContain:add_rules{
            AL.width:eq(AL.parent("width")),
            AL.height:eq(60),
            AL.left:eq(0),
        }

        self.m_iconContain.autolayout_mask = Widget.AL_MASK_TOP
        
        self.m_iconContain.x = 0
 
        self.m_scrollView:add(self.m_iconContain)
        self.m_iconContain.zorder = -1

        self.m_hintTxt = Label()
        self.m_iconContain:add(self.m_hintTxt)
        self.m_hintTxt.absolute_align = ALIGN.CENTER
        self.m_hintTxt:set_rich_text("<font color=#C3C3C3 bg=#00000000 size=24>下拉查看历史消息</font>")
        self.m_hintTxt:update()

        self.m_hintIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatHintIcon)))
        self.m_hintIcon:add_rules{
            AL.width:eq(18),
            AL.height:eq(10),
            AL.top:eq(25),


        }
        self.m_iconContain:add(self.m_hintIcon)
        self.m_hintIcon.anchor = Point(0.5,0.5)

        self:scroll2Update()
    end,

    --下拉刷新
    scroll2Update = function (self)
        local startY = -60
        self.m_iconContain.y = startY

        local updateDis = 65
        local status = true
        local autoMove = nil
        self.m_scrollView.on_overscroll = function(iself, overscroll)
            --说明是松手后的惯性移动
            if self.m_scrollView.m_touchUp and overscroll.y <= 0 then
                self.m_scrollView.m_autoMove = true
            end

            if overscroll.y <= 0 then
                self.m_iconContain.visible = false
                if self.m_Updating then
                    self.m_Updating = nil
                    self.m_content:add(self.m_updateItem, self.m_topSpaceWg)                    
                    Clock.instance():schedule_once(function()
                        self:addHistoryMsg(self.m_data)                           
                    end, 0.1)
                elseif self.m_networkUpdating and not self.m_isloading then
                    self.m_networkUpdating = nil
                    self.m_isloading = true
                    self.m_content:add(self.m_updateItem, self.m_topSpaceWg)

                    local seqId = UserData.getLastMsgSeqId()
                    NetWorkControl.loadHistoryMsgFromNetwork(seqId, function (rsp)
                        --获取失败了
                        if rsp.errmsg or rsp.code ~= 200 then
                            self.m_content:remove(self.m_updateItem)
                            return 
                        end

                        local content = rsp.content
                        local contentTb = json.decode(content)
                        --获取成功
                        --按时间降序排序
                        if contentTb.code == 0 and contentTb.data then
                            self.m_scrollView.enabled = false

                            table.sort(contentTb.data, function (v1, v2)
                                if v1.clock > v2.clock then
                                    return true
                                end
                                return false
                            end)

                            UserData.addHistoryMsg(contentTb.data)
                            local historyData = UserData.getHistoryMsgFromDB()
                            self:addHistoryMsg(historyData)
                        elseif contentTb.code == 2 or not contentTb.data then     --服务端已经没有消息
                            self.m_hasNoMessage = true
                            self.m_content:remove(self.m_updateItem)
                        end

                        self.m_isloading = nil
                    end)

                end
            elseif overscroll.y > 0 then  --当移动超过顶端时
                if not self.m_scrollView.m_autoMove then
                    self.m_iconContain.visible = true
                    self.m_iconContain.y = startY + overscroll.y
                else
                    --如果是惯性移动，则停止运动，不会刷新历史消息
                    self.m_scrollView:scroll_to_top(0.0)
                    self.m_scrollView.m_autoMove = false
                    return
                end
            end

            --需要改为:释放刷新
            if overscroll.y >= updateDis then
                if status then
                    status = false
                    self.m_hintTxt:set_rich_text("<font color=#C3C3C3 bg=#00000000 size=24>释放刷新</font>")
                    self.m_hintTxt:update()
                    self.m_hintIcon.rotation = -180                                  
                end

                --表示可以刷新了
                if self.m_scrollView.m_touchUp then
                    --请求历史消息
                    if self.m_hasNoMessage then return end
                    local historyData = UserData.getHistoryMsgFromDB()

                    self.m_scrollView.m_touchUp = false
                    self.m_iconContain.visible = false

                    --本地有数据
                    if historyData then
                        --self.m_Updating = true
                        self.m_data = historyData
                        self.m_scrollView.enabled = false
                        print_string("==========本地有数据========")
                        Clock.instance():schedule_once(function()
                            self.m_content:add(self.m_updateItem, self.m_topSpaceWg)
                            Clock.instance():schedule_once(function()                    
                                self:addHistoryMsg(self.m_data)
                            end, 0.1)                           
                        end, 0.1)


                    else
                        print_string("==========网络请求数据========")
                        self.m_networkUpdating = true
                        
                    end

                end
            else
                if not status then
                    status = true
                    self.m_hintTxt:set_rich_text("<font color=#C3C3C3 bg=#00000000 size=24>下拉查看历史消息</font>")
                    self.m_hintTxt:update()
                    self.m_hintIcon.rotation = 0
                end
            end

            self.m_hintIcon.x = (self.m_iconContain.width - self.m_hintTxt.width)/2-40

        end
        
    end,

	--需要重载该函数
    onUpdate = function (self, ...)
        local data = UserData.getStatusData()
        self.m_isVip = data.isVip
        self.m_scrollView.enabled = true
        self.m_hasNoMessage = nil

    end,

    --显示发送文本
    sendTxtMsg = function (self, str)
        local msgWg = KefuCommon.createRightChatMsg(str, self.m_isVip)
        self:contentAddChild(msgWg)

        Clock.instance():schedule_once(function ()
            Clock.instance():schedule_once(function ()
                self.m_scrollView:scroll_to_bottom(0.25)
            end)
        end)
        
    end,

    
    sendVoice = function (self, time, path)
        local cc = kefuCommon.createRightVoiceItem(time, path, self.m_isVip)
        self:contentAddChild(cc)
        Clock.instance():schedule_once(function ()
            Clock.instance():schedule_once(function (  )
                self.m_scrollView:scroll_to_bottom(0.25)
            end)
        end)

        return cc
    end,

    createScrollViewBtn = function (self)
        self.m_scrollBtn = UI.Button{
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.0),
            },
            border = true,
            text = "",
        }

        self.m_scrollView:add(self.m_scrollBtn)
        self.m_scrollBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }
        self.m_scrollBtn.visible = false
    end,

    setScrollViewBtnEvent = function (self, func)
        self.m_scrollBtn.on_click = func
    end,

    --添加空格
    contentPreUpdate = function (self)
        UserData.resetHistoryIndex()
        self.m_content:remove_all()
        self.m_hasNoMessage = nil
        --content实际高度
        self.m_realHeight = 30

        --添加头部的空格
        self.m_topSpaceWg = Widget()
        self.m_topSpaceWg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(30),                 
        }
        self.m_content:add(self.m_topSpaceWg)

    end,

    --显示历史消息
    addHistoryMsg = function (self, historyData)
        local lastWg = self.m_topSpaceWg
        local data = UserData.getStatusData()

        self.m_historyItem = {}
        for i, v in ipairs(historyData) do
            local wg
            if v.isClient == 0 then       --左边
                --图片,客服暂时不能发图片和语音
                if v.types == 1 then      --文本
                    wg = kefuCommon.createLeftChatMsg(v.msg)
                    table.insert(self.m_historyItem, wg)                  
                end
            else                                --右边
                if v.types == 1 then
                    wg = kefuCommon.createRightChatMsg(v.msg, data.isVip)
                    table.insert(self.m_historyItem, wg)
                elseif v.types == 2 then
                    -- 本地存在图片资源, v.msg是部分路径
                    local path = System.getStorageImagePath()..v.msg
                    if os.isexist(path) then                        
                        wg = kefuCommon.createRightImageItem(v.msg, data.isVip)
                        table.insert(self.m_historyItem, wg)                  
                    end
                elseif v.types == 3 then
                    --v.msg是全路径
                    local path = v.msg
                    if os.isexist(path) then
                        wg = kefuCommon.createRightVoiceItem(nil, path, data.isVip)
                        table.insert(self.m_historyItem, wg)
                    end
                end
            end

            lastWg = wg or lastWg 

            if wg and (i == #historyData or (v.seqId - historyData[i+1].seqId) > INTERVAL_IN_MILLISECONDS) then
                local txtTips = kefuCommon.getStringTime(v.seqId/1000)
                wg = KefuCommon.createTimeWidget(txtTips)
                table.insert(self.m_historyItem, wg)
                lastWg = wg
            end

        end

        if not next(self.m_historyItem) then return end
        self.m_content.y = 0
        local addFunc
        addFunc = function (i, lastWg)
            Clock.instance():schedule_once(function()
                -- if i <= #self.m_historyItem then
                --     self.m_content:add(self.m_historyItem[i], lastWg)
                --     self.m_content.y = self.m_content.y - self.m_historyItem[i].height
                --     addFunc(i+1, self.m_historyItem[i])
                -- else
                --     self.m_topSpaceWg = Widget()
                --     self.m_topSpaceWg:add_rules{
                --         AL.width:eq(AL.parent('width')),
                --         AL.height:eq(30),                 
                --     }
                --     self.m_content:add(self.m_topSpaceWg, lastWg)
                --     self.m_scrollView.enabled = true
                --     self.m_content:remove(self.m_updateItem)
                --     self.m_content.y = self.m_content.y + self.m_updateItem.height - 30
                -- end
                self.m_content.y = 0
                for i, v in ipairs(self.m_historyItem) do
                    self:contentAddChild(v, lastWg)
                    self.m_content.y = self.m_content.y - v.height

                    lastWg = v
                end
                Clock.instance():schedule_once(function()
                    self.m_content:remove(self.m_updateItem)
                    self.m_topSpaceWg = Widget()
                    self.m_topSpaceWg:add_rules{
                        AL.width:eq(AL.parent('width')),
                        AL.height:eq(30),                 
                    }
                    self:contentAddChild(self.m_topSpaceWg, lastWg)
                    self.m_content.y = self.m_content.y + self.m_updateItem.height - 30
                    self.m_scrollView.enabled = true
                end)
            end)
        end
        addFunc(1, self.m_topSpaceWg)
    end,

    addTimeTips = function (self, tips)
        local wg = KefuCommon.createTimeWidget(tips)
        self:contentAddChild(wg)
    end,

    addLeftMsg = function (self, msg)
        local wg = kefuCommon.createLeftChatMsg(msg)
        self:contentAddChild(wg)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
              
    end,

    addImage = function (self, path, isleft)
        local wg = nil
        if isleft then
            wg = kefuCommon.createLeftImageItem(path)           
        else
            wg = kefuCommon.createRightImageItem(path, self.m_isVip)
        end

        self:contentAddChild(wg)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)

        return wg
    end,

    addRobotMsg = function (self, msg, links)
        local wg = kefuCommon.createRobotChatMsg(msg, links)
        
        self:contentAddChild(wg)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
    end,

    --添加重连信息
    addReloginMsg = function (self)
        local wg = Widget()
        local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
        chatBg.v_border = {20,50,18,20}
        chatBg.t_border = {20,50,18,20}
        wg:add(chatBg)

        local txtWg = Widget()
        wg:add(txtWg)

        local txt = Label()
        txtWg:add(txt)
        txt.absolute_align = ALIGN.CENTER
        txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font><font color=#0000ff bg=#00000000 size=30><a tag=link> %s</a></font>", ConstString.hint_logout_tips, [["重连"]]))
        txt:init_link(function (self, tag)
            NetWorkControl.sendProtocol("login")
        end)
        txtWg:add(txt)
        txt.layout_size = Point(SCREENWIDTH*0.6, 0)
        txt:update()

        kefuCommon.createHeadIcon(wg, nil, true)

        local headH = 80
        local w,h = txt.width, txt.height
        local realH = h+40 > headH and h+40 or headH

        chatBg:add_rules{
            AL.width:eq(w+60),
            AL.height:eq(realH),
            AL.top:eq(0),
            AL.left:eq(120),
        }

        txtWg:add_rules{
            AL.width:eq(w+60),
            AL.height:eq(realH),
            AL.top:eq(0),
            AL.left:eq(120),
        }

        wg:add_rules{
            AL.width:eq(AL.parent("width")),
        }
        wg.height = realH+40

        self:contentAddChild(wg)
    end,

    contentAddChild = function (self, child, lastWg)
        if self.m_bottomSpaceWg then
            self.m_content:remove(self.m_bottomSpaceWg)
            self.m_bottomSpaceWg = nil
        end

        self.m_realHeight = self.m_realHeight or 0
        self.m_realHeight = self.m_realHeight + child.height
        self.m_content:add(child, lastWg)

        --为了填满content加入了一个widget
        if self.m_realHeight < self.m_content.height then
            self.m_bottomSpaceWg = Widget()
            self.m_bottomSpaceWg:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(self.m_content.height - self.m_realHeight),
            }
            self.m_content:add(self.m_bottomSpaceWg)
        end
    end,

    removeBottomSpaceWg = function (self)
        if self.m_bottomSpaceWg then
            self.m_content:remove(self.m_bottomSpaceWg)
            self.m_bottomSpaceWg = nil
        end
    end,

    addTips = function (self, str)
        local tips = KefuCommon.showTips(str)
        self:contentAddChild(tips)
    end,

    showExceptionTips = function (self, time)
        if not self.m_exceptionTips then
            self.m_exceptionTips = kefuCommon.createExceptionTip()
            self.m_scrollView:add(self.m_exceptionTips)
            self.m_exceptionTips.visible = false
        end

        if self.m_expCk then
            self.m_expCk:cancel()
            self.m_expCk = nil
        end

        if time > 0 then
            self.m_expCk = Clock.instance():schedule(function()
                self.m_exceptionTips.visible = true  
            end, time)
        else
            self.m_exceptionTips.visible = true
        end
       
    end,

    hideExceptionTips = function (self)
        if self.m_expCk then
            self.m_expCk:cancel()
            self.m_expCk = nil
        end

        if self.m_exceptionTips then
            self.m_exceptionTips.visible = false
        end
    end,

    resetBottom = function (self)
        self.m_bottomCp:reset()
    end,

    --返回键事件回调
    onBackEvent = function (self)
        local data = UserData.getStatusData()
        if data.conversationStatus ~= ConversationStatus_Map.SESSION then
            SessionControl.logout()
            return
        end

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
    end,

    
    --销毁方法
    on_destroy = function (self)
       EventDispatcher.getInstance():unregister(Event.Resume, self, self.onResume)
    end,
})


return vipChatView