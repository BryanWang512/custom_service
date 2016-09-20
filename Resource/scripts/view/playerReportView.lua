local UI = require('byui/basic')
local AutoLayout = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local Layout = require('byui/layout')
local Anim = require(string.format('%sanimation', KefuRootPath))
local baseView = require(string.format('%sview/baseView', KefuRootPath))
local SelComponent = require(string.format('%sview/selComponent', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))

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
                { 0.0, { x = sliderBlock.x }, Anim.accelerate_decelerate },
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
                { 0.0, { x = sliderBlock.x }, Anim.accelerate_decelerate },
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

local playerReportView
local root

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


local addFirstPageSub1 = function()
    local container = Widget()
    container:add_rules(AutoLayout.rules.fill_parent)

    local itemsData = {
        { title = "被盗ID", hint_text = "请输入需要申诉的ID", ui_type = "edit", icon = KefuResMap.commonNecessary },
        { title = "被盗时间", hint_text = "请选择被盗时间", ui_type = "label", icon = KefuResMap.commonMore },
        { title = "被盗金额", hint_text = "请输入被盗金额", ui_type = "edit", icon = KefuResMap.commonNecessary }
    }

    for i = 1, 3 do
        local item = Widget()
        item:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(90),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.top:eq(90 *(i - 1)),
        } )
        container:add(item)

        local line = Widget()
        line:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(1),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.top:eq(90),
        } )
        line.background_color = Colorf(0.77, 0.77, 0.77, 1)
        item:add(line)

        local title = Label()
        title.align = Label.CENTER
        title:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, itemsData[i].title))
        title:add_rules( {
            AutoLayout.width:eq(200),
            AutoLayout.height:eq(42),

            AutoLayout.left:eq(30),
            AutoLayout.top:eq(24),
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
            edit:add_rules( {
                AutoLayout.width:eq(450),
                AutoLayout.height:eq(80),

                AutoLayout.left:eq(209),
                AutoLayout.top:eq(18),
            }
            )
            -- edit.name = "editID"
            edit.keyboard_type = Application.KeyboardTypeNumberPad
            item:add(edit)
        elseif itemsData[i].ui_type == "label" then
            local label = Label()
            label:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, itemsData[i].hint_text))
            label:add_rules( {
                AutoLayout.width:eq(500),
                AutoLayout.height:eq(20),

                AutoLayout.left:eq(218),
                AutoLayout.top:eq(24),
            }
            )
            item:add(label)

            if i == 2 then
                local container = Widget()
                container:add_rules( {
                    AutoLayout.width:eq(600),
                    AutoLayout.height:eq(90),

                    AutoLayout.left:eq(218),
                }
                )
                -- container.background_color = Colorf.green
                item:add(container)

                local popup = false
                local selcomp = SelComponent(root, { title = "被盗时间", action = "确定", ui_type = 1 })
                selcomp.btn_callback = function(str)
                    label:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, str))
                end
                local callback = function()
                    if popup then
                        selcomp:pop_back( function()
                            container.enabled = true
                        end )
                        popup = false
                    else
                        container.enabled = false
                        selcomp:pop_up()
                        popup = true
                    end
                end

                UI.init_simple_event(container, callback)
            end
        end

        if itemsData[i].icon then
            local icon = Sprite(TextureUnit(TextureCache.instance():get(itemsData[i].icon)))
            icon:add_rules( {
                AutoLayout.left:eq(AutoLayout.parent('width') -30),
                AutoLayout.centery:eq(45),
            }
            )
            item:add(icon)
        end
    end

    local btnNext = UI.Button {
        text = string.format('<font color=#ffffff size=%d>%s</font>',34,"下一步"),
        radius = 10,
        margin = { 10, 10, 10, 10 },
        image =
        {
            normal = Colorf(0.43,0.73,0.17,1.0),
            down = Colorf(0.77,0.77,0.77,1),
            disabled = Colorf(0.77,0.77,0.77,1),
        },
    }
    btnNext:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(100),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(850),
    }
    )
    container:add(btnNext)

    btnNext.state = "disabled"
    btnNext.on_click = function()
        self.m_pageSub1.visible = false
        self.m_pageSub2.visible = true
        self.m_pageSub3.visible = false
    end

    return container
end

local addFirstPageSub2 = function()
    local container = Widget()
    container:add_rules(AutoLayout.rules.fill_parent)

    local createItem =( function()
        local index = 1
        return function(caption, callback)
            local item = Widget()
            item:add_rules( {
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(90),

                AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
                AutoLayout.top:eq(90 *(index - 1)),
            } )
            container:add(item)

            local line = Widget()
            line:add_rules( {
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(1),

                AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
                AutoLayout.top:eq(90),
            } )
            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            item:add(line)

            if caption.content.ui_type == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=%d>%s</font>',30,""),
                    hint_text = string.format('<font color=#9b9b9b size=%d>%s</font>',30,caption.content.hint_text),
                }
                edit:add_rules( {
                    AutoLayout.width:eq(600),
                    AutoLayout.height:eq(80),

                    AutoLayout.left:eq(20),
                    AutoLayout.top:eq(18),
                }
                )
                -- edit.name = "editID"
                edit.keyboard_type = Application.KeyboardTypeNumberPad
                item:add(edit)
            elseif caption.content.ui_type == "label" then
                local label = Label()
                label:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, caption.content.hint_text))
                label:add_rules( {
                    AutoLayout.width:eq(600),
                    AutoLayout.height:eq(20),

                    AutoLayout.left:eq(30),
                    AutoLayout.top:eq(24),
                }
                )
                item:add(label)
            end

            if caption.icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(caption.icon)))
                icon:add_rules( {
                    AutoLayout.left:eq(AutoLayout.parent('width') -30),
                    AutoLayout.centery:eq(45),
                }
                )
                item:add(icon)
            end

            index = index + 1
            return item
        end
    end )()

    createItem( { content = { hint_text = "请输入登录游戏时常用IP及地区", ui_type = "edit" }, icon = KefuResMap.commonNecessary })
    createItem( { content = { hint_text = "请选择被盗时间", ui_type = "edit" }, icon = KefuResMap.commonNecessary })
    createItem( { content = { hint_text = "请输入最后一次下线时间的游戏币数量", ui_type = "label" }, icon = KefuResMap.commonMore })
    createItem( { content = { hint_text = "请输入第一次加入游戏的时间", ui_type = "label" }, icon = KefuResMap.commonMore })
    createItem( { content = { hint_text = "请输入最后一次登录游戏的时间", ui_type = "edit" } })

    local btnNext = UI.Button {
        text = string.format('<font color=#ffffff size=%d>%s</font>',34,"下一步"),
        radius = 10,
        margin = { 10, 10, 10, 10 },
        image =
        {
            normal = Colorf(0.43,0.73,0.17,1.0),
            down = Colorf(0.77,0.77,0.77,1),
            disabled = Colorf(0.77,0.77,0.77,1),
        },
    }
    btnNext:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(100),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(850),
    }
    )
    container:add(btnNext)

    btnNext.enable = false
    btnNext.on_click = function()
        self.m_pageSub1.visible = false
        self.m_pageSub2.visible = false
        self.m_pageSub3.visible = true
    end

    return container
end

local addFirstPageSub3 = function()
    local container = Widget()
    container:add_rules(AutoLayout.rules.fill_parent)

    local labelTitle = Label()
    labelTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 40, "申诉协议"))
    labelTitle:add_rules( {
        AutoLayout.width:eq(200),
        AutoLayout.height:eq(40),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(80),
    }
    )
    labelTitle:update(false)
    container:add(labelTitle)

    local labelContent = Label()
    labelContent.multiline = true
    labelContent:set_rich_text([[<font size=30 color=#000000>如果金币找回，您的金币将补还至</font><font size=30 color=#ff0000>ID:54</font><font size=30 color=#000000>，具体找回金额以实际情况为准，还请您确认该账号的安全，如果该账号两星期内再次发生被盗，将不予找回。</font>]])
    labelContent:add_rules( {
        AutoLayout.height:eq(40),

        AutoLayout.left:eq(100),
        AutoLayout.top:eq(128 + labelTitle.height),
    }
    )
    labelContent:update(false)
    labelContent.layout_size = Point(600, 80)
    container:add(labelContent)

    local radioAgree = UI.RadioButton {
        size = Point(50,50),
        checked = true,
        image =
        {
            checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.commonSelected)),
            unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.commonNotsel)),
        }
    }
    radioAgree:add_rules( {
        AutoLayout.left:eq(160),
        AutoLayout.top:eq(326 + labelTitle.height + labelContent.height),
    } )
    container:add(radioAgree)

    local labelAgree = Label()
    labelAgree:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "同意"))
    labelAgree:add_rules( {
        AutoLayout.width:eq(200),
        AutoLayout.height:eq(40),

        AutoLayout.left:eq(AutoLayout.parent('width') + 14),
        AutoLayout.top:eq(10),
    }
    )
    labelAgree:update(false)
    radioAgree:add(labelAgree)

    local radioAgainst = UI.RadioButton {
        size = Point(50,50),
        checked = false,
        image =
        {
            checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.commonSelected)),
            unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.commonNotsel)),
        }
    }
    radioAgainst:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') -350),
        AutoLayout.top:eq(326 + labelTitle.height + labelContent.height),
    } )
    container:add(radioAgainst)

    local labelAgainst = Label()
    labelAgainst:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "不同意"))
    labelAgainst:add_rules( {
        AutoLayout.width:eq(200),
        AutoLayout.height:eq(40),

        AutoLayout.left:eq(AutoLayout.parent('width') + 14),
        AutoLayout.top:eq(10),
    }
    )
    labelAgainst:update(false)
    radioAgainst:add(labelAgainst)

    local radioGroup = UI.RadioGroup { }
    function radioGroup:on_change(id)
        print('radioGroup on change', id)
    end
    radioAgree.group = radioGroup
    radioAgainst.group = radioGroup

    local btnCommit = UI.Button {
        text = string.format('<font color=#ffffff size=%d>%s</font>',34,"提交"),
        radius = 10,
        margin = { 10, 10, 10, 10 },
        image =
        {
            normal = Colorf(0.43,0.73,0.17,1.0),
            down = Colorf(0.77,0.77,0.77,1),
            disabled = Colorf(0.77,0.77,0.77,1),
        },
    }
    btnCommit:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(100),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(850),
    }
    )
    container:add(btnCommit)

    btnCommit.state = "disabled"

    btnCommit.on_click = function()
        self.m_pageSub1.visible = true
        self.m_pageSub2.visible = false
        self.m_pageSub3.visible = false
    end

    return container
end

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

    local line = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.kefuLine)))
    line.v_border = {0,4,0,4}
    line.t_border = {0,4,0,4}
    line:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(10),
        AutoLayout.bottom:eq(AutoLayout.parent('height')+4),

    } )
    line.colorf = Colorf(0.0, 0.0, 0.0, 1)
    btnItem:add(line)

    local txtTitle = Label()
    txtTitle:set_rich_text('<font color=#000000 size=30>盗号申诉</font>')
    txtTitle:add_rules{
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(30),
    }

    btnItem:add(txtTitle)

    local txtTime = Label()
    local timeStr = os.date("%Y-%m-%d %H:%M", data.time)
    txtTime:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, timeStr))
    btnItem:add(txtTime)
    txtTime:update()

    txtTime:add_rules{
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),
        AutoLayout.left:eq(AutoLayout.parent('width') - txtTime.width - 70),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.44),
    }

    -- 创建箭头图标
    local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonUnfold)))
    arrowIcon:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') -30),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    } )
    btnItem:add(arrowIcon)

    -- 创建箭头图标
    local arrowIcon1 = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonRetract)))
    arrowIcon1:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') -30),
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

--回复
    posY = posY + space*2 + 30          --30为文字高    
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

playerReportView = class('playerReportView', baseView, {
    __init__ = function(self)
        super(playerReportView, self).__init__(self)
        self.m_status = {}
        root = self.m_root
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
        self.m_root:add(topContainer)
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>盗号申诉</font>"))
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
                --ViewManager.showPreView(View_Anim_Type.LTOR)
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

        sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)
        tabBg:add(sliderBlock)

        

        local btnAppealAgainst = UI.Button {
            text = '<font color=#f4c493 size=30>我要申诉</font>',
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
            text = '<font color=#9b9b9b size=30>申诉历史</font>',
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
            -- body
            local action = Anim.keyframes {
                -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
                { 0.0, { x = sliderBlock.x }, Anim.accelerate_decelerate },
                { 1.0, { x = 0 }, nil },
            }

            local move = Anim.duration(0.3, action)

            local anim = Anim.Animator()
            anim:start(move, function(v)
                sliderBlock.x = v.x
            end , true)
            page_view.page_num = 1
            btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '我要申诉')
            btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', '申诉历史')
        end

        btnAppealHistory.on_click = function()
            -- body
            local action = Anim.keyframes {
                -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
                { 0.0, { x = sliderBlock.x }, Anim.accelerate_decelerate },
                { 1.0, { x = sliderBlock.width }, nil },
            }

            local move = Anim.duration(0.3, action)

            local anim = Anim.Animator()
            anim:start(move, function(v)
                sliderBlock.x = v.x
            end , true)
            page_view.page_num = 2
            btnAppealAgainst.text = string.format('<font color=#9b9b9b size=30>%s</font>', '我要申诉')
            btnAppealHistory.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '申诉历史')
        end

        btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '我要申诉')
        btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', '申诉历史')


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
        page_view:update_data()
        self.m_pageView = page_view

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if self.m_pageView.page_num == 1 then
                btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '我要申诉')
                btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', '申诉历史')
            else
                btnAppealAgainst.text = string.format('<font color=#9b9b9b size=30>%s</font>', '我要申诉')
                btnAppealHistory.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, '申诉历史')
            end
        end

        self.m_root:add(topContainer)
    end,

    initPage = function (self, i)
        local container = Widget()
        if i == 1 then
            local container = Widget()
            container:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')-1),
                AutoLayout.height:eq(AutoLayout.parent('height')),
            }

            self.m_pageSub1 = self:addPageSub1()
            -- self.m_pageSub2 = addFirstPageSub2()
            -- self.m_pageSub3 = addFirstPageSub3()
            -- self.m_pageSub2.visible = false
            -- self.m_pageSub3.visible = false
            container:add(self.m_pageSub1)
            -- container:add(self.m_pageSub2)
            -- container:add(self.m_pageSub3)
            return container
        elseif i == 2 then
            local container = Widget()
            container:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(AutoLayout.parent('height')),
            }

            self.m_listview = UI.ListView {
                size = container.size,
                create_cell = function(data)
                    local container = createHistoryItem(data)
                    return container
                end,
            }
            self.m_listview:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(AutoLayout.parent('height')),
                AutoLayout.left:eq(1),
            }
            container:add(self.m_listview)
            self.m_listview.velocity_factor = 3.1

            self.m_noRecordLabel = Label()
            self.m_noRecordLabel:set_rich_text(string.format("<font color=#9b9b9b bg=#00000000 size=44 weight=3>暂无任何记录</font>"))
            container:add(self.m_noRecordLabel)
            self.m_noRecordLabel.absolute_align = ALIGN.CENTER
            self.m_listview.background_color = Colorf(244/255, 244/255, 244/255, 1)

            return container
        end

    end,

    addPageSub1 = function (self)
        local container = Widget()
        container:add_rules(AutoLayout.rules.fill_parent)

        local itemsData = {
            { title = "被盗ID", hint_text = "请输入需要申诉的ID", ui_type = "edit", icon = KefuResMap.commonNecessary },
            { title = "被盗时间", hint_text = "请选择被盗时间", ui_type = "label", icon = KefuResMap.commonMore },
            { title = "被盗金额", hint_text = "请输入被盗金额", ui_type = "edit", icon = KefuResMap.commonNecessary }
        }

        self.m_Items = {}
        local height = 110

        for i = 1, 3 do
            local item = Widget()
            item:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(height),
                AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
                AutoLayout.top:eq(height*(i-1)),
            }
            container:add(item)
            self.m_Items[i] = item

            local line = Widget()
            line:add_rules{
                AutoLayout.width:eq(AutoLayout.parent('width')),
                AutoLayout.height:eq(2.5),
                AutoLayout.bottom:eq(AutoLayout.parent('height')),
            }
            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            item:add(line)

            local title = Label()
            title.align = Label.CENTER
            title:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, itemsData[i].title))
            title:add_rules{
                AutoLayout.left:eq(30),
                AutoLayout.top:eq(40),
            }
            
            item:add(title)

            if itemsData[i].ui_type == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=30>%s</font>',""),
                    hint_text = string.format('<font color=#9b9b9b size=30>%s</font>',itemsData[i].hint_text),
                }
                edit:add_rules{
                    AutoLayout.width:eq(AutoLayout.parent('width')-220),
                    AutoLayout.height:eq(80),
                    AutoLayout.left:eq(220),
                    AutoLayout.top:eq(40),
                }

                edit.keyboard_type = Application.KeyboardTypeNumberPad
                item:add(edit)
                if i == 1 then
                    self.m_editId = edit
                else
                    self.m_editLostMoney = edit
                end
            elseif itemsData[i].ui_type == "label" then
                local typeWg = Widget()
                typeWg:add_rules{
                    AutoLayout.width:eq(AutoLayout.parent('width')-220),
                    AutoLayout.height:eq(AutoLayout.parent('height')),
                    AutoLayout.left:eq(220),
                    AutoLayout.top:eq(0),
                }
                item:add(typeWg)

                local label = Label()
                label:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', itemsData[i].hint_text))
                label.absolute_align = ALIGN.LEFT
                typeWg:add(label)
                self.m_typeLabel = label

                self.m_selComp = SelComponent(self.m_root, {title = "被盗时间", action = "确定", ui_type = 1})

                UI.init_simple_event(typeWg, function ()
                    self.m_selComp:pop_up()
                end)

                self.m_selComp.btn_callback = function(str)
                    label:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', str))
                    self.m_status[2] = true
                    self.m_selectTxt = str

                    --todo
                    -- if self.m_status[1] and self.m_status[2] and self.m_status[3] then
                    --     if not self.m_btnCommit.enabled then
                    --         self.m_btnCommit.enabled = true
                    --         self.m_btnCommit.state = "normal"
                    --     end
                    -- elseif self.m_btnCommit.enabled then
                    --     self.m_btnCommit.enabled = false
                    --     self.m_btnCommit.state = "disabled"
                    -- end
                end

            end

            if itemsData[i].icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(itemsData[i].icon)))
                icon:add_rules{
                    AutoLayout.left:eq(AutoLayout.parent('width') -30),
                    AutoLayout.centery:eq(50),
                }
                item:add(icon)
            end
        end

        local btnNext = UI.Button {
            text = string.format('<font color=#ffffff size=%d>%s</font>',34,"下一步"),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(0.43,0.73,0.17,1.0),
                down = Colorf(0.77,0.77,0.77,1),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        btnNext:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width') * 0.92),
            AutoLayout.height:eq(100),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.bottom:eq(AutoLayout.parent('height')-30),
        }
        container:add(btnNext)

        btnNext.state = "disabled"
        btnNext.on_click = function()
            self.m_pageSub1.visible = false
            self.m_pageSub2.visible = true
            self.m_pageSub3.visible = false
        end

        return container
    end,

    -- 需要重载该函数
    onUpdate = function(self, ...)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end
        
        self.m_pageView.page_num = 1
        local data = UserData.getStatusData()
        sliderBlock.x = 0
        self:setNormalItem()
    end,

    onBackEvent = function (self)
        local data = UserData.getStatusData() or {}
        if data.isVip then
            ViewManager.showVipChatView(View_Anim_Type.LTOR)
        else
            ViewManager.showNormalChatView(View_Anim_Type.LTOR)
        end
    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text("<font color=#ffffff bg=#00000000 size=34 weight=3>盗号申诉</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = "<font color=#ffffff bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text("<font color=#F4C392 bg=#00000000 size=34 weight=3>盗号申诉</font>")
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip))
            self.m_btnBack.text = "<font color=#F4C392 bg=#00000000 size=28>返回</font>"
            sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)

        end
    end,
} )


return playerReportView