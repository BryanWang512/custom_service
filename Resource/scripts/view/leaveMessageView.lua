local UI = require('byui/basic')
local AutoLayout = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Anim = require(string.format('%sanimation', KefuRootPath))
local baseView = require(string.format('%sview/baseView', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
local kefuCommon = require(string.format('%skefuCommon', KefuRootPath))
local SelComponent = require(string.format('%sview/selComponent', KefuRootPath))

local leaveMessageView
local page_view
local sliderBlock


local rules = {
    top_container =
    {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(100),
    },
    top_title =
    {
        AutoLayout.width:eq(200),
        AutoLayout.height:eq(30),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    },
    btn_back =
    {
        AutoLayout.width:eq(160),
        AutoLayout.height:eq(AutoLayout.parent('height')),
    },
    arrow_icon =
    {
        AutoLayout.width:eq(24),
        AutoLayout.height:eq(42),

        AutoLayout.top:eq(26),
        AutoLayout.left:eq(17),
    },

}



local createReplyItem = function(data)
    local container = Widget()
    container:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
    } )
    container.height_hint = 90

    local btnItem = UI.Button {
        text = "",
        margin = { 10, 10, 10, 10 },
        image =
        {
            normal = Colorf(1.0,1.0,1.0,0.0),
            down = Colorf(0.996,0.7411,0.1411,1.0),
            disabled = Colorf(0.2,0.2,0.2,1),
        },
        border = true,

    }
    btnItem.zorder = 1
    btnItem:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(89),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(1),
    } )
    container:add(btnItem)

    local txtTitle = Label()
    local titleStr = data.title
    if string.len(data.title) > 15 then
        titleStr =  string.format("%s...",kefuCommon.subUTF8String(data.title, 15))
    end


    txtTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, titleStr))
    txtTitle:add_rules( {
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(30),
    } )
    btnItem:add(txtTitle)

    local txtTime = Label()
    local timeStr = os.date("%Y-%m-%d %H:%M", data.time)
    txtTime:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, timeStr))
    btnItem:add(txtTime)
    txtTime:update()

    txtTime:add_rules( {
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(AutoLayout.parent('width') - txtTime.width - 70),
        AutoLayout.top:eq(30),
    } )

    -- 创建箭头图标
    local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonUnfold)))
    arrowIcon:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') * 0.94),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    } )
    btnItem:add(arrowIcon)

    -- 创建箭头图标
    local arrowIcon1 = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonRetract)))
    arrowIcon1:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') * 0.94),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    } )
    arrowIcon1.visible = false
    btnItem:add(arrowIcon1)

    local contentCon = Widget()
    contentCon:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.top:eq(90),
    } )
    contentCon.background_color = color_to_colorf(Color(224, 224, 224, 255))
    contentCon.visible = false
    container:add(contentCon)

    local line = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.kefuLine)))
    line.v_border = {0,4,0,4}
    line.t_border = {0,4,0,4}
    line.zorder = 1
    line:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(10),
        AutoLayout.bottom:eq(AutoLayout.parent('height')+4),
    } )
    line.colorf = Colorf(0.0, 0.0, 0.0, 1)
    btnItem:add(line)

    local lines = {}
    for i = 1, 4 do
        lines[i] = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.kefuLine)))
        lines[i].v_border = {0,4,0,4}
        lines[i].t_border = {0,4,0,4}
        lines[i].zorder = 1
        lines[i]:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(9),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
   
        } )
        lines[i].colorf = Colorf(0.0, 0.0, 0.0, 1)
        contentCon:add(lines[i])
    end

    local space = 30
    local posY = space
----------编号
    local txtNo = Label()
    txtNo:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "编号:"))
    txtNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtNo)

    local labelNo = Label()
    labelNo:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.id))
    labelNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(115),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelNo)

    lines[1].y = posY + space + 30 - 4

------------手机号码
    posY = posY + space*2 + 30          --30为文字高
    local txtPhone = Label()
    txtPhone:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "手机号码:"))
    txtPhone:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtPhone)

    local labelPhone = Label()
    labelPhone:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.phone))
    labelPhone:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(180),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelPhone)

    lines[2].y = posY + space + 30 - 4 
-------------邮箱
    posY = posY + space*2 + 30          --30为文字高
    local txtMail = Label()
    txtMail:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "类型:"))
    txtMail:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtMail)

    local labelMail = Label()
    labelMail:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.mail))
    labelMail:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(115),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelMail)

    lines[3].y = posY + space + 30 - 4
--------------内容
    posY = posY + space*2 + 30          --30为文字高
    local txtContent = Label()
    txtContent:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "内容:"))
    txtContent:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtContent)

    
    local labelContent = Label()
    labelContent:add_rules( {
        AutoLayout.left:eq(115),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelContent)

    labelContent.layout_size = Point(SCREENWIDTH*0.77, 0)
    labelContent:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.title))
    labelContent:update()


    lines[4].y = posY + space + labelContent.height - 4

----------客服回复
    posY = posY + space*2 + labelContent.height
    local txtReply = Label()
    txtReply:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "客服回复:"))
    txtReply:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtReply)

    
    local labelReply = Label()
    labelReply:add_rules( {
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(180),
        AutoLayout.top:eq(posY),
    } )
    labelReply.layout_size = Point(SCREENWIDTH*0.77-60, 0)
    contentCon:add(labelReply)


    labelReply:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.reply))
    labelReply:update()

    posY = posY + labelReply.height+space
    contentCon.height_hint = posY

    
    local lineBottom = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.kefuLine)))
    lineBottom.v_border = {0,4,0,4}
    lineBottom.t_border = {0,4,0,4}

    lineBottom:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(9),
        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(contentCon.height_hint-4),
    } )


    btnItem.on_click = function()
        arrowIcon.visible = contentCon.visible
        arrowIcon1.visible = not contentCon.visible
        contentCon.visible = not contentCon.visible

        if contentCon.visible then
            container.height_hint = contentCon.height_hint + 90
        else
            container.height_hint = 90
        end
        container:update_constraints()
    end

    return container
end



leaveMessageView = class('leaveMessageView', baseView, {
    __init__ = function(self)
        super(leaveMessageView, self).__init__(self)
        self.m_status = {}

        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self.m_root.background_color = Colorf(235/255,235/255,235/255,1)
        -- ==============================================top=========================================================
        local topContainer = Widget()
        topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
        topContainer:add_rules(rules.top_container)
        
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>留言回复</font>"))
        txtTitle.absolute_align = ALIGN.CENTER
        topContainer:add(txtTitle)
        self.m_txtTitle = txtTitle

        local btnBack = UI.Button {
            text = "<font color=#F4C392 bg=#00000000 size=28>返回</font>",
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.6),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
            border = true,
            on_click = function()
                self:onBackEvent()
            end
        }
        btnBack:add_rules(rules.btn_back)
        topContainer:add(btnBack)
        self.m_btnBack = btnBack

        -- 创建必填图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip)))
        arrowIcon:add_rules(rules.arrow_icon)
        btnBack:add(arrowIcon)
        self.m_arrowIcon = arrowIcon

        -- ==============================================tab=========================================================
        local buttomContainer = Widget()
        buttomContainer.background_color = Colorf(1, 1, 1, 1.0)
        buttomContainer:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')-40),
            AutoLayout.height:eq(120),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),

        }
        self.m_root:add(buttomContainer)

        self.m_buttomContainer = buttomContainer
        self.m_buttomContainerY = 120
        buttomContainer.y = self.m_buttomContainerY


        -- tab 的灰色背景条
        local tabBg = Widget()
        tabBg:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(10),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.top:eq(0),
        }

        tabBg.background_color = Colorf(0.68, 0.68, 0.68, 1)
        buttomContainer:add(tabBg)

        sliderBlock = Widget()
        sliderBlock:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') / 2),
            AutoLayout.height:eq(10),
        }
        tabBg:add(sliderBlock)


    
        local btnLeaveMessage = UI.Button {
            text = '<font color=#f4c493 size=30>我要留言</font>',
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },

        }

        btnLeaveMessage:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') / 2),
            AutoLayout.height:eq(AutoLayout.parent('height')-10),
            AutoLayout.left:eq(0),
            AutoLayout.top:eq(10),
        }
        buttomContainer:add(btnLeaveMessage)

        local btnReplyMessage = UI.Button {
            text = '<font color=#9b9b9b size=30>留言回复</font>',
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
      
        }
        btnReplyMessage:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') / 2),
            AutoLayout.height:eq(AutoLayout.parent('height')-10),
            AutoLayout.top:eq(10),
            AutoLayout.right:eq(AutoLayout.parent('width')),
        }
        buttomContainer:add(btnReplyMessage)

        btnLeaveMessage.on_click = function()
            if page_view.page_num == 1 then return end           
            page_view.page_num = 1

        end

        btnReplyMessage.on_click = function()
            if page_view.page_num == 2 then return end
            page_view.page_num = 2
           
        end

        

        -- tapTOp 分界线
        local partLine = Sprite(TextureUnit.default_unit())
        partLine:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(5.5),
            AutoLayout.bottom:eq(AutoLayout.parent('height')),
        }
        partLine.colorf = Colorf(0.7, 0.7, 0.7, 1)
        buttomContainer:add(partLine)

        page_view = UI.PageView {
            dimension = kHorizental,
            max_number = 2,
        }

        page_view.background_color = Colorf.white
        page_view:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') -40),
            AutoLayout.height:eq(AutoLayout.parent('height') -255),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        }
        self.m_root:add(page_view)
        self.m_pageViewY = 240
        page_view.y = self.m_pageViewY 


        page_view.create_cell = function(pageView, i)
            local page = self:initPage(i)
            return page
        end
        page_view.focus = true
        page_view:update_data()
        self.m_pageView = page_view

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if self.m_pageView.page_num == 1 then
                btnLeaveMessage.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '我要留言')
                btnReplyMessage.text = string.format('<font color=#9b9b9b size=30>%s</font>', '留言回复')
            
                if sliderBlock.x ~= 0 then
                    local action = Anim.keyframes {
                        -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
                        { 0.0, { x = sliderBlock.width }, Anim.accelerate_decelerate },
                        { 1.0, { x = 0 }, nil },
                    }

                    local move = Anim.duration(0.3, action)

                    local anim = Anim.Animator()
                    anim:start(move, function(v)
                        sliderBlock.x = v.x
                    end , true)
                end
            else
                btnLeaveMessage.text = string.format('<font color=#9b9b9b size=30>%s</font>', '我要留言')
                btnReplyMessage.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '留言回复')
            
                if sliderBlock.x ~= sliderBlock.width then
                    local action = Anim.keyframes {                    
                        { 0.0, { x = 0 }, Anim.accelerate_decelerate },
                        { 1.0, { x = sliderBlock.width }, nil },
                    }

                    local move = Anim.duration(0.3, action)

                    local anim = Anim.Animator()
                    anim:start(move, function(v)
                        sliderBlock.x = v.x
                    end , true)
                end
            end
        end

        self.m_root:add(topContainer)
    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text("<font color=#ffffff bg=#00000000 size=34 weight=3>留言回复</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = "<font color=#ffffff bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text("<font color=#F4C392 bg=#00000000 size=34 weight=3>留言回复</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip))
            self.m_btnBack.text = "<font color=#F4C392 bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)

        end
    end,

    -- 需要重载该函数
    onUpdate = function(self, arg1, arg2)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end
        
        self:setNormalItem()
        self.m_pageView.page_num = 1
        self.m_btnCommit.state = "disabled"
        self.m_btnCommit.enabled = false
        sliderBlock.x = 0
        self.m_editContent.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        self.m_editContent.hint_text = string.format('<font color=#c3c3c3 size=%d>%s</font>', 30, "留言内容")

        self.m_editPhone.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        self.m_editPhone.hint_text = string.format('<font color=#9b9b9b size=30>请输入手机号码</font>')
        self.m_typeLabel:set_rich_text("<font color=#9b9b9b size=30>请选择留言类型</font>")
        self.m_selComp:hide()

        self.m_buttomContainer.y = self.m_buttomContainerY
        self.m_pageView.y = self.m_pageViewY

        --标记是否可以提交
        self.m_status = {}
        
        if not arg2 then
            self:requireData()
        end

        self.m_Items[2].visible = false
        self:updateItemPos()
    end,

    requireData = function (self, isRequire, callback)
        --不需要向服务器拉数据
        if not isRequire then
            local leaveData = UserData.getLeaveMessageViewData() or {}
            if leaveData.historyData then
                self.m_noRecordLabel.visible = false
                if self.m_replyData then
                    --说明有数据更新
                    if leaveData.hasNewReport then
                        self.m_listViewReply.data = leaveData.historyData
                    end
                else
                    --第一次数据更新
                    self.m_listViewReply.data = leaveData.historyData
                end

                self.m_replyData = leaveData.historyData
            else
                --没有留言
                self.m_noRecordLabel.visible = true
                self.m_replyData = nil
            end

            return 
        end

        NetWorkControl.obtainUserTabHistroy(0, 50, HTTP_SUBMIT_ADVISE_HISTORY_URI, function (content)

            local tb = json.decode(content)

            --0表示成功
            if tb.code == 0 then
                --没有留言历史记录
                if not tb.data then return end


                table.sort(tb.data, function (v1,v2)
                    if v1.id > v2.id then
                        return true
                    end
                    return false
                end)

                local replyData = {}
                for i, v in ipairs(tb.data) do
                    local data = {}
                    data.title = v.content
                    data.time = v.clock
                    data.id = v.id
                    data.mail = v.mail
                    data.phone = v.phone
                    if v.replies and v.replies[1] then
                        data.reply = v.replies[1].reply
                    else
                        data.reply = ConstString.replay_default
                    end
                    table.insert(replyData, data)

                end
                self.m_noRecordLabel.visible = false               
                self.m_listViewReply.data = replyData

                if callback then
                    callback()                   
                end
                
            else            --获取失败
                Log.w("obtainUserTabHistroy", "留言内容获取失败")
            end

        end)
    end,

    initPage = function(self, i)
        if i == 1 then
            local content = self:addFirstPage()
            return content
        elseif i == 2 then

            local container = Widget()
            container:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(AutoLayout.parent('height')),              
            }

            local listviewReply = UI.ListView {

                create_cell = function(data)
                    local container = createReplyItem(data)
                    return container
                end,
            }

            listviewReply:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(AutoLayout.parent('height')),
                AutoLayout.left:eq(1),
            }
            container:add(listviewReply)
            listviewReply.velocity_factor = 3.1


            self.m_listViewReply = listviewReply

            self.m_noRecordLabel = Label()
            self.m_noRecordLabel:set_rich_text(string.format("<font color=#9b9b9b bg=#00000000 size=44 weight=3>暂无任何记录</font>"))
            container:add(self.m_noRecordLabel)
            self.m_noRecordLabel.absolute_align = ALIGN.CENTER
            self.m_listViewReply.background_color = Colorf(244/255, 244/255, 244/255, 1)

            return container
        end

    end,

    addFirstPage = function(self)
        local container = Widget()
        container:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')-1),
            AutoLayout.height:eq(AutoLayout.parent('height')),
        }
        self.m_Items = {}
        local height = 110

        local txtConfig = {
            {title = "手机号码", color = "#000000"},
            {title = "请输入正确的手机号码", color = "#ff1010"},
            {title = "留言类型", color = "#000000"},
        }

        for i=1, 3 do
            self.m_Items[i] = Widget()
            self.m_Items[i]:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(height),
                AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            }

            self.m_Items[i].y = height*(i-1)
            container:add(self.m_Items[i])

            local line = Widget()
            line:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(2.5),
                AutoLayout.bottom:eq(AutoLayout.parent('height')),
            }

            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            self.m_Items[i]:add(line)

            local title = Label()
            title.align = Label.CENTER
            title:set_rich_text(string.format('<font color=%s size=30>%s</font>', txtConfig[i].color, txtConfig[i].title))
            title:add_rules{
                AutoLayout.left:eq(30),
                AutoLayout.top:eq(40),
            }
            self.m_Items[i]:add(title)


        end
        self.m_Items[2].background_color = Colorf(233/255, 233/255, 233/255, 1)

        --手机号码
        self.m_editPhone = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            text = string.format('<font color=#000000 size=30>%s</font>',""),
            hint_text = '<font color=#9b9b9b size=30>请输入手机号码</font>',
        
        }
        self.m_editPhone:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')-220),
            AutoLayout.height:eq(80),
            AutoLayout.left:eq(220),
            AutoLayout.top:eq(40),
        }

        self.m_editPhone.keyboard_type = Application.KeyboardTypeNumberPad
        self.m_Items[1]:add(self.m_editPhone)

        local icon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonNecessary)))
        icon:add_rules( {
            AutoLayout.left:eq(AutoLayout.parent('width') -30),
            AutoLayout.centery:eq(50),
        }
        )
        self.m_Items[1]:add(icon)

        --留言类型
        local typeWg = Widget()
        typeWg:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')-220),
            AutoLayout.height:eq(AutoLayout.parent('height')),
            AutoLayout.left:eq(220),
            AutoLayout.top:eq(0),
        }
        self.m_Items[3]:add(typeWg)

        self.m_typeLabel = Label()
        self.m_typeLabel:set_rich_text("<font color=#9b9b9b size=30>请选择留言类型</font>")
        self.m_typeLabel.absolute_align = ALIGN.LEFT
        typeWg:add(self.m_typeLabel)

        local moreIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonMore)))
        moreIcon:add_rules{
            AutoLayout.right:eq(AutoLayout.parent('width') -15),
            AutoLayout.centery:eq(50),
        }
        typeWg:add(moreIcon)



        self.m_selComp = SelComponent(self.m_root, {title = "留言类型", action = "完成", ui_type = 2 })
        UI.init_simple_event(typeWg, function ()
            self.m_selComp:pop_up()
        end)

        self.m_selComp.btn_callback = function(str)
            str = str or "无法登陆"
            self.m_typeLabel:set_rich_text("<font color=#000000 size=30>"..str.."</font>")
            self.m_status[2] = true
            self.m_selectTxt = str

            if self.m_status[1] and self.m_status[2] and self.m_status[3] then
                if not self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = true
                    self.m_btnCommit.state = "normal"
                end
            elseif self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = false
                self.m_btnCommit.state = "disabled"
            end


        end


        self.m_editPhone.on_text_changed = function ()
            if self.m_editPhone.text == "" then
                self.m_status[1] = nil
                self.m_Items[2].visible = false
            else
                if kefuCommon.isTelPhoneNumber(self.m_editPhone.text) then
                    self.m_status[1] = true
                    self.m_Items[2].visible = false
                else
                    self.m_status[1] = nil
                    self.m_Items[2].visible = true                
                end
            end

            self:updateItemPos()

            if self.m_status[1] and self.m_status[2] and self.m_status[3] then
                if not self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = true
                    self.m_btnCommit.state = "normal"
                end
            elseif self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = false
                self.m_btnCommit.state = "disabled"
            end
        end


        self.m_Items[4] = Widget()
        self.m_Items[4]:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(245),
        }
        self.m_Items[4].y = height*3
        container:add(self.m_Items[4])

        self.m_contentBtn = UI.Button{
            text = "",
            image =
            {
                normal= Colorf(0.43,0.8,0.17,0.0),
                down= Colorf(0.43,0.73,0.17,0.0),
                disabled = Colorf(0.77,0.77,0.77,0.0),
            },
        }
        self.m_contentBtn:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(AutoLayout.parent('height')),
        }        
        self.m_contentBtn.visible = false


        local editContent = UI.MultilineEditBox { expect_height = 180 }
        editContent.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        editContent.style = KTextBorderStyleNone
        editContent.background_style = KTextBorderStyleNone
        editContent:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width') -48),
            AutoLayout.height:eq(180),
            AutoLayout.left:eq(30),
            AutoLayout.top:eq(28),
        }
        )
        editContent.max_height = 180
        editContent.hint_text = string.format('<font color=#c3c3c3 size=%d>%s</font>', 30, "留言内容")
        self.m_Items[4]:add(editContent)
        container:add(self.m_contentBtn)

        local line1 = Widget()

        line1:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(2.5),
            AutoLayout.bottom:eq(AutoLayout.parent('height')),
        } )
        line1.background_color = Colorf(0.77, 0.77, 0.77, 1)
        self.m_Items[4]:add(line1)

        self.m_editContent = editContent

        self.m_editContent.on_text_changed = function ()
            if self.m_editContent.text == "" then
                self.m_status[3] = nil
            else
                self.m_status[3] = true
            end

            if self.m_status[1] and self.m_status[2] and self.m_status[3] then
                if not self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = true
                    self.m_btnCommit.state = "normal"
                end
            elseif self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = false
                self.m_btnCommit.state = "disabled"
            end
        end

        self.m_editContent.on_keyboard_show = function (args)
            self.m_contentBtn.visible = true
            local linePos = self.m_Items[4]:to_world(Point(0, 245))
            local disY = linePos.y - args.y
            if disY > 0 then
                self.m_buttomContainer.y = self.m_buttomContainerY - disY
                self.m_pageView.y = self.m_pageViewY - disY
            end

        end

        self.m_editContent.on_keyboard_hide = function (args)
            self.m_buttomContainer.y = self.m_buttomContainerY
            self.m_pageView.y = self.m_pageViewY
            self.m_contentBtn.visible = false
        end


        local btnCommit = UI.Button {
            text = string.format('<font color=#ffffff size=%d>%s</font>',34,"提交"),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal= Colorf(0.43,0.8,0.17,1),
                down= Colorf(0.43,0.73,0.17,1.0),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        self.m_btnCommit = btnCommit
        btnCommit:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width') * 0.92),
            AutoLayout.height:eq(100),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.bottom:eq(AutoLayout.parent('height')-30),
        }
        )
        container:add(btnCommit)
        btnCommit.on_click = function()
            local tb = {}
            tb.gid = mqtt_client_config.gameId
            tb.site_id = mqtt_client_config.siteId
            tb.client_id = mqtt_client_config.stationId
            tb.content = self.m_editContent.text
            tb.phone = self.m_editPhone.text
            tb.mail = self.m_selectTxt
            tb.client_info = NetWorkControl.generateClientInfo("")

            if not self.m_submitTips then
                self.m_submitTips, bg = kefuCommon.createSubmitTips()
                self.m_root:add(self.m_submitTips)
                self.m_root:add(bg)
            end
            self.m_submitTips.showTips()


            NetWorkControl.postString(HTTP_SUBMIT_ADVISE_URI, json.encode(tb), function (rsp)
                if rsp.errmsg or rsp.code ~= 200 then
                    self.m_submitTips.hideTips("提交失败")
                else
                    print_string("=============留言内容发送结果:"..rsp.content)
                    local result = json.decode(rsp.content)
                    if result.code == 0 then                   
                        self:requireData(true, function ()
                            Clock.instance():schedule_once(function ()                       
                                self.m_submitTips.hideTips("提交成功!", 1)
                                self:onUpdate(nil, true)
                                self.m_pageView.page_num = 2
                            end, 1)
                        end)
                    else
                        self.m_submitTips.hideTips("提交失败")
                    end
                end
            end)
        end

        return container
    end,

    onBackEvent = function (self)
        local data = UserData.getStatusData() or {}
        if data.isVip then
            ViewManager.showVipChatView(View_Anim_Type.LTOR)
        else
            ViewManager.showNormalChatView(View_Anim_Type.LTOR)
        end
    end,

    updateItemPos = function (self)
        local idx = 0
        local height = 110
        for i, v in ipairs(self.m_Items) do
            if v.visible then
                v.y = idx*height
                idx = idx + 1
            end
        end
    end,

    onDelete = function (self)
        
    end,

} )

return leaveMessageView