local Am = require('animation')
local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
View_Anim_Type = 
{
  No = 0,
  LTOR = 1,   --从左到右
  RTOL = 2,   --从右到左
}

local changeTime = 0.25

local baseView = class('baseView', nil, {
    __init__ = function (self)


        self.m_root = Widget()
        self.m_root:add_rules(AL.rules.fill_parent)
        
        self.m_root.background_color = Colorf(0.9,0.9,0.9,1.0)

        self.m_root:initId()
        self.m_success = false
        Window.instance().drawing_root:add(self.m_root)
        self.m_root.visible = false

        self.transition_anim = Am.Animator()

    end,
   

    getViewRoot = function (self)
        return self.m_root
    end,

   
    onShow = function (self, animType)

        self.m_root.visible = true
        
        animType = animType or View_Anim_Type.RTOL
        if View_Anim_Type.No == animType then
            self.m_root.x = 0

            if self.m_showCallBack then
                self.m_showCallBack()
                self.m_showCallBack = nil
            end

            return
        end

        
        local aminTor = nil
        if animType == View_Anim_Type.LTOR then
            local startX = -SCREENWIDTH         
            self.m_root.x = startX
            local ac = Am.value(startX, 0)
            aminTor = Am.Animator(Am.timing(Am.linear, Am.duration(changeTime, ac)), function (v)
                self.m_root.x = v
            end)
            aminTor:start()


            
        elseif animType == View_Anim_Type.RTOL then
            local startX = SCREENWIDTH
            self.m_root.x = startX
            local ac = Am.value(startX, 0)

            -- local funPow = function (f)
            --     return math.pow(f, 1.5)
            -- end

            aminTor = Am.Animator(Am.timing(Am.linear, Am.duration(changeTime, ac)), function (v)
                self.m_root.x = v
            end)
            aminTor:start()
        end

        aminTor.on_stop = function ()
            if self.m_showCallBack then
                self.m_showCallBack()
                self.m_showCallBack = nil
            end
        end
    
    end,

    onHide = function (self, animType)
        animType = animType or View_Anim_Type.RTOL

        if not self.m_root then return end 
        if animType == View_Anim_Type.No then
            self.m_root.visible = false           
            if self.m_hideCallBack then
                self.m_hideCallBack()
            end

            return
        end


        local animTor
        if animType == View_Anim_Type.LTOR then
            local startX = 0
            self.m_root.x = startX
            local ac = Am.value(startX, SCREENWIDTH)


            animTor = Am.Animator(Am.timing(Am.linear, Am.duration(changeTime,ac)), function (v)
                self.m_root.x = v
            end)
            animTor:start()

        elseif animType == View_Anim_Type.RTOL then
            self.m_root.x = 0
            local ac = Am.value(0, -SCREENWIDTH)

            animTor = Am.Animator(Am.timing(Am.linear, Am.duration(changeTime, ac)), function (v)
                if not self.m_root then
                    return
                end
                self.m_root.x = v
            end)
            animTor:start()
        end

        animTor.on_stop = function ()
            self.m_root.visible = false
            if self.m_hideCallBack then
                self.m_hideCallBack()
            end
        end

    end,

    onDelete = function (self)
        self.m_root:remove_from_parent()
        self.m_root = nil
    end,

    setHideCallBack = function (self, callback)
        self.m_hideCallBack = callback
    end,

    --需要重载该函数
    onUpdate = function (self, ...)
        -- body
    end,

    --返回键事件
    onBackEvent = function (self)
        
    end,

})


return baseView


