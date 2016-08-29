local baseView = require("view.baseView")
local UI = require('byui/basic')
local AutoLayout = require('byui/autolayout')
local Anim = require("animation")
local Layout = require('byui/layout')
require("byui/utils")
require("libs/json_wrap");
local class, mixin, super = unpack(require('byui/class'))
local SelComponent = require("view/selComponent")
local kefuCommon = require("kefuCommon")
local UserData = require("conversation/sessionData")


local page_view
local sliderBlock
local MyPageView
MyPageView = class('MyPageView', UI.PageView, {
    on_touch_up = function(self, p, t)
        super(MyPageView, self).on_touch_up(self, p, t)
        if page_view.page_num == 2 then
            if sliderBlock.x == sliderBlock.width then return end 

            local action = Anim.keyframes {
                -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
                { 0.0, { x = 0 }, Anim.accelerate_decelerate },
                { 1.0, { x = sliderBlock.width }, nil },
            }

            local move = Anim.duration(0.3, action)

            local anim = Anim.Animator()
            anim:start(move, function(v)
                sliderBlock.x = v.x
            end , true)
        else
            if sliderBlock.x == 0 then return end
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
    end,
} )

--通牌作弊 1；滥发广告2；刷分倒币3；捣乱游戏4；不雅用语5；其他6
local txt2NumType = {
    ["通牌作弊"] = 1,
    ["滥发广告"] = 2,
    ["刷分倒币"] = 3,
    ["捣乱游戏"] = 4,
    ["不雅用语"] = 5,
    ["其他"] = 6,
    ["其他"] = 0,
}

local num2TxtType = {}
for i, v in pairs(txt2NumType) do
    num2TxtType[v] = i
end

local transformType = function (str)
    if "通牌作弊" == str then
        return 1
    elseif "滥发广告" == str then
        return 2
    elseif "刷分倒币" == str then
        return 3
    elseif "捣乱游戏" == str then
        return 4
    elseif "不雅用语" == str then
        return 5
    end

    return 6
end

local hackAppealView

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



local createHistoryItem = function(data)
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
        AutoLayout.height:eq(90),
        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(0),
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
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.44),
    } )


    -- 创建箭头图标
    local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get("common/unfold.png")))
    arrowIcon:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') * 0.94),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    } )
    btnItem:add(arrowIcon)

    -- 创建箭头图标
    local arrowIcon1 = Sprite(TextureUnit(TextureCache.instance():get("common/retract.png")))
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
    contentCon.background_color = color_to_colorf(Color(230, 230, 230, 220))
    contentCon.visible = false
    container:add(contentCon)

    local line = BorderSprite(TextureUnit(TextureCache.instance():get("line.png")))
    line.v_border = {0,4,0,4}
    line.t_border = {0,4,0,4}
    line:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(10),
        AutoLayout.bottom:eq(AutoLayout.parent('height')+4),

    } )
    line.colorf = Colorf(0.0, 0.0, 0.0, 1)
    btnItem:add(line)



    local lines = {}
    for i = 1, 2 do
        lines[i] = BorderSprite(TextureUnit(TextureCache.instance():get("line.png")))
        lines[i].v_border = {0,4,0,4}
        lines[i].t_border = {0,4,0,4}

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

    lines[1].y = posY + space + 30 - 4

    local posX = 30
----------编号
    local txtNo = Label()
    txtNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtNo)
    txtNo:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "编号:"))

    posX = posX + 82
    local labelNo = Label()
    labelNo:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.id))
    labelNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelNo)


----------------id
    posX = posX + 120
    local txtID = Label()
    txtID:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "ID:"))
    txtID:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtID)

    posX = posX + 50
    local labelID = Label()
    labelID:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.mid))
    labelID:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelID)
    labelID:update()


-----------类型
    posX = posX + 50 + labelID.width   
    local txtType = Label()
    txtType:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "类型:"))
    txtType:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtType)


    posX = posX + 90 
    local labelType = Label()
    labelType:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.typeStr))
    labelType:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(posX),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelType)


---------举报内容
    posY = posY + space*2 + 30          --30为文字高
    local txtContent = Label()
    txtContent:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "举报内容:"))
    txtContent:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(txtContent)

    local labelContent = Label()
    labelContent.layout_size = Point(SCREENWIDTH*0.77-60, 0)
    labelContent:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.title))
    labelContent:add_rules( {
        AutoLayout.left:eq(180),
        AutoLayout.top:eq(posY),
    } )
    contentCon:add(labelContent)
    labelContent:update()

    lines[2].y = posY + space + labelContent.height - 4
--------------客服回复
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
    labelReply.multiline = true
    labelReply:add_rules( {
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(180),
        AutoLayout.top:eq(posY),
    } )
    labelReply.layout_size = Point(SCREENWIDTH*0.77-60, 0)
    
    
    labelReply:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, data.reply))
    contentCon:add(labelReply)
    labelReply:update()

    posY = posY + labelReply.height+space
    contentCon.height_hint = posY

    

    local lineBottom = BorderSprite(TextureUnit(TextureCache.instance():get("line.png")))
    lineBottom.v_border = {0,4,0,4}
    lineBottom.t_border = {0,4,0,4}

    lineBottom:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(9),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),

        AutoLayout.bottom:eq(contentCon.height_hint+4),
    } )
    lineBottom.colorf = Colorf(0.0, 0.0, 0.0, 1)
--    contentCon:add(lineBottom)

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



hackAppealView = class('hackAppealView', baseView, {
    __init__ = function(self)
        super(hackAppealView, self).__init__(self)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self.m_root.background_color = Colorf(242/255,240/255,235/255,1)
        -- ==============================================top=========================================================
        local topContainer = Widget()
        topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
        topContainer:add_rules(rules.top_container)
        
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>玩家举报</font>"))
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

        -- 创建箭头图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip)))
        arrowIcon:add_rules(rules.arrow_icon)
        btnBack:add(arrowIcon)
        self.m_arrowIcon = arrowIcon

        -- ==============================================tab=========================================================
        local buttomContainer = Widget()
        buttomContainer.background_color = Colorf(1.0, 1.0, 1.0, 1.0)
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
        sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)
        tabBg:add(sliderBlock)

        

        local btnAppealAgainst = UI.Button {
            text = string.format('<font color=#f4c493 size=%d>%s</font>',30,'我要举报'),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },

        }

        btnAppealAgainst:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') / 2),
            AutoLayout.height:eq(AutoLayout.parent('height')-10),
            AutoLayout.left:eq(0),
            AutoLayout.top:eq(10),
        }
        buttomContainer:add(btnAppealAgainst)

        local btnAppealHistory = UI.Button {
            text = string.format('<font color=#9b9b9b size=%d>%s</font>',30,'举报历史'),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },

        }
        btnAppealHistory:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') / 2),
            AutoLayout.height:eq(AutoLayout.parent('height')-10),
            AutoLayout.top:eq(10),
            AutoLayout.right:eq(AutoLayout.parent('width')),
        }
        buttomContainer:add(btnAppealHistory)

        btnAppealAgainst.on_click = function()
            if page_view.page_num == 1 then return end 

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
            page_view.page_num = 1
            btnAppealAgainst.text = string.format('<font color=%s size=%d>%s</font>', self.m_txtColor, 30, '我要举报')
            btnAppealHistory.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '举报历史')
        end

        btnAppealHistory.on_click = function()
            if page_view.page_num == 2 then return end
            local action = Anim.keyframes {
                -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
                { 0.0, { x = 0 }, Anim.accelerate_decelerate },
                { 1.0, { x = sliderBlock.width }, nil },
            }

            local move = Anim.duration(0.3, action)

            local anim = Anim.Animator()
            anim:start(move, function(v)
                sliderBlock.x = v.x
            end , true)
            page_view.page_num = 2
            btnAppealAgainst.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '我要举报')
            btnAppealHistory.text = string.format('<font color=%s size=%d>%s</font>', self.m_txtColor, 30, '举报历史')
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

        page_view = MyPageView {
            dimension = kHorizental,
            max_number = 2,
        }

        self.m_pageView = page_view
        self.m_pageViewY = 240
        page_view.y = self.m_pageViewY 

        page_view.background_color = Colorf.white
        page_view:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') -40),
            AutoLayout.height:eq(AutoLayout.parent('height') -255),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        }
        self.m_root:add(page_view)

        page_view.create_cell = function(pageView, i)
            local page = self:initPage(i)
            return page
        end
        page_view.focus = true

        page_view:update_data()

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if self.m_pageView.page_num == 1 then
                btnAppealAgainst.text = string.format('<font color=%s size=%d>%s</font>', self.m_txtColor, 30, '我要举报')
                btnAppealHistory.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '举报历史')
            else
                btnAppealAgainst.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '我要举报')
                btnAppealHistory.text = string.format('<font color=%s size=%d>%s</font>', self.m_txtColor, 30, '举报历史')
            end

            if self.m_newCommit then
                self:requireData()
            end

        end
        self.m_status = {}
        self.m_root:add(topContainer)

        self:requireData()

    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text("<font color=#ffffff bg=#00000000 size=34 weight=3>玩家举报</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = "<font color=#ffffff bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text("<font color=#F4C392 bg=#00000000 size=34 weight=3>玩家举报</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip))
            self.m_btnBack.text = "<font color=#F4C392 bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)
        end
    end,

    -- 需要重载该函数
    onUpdate = function(self, ...)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self:setNormalItem()
        self.m_editHackId.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        self.m_editHackId.hint_text = "<font color=#9b9b9b size=30>请输入需要举报的ID</font>" 
        self.m_pageView.page_num = 1
        self.m_typeLabel:set_rich_text("<font color=#9b9b9b size=30>请输入举报类型</font>")
        self.m_eidtContent.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        self.m_eidtContent.hint_text = string.format('<font color=#aaaaaa size=%d>%s</font>', 30, "举报内容（在游戏中可点击玩家头像进行举报）")
        
        self.m_pictureTips.visible = true
        self.m_pictureTips:set_rich_text(string.format('<font color=#aaaaaa size=%d>%s</font>', 30, "（通牌作弊必须上传游戏截图）"))
        self.m_btnCommit.state = "disabled"
        self.m_btnCommit.enabled = false
        self.m_selectTxt = ""
        self.m_buttomContainer.y = self.m_buttomContainerY
        self.m_pageView.y = self.m_pageViewY

        sliderBlock.x = 0

        if self.m_uploadImg then
            self.m_uploadImg:remove_from_parent()
            self.m_uploadImg = nil
        end

        --标记是否可以提交
        self.m_status = {}
        
        if self.m_newCommit then
            self:requireData()
        
        end

    end,

    requireData = function (self, isNotify)

        NetWorkControl.obtainUserTabHistroy(0, 50, HTTP_SUBMIT_REPORT_HISTORY_URI, function (content)
            local tb = json.decode(content)
            if tb.code == 0 then
                self.m_newCommit = nil

                if self.m_commitClock then
                    self.m_commitClock:cancel()
                    self.m_commitClock = nil
                end
                --30秒可以更新一次
                self.m_commitClock = Clock.instance():schedule_once(function()
                    self.m_newCommit = true

                end, 30)
                
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
                    data.id = v.id
                    data.title = v.report_content
                    data.time = v.clock
                    data.reply = v.reply
                    data.typeStr = num2TxtType[v.report_type]
                    data.mid = v.report_mid

                    if data.reply == "" then
                        data.reply = ConstString.replay_default
                    end

                    table.insert(replyData, data)
                end

                self.m_noRecordLabel.visible = false
                if self.m_replyData then
                    --说明有数据更新，需要改动界面
                    if #self.m_replyData ~= #replyData then
                        self.m_listViewReply.data = replyData
                        self.m_replyData = replyData
                    else
                        for i, v in ipairs(self.m_replyData) do
                            if v.reply ~= replyData[i].reply then
                                self.m_listViewReply.data = replyData
                                self.m_replyData = replyData
                                break
                            end
                        end
                    end
                else
                    self.m_replyData = replyData
                    self.m_listViewReply.data = replyData
                end


            else
                Log.w("obtainUserTabHistroy", "举报内容获取失败")
            end
        end)
    end,

    initPage = function (self, i)
        if i == 1 then
            local content = self:addFirstPage()
            return content
        elseif i == 2 then
            local container = Widget()
            container:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')-1),
                AutoLayout.height:eq(AutoLayout.parent('height')),
            }

            local listviewHistory = UI.ListView {
                create_cell = function(data)
                    local container = createHistoryItem(data)
                    return container
                end,
            }
            listviewHistory:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(AutoLayout.parent('height')),
                AutoLayout.left:eq(1),
            }
            container:add(listviewHistory)

            self.m_listViewReply = listviewHistory
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

        self.m_firstPage = container

        local itemsData = {
            { title = "举报ID", hint_text = "请输入需要举报的ID", ui_type = "edit" },
            { title = "举报类型", hint_text = "请输入举报类型", ui_type = "label", icon = "common/more.png" },
        }

        local height = 100
        for i = 1, 2 do
            local item = Widget()
            item:add_rules( {
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(height),
                AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
                AutoLayout.top:eq(height *(i - 1)),
            } )
            container:add(item)

            local line = Widget()
            line:add_rules( {
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(2.5),
                AutoLayout.bottom:eq(AutoLayout.parent('height')),
            } )
            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            item:add(line)

            local title = Label()
            title.align = Label.CENTER
            title:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, itemsData[i].title))
            title:add_rules( {
                AutoLayout.left:eq(30),
                AutoLayout.top:eq(35),
            }
            )
            item:add(title)

            if itemsData[i].ui_type == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=%d>%s</font>',30,""),
                    hint_text = string.format('<font color=#9b9b9b size=%d>%s</font>',30,itemsData[i].hint_text),
                }

                self.m_editHackId = edit

                self.m_editHackId.on_text_changed = function ()
                    if self.m_editHackId.text == "" then
                        self.m_status[1] = nil
                    else
                        self.m_status[1] = true
                    end

                    if self.m_selectTxt == "通牌作弊" then
                        if self.m_status[1] and self.m_status[2] and self.m_status[3] and self.m_status[4] then
                            if not self.m_btnCommit.enabled then
                                self.m_btnCommit.enabled = true
                                self.m_btnCommit.state = "normal"
                            end
                        elseif self.m_btnCommit.enabled then
                            self.m_btnCommit.enabled = false
                            self.m_btnCommit.state = "disabled"
                        end
                    else
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

                end
                edit:add_rules( {
                    AutoLayout.width:eq(450),
                    AutoLayout.height:eq(80),
                    AutoLayout.left:eq(209),
                    AutoLayout.top:eq(34),
                }
                )
              
                edit.keyboard_type = Application.KeyboardTypeNumberPad
                item:add(edit)
            elseif itemsData[i].ui_type == "label" then
                local label = Label()
                self.m_typeLabel = label
                label:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, itemsData[i].hint_text))
                label:add_rules( {
                    AutoLayout.width:eq(500),
                    AutoLayout.height:eq(20),

                    AutoLayout.left:eq(218),
                    AutoLayout.top:eq(35),
                }
                )
                item:add(label)

                if i == 2 then
                    local wg = Widget()
                    wg:add_rules( {
                        AutoLayout.width:eq(600),
                        AutoLayout.height:eq(90),
                        AutoLayout.left:eq(218),
                    }
                    )
 
                    item:add(wg)


                    local selcomp = SelComponent(self.m_root, {title = "举报类型", action = "完成", ui_type = 2 })
                    selcomp.btn_callback = function(str)
                        label:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, str))
                        self.m_selectTxt = str
                        self.m_status[2] = true

                        if self.m_selectTxt == "通牌作弊" then
                            if self.m_status[1] and self.m_status[2] and self.m_status[3] and self.m_status[4] then
                                if not self.m_btnCommit.enabled then
                                    self.m_btnCommit.enabled = true
                                    self.m_btnCommit.state = "normal"
                                end
                            elseif self.m_btnCommit.enabled then
                                self.m_btnCommit.enabled = false
                                self.m_btnCommit.state = "disabled"
                            end
                        else    
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

                    end
                    self.m_selComp = selcomp
                  
                    UI.init_simple_event(wg, function ()
                        selcomp:pop_up()
                    end)
                end
            end

            if itemsData[i].icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(itemsData[i].icon)))
                icon:add_rules( {
                    AutoLayout.left:eq(AutoLayout.parent('width') -30),
                    AutoLayout.centery:eq(50),
                }
                )
                item:add(icon)
            end
        end

        local itemWg = Widget()
        itemWg:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(220),
        }
        itemWg.y = height*2
        container:add(itemWg)


        local line3 = Sprite(TextureUnit.default_unit())
        line3:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(2.5),
            AutoLayout.bottom:eq(AutoLayout.parent('height')),
        } )
        line3.colorf = Colorf(0.77, 0.77, 0.77, 1)
        itemWg:add(line3)

        local editContent = UI.MultilineEditBox { expect_height = 170 }
        editContent.text = string.format('<font color=#000000 size=%d>%s</font>', 30, "")
        editContent.style = KTextBorderStyleNone
        editContent.background_style = KTextBorderStyleNone
        editContent:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width') -48),
            AutoLayout.height:eq(170),
            AutoLayout.left:eq(30),
            AutoLayout.top:eq(28),
        }
        )
        editContent.max_height = 170
        editContent._hint_label.layout_size = Point(SCREENWIDTH-92, 0)
        editContent.hint_text = string.format('<font color=#aaaaaa size=%d>%s</font>', 30, "举报内容（在游戏中可点击玩家头像进行举报）")
        itemWg:add(editContent)
        self.m_eidtContent = editContent

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

        
        itemWg:add(self.m_contentBtn)
        self.m_contentBtn.visible = false

        self.m_eidtContent.on_text_changed = function ()
            if self.m_eidtContent.text == "" then
                self.m_status[3] = nil
            else
                self.m_status[3] = true
            end

            if self.m_selectTxt == "通牌作弊" then
                if self.m_status[1] and self.m_status[2] and self.m_status[3] and self.m_status[4] then
                    if not self.m_btnCommit.enabled then
                        self.m_btnCommit.enabled = true
                        self.m_btnCommit.state = "normal"
                    end
                elseif self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = false
                    self.m_btnCommit.state = "disabled"
                end
            else
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
        end

        self.m_eidtContent.on_keyboard_show = function (args)
            self.m_contentBtn.visible = true
            local linePos = itemWg:to_world(Point(0, 220))
            local disY = linePos.y - args.y
            if disY > 0 then
                self.m_buttomContainer.y = self.m_buttomContainerY - disY
                self.m_pageView.y = self.m_pageViewY - disY
            end

        end

        self.m_eidtContent.on_keyboard_hide = function (args)
            self.m_contentBtn.visible = false
            self.m_buttomContainer.y = self.m_buttomContainerY
            self.m_pageView.y = self.m_pageViewY
        end



        local btnUpgrade = UI.Button {
            text = "",
            radius = 0,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = TextureUnit(TextureCache.instance():get("common/upgrade_up.png")),
                down = TextureUnit(TextureCache.instance():get("common/upgrade_down.png")),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
        }
        btnUpgrade:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(150),
            AutoLayout.left:eq(30),
            AutoLayout.top:eq(height*2+252),
        }
        )
        container:add(btnUpgrade)
        self.m_btnUpgrade = btnUpgrade

        btnUpgrade.on_click = function()
            if self.m_uploadImg then
                self.m_uploadImg:remove_from_parent()
                self.m_uploadImg = nil
            end
            self.m_pictureTips.visible = true
            
            EventDispatcher.getInstance():register(Event.Call,self, self.onNativeEvent);
            self.m_imgPath = Clock.now() .. "_Upgrade_img.jpg";
            local savePath = string.format("%s%s",System.getStorageImagePath(), self.m_imgPath);
            local tab = {};
            tab.savePath = savePath;
            local json_data = json.encode(tab);
            NativeEvent.getInstance():RequestGallery(json_data);
        end

        local labelTip = Label()
        self.m_pictureTips = labelTip
        labelTip.layout_size = Point(SCREENWIDTH-260, 0)
        labelTip:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "（通牌作弊必须上传游戏截图）"))
        labelTip:add_rules( {
            AutoLayout.width:eq(450),
            AutoLayout.height:eq(20),

            AutoLayout.left:eq(200),
            AutoLayout.top:eq(height*2+280),
        }
        )
        container:add(labelTip)

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
            AutoLayout.bottom:eq(AutoLayout.parent('height')-20),
        }
        )
        container:add(btnCommit)

        btnCommit.on_click = function()
            local tb = {}
            tb.gid = mqtt_client_config.gameId
            tb.site_id = mqtt_client_config.siteId
            tb.client_id = mqtt_client_config.stationId
            tb.report_mid = self.m_editHackId.text
            tb.report_data = ""
            tb.report_type = txt2NumType[self.m_selectTxt]
            tb.report_content = self.m_eidtContent.text
            tb.report_pics = json.encode(self.m_imgUrl or {})
            tb.client_info = NetWorkControl.generateClientInfo("")
            Log.v("hackAppealView","举报内容:" ,tb);
            if not self.m_submitTips then
                self.m_submitTips, bg = kefuCommon.createSubmitTips()
                self.m_root:add(self.m_submitTips)
                self.m_root:add(bg)
            end
            self.m_submitTips.showTips()

            NetWorkControl.postString(HTTP_SUBMIT_REPORT_URI, json.encode(tb), function (rsp)
                if rsp.errmsg or rsp.code ~= 200 then
                    self.m_submitTips.hideTips("提交失败")
                else
                    print("=============举报内容发送成功=============")
                    self.m_newCommit = true
                    self.m_submitTips.hideTips("提交成功!", 1)
                    self:onUpdate()
                    self.m_pageView.page_num = 2
                end

            end)
        end

        return container
    end,

    onNativeEvent = function(self, param,status, jsonTable)
        EventDispatcher.getInstance():unregister(Event.Call,nil,onNativeEvent);

        local fullPath = jsonTable.savePath;

        Log.v("hackAppealView" ,"self.onNativeEvent fullPath:" .. fullPath);

        local data = UserData.getStatusData() or {}
        local args = {
            url = FILE_UPLOAD_URI, 
            headers = {

            },

            query = {                      -- optional, query_string
                fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
                session_id = data.sessionId,
                sign = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
            },
            timeout = 10,                    -- optional, seconds
            connecttimeout = 10,             -- optional, seconds
            post = {
                {
                    type = "file",
                    name = "file",
                    filepath = fullPath,
                    file_type = "image/jpeg",
                },                      
            },
        }

        self.m_pictureTips.visible = false
        if self.m_uploadImg then
            self.m_uploadImg:remove_from_parent()
            self.m_uploadImg = nil
        end

        --todo: 1. 需要显示上传时的转圈圈, 防止用户进行任何操作
        --显示图片
        self.m_uploadImg = Sprite(TextureUnit(TextureCache.instance():get(self.m_imgPath)))
        local imgH = self.m_pageView.height - 460 - 120
        if imgH < 0 then
            imgH = 400
        end

        if self.m_uploadImg.height > imgH then
            self.m_uploadImg.width = self.m_uploadImg.width * (imgH/self.m_uploadImg.height)
            self.m_uploadImg.height = imgH
        end

        if self.m_uploadImg.width > SCREENWIDTH*0.5 then
            self.m_uploadImg.height = self.m_uploadImg.height * (SCREENWIDTH*0.6/self.m_uploadImg.width)
            self.m_uploadImg.width = SCREENWIDTH*0.5
        end

        self.m_uploadImg:add_rules{
            AutoLayout.width:eq(self.m_uploadImg.width),
            AutoLayout.height:eq(self.m_uploadImg.height),
            AutoLayout.top:eq(440),
            AutoLayout.right:eq(AutoLayout.parent("width")-30),
        }

        self.m_firstPage:add(self.m_uploadImg)

        if not self.m_submitTips then
            self.m_submitTips, bg = kefuCommon.createSubmitTips()
            self.m_root:add(self.m_submitTips)
            self.m_root:add(bg)
        end
        self.m_submitTips.showTips()
        
        local uploadRequest = require('network.http2');
        --上传图片
        uploadRequest.request_async(args,
            function(rsp)
                if rsp.errmsg or rsp.code ~= 200 then
                    Log.v("uploadRequest" ,"==failed:", rsp.errmsg, rsp.code)
                    self.m_submitTips.hideTips("提交失败")
                else
                    local content = json.decode(rsp.content)
                    if content.code == 0 then
                        Log.v("uploadRequest" ,"上传图片成功")

                        self.m_imgUrl = {}
                        local imgUrl = FILE_UPLOAD_HOST..content.file
                        table.insert(self.m_imgUrl, imgUrl)
                        self.m_submitTips.hideTips("上传图片成功",1)
                        self.m_status[4] = true
                        
                        if self.m_selectTxt == "通牌作弊" then
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
                    else
                        Log.v("uploadRequest" ,"返回结果不正确", content.code)
                        self.m_submitTips.hideTips("提交失败")
                    end
                  
                end

            end
        )
    end,

    onBackEvent = function (self)
        local data = UserData.getStatusData() or {}
        if data.isVip then
            ViewManager.showVipChatView(View_Anim_Type.LTOR)
        else
            ViewManager.showNormalChatView(View_Anim_Type.LTOR)
        end
    end,

    onDelete = function (self)
        self.m_newCommit = nil
        if self.m_commitClock then
            self.m_commitClock:cancel()
            self.m_commitClock = nil
        end
    end,

} )


return hackAppealView