local UI = require('byui/basic')
local AutoLayout = require('byui/autolayout')
local Anim = require("animation")
local class, mixin, super = unpack(require('byui/class'))
local PV = require('view/pickerView')

local selComponent
selComponent = class('selComponent', nil, {
    __init__ = function(self, root, data)
        self.root = root
        self.m_spaceBtn = UI.Button{
            text = "",
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.0),
                disabled = Colorf(0.2,0.2,0.2,0.0),
            },
            border = true,
            on_click = function()
                self:pop_back()
            end
        }
        self.root:add(self.m_spaceBtn)
        self.m_spaceBtn:add_rules{
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(AutoLayout.parent('height')-530),          
        }

        self.m_spaceBtn.visible = false

        self.container = Widget()
        self.container:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(530 ),
            AutoLayout.top:eq(AutoLayout.parent('height')),
            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        } )
        self.container.background_color = Colorf.white

        root:add(self.container)

        local topContainer = Widget()
        topContainer:add_rules( {
            AutoLayout.width:eq(AutoLayout.parent('width')),
            AutoLayout.height:eq(90),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
        } )
        topContainer.background_color = color_to_colorf(Color(230, 230, 230)),
        self.container:add(topContainer)

        local labelTitle = Label()
        labelTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 34, data.title))
        labelTitle.absolute_align = ALIGN.CENTER
        topContainer:add(labelTitle)

        self.m_finishBtn = UI.Button{
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.5,0.5,0.5,0.3),
            },
            border = false,
            text = string.format('<font color=#000000 size=34>%s</font>', data.action),
        }

        self.m_finishBtn:add_rules{
            AutoLayout.width:eq(130),
            AutoLayout.height:eq(AutoLayout.parent('height')),
            AutoLayout.right:eq(AutoLayout.parent('width')),
        }

        topContainer:add(self.m_finishBtn)

        if data.ui_type == 1 then
            self:createTimePacker()
        elseif data.ui_type == 2 then
            self:createTypePacker(data.title)   
        end

        for i = 1, 2 do
            local line = Widget()
            line.zorder = 3
            line:add_rules( {
                AutoLayout.width:eq(AutoLayout.parent('width') -80),
                AutoLayout.height:eq(2.5),

                AutoLayout.left:eq(40),
                AutoLayout.top:eq(280 +(i - 1) * 60),
            } )
            line.background_color = Colorf(106/255, 106/255, 106/255, 1)
            self.container:add(line)
        end

        self.anim = Anim.Animator()
    end,
    pop_up = function(self)
        self.container.visible = true
        self.m_spaceBtn.visible = true
        self.anim.on_stop = nil
        self.container.autolayout_mask = Widget.AL_MASK_TOP
        local action = Anim.keyframes {
            -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
            { 0.0, { y = self.root.height }, Anim.anticipate_overshoot() },
            { 1.0, { y = (self.root.height - self.container.height) }, nil },
        }

        local move = Anim.duration(0.7, action)

        self.anim:start(move,
        function(v)
            self.container.y = v.y
        end)
    end,

    pop_back = function(self)
        self.container.autolayout_mask = Widget.AL_MASK_TOP
        local action = Anim.keyframes {
            -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
            { 0.0, { y = self.root.height - self.container.height }, Anim.anticipate_overshoot() },
            { 1.0, { y = self.root.height }, nil },
        }

        local move = Anim.duration(0.7, action)

        -- 使用 Animator 来运行动画, 第三个参数表示循环播放，Anim.updator为默认的更新widget属性的函数。
        self.anim:start(move,
        function(v)
            self.container.y = v.y
        end)

        self.m_spaceBtn.visible = false
        self.anim.on_stop = function ()
            self.container.visible = false
        end
    end,

    createTypePacker = function(self, title)
        local data = {
            "通牌作弊",
            "滥发广告",
            "刷分倒币",
            "捣乱游戏",
            "不雅用语",
        }

        local leaveData = {
            "无法登陆",
            "支付问题",
            "故障问题",
            "游戏问题",
            "其他",
        }
        if title == "留言类型" then
            data = leaveData
        end


        local pickerType = PV.PickerView {
            size = Point(300,100),
            row_height = 440 / 7
        }
        pickerType.data = data
        pickerType.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerType:add_rules( {
            AutoLayout.width:eq(300),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.centerx:eq(AutoLayout.parent('width')*0.5),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerType)

        pickerType.on_change_select = function(index)
            self.result = data[index]
        end

        self.m_finishBtn.on_click = function ()
            self:pop_back()
            if self.btn_callback then
                self.btn_callback(self.result)
            end
        end


    end,

    createTimePacker = function(self)
        self.m_finishBtn.on_click = function ()
            self:pop_back()
            self.result = self.year .. "-" .. self.month .. "-" .. self.day .. " " .. self.hour .. ":" .. self.min
            if self.btn_callback then
                self.btn_callback(self.result)
            end
        end

        local year = os.date("%Y", os.time())
        local month = os.date("%m", os.time())
        local day = os.date("%d", os.time())
        local hour = os.date("%H", os.time())
        local min = os.date("%M", os.time())

        self.result = year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. min

        local listYearData = { }

        for i = 1, year - 2003 do
            listYearData[i] = tostring(2003 + i) .. "年"
        end

        local listMonthData = { }
        for i = 1, 12 do
            listMonthData[i] = i < 10 and "0" .. tostring(i) .. "月" or "" .. tostring(i) .. "月"
        end

        local listDayData = { }
        for i = 1, 31 do
            listDayData[i] = i < 10 and "0" .. tostring(i) .. "日" or "" .. tostring(i) .. "日"
        end

        local listHourData = { }
        for i = 1, 24 do
            listHourData[i] = i - 1 < 10 and "0" .. tostring(i - 1) .. "时" or "" .. tostring(i - 1) .. "时"
        end

        local listMinData = { }
        for i = 1, 59 do
            listMinData[i] = i < 10 and "0" .. tostring(i) .. "分" or "" .. tostring(i) .. "分"
        end

        local pickerYear = PV.PickerView {
            size = Point(150,100),
            row_height = 440 / 7
        }
        pickerYear.data = listYearData
        pickerYear.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerYear:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.left:eq(50),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerYear)


        local pickerMonth = PV.PickerView {
            size = Point(150,600),
            row_height = 440 / 7
        }
        pickerMonth.data = listMonthData
        pickerMonth.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerMonth:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.33),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerMonth)


        local pickerDay = PV.PickerView {
            size = Point(150,600),
            row_height = 440 / 7
        }
        pickerDay.data = listDayData
        pickerDay.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerDay:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.5),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerDay)

        local pickerHour = PV.PickerView {
            size = Point(150,600),
            row_height = 440 / 7
        }
        pickerHour.data = listHourData
        pickerHour.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerHour:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.centerx:eq(AutoLayout.parent('width') * 0.68),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerHour)

        local pickerMin = PV.PickerView {
            size = Point(150,600),
            row_height = 440 / 7
        }
        pickerMin.data = listMinData
        pickerMin.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerMin:add_rules( {
            AutoLayout.width:eq(150),
            AutoLayout.height:eq(AutoLayout.parent('height') -90),

            AutoLayout.left:eq(AutoLayout.parent('width') -50 - pickerMin.width),
            AutoLayout.top:eq(90),
        } )
        self.container:add(pickerMin)


        pickerYear.on_change_select = function(index)
            self.year = tonumber(index + 2003)
            --            if tonumber(self.month)== 1 or  tonumber(self.month)== 3 or tonumber(self.month)== 5 or tonumber(self.month)== 7 or tonumber(self.month)== 8 or tonumber(self.month)== 10 or tonumber(self.month)== 12  then
            --                --pickerDay:insert("31",31)
            --            elseif tonumber(self.month)== 4 or  tonumber(self.month)== 6 or tonumber(self.month)== 9 or tonumber(self.month)== 11 then
            --                if pickerDay:get_view(31) then
            --                     pickerDay:delete(31)
            --                end
            --            end

            --            if (math.fmod(self.year, 4) == 0 and math.fmod(self.year, 100) ~= 0) or math.fmod(self.year, 400) == 0 then
            --                self.leap = true
            --                if tonumber(self.month)== 2 then
            --                end
            --            else
            --                 self.leap = false

            --                 if tonumber(self.month)== 2 then

            --                end
            --            end
        end
        pickerMonth.on_change_select = function(index)
            self.month = index < 10 and "0" .. index or index

            --            if tonumber(self.month)== 1 or  tonumber(self.month)== 3 or tonumber(self.month)== 5 or tonumber(self.month)== 7 or tonumber(self.month)== 8 or tonumber(self.month)== 10 or tonumber(self.month)== 12  then
            --                --pickerDay:insert("31",31)
            --            elseif tonumber(self.month)== 4 or  tonumber(self.month)== 6 or tonumber(self.month)== 9 or tonumber(self.month)== 11 then
            --                if pickerDay:get_view(31) then
            --                     pickerDay:delete(31)
            --                end

            --            end

            --            if index ==2 then
            --                if self.leap then
            --                else
            --                end
            --            end
        end
        pickerDay.on_change_select = function(index)
            self.day = index < 10 and "0" .. index or index
        end
        pickerHour.on_change_select = function(index)
            self.hour = index < 10 and "0" .. index - 1 or index - 1
        end

        pickerMin.on_change_select = function(index)
            self.min = index < 10 and "0" .. index or index
        end

        Clock.instance():schedule_once( function()
            pickerYear:select_item(tonumber(year) -2003)
            pickerMonth:select_item(tonumber(month))
            pickerDay:select_item(tonumber(day))
            pickerHour:select_item(tonumber(hour))
            pickerMin:select_item(tonumber(min))
        end , 1)

    end

} )


return selComponent