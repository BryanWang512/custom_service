local baseView = require("view.baseView")
local UI = require('byui/basic')
local AutoLayout = require('byui/autolayout')
local Anim = require("animation")
local Layout = require('byui/layout')
require("byui/utils")
local SelComponent = require("view/selComponent")
local class, mixin, super = unpack(require('byui/class'))

local page_view
local sliderBlock
local MyPageView
MyPageView = class('MyPageView', UI.PageView, {
    on_touch_up = function(self, p, t)
        super(MyPageView, self).on_touch_up(self, p, t)
        if page_view.page_num == 2 then
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
    buttomContainer =
    {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(AutoLayout.parent('height') -100),

        AutoLayout.top:eq(100),
    },

    tab_bg =
    {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(6),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(20),
    },
    slider_block =
    {
        AutoLayout.width:eq(AutoLayout.parent('width') / 2),
        AutoLayout.height:eq(6),
    },
    btn_appeal_against =
    {
        AutoLayout.width:eq((AutoLayout.parent('width') -40) / 2),
        AutoLayout.height:eq(100),

        AutoLayout.left:eq(20),
        AutoLayout.top:eq(20),
    },

    btn_appeal_history =
    {
        AutoLayout.width:eq((AutoLayout.parent('width') -40) / 2),
        AutoLayout.height:eq(100),

        AutoLayout.left:eq(AutoLayout.parent('width') * 0.025 + AutoLayout.parent('width') * 0.95 / 2),
        AutoLayout.top:eq(20),
    },
    part_line =
    {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(2),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(119),
    },
    page_view =
    {
        AutoLayout.width:eq(AutoLayout.parent('width') -40),
        AutoLayout.height:eq(AutoLayout.parent('height') -120),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(120),
    },
}

local firstPageSub1
local firstPageSub2
local firstPageSub3

local addFirstPageSub1 = function()
    local container = Widget()
    container:add_rules(AutoLayout.rules.fill_parent)

    local itemsData = {
        { title = "被盗ID", hint_text = "请输入需要申诉的ID", ui_type = "edit", icon = "common/necessary.png" },
        { title = "被盗时间", hint_text = "请选择被盗时间", ui_type = "label", icon = "common/more.png" },
        { title = "被盗金额", hint_text = "请输入被盗金额", ui_type = "edit", icon = "common/necessary.png" }
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
        print_string("btnCommit.on_click")
        firstPageSub1.visible = false
        firstPageSub2.visible = true
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

    createItem( { content = { hint_text = "请输入登录游戏时常用IP及地区", ui_type = "edit" }, icon = "common/necessary.png" })
    createItem( { content = { hint_text = "请选择被盗时间", ui_type = "edit" }, icon = "common/necessary.png" })
    createItem( { content = { hint_text = "请输入最后一次下线时间的游戏币数量", ui_type = "label" }, icon = "common/more.png" })
    createItem( { content = { hint_text = "请输入第一次加入游戏的时间", ui_type = "label" }, icon = "common/more.png" })
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
        firstPageSub2.visible = false
        firstPageSub3.visible = true
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
            checked_enabled = TextureUnit(TextureCache.instance():get('common/selected.png')),
            unchecked_enabled = TextureUnit(TextureCache.instance():get('common/notsel.png')),
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
            checked_enabled = TextureUnit(TextureCache.instance():get('common/selected.png')),
            unchecked_enabled = TextureUnit(TextureCache.instance():get('common/notsel.png')),
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

    -- btnCommit.enabled = false
    btnCommit.on_click = function()
        firstPageSub1.visible = true
        firstPageSub3.visible = false
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
        AutoLayout.height:eq(89),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(1),
    } )
    container:add(btnItem)

    local line = Widget()
    line:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(1),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(89),
    } )
    line.background_color = Colorf(0.0, 0.0, 0.0, 1)
    btnItem:add(line)

    local txtTitle = Label()
    txtTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "盗号申诉"))
    txtTitle:add_rules( {
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(30),
    } )
    btnItem:add(txtTitle)

    local txtTime = Label()
    txtTime:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, data.time))
    txtTime:add_rules( {
        AutoLayout.width:eq(150),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(AutoLayout.parent('width') * 0.54),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.44),
    } )
    btnItem:add(txtTime)

    -- 创建箭头图标
    local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get("common/unfold.png")))
    arrowIcon:add_rules( {
        AutoLayout.left:eq(AutoLayout.parent('width') -30),
        AutoLayout.centery:eq(AutoLayout.parent('height') * 0.5),
    } )
    btnItem:add(arrowIcon)

    -- 创建箭头图标
    local arrowIcon1 = Sprite(TextureUnit(TextureCache.instance():get("common/retract.png")))
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
    contentCon.background_color = color_to_colorf(Color(230, 230, 230, 220))
    contentCon.visible = false
    container:add(contentCon)


    local txtNo = Label()
    txtNo:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "编号:"))
    txtNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(30),
    } )
    contentCon:add(txtNo)

    local txtReply = Label()
    txtReply:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, "客服回复:"))
    txtReply:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(30),
        AutoLayout.top:eq(120),
    } )
    contentCon:add(txtReply)

    local labelNo = Label()
    labelNo:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "258"))
    labelNo:add_rules( {
        AutoLayout.width:eq(60),
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(120),
        AutoLayout.top:eq(30),
    } )
    contentCon:add(labelNo)

    local labelReply = Label()
    labelReply.multiline = true
    labelReply:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, "客服人员正在处理中，将在3个工作日内给予答复，如果情况紧急，您可以联系语音客服反馈此问题或联系在线客服反馈此问题"))
    labelReply:add_rules( {
        AutoLayout.height:eq(20),

        AutoLayout.left:eq(180),
        AutoLayout.top:eq(120),
    } )
    labelReply.layout_size = Point(600, 20)
    contentCon:add(labelReply)
    labelReply:update(false)
    contentCon.height_hint = labelReply.height + 150

    local line = Widget()
    line:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(1),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        AutoLayout.top:eq(90),
    } )
    line.background_color = Colorf(0.0, 0.0, 0.0, 1)
    contentCon:add(line)

    local lineBottom = Widget()
    lineBottom:add_rules( {
        AutoLayout.width:eq(AutoLayout.parent('width')),
        AutoLayout.height:eq(1),

        AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),

        AutoLayout.bottom:eq(contentCon.height_hint),
    } )
    lineBottom.background_color = Colorf(0.0, 0.0, 0.0, 1)
    contentCon:add(lineBottom)

    btnItem.on_click = function()
        arrowIcon.visible = contentCon.visible
        arrowIcon1.visible = not contentCon.visible
        contentCon.visible = not contentCon.visible

        Clock.instance():schedule_once( function()
            container.height_hint = contentCon.bbox.h + 90
            container:update_constraints()
        end )

    end

    return container
end

local initPage = function(i)
    local container = Widget()
    container:add_rules(AutoLayout.rules.fill_parent)

    if i == 1 then
        firstPageSub1 = addFirstPageSub1()
        firstPageSub2 = addFirstPageSub2()
        firstPageSub3 = addFirstPageSub3()
        firstPageSub2.visible = false
        firstPageSub3.visible = false
        container:add(firstPageSub1)
        container:add(firstPageSub2)
        container:add(firstPageSub3)
    elseif i == 2 then
        local dataHistory = {
            { height = 200, color = Colorf.red, title = "11111", No = "254", ID = "111", Type = "刷分倒币", time = "2016-07-12  17:28" },
            { height = 300, color = Colorf(0.8, 0.5, 0.3), title = "22222", time = "2016-07-12  13:45" },
            { height = 50, color = Colorf(0.2, 0.5, 0.9), title = "33333", time = "2016-07-12  07:26" },
            { height = 100, color = Colorf(0.2, 0.7, 0.3), title = "44444", time = "2016-07-12  11:24" },
            { color = Colorf(0.2, 0.3, 0.3), title = "55555", time = "2016-07-12  17:28" },
            { height = 30, color = Colorf(1.0, 0.5, 0.3), title = "66666", time = "2016-07-12  01:28" },
        }

        local listviewHistory = UI.ListView {
            size = container.size,
            create_cell = function(data)
                local container = createHistoryItem(data)
                return container
            end,
        }
        listviewHistory:add_rules(AutoLayout.rules.fill_parent)
        container:add(listviewHistory)

        listviewHistory.data = dataHistory
    elseif i == 3 then
        addFirstPageSub1(container)
    end

    return container
end

playerReportView = class('playerReportView', baseView, {
    __init__ = function(self)
        super(playerReportView, self).__init__(self)
        root = self.m_root
        -- ==============================================top=========================================================
        local topContainer = Widget()
        topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
        topContainer:add_rules(rules.top_container)
        self.m_root:add(topContainer)

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>盗号申诉</font>"))
        txtTitle.absolute_align = ALIGN.CENTER
        topContainer:add(txtTitle)

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
                ViewManager.showPreView(View_Anim_Type.LTOR)
            end
        }
        btnBack:add_rules(rules.btn_back)
        topContainer:add(btnBack)

        -- 创建箭头图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get("common/vip_back.png")))
        arrowIcon:add_rules(rules.arrow_icon)
        btnBack:add(arrowIcon)

        -- ==============================================tab=========================================================
        local buttomContainer = Widget()
        buttomContainer.background_color = Colorf(1.0, 1.0, 1.0, 1.0)
        buttomContainer:add_rules(rules.buttomContainer)
        self.m_root:add(buttomContainer)

        -- tab 的灰色背景条
        local tabBg = Widget()
        tabBg:add_rules(rules.tab_bg)
        tabBg.background_color = Colorf(0.68, 0.68, 0.68, 1)
        buttomContainer:add(tabBg)

        sliderBlock = Widget()
        sliderBlock:add_rules(rules.slider_block)
        sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)
        tabBg:add(sliderBlock)

        page_view = MyPageView {
            dimension = kHorizental,
            max_number = 4,
        }
        page_view.background_color = Colorf.white
        page_view.zorder = 1
        page_view:add_rules(rules.page_view)
        buttomContainer:add(page_view)

        page_view.create_cell = function(self, i)
            local page = initPage(i)
            return page
        end
        page_view:update_data()

        local btnAppealAgainst = UI.Button {
            text = string.format('<font color=#f4c493 size=%d>%s</font>',30,'我要申诉'),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
            border = true,

        }

        btnAppealAgainst:add_rules(rules.btn_appeal_against)
        buttomContainer:add(btnAppealAgainst)

        local btnAppealHistory = UI.Button {
            text = string.format('<font color=#9b9b9b size=%d>%s</font>',30,'申诉历史'),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
            border = true,

        }
        btnAppealHistory:add_rules(rules.btn_appeal_history)
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
            btnAppealAgainst.text = string.format('<font color=#f4c493 size=%d>%s</font>', 30, '我要申诉')
            btnAppealHistory.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '申诉历史')
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
            btnAppealAgainst.text = string.format('<font color=#9b9b9b size=%d>%s</font>', 30, '我要申诉')
            btnAppealHistory.text = string.format('<font color=#f4c493 size=%d>%s</font>', 30, '申诉历史')
        end

        -- tapTOp 分界线
        local partLine = Sprite(TextureUnit.default_unit())
        partLine:add_rules(rules.part_line)
        partLine.colorf = Colorf(0.77, 0.77, 0.77, 1)
        buttomContainer:add(partLine)

    end,

    -- 需要重载该函数
    onUpdate = function(self, ...)
        -- body
    end,

} )


return playerReportView