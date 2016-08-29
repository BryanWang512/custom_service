
package.preload[ "libEffect/easing" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

---
-- 
-- @module libEffect.easing

local M = { }


-- 如果是16，那么理论上一帧至少会有一个数值。
-- 如果是8，那么理论上一帧至少会有2个数值。
-- 要平滑，必须确保 1 <= fillStep <= 16。8可能是比较完美的值，待确定。

local fillStep = 16 

--- 
-- 获得当前 fillStep 。单位：毫秒。默认为16。
M.getFillStep = function ()
    return fillStep
end

---
-- 设置 fillStep 。单位：毫秒.
--
-- 关于 fillstep ：
-- 
--  * 如果是16，那么理论上一帧至少会有一个数值。
--  * 如果是8，那么理论上一帧至少会有2个数值。
--  * 要平滑，必须确保 1 <= fillStep <= 16。8可能是比较完美的值。
-- 
-- @param #number value 新的 fillstep 。
M.setFillStep = function (value)
    fillStep = value 
end

---
-- 返回一个数组，数组中填充了根据缓动函数所提供的值。
-- @param easeFunction 缓动函数。类型可以是 #string 也可以是 #function 。如果是 #string ，则使用的函数为 @{#libEffect.easing.fns}[easeFunction] 。
-- @param duration 缓动动画持续的时间。函数假定在此时间内，每隔 fillstep 毫秒（参见： @{#libEffect.easing.getFillStep} 和 @{#libEffect.easing.setFillStep}），返回的数组中的内容会被读取一次。所以返回的数组中仅保留每隔 fillstep 毫秒时刻的数值。
-- @param b 用于缓动函数的参数b（起始值）。
-- @param c 用于缓动函数的参数c（变化值）。
-- @param ... 用于缓动函数的其它额外参数。
-- @return #list<#number> 用缓动函数计算出来的一系列数值。
M.getEaseArray = function (easeFunction, duration, b, c, ...)
    local fn = easeFunction
    if type(easeFunction) == "string" then 
        fn = M.fns[easeFunction]
    end 

    -- fill the array
    local arr = {}
    local i = 1
    local t = 0
    while t < duration do   
        arr[i] = fn(t, b, c, duration, ...)
        i = i + 1
        t = t + fillStep
    end 

    arr[i] = fn(duration, b, c, duration, ...)
    return arr
end

-- 把t里的缓动函数变成更易用的版本（b,c可以任意取值，若c<0则函数图像是上下翻转的）
local getConvenienceVersion = function (t)
    local newT = {}
    for name, fn in pairs(t) do
        local newFn = (function ()
            local origFn = fn
            return function (t, b, c, ...)
                if c >= 0 then 
                    return origFn(t, 0, c, ...) + b
                else 
                    -- c < 0
                    return b - origFn(t, 0, - c, ...)
                end                 
            end
        end)()        
        newT[name] = newFn
    end 
    
    return newT
end

--- 
-- 这个 #table 提供了一系列的缓动函数.
--
-- 字段名称和函数效果参见 [这里](http://easings.net/zh-cn) 。
-- 
-- 在这基础上，还多了一个 fns['swing'] ，其值同 fns['easeOutQuad'] 。
M.fns = getConvenienceVersion({

    --- 
    -- 计算从b变化到b+c的值。
    -- @param t #number current time (t>=0)
    -- @param b #number beginning value (b>=0)
    -- @param c #number change in value (c>=0)
    -- @param d #number duration (d>0)
    -- @return #number the calculated result
    swing = function(t, b, c, d)
        return M.fns.easeOutQuad(t, b, c, d)
    end,

    linear = function (t, b, c, d)
        local k = c / d
        local r = b
        return k * t + r
    end,

    easeInQuad = function(t, b, c, d)
        t = t / d
        return c * t * t + b
    end,

    easeOutQuad = function(t, b, c, d)
        t = t / d
        return - c * t *(t - 2) + b
    end,

    easeInOutQuad = function(t, b, c, d)
        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * t * t + b
        end

        t = t - 1

        return - c / 2 *(t *(t - 2) -1) + b
    end,

    easeInCubic = function(t, b, c, d)
        t = t / d
        return c * t * t * t + b
    end,

    easeOutCubic = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t + 1) + b
    end,

    easeInOutCubic = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t + b
        end

        t = t - 2
        return c / 2 *(t * t * t + 2) + b
    end,

    easeInQuart = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t + b
    end,

    easeOutQuart = function(t, b, c, d)
        t = t / d - 1
        return - c *(t * t * t * t - 1) + b
    end,

    easeInOutQuart = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t + b
        end

        t = t - 2
        return - c / 2 *(t * t * t * t - 2) + b
    end,

    easeInQuint = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t * t + b
    end,

    easeOutQuint = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t * t * t + 1) + b
    end,

    easeInOutQuint = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t * t + b
        end
        t = t - 2
        return c / 2 *(t * t * t * t * t + 2) + b
    end,


    easeInSine = function(t, b, c, d)
        return - c * math.cos(t / d *(math.pi / 2)) + c + b
    end,

    easeOutSine = function(t, b, c, d)
        return c * math.sin(t / d *(math.pi / 2)) + b
    end,

    easeInOutSine = function(t, b, c, d)
        return - c / 2 *(math.cos(math.pi * t / d) -1) + b
    end,

    easeInExpo = function(t, b, c, d)
        if t == 0 then
            return b
        else
            return c * math.pow(2, 10 *(t / d - 1)) + b
        end
    end,

    easeOutExpo = function(t, b, c, d)
        if t == d then
            return b + c
        else
            return c *(- math.pow(2, -10 * t / d) + 1) + b
        end
    end,

    easeInOutExpo = function(t, b, c, d)
        if (t == 0) then
            return b
        end

        if (t == d) then
            return b + c
        end

        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * math.pow(2, 10 *(t - 1)) + b
        end

        t = t - 1
        return c / 2 *(- math.pow(2, -10 * t) + 2) + b
    end,

    easeInCirc = function(t, b, c, d)
        t = t / d
        return - c *(math.sqrt(1 - t * t) -1) + b
    end,

    easeOutCirc = function(t, b, c, d)
        t = t / d - 1
        return c * math.sqrt(1 - t * t) + b
    end,

    easeInOutCirc = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return - c / 2 *(math.sqrt(1 - t * t) -1) + b
        end
        t = t - 2
        return c / 2 *(math.sqrt(1 - t * t) + 1) + b
    end,

    easeInElastic = function(t, b, c, d)
        if (t == 0) then
            return b
        end

        if t == d then
            return b + c
        end

        t = t / d
        
        local p = d * .3
        local s = p / 4

        t = t - 1
        return -(c * math.pow(2, 10 * t) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
    end,

    easeOutElastic = function(t, b, c, d)
        if t == 0 then
            return b
        end

        if t == d then
            return b + c
        end

        t = t / d

        local p = d * .3        
        local s = p / 4

        return c * math.pow(2, -10 * t) * math.sin((t * d - s) *(2 * math.pi) / p) + c + b
    end,

    easeInOutElastic = function(t, b, c, d)
        if t == 0 then
            return b
        end

        if t == d then
            return b + c
        end
        
        t = t / (d / 2)

        local p = d * (.3 * 1.5)
        local s = p / 4

        if (t < 1) then
            t = t - 1
            return -.5 *(c * math.pow(2, 10 *(t)) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
        end

        t = t - 1
        return c * math.pow(2, -10 *t) * math.sin((t * d - s) *(2 * math.pi) / p) * .5 + c + b
    end,

    easeInBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d
        return c *(t) * t *((s + 1) * t - s) + b
    end,

    easeOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d - 1
        return c *(t * t *((s + 1) * t + s) + 1) + b
    end,

    easeInOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t /(d / 2)

        if (t < 1) then
            s = s *(1.525)
            return c / 2 *(t * t *((s + 1) * t - s)) + b
        end
        s = s *(1.525)
        t = t - 2
        return c / 2 *(t * t *((s + 1) * t + s) + 2) + b
    end,

    easeInBounce = function(t, b, c, d)
        return c - M.fns.easeOutBounce(d - t, 0, c, d) + b
    end,

    easeOutBounce = function(t, b, c, d)
        t = t / d
        if (t <(1 / 2.75)) then
            return c *(7.5625 * t * t) + b
        elseif (t <(2 / 2.75)) then
            t = t -(1.5 / 2.75)
            return c *(7.5625 * t * t + .75) + b
        elseif (t <(2.5 / 2.75)) then
            t = t -(2.25 / 2.75)
            return c *(7.5625 * t * t + .9375) + b
        else

            t = t -(2.625 / 2.75)
            return c *(7.5625 * t * t + .984375) + b
        end
    end,

    easeInOutBounce = function(t, b, c, d)
        if (t < d / 2) then
            return M.fns.easeInBounce(t * 2, 0, c, d) * .5 + b
        end
        return M.fns.easeOutBounce(t * 2 - d, 0, c, d) * .5 + c * .5 + b
    end
})

return M

end
        

package.preload[ "libEffect.easing" ] = function( ... )
    return require('libEffect/easing')
end
            

package.preload[ "libEffect/version" ] = function( ... )
---
-- @module libEffect.version
-- @return #string 
-- @usage local ver = require 'libEffect.version' -- ver为一个字符串，内容是libEffect的版本号。

return '3.1(1c48bd33615df40a55f10959a7a2367bd99b589e)'

end
        

package.preload[ "libEffect.version" ] = function( ... )
    return require('libEffect/version')
end
            

package.preload[ "libEffect/shaders/blur" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--Fang Fang

---
-- `libEffect.shaders.blur` 提供了模糊效果的实现。通过调用  libEffect.shaders.blur.applyToDrawing()，将模糊效果应用到一个drawing对象上。
-- 注意：如果drawing在已经有父节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到原父节点上，也就是在原有基础上插入一个节点。
--       如果drawing在没有添加节点或者父节点为根节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到根节点上，也就是在原有基础上插入一个节点。
--       由于FBO的特性，如果对drawing本身有transform变化，则请将操作作用在新插入的节点上，而不是drawing本身，对drawing 本身的变化只会影响其在FBO中的位置。 
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447991528093_732950102394400056.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447991719627_2529650974615735684.png"></td>
-- </tr>
-- </table>
-- </p>
--
-- @module libEffect.shaders.blur
-- @author Fang Fang
--
-- @usage local Blur = require 'libEffect.shaders.blur'
local Blur = {}

local ShaderInfo    = require("libEffect.shaders.internal.shaderInfo")
local effectName = 'blur'
local blur2 = require("shaders.blur")
 ---@type configType
 --@field [parent=#configType] #number intensity 模糊程度,范围:[ 0 ,12].越大则越模糊（且越耗时）.若为nil，则默认为2.若超出取值范围，则error.
 
---
-- 将模糊特效应用到drawing对象上。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error。
-- @param #table config  模糊效果的配置信息.详见@{#configType.intensity}
Blur.applyToDrawing = function (drawing,config)  
    
    local drawing_w = drawing
    drawing_w:update()
    local eff = nil

   
        local imageSize = Point(drawing_w.bbox.w ,drawing_w.bbox.h );

        eff = EffectsWidget(imageSize)

        for i = 1, 4 do
             eff:add_effect(FBOEffect(blur2))
             eff.effects[i]:set("horizontalPass", Shader.uniform_value_int(math.fmod(i,2)))
             eff.effects[i]:set("sigma", Shader.uniform_value_float(config.intensity))
             eff.effects[i]:set("texOffset", Shader.uniform_value_float2(1/drawing_w.bbox.w,1/drawing_w.bbox.h))
        end
    
        local parent = drawing.m_parent

        ShaderInfo.setShaderInfo(drawing, effectName, 
               {
                parent = parent,
                eff = eff,
                intensity = config.intensity;
               })

        if parent ~=nil then 
            parent:add(eff,drawing_w); 
            eff:add(drawing_w)     
        else
            Window.instance().drawing_root:add(eff,drawing_w); 
            eff:add(drawing_w)
        end 
    return eff
end

--
-- 获得当前应用到drawing的模糊效果的模糊程度。
--
-- @param core.drawing#DrawingImage drawing 应用了模糊效果的对象。
-- @return #number 模糊程度。
-- @return #nil 如果drawing为nil，或者没有应用模糊效果，则什么都不做，返回nil。
Blur.getIntensity = function (drawing)
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    return shaderInfo.intensity;
end 

Blur.setIntensity = function (drawing,eff,config)
    
    for i = 1, 4 do
        eff.effects[i]:set("sigma", Shader.uniform_value_float(config.intensity))
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    shaderInfo.intensity = config.intensity
end


Blur.getEffWidget = function (drawing)
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    return shaderInfo.eff;
end 


Blur.removeBlurEffect = function(drawing)
    
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    if shaderInfo then
        if shaderInfo.parent ~= nil then
            shaderInfo.parent:add(drawing,shaderInfo.eff)
            shaderInfo.eff:cleanup()
            shaderInfo.eff = nil
        else
            Window.instance().root:add(drawing,shaderInfo.eff)
            shaderInfo.eff:cleanup()
            shaderInfo.eff = nil
        end
    end

end

return Blur

end
        

package.preload[ "libEffect.shaders.blur" ] = function( ... )
    return require('libEffect/shaders/blur')
end
            

package.preload[ "libEffect/shaders/blurWidget" ] = function( ... )

local blur = require("shaders.blur")
local glassBlend = require("shaders.glassBlend")
---
-- `libEffect.shaders.blurWidget` 提供了模糊效果的实现。通过调用  libEffect.shaders.blurWidget.createBlurWidget()，将一个drawing的按内容进行模糊后绘制到新生成的节点上。
-- *注意:如果该节点有屏幕外的部分是不会在模糊的计算范围内，同时这个效果是静态的，如果需要动态的模糊效果可以参考@{libEffect.shaders.blur}。*
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img  src="http://engine.by.com:8080/hosting/data/1468564552980_8697990169519154134.png"></td>
-- <td><img  src="http://engine.by.com:8080/hosting/data/1468564538941_8008858029720317635.png"></td>
-- </tr>
-- </table>
-- </p>
-- @module libEffect.shaders.blurWidget
-- @author QigaoLiu
--
-- @usage local blurWidget = require 'libEffect.shaders.blurWidget'

---
-- 需要的配置参数.
-- @type configType

---
-- 模糊程度.
-- 范围:[ 0 ,12].越大则越模糊（且越耗时）.若为nil，则默认为2.若大于12则等于12，若小于0则取绝对值.小数则会取整.
-- @field [parent=#configType] #number intensity 

local function gc_userdata (ud)
    ud:__gc()
    setudmetatable(ud, {})
end

local function blurStage(drawingW,fboIn,config,dir)
    local t = fboIn.texture
    t.pre_alpha = true
    local u = TextureUnit(t)
    local sprite = Sprite(u)
    sprite.shader = blur
    sprite:set_uniform('horizontalPass', Shader.uniform_value_int(dir))
    sprite:set_uniform("sigma",Shader.uniform_value_float(config.intensity))
    sprite:set_uniform('texOffset', Shader.uniform_value_float2(1/(drawingW.bbox.x+drawingW.bbox.w),1/(drawingW.bbox.y+drawingW.bbox.h)))
    
    local fboOut = FBO.create(Point(drawingW.bbox.w,drawingW.bbox.h))
    
    fboOut:render(sprite)

    sprite:cleanup()
    gc_userdata(t)
    gc_userdata(u)

    return fboOut
end

local M = {}

---
-- 创建一个带有模糊效果的widget。
-- 将给定的drawing及其所有字节点的内容添加模糊后渲染到创建的节点上.这是静态的，每一次调用产生的模糊结果都是当前的状态产生的
-- @param engine#Widget drawing 
-- @param #configType config 创建BlurWidget需要的配置参数。详见@{#configType}
-- @return engine#Sprite 生成的带Blur特效的Sprite.
-- @return engine#Texture 生成的drawing内容的纹理对象.
-- @return engine#TextureUnit 生成的drawing内容的纹理包装对象.
-- @usage
-- local blurWidget = require 'libEffect.shaders.blurWidget'
-- local bg = Sprite()
-- bg.pos= Point(50,100)
-- bg.unit  = TextureUnit(TextureCache.instance():get('dota2.png'))
-- bg.size = Point(100,100)
-- local w = Sprite()
-- w.unit  = TextureUnit(TextureCache.instance():get('cocos.png'))
-- w.size = Point(100,100)
-- w.pos = Point(-100,150)
-- bg:add(w)
-- 
-- blur 是生成了带有模糊特效的Sprite,你可以放置的任意地方.
-- local blur = blurWidget.createBlurWidget(bg,{intensity = 2})
-- blur.pos  = bg.pos + Point(200,0)
-- Window.instance().drawing_root:add(bg)
-- Window.instance().drawing_root:add(blur)
M.createBlurWidget = function (drawing,config)
    local drawing_w = nil;
    
    if config.onRoot == true then
        drawing_w = Window.instance().root
    else
        drawing_w = drawing
    end

    drawing_w:update()


    local nF = FBO.create(Point(drawing_w.bbox.x+drawing_w.bbox.w,drawing_w.bbox.y+drawing_w.bbox.h)) 
    

    nF.need_stencil = true
    

    nF:render(drawing_w)
    
    local newFbo = nil


    if config.onRoot == true then
        newFbo = nF
    else
        local tex = nF.texture
        tex.pre_alpha = true

        local textureUnit = TextureUnit(tex)

        textureUnit.rect = drawing_w.bbox

        local newSprite = Sprite(textureUnit)

        newFbo = FBO.create(drawing_w.size)

        newFbo:render(newSprite)

        newSprite:cleanup()
        gc_userdata(textureUnit)
        gc_userdata(tex)
    end

    local vF = blurStage(drawing_w,newFbo,config,0)
    


    local hF = blurStage(drawing_w,vF,config,1)
    


    local vF2 = blurStage(drawing_w,hF,config,0)
    


    local hF2 = blurStage(drawing_w,vF2,config,1)
    
    local tex = hF2.texture
    local texUnit = TextureUnit(tex)
    if config.onRoot == true then
        texUnit:flip_vertical() 
    end
    local hS = Sprite(texUnit)
    hS.pos = drawing_w.pos


    gc_userdata(nF)
    if config.onRoot ~= true then
        gc_userdata(newFbo)
    end
    gc_userdata(vF)
    gc_userdata(hF)
    gc_userdata(vF2)
    gc_userdata(hF2)
    gc_userdata(texUnit)
    gc_userdata(tex)


    return hS
end 



M.createGlassWidget = function (mask,config)
    if mask.parent ~= nil then
        mask.parent:remove(mask)
    end

    local sprite = M.createBlurWidget(nil,{intensity = config.intensity,onRoot = true})
    

    local texUnit = sprite.unit

    local tex = texUnit.texture

    local w = LuaWidget()
    

    local rc = RenderContext(glassBlend)
    w:add(mask)
    w.lua_do_draw = function (_,canvas)
        canvas:begin_rc(rc)
        canvas:add(BindTexture(tex,1))
        mask:draw(canvas)
        canvas:end_rc(rc)

        return true
   end
   sprite:cleanup()
   gc_userdata(texUnit)
   return w,tex
end



---
-- 立即删除带特效的节点.
-- 删除后会释放其所有的资源，在不使用特效后调用此方法.
-- @param engine#Widget blurWidget 需要被删除的带模糊特效的widget
-- @usage 
-- local blurWidget = require 'libEffect.shaders.blurWidget'
-- local blur = blurWidget.createBlurWidget(bg,{intensity = 2})
-- blurWidget.removeBlur(blur)   --立即释放所有资源.
M.removeBlur = function (blurWidget)  
   blurWidget:cleanup()
end

M.removeGlass = function (glassWidget,tex)  
    glassWidget:cleanup()
    gc_userdata(tex)
end
return M
end
        

package.preload[ "libEffect.shaders.blurWidget" ] = function( ... )
    return require('libEffect/shaders/blurWidget')
end
            

package.preload[ "libEffect/shaders/circleScan" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           

-- @module libEffect.shaders.circleMask
-- @author Heng Li
--
-- @usage local circleMask = require 'libEffect.shaders.circleMask'

---
-- `libEffect.shaders.circleScan`提供了圆形扫描裁剪效果的实现。通过调用`libEffect.shaders.circleScan.applyToDrawing()`，将圆形扫描裁剪效果应用到一个drawing对象上。
-- 
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447896707490_9178475097060390538.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447922566028_8701810160593022827.png"></td>
-- </tr>
-- </table>
-- </p>
-- @module libEffect.shaders.circleScan
-- @author LucyWang
--
-- @usage local CircleScan = require 'libEffect.shaders.circleScan'

local CircleScan_Shader = require("shaders.circleScan")
local GC = require ("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local circleScan = {}

local effectName = 'circleScan'

---
-- @type configType

---
-- 起始角度.
-- 
-- 单位：度。如图所示：点O为drawing对象的中心点，直线AC为中心线，∠α即为起始角，其对应的角度值即为起始角度。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448269035196_5229480293137900794.png)
-- 
-- @field [parent = #configType] #number startAngle 

---
-- 结束角度.
-- 单位：度。如图所示：点O为drawing对象的中心点，直线AC为中心线，∠α即为结束角，其对应的角度值即为结束角度。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448269035196_5229480293137900794.png)
-- @field [parent = #configType] #number endAngle 。


---
-- 渲染的区域.
-- 
-- 用于指定需要渲染的区域。如图所示：直线CD为drawing对象的中心线，点O为drawing对象的中心点，假定∠α为起始角，∠β为结束角，以点O为中心，∠α的终边OA顺时针旋转到∠β的终边OB，所扫过的区域为”区域Ⅰ“（如图中OAGHFB所构成的区域），drawing中剩余的区域为”区域Ⅱ“（如图中OAEB所构成的区域）。
-- 若displayClickWiseArea值为1，则只渲染区域Ⅰ；若displayClickWiseArea值为-1，只渲染区域Ⅱ。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448270556017_4630032618474190324.png)
--
-- @field [parent = #configType] #boolean displayClickWiseArea 

---
-- 将圆形扫描效果应用到drawing对象上.
-- 
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error().
-- @param #configType config 圆形扫描效果的配置信息。详见@{#configType}
circleScan.applyToDrawing = function (drawing, config) 
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end
    
    if config.endAngle - config.startAngle < 0 then
        config.startAngle = config.endAngle
    end

    local offsetMatrix = {
                        math.cos(config.startAngle*3.14/180.0),
                        math.sin(config.startAngle*3.14/180.0),
                        -math.sin(config.startAngle*3.14/180.0),
                        math.cos(config.startAngle*3.14/180.0)
                        }

    local progress = config.endAngle - config.startAngle > 360 and math.fmod(config.endAngle-config.startAngle)/360.0 or (config.endAngle-config.startAngle)/360.0
   
    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)
            drawing.shader = CircleScan_Shader;

            ShaderInfo.setShaderInfo(drawing, effectName, {
                                                           startAngle = config.startAngle, 
                                                           endAngle = config.endAngle, 
                                                           displayClickWiseArea = config.displayClickWiseArea})
        end
    end

    
     
    drawing:set_uniform("progress", Shader.uniform_value_float(progress))
    drawing:set_uniform("displayClickWiseArea", Shader.uniform_value_float(config.displayClickWiseArea)) 
    drawing:set_uniform("offsetMatrix", Shader.uniform_value_color(Colorf(unpack(offsetMatrix))));
    
    drawing:invalidate();
    
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    GC.setFinalizer(shaderInfo, function ()
        local isDrawingExists =  drawingTracer.isDrawingExists(drawing.m_drawingID)
        if isDrawingExists ~= nil and  ShaderInfo.getShaderInfo(drawing)~= nil then
            drawing.shader = -1;
        end
       
    end)
  
end



---
-- 返回起始角度.
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描效果的对象。
-- @return #number 起始角度。详见@{#configType.startAngle}。 
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描效果，则什么都不做，返回nil。
circleScan.getStartAngle = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.startAngle
	else
	    return nil
	end
end


---
-- 返回结束角度。
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描裁剪效果的对象。
-- @return #number 结束角度。详见@{#configType.endAngle}。
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描裁剪效果，则什么都不做，返回nil。
circleScan.getEndAngle = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.endAngle
	else
	    return nil
	end
end

---
-- 返回渲染的区域.
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描裁剪效果的对象。
-- @return #boolean 渲染的区域。详见@{#configType.displayClickWiseArea}。
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描裁剪效果，则什么都不做，返回nil。
circleScan.getDisplayClickWiseArea = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.displayClickWiseArea
	else
	    return nil
	end
end

return circleScan
end
        

package.preload[ "libEffect.shaders.circleScan" ] = function( ... )
    return require('libEffect/shaders/circleScan')
end
            

package.preload[ "libEffect/shaders/colorTransform" ] = function( ... )
-- @module libEffect.shaders.grayScale
-- @author Fang Fang
--
-- @usage local grayScale = require 'libEffect.shaders.grayScale'

---
-- `libEffect.shaders.grayScale`提供了变灰效果的实现.通过调用`libEffect.shaders.grayScale.applyToDrawing()`，将变灰效果应用到一个drawing对象上。
-- 
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818110894_1148680505493681647.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818610977_1089562062061800631.png"></td>
-- </tr>
-- </table>
-- </p>
-- 
-- @module libEffect.shaders.grayScale
-- @author Fang Fang
--
-- @usage local grayScale = require 'libEffect.shaders.grayScale'

local shader = require("shaders.image2dColor")
local GC = require ("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local image2dColor = {}

local effectName = 'image2dColor'

---
-- @type configType
-- @field [parent=#configType] #number r 显示的像素的红色通道缩放值.范围：0-1。当该值为0的时候，原色的红色通道为0，当该值为1的时候，原色的红色通道不变；
-- @field [parent=#configType] #number g 显示的像素的绿色通道缩放值.范围：0-1。当该值为0的时候，原色的绿色通道为0，当该值为1的时候，原色的绿色通道不变；
-- @field [parent=#configType] #number b 显示的像素的蓝色通道缩放值.范围：0-1。当该值为0的时候，原色的蓝色通道为0，当该值为1的时候，原色的蓝色通道不变；
-- @field [parent=#configType] #number a 显示的像素的透明通道缩放值.范围：0-1。当该值为0的时候，原色的透明通道为0，当该值为1的时候，原色的透明通道不变；
-- @field [parent=#configType] #number oR 显示的像素的红色通道偏移值.范围：0-255。当该值为0的时候，原色的红色通道偏移为0，当该值为255的时候，红色通道为最大值；
-- @field [parent=#configType] #number oG 显示的像素的绿色通道偏移值.范围：0-255。当该值为0的时候，原色的绿色通道偏移为0，当该值为255的时候，绿色通道为最大值；
-- @field [parent=#configType] #number oB 显示的像素的蓝色通道偏移值.范围：0-255。当该值为0的时候，原色的蓝色通道偏移为0，当该值为255的时候，蓝色通道为最大值；
-- @field [parent=#configType] #number oA 显示的像素的透明通道偏移值.范围：0-255。当该值为0的时候，原色的透明通道偏移为0，当该值为255的时候，透明通道为最大值；
-- 
-- 计算公式  color = color * （r,g,b,a） + (oR,oG,oB,oA)

---
-- 对drawing应用颜色变换效果.
-- @param core.drawing#DrawingImage drawing 要应用的对象.若不是DrawingImage，则error().
-- @param #configType config  颜色变化参数.详见@{#configType}.
image2dColor.applyToDrawing = function (drawing,config)
    image2dColor.setUniform(drawing, config)
end

image2dColor.setUniform = function (drawing, config)
    drawing.colorf_offset = Colorf(config.oR or 0,config.oG or 0,config.oB or 0,config.oA or 0)
    drawing.colorf = Colorf(config.r or 1, config.g or 1, config.b or 1, config.a or 1)
end

  
return image2dColor

end
        

package.preload[ "libEffect.shaders.colorTransform" ] = function( ... )
    return require('libEffect/shaders/colorTransform')
end
            

package.preload[ "libEffect/shaders/common" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

---
-- 提供了一组用于特效的通用函数。
--
-- @module libEffect.shaders.common
-- @author Xiaofeng Yang
--
-- @usage local Common = require 'libEffect.shaders.common'

local ShaderInfo = require('libEffect.shaders.internal.shaderInfo')


local common = {}

--- 判断drawing是否使用了特效，如果drawing使用了特效的话，返回ture，否则返回false。
-- @param core.drawing#DrawingImage drawing 应用了特效了drawing对象。
-- @return #boolean 如果drawing使用了特效的话，返回ture；否则，返回false。
common.hasEffect = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) then
        return true
    else
        return false
    end
end


--- 移除drawing的特效。若无法获得特效信息，则什么都不做。
-- @param core.drawing#DrawingImage drawing 应用了特效了drawing对象。
common.removeEffect = function (drawing)
    if not common.hasEffect(drawing) then 
        return 
    end 
    
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)

    if type(shaderInfo['__cleanup']) == 'function' then 
        shaderInfo['__cleanup']()
    end 

    ShaderInfo.setShaderInfo(drawing, nil)

    drawing:getWidget().shader = -1
end

return common
end
        

package.preload[ "libEffect.shaders.common" ] = function( ... )
    return require('libEffect/shaders/common')
end
            

package.preload[ "libEffect/shaders/fireWidget" ] = function( ... )
---
-- `libEffect.shaders.fireWidget`会创建一个具有动态火焰特效的widget。
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="justify" style="border-style: none;">火焰特效</td>
-- <tr>
-- <td><img src="http://engine.by.com:8080/hosting/data/1468574080861_2260265956383601448.gif"></td>
-- </tr>
-- </table>
-- </p>
-- @module libEffect.shaders.fireWidget
-- @author QigaoLiu
-- 
-- @usage local fireWidget = require 'libEffect.shaders.fireWidget'
-- Window.instance().drawing_root:add(fireWidget)

local M = {}
require("shaders/shaderConstant")
local fireShader = require("shaders/fire")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local effectName = 'fireWidget'

---
-- 创建一个带火焰特效的widget.
-- 火焰效果以及使用方式见@{libEffect.shaders.fireWidget}
-- @return engine#LuaWidget 创建的带火焰特效的widget.
M.createFireWidget = function ()
    
    local tex0 = TextureUnit(TextureCache.instance():get("noise01.png"))
    local tex1 = TextureUnit(TextureCache.instance():get("fire01.png"))
    local tex2 = TextureUnit(TextureCache.instance():get("alpha01.png"))

    tex0.texture.wrap = gl.GL_REPEAT

    local instTime = SetState("time",Shader.uniform_value_float(1))

    local rc = RenderContext(fireShader)

    local w = LuaWidget{
        do_draw = function (self,canvas)
            canvas:begin_rc(rc)
            canvas:add(BindTexture(tex0.texture,0))
            canvas:add(BindTexture(tex1.texture,Shader_Texture_Index.fireColor))
            canvas:add(BindTexture(tex2.texture,Shader_Texture_Index.fireAlpha))
            canvas:add(instTime)
            canvas:add(Rectangle(Rect(900,0,300,300),Matrix(),Rect(0,0,1,1)))
            canvas:end_rc(rc)
        end

    }
    w.size = Point(300,300)
    w.pos = Point(900,0)
    Window.instance().root:add(w)

    local time = 1
    local clock = Clock.instance():schedule(function (dt)
    time = time - dt*10
    instTime.value = Shader.uniform_value_float(time)
    w:invalidate()

    end)

    ShaderInfo.setShaderInfo(w, effectName, {clock = clock})
    return w
end

M.stopFireWidget = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.clock:cancel()
	else
	    return nil
	end  
end

return M
 
    
end
        

package.preload[ "libEffect.shaders.fireWidget" ] = function( ... )
    return require('libEffect/shaders/fireWidget')
end
            

package.preload[ "libEffect/shaders/flash" ] = function( ... )
--
-- libEffect Version: @@Version@@
--
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang
-- Heng Li
--

---
-- @{libEffect.shaders.flash} 提供了高亮效果的实现。通过调用 @{#libEffect.shaders.flash.applyToDrawing} 函数，将高亮效果应用到一个drawing对象上。
--
-- 高亮效果用于在一个drawing上增加一个白色的条状物（下文简称“白条”），并通过 position 属性来指定“白条”的位置。
--
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none">应用效果前</td>
--     <td align="center" style="border-style: none">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447991528093_732950102394400056.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447991818380_8932262946295742184.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
--
-- @module libEffect.shaders.flash
-- @author Heng Li
--
-- @usage local Flash = require 'libEffect.shaders.flash'



local Flash1_Shader = require("shaders.flashShader")
local GC = require("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local screenWidth = sys_get_int("screen_width", -1)
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local screenHeight = sys_get_int("screen_height", -1)
local flash = { }

local effectName = 'flash'

---
-- 返回 position 属性的取值范围。
-- @return #number, #number 最小值, 最大值
flash.getPositionRange = function()
    return 0, 1
end

---
-- 返回 scale 属性的取值范围。
-- @return #number, #number 最小值, 最大值
flash.getScaleRange = function()
    return 1, 2
end


---
-- 对drawing应用高亮效果。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error()。
--
-- @param #table config 一个table，用于指定所应用的特效的各种属性。若为nil，则默认为{}。
--
-- config必须具有以下几个字段。
--
-- config.position
-----------------
--
-- 类型：#number
--
-- 高亮效果的 **position** 属性，该属性决定了“白条”的位置。
--
-- 取值范围：0 <= config.position <= 1 。
--
-- _注：_
--
-- * 若 config.position == 0，则白条处于 drawing 左下端（恰好位于不可见区域），若 config.position == 1 则白条处于 drawing 右上端（恰好位于不可见区域）。
-- * 若 config.position 为 nil，则默认为 0.5。
-- * 若 config.position 超出取值范围，则 error() 。
--
--
-- config.color
--------------
--
-- 类型：#table
--
-- 高亮效果的 **color** 属性，该属性决定了高亮的颜色。
--
-- `config.color'是一个形式为{R,G,B,A}的table，满足范围 :0 <= R，G，B，A <= 255。用于指定一个RGBA颜色值。
--
-- _注：_
--
-- * 若config.color 为 nil ，则默认为{255,255,255,255}，即白色。
-- * 若config.color 超出取值范围，则 error() 。
--
--
-- config.scale
--------------
--
-- 类型：#number
--
-- 高亮效果的 **scale** 属性，决定光柱粗细。
--
-- 范围：1 <= scale <= 2。
--
-- _注：_
--
-- * 若 config.scale 为1时是标准大小，光柱粗细随着该值的增大而增大，最大为2。
-- * 若 config.scale 为 nil ，则默认为1。
-- * 若 config.scale 超出取值范围，则 error() 。
--
flash.applyToDrawing = function(drawing, config)
    if config == nil then
        config = { }
    end

    local position = config.position
    local color = config.color
    local scale = config.scale

    local flashTexResId = res_alloc_id()

    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end


    if color == nil then
        color = { 255, 255, 255, 255 }
    end

    if not(type(color) == 'table') then
        error("The type of `config.color' should be a table.")
    end

    if 4 ~= #color then
        error("The length of `config.color' should be 4.")
    end

    for _, v in ipairs(color) do
        if (v < 0 or v > 255) then
            error("The element of `config.color' should be in range 0 .. 255.")
        end
    end


    if scale == nil then
        scale = 1.0
    end


    if scale < 1.0 or scale > 2.0 then
        error("The value of `config.scale' should be in range 1 .. 2")
    end


    if position == nil then
        position = 0.5
    end

    if (position < 0) or(position > 1) then
        error("The value of `position' should be in range 0 .. 1")
    end

    local colorScale = { color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255 }
    local scaleInvert = 1.0 / scale
    local offsetScale = position * 2 - 1

    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)
           
            local ratioH
            local ratioW
            local w = drawing.unit.size.x
            local h = drawing.unit.size.y
            local rectXScale, rectYScale

            if typeof(drawing.m_res, ResImage) then
                local rectX, rectY, sizeX, sizeY = drawing.m_res:getSubTextureCoord()
                if rectY and sizeY and rectX and sizeX then
                    rectXScale = rectX / w
                    rectYScale = rectY / h
                    ratioW = sizeX / w
                    ratioH = sizeY / h
                else
                    rectXScale = 0.0
                    rectYScale = 0.0
                    ratioH = 1.0
                    ratioW = 1.0
                end
            else
                rectXScale = 0.0
                rectYScale = 0.0
                ratioH = 1.0
                ratioW = 1.0
            end


            drawing.shader = Flash1_Shader
            drawing:set_uniform("direction", Shader.uniform_value_float2(ratioW, ratioH))
            drawing:set_uniform("inColor", Shader.uniform_value_color(Colorf(unpack(colorScale))))
            drawing:set_uniform("scale", Shader.uniform_value_float(scaleInvert))
            drawing:set_uniform("pos", Shader.uniform_value_float2(rectXScale, rectYScale))
            

            local unit = TextureUnit(TextureCache.instance():get("whiteSampler.png"))

            local sprite = LuaWidget{
                 do_draw = function (self,canvas)
                     canvas:add(BindTexture(unit.texture, Shader_Texture_Index.flash1))                 
                 end
             }
             sprite.size = unit.size   
             drawing.parent:add(sprite,drawing)
            
           
            ShaderInfo.setShaderInfo(drawing, effectName,
            {
                position = position,              
                scale = scale,
                color = color,
                flashTexResId = flashTexResId
            })

        end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
   
    drawing:invalidate();
    drawing:set_uniform("offset", Shader.uniform_value_float(offsetScale))
    
    GC.setFinalizer(shaderInfo, function()
     local ifExists= drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists~=nil  and ShaderInfo.getShaderInfo(drawing)~=nil then
            drawing.shader = -1;
        end
    end )
end

---
-- 设置高亮效果的 position 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #number position 高亮效果的 position 属性。详见 @{#libEffect.shaders.flash.applyToDrawing} 的说明。
flash.setPosition = function(drawing, position)
    if (position < 0) or(position > 1) then
        error("The value of `position' should be in range 0 .. 1.")
    end
    if drawing == nil then
         return drawing
    end
    local offsetScale = position * 2 - 1
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.position = position
        drawing:set_uniform("offset", Shader.uniform_value_float(offsetScale))
    end
end
             
---
-- 获得当前应用到drawing的高亮效果的 position 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #number 高亮效果的 position 属性。详见 @{#Flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getPosition = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.position
    else
        return nil
    end
end

---
-- 设置高亮效果的 scale 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #number scale 高亮效果的 scale 属性。详见 @{#libEffect.shaders.flash.applyToDrawing} 的说明。
flash.setScale = function(drawing, scale)
    if (scale < 1) or(scale > 2) then
        error("The value of `scale' should be in range 1 .. 2.")
    end

    local scaleInvert = { 1.0 / scale }
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.scale = scale
        drawing:set_uniform("scale", Shader.uniform_value_float(scaleInvert))

    end
end

---
-- 获得当前应用到 drawing 的高亮效果的 scale 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #number 高亮效果的 scale 属性。详见 @{#libEffect.shaders.flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getScale = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.scale
    else
        return nil
    end
end

---
-- 设置高亮效果的 color 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #table color 高亮效果的color属性。详见 @{#libEffect.shaders.flash.applyToDrawing} 的说明。
flash.setColor = function(drawing, color)
    if not(type(color) == 'table') then
        error("The type of `color' should be a table.")
    end

    if 4 ~= #color then
        error("The length of `color' should be 4.")
    end

    for _, v in ipairs(color) do
        if (v < 0 or v > 255) then
            error("The element of `color' should be in range 0 .. 255.")
        end
    end

    local colorScale = { color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255 }
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.color = color
        drawing:set_uniform("inColor", Shader.uniform_value_color(Colorf(unpack(colorScale))))
    end
end

---
-- 获得当前应用到drawing的高亮效果的color属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #table 高亮效果的color属性。详见 @{#libEffect.shaders.flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getColor = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.color
    else
        return nil
    end
end

return flash

end
        

package.preload[ "libEffect.shaders.flash" ] = function( ... )
    return require('libEffect/shaders/flash')
end
            

package.preload[ "libEffect/shaders/flash2" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:           
-- LucyWang

---
-- `libEffect.shaders.flash2`提供了扫光效果的实现。通过调用`libEffect.shaders.flash2.applyToDrawing()`，将扫光效果应用到一个drawing对象上。
-- 
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447896707490_9178475097060390538.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447987150085_4184076352427086950.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
-- @module libEffect.shaders.flash2
-- @author LucyWang
--
-- @usage local Flash2 = require 'libEffect.shaders.flash2'
local Flash2_Shader = require("shaders.flash2")
local GC = require ("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local Common = require("libEffect.shaders.common")
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)
local flash2 = {}

local effectName = 'flash2'

---
-- @type configType


---
-- 光柱宽度。单位：像素。
-- @field [parent = #configType] #number width  

---
-- drawing中心点到光柱中心线的距离。单位：像素.
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448012270074_5675142339537311585.png)
-- 
-- 如图所示，点O为drawing对象的中心点，直线AB为光柱的中心线，作线段OC⊥AB，OC的长度即是offset的值。
-- @field [parent = #configType] #number offset 

---
-- 光柱角度.
-- 
--  单位：度。光柱和drawing对象中心线的夹角（顺时针），如图所示。
-- 
--  ![](http://engine.by.com:8080/hosting/data/1448014907213_8185746912619618111.png)  
-- @field [parent = #configType] #number angle 

---
-- 光柱内忖RGB颜色.
-- 
-- innerColor[1]是RGB中的R分量,innerColor[2]是RGB中的G分量,innerColor[3]是RGB中的B分量。单个分量取值范围 0-255。例：如下图所示，光柱内忖颜色为白色，则innerColor的值为{255，255，255}。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1447986184470_980724142346816981.png) 
-- 
-- @field [parent = #configType] #table innerColor 

---
-- 光柱边缘RGB颜色.
-- 
-- edgeColor[1]是RGB中的R分量,edgeColor[2]是RGB中的G分量,edgeColor[3]是RGB中的B分量。单个分量取值范围 0-255。例:如下图所示，光柱边缘颜色为绿色，则edgeColor的值为{0，255，0}。
--  
--  ![](http://engine.by.com:8080/hosting/data/1447986184470_980724142346816981.png)
--  
-- @field [parent = #configType] #table edgeColor   


---
-- 将扫光效果应用到drawing对象上. 
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error().
-- @param #configType config 扫光效果的配置信息。
flash2.applyToDrawing = function (drawing,config)
   
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    local color = {}

    for i=1,3 do
        color[i] = (config.innerColor[i] + config.edgeColor[i])/255  --后期修改
    end

    local drawingWidth,drawingHeight = drawing:getSize()
   
    local width = (4*drawingHeight)/config.width    
    
    local offsetMatrix = {
                        math.cos(math.fmod(config.angle,360)*3.14/180.0),
                        math.sin(math.fmod(config.angle,360)*3.14/180.0),
                        -math.sin(math.fmod(config.angle,360)*3.14/180.0),
                        math.cos(math.fmod(config.angle,360)*3.14/180.0)
                        }

    local offset = config.offset/(drawingWidth/2)
  
    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)        

            drawing.shader = Flash2_Shader

            ShaderInfo.setShaderInfo(drawing, effectName, {angle = config.angle, 
                                                           offset = config.offset, 
                                                           innerColor = config.innerColor,
                                                           edgeColor = config.edgeColor})
        end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)

    drawing:set_uniform("offsetMatrix", Shader.uniform_value_color(Colorf(unpack(offsetMatrix))))
    drawing:set_uniform("inColor", Shader.uniform_value_color(Colorf(color[1], color[2], color[3], 0.0)))
    drawing:set_uniform("offset", Shader.uniform_value_float(offset))
    drawing:set_uniform("width", Shader.uniform_value_float(width))
    drawing:invalidate();

    GC.setFinalizer(shaderInfo, function ()  
        local isDrawingExists =  drawingTracer.isDrawingExists(drawing.m_drawingID)

        if isDrawingExists ~= nil and ShaderInfo.getShaderInfo(drawing)~=nil then
            drawing.shader = -1;
        end

    end)
end 


---
-- 返回光柱内忖RGB颜色值。
-- @param  core.drawing#DrawingBase drawing 应用到flash2效果的对象。
-- @return #table 内忖RGB颜色值。
-- @return #nil 如果drawing为nil，或者没有应用flash2效果，则什么都不做，返回nil。
flash2.getInnerColor = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.innerColor
	else
	    return nil
	end
end

---
-- 返回光柱边缘RGB颜色值。
-- @param  core.drawing#DrawingBase drawing 应用到flash2效果的对象。
-- @return #table 光柱边缘RGB颜色值。
-- @return #nil 如果drawing为nil，或者没有应用flash2效果，则什么都不做，返回nil。
flash2.getEdgeColor = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.edgeColor
	else
	    return nil
	end
end

---
-- 返回光柱宽度。
-- @param  core.drawing#DrawingBase drawing 应用到flash2效果的对象。
-- @return #number 光柱可见宽度。
-- @return #nil 如果drawing为nil，或者没有应用flash2效果，则什么都不做，返回nil。
flash2.getWidth = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.width
	else
	    return nil
	end
end

---
-- 返回光柱角度。
-- @param  core.drawing#DrawingBase drawing 应用到flash2效果的对象。
-- @return #number 光柱角度。
-- @return #nil 如果drawing为nil，或者没有应用flash2效果，则什么都不做，返回nil。
flash2.getAngle = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.angle
	else
	    return nil
	end
end


---
-- 返回drawing中心点到光柱中心线的距离。
-- @param  core.drawing#DrawingBase drawing 应用到flash2效果的对象。
-- @return #number drawing中心点到光柱中心线的距离。
-- @return #nil 如果drawing为nil，或者没有应用flash2效果，则什么都不做，返回nil。
flash2.getOffset = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.offset
	else
	    return nil
	end
end

return flash2
end
        

package.preload[ "libEffect.shaders.flash2" ] = function( ... )
    return require('libEffect/shaders/flash2')
end
            

package.preload[ "libEffect/shaders/frost" ] = function( ... )
--
-- libEffect Version: @@Version@@
--
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang
-- Heng Li
--

---
-- `frost`提供了冰冻效果的实现。通过调用 `frost.applyToDrawing()` 等函数，将冰冻效果应用到一个drawing对象上。
--
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1452062478097_5997871111685749297.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1452062417345_2084975435452355851.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
--
-- @module libEffect.shaders.frost
-- @author Heng Li
--
-- @usage local frost = require 'libEffect.shaders.frost'

local Frost_Shader = require("shaders.frostShader")
local GC = require("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1) 

local frost = { }

local effectName = 'frost'

---
-- 返回 offset 属性的取值范围。
-- @return #number, #number 最小值, 最大值
frost.getIntensityRange = function()
    return 0, 1
end



---
-- 对drawing应用冰冻效果。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error()。
-- @param #number intensity 决定冰冻效果噪点的大小。范围：0 <= intensity <= 1.0, 随着0到1.0的增加冰冻的效果越明显。若intensity == nil，则默认为1。若intensity超出范围，则error()。
frost.applyToDrawing = function(drawing, config)
    
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    if config.intensity == nil then
        config.intensity = 1
    end

    if (config.intensity < 0) or(config.intensity > 1) then
        error("The value of `intensity' should be in range 0..1")
    end


    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)
    
            drawing.shader = Frost_Shader
            drawing:set_uniform("screenSize", Shader.uniform_value_float2(screenWidth, screenHeight))

            local unit = TextureUnit(TextureCache.instance():get("noise2dstd.png"))
            local sprite = LuaWidget{
                do_draw = function(self, canvas)
                    canvas:add(BindTexture(unit.texture, Shader_Texture_Index.frost))
              
                end
            }
            sprite.size = unit.size   
            drawing.parent:add(sprite,drawing)

            ShaderInfo.setShaderInfo(drawing, effectName,
            {           

            })
        end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    shaderInfo.intensity = config.intensity
    drawing:invalidate();

    drawing:set_uniform("intensity", Shader.uniform_value_float(config.intensity))
    
    GC.setFinalizer(shaderInfo, function()
        local ifExists= drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists~=nil  and ShaderInfo.getShaderInfo(drawing)~=nil then
            drawing.shader = -1
        end
      
    end )
end


---
-- 获得当前应用到drawing的冰冻效果的位置。
--
-- @param core.drawing#DrawingImage drawing 应用了frost效果的对象。
-- @return #number 决定冰冻效果噪点的大小。范围：0 =< offset =< 1
-- @return #nil 如果drawing为nil，或者没有frost效果，则什么都不做，返回nil。
frost.getIntensity = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.intensity
    else
        return nil
    end
end
return frost

end
        

package.preload[ "libEffect.shaders.frost" ] = function( ... )
    return require('libEffect/shaders/frost')
end
            

package.preload[ "libEffect/shaders/genieWidget" ] = function( ... )
---
-- `libEffect.shaders.genieWidget`能生成genie effect效果。所谓genie effect，即点击按钮之后（缩小，删除、收藏等等），视图会被吸进某个地方。 本代码实现了四个方位的吸收效果。        。通过调用  libEffect.shaders.genieWidget.createGenieWidget()，将效果应用到一个drawing对象上。
-- 注意：如果drawing在已经有父节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到原父节点上，也就是在原有基础上插入一个节点。
--       如果drawing在没有添加节点或者父节点为根节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到根节点上，也就是在原有基础上插入一个节点。
--       由于FBO的特性，如果对drawing本身有transform变化，则请将操作作用在新插入的节点上，而不是drawing本身，对drawing 本身的变化只会影响其在FBO中的位置。
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">出现效果</td>
--     <td align="center" style="border-style: none;">消失效果</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1468902597710_7837559351469787825.gif"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1468902606478_7487153698481650650.gif"></td>
-- </tr>
-- </table>
-- </p>
-- @module libEffect.shaders.genieWidget
-- @author Qigao Liu
-- 
-- @usage local genie = require 'libEffect.shaders.genieWidget'
local M = {}

local easing = require("libEffect.easing")
local genieShader = require("shaders.genie")

M.createGenieWidget = function (drawing,x,y)
    if y < 0 then
        error("the end pos offset Y must greater or euqal 0")
    end

    local parent = drawing.parent
    
    drawing:update()

    local gridWidth,gridHeight = drawing.bbox.w,drawing.bbox.h

    local endX = gridWidth * 0.5  + x
    local endY = gridHeight + y

    local realtiveMatrix = drawing.relative_matrix

    local grids = 8

    local gridVertex = {}
    local gridUV = {}

    for i = 1,grids+1 do
        gridVertex[i] = {}
        gridUV[i] = {}
        for j = 1, grids+1 do
             gridVertex[i][j] = {}
             gridVertex[i][j].x = (i-1) * gridWidth/grids
             gridVertex[i][j].y = (j-1) * gridHeight/grids  

             gridUV[i][j] = {}
             gridUV[i][j].x = (i-1)/grids
             gridUV[i][j].y = (j-1)/grids       
        end
    end

   

    local g = LuaVertexBuilder(VBO.default_format_id(),gl.GL_TRIANGLES,function ()
        local v = {}
        local index = {}

        for i = 1, grids do
            for j = 1,grids do
                table.insert(v,struct.pack("ffffffffffffff",gridVertex[i][j].x,gridVertex[i][j].y,0,
                                                           gridUV[i][j].x,gridUV[i][j].y,1,
                                                           1,1,1,1,0,0,0,0))
                table.insert(v,struct.pack("ffffffffffffff",gridVertex[i+1][j].x,gridVertex[i+1][j].y,0,
                                                           gridUV[i+1][j].x,gridUV[i+1][j].y,1,
                                                           1,1,1,1,0,0,0,0))
                table.insert(v,struct.pack("ffffffffffffff",gridVertex[i+1][j+1].x,gridVertex[i+1][j+1].y,0,
                                                           gridUV[i+1][j+1].x,gridUV[i+1][j+1].y,1,
                                                           1,1,1,1,0,0,0,0))
                table.insert(v,struct.pack("ffffffffffffff",gridVertex[i][j+1].x,gridVertex[i][j+1].y,0,
                                                           gridUV[i][j+1].x,gridUV[i][j+1].y,1,
                                                           1,1,1,1,0,0,0,0))
            
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 0)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 1)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 2)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 2)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 3)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 0)
            end
        end

        return v, index
    end)


    
    
    local instTime = SetState("time",Shader.uniform_value_float(0))
    local instBend = SetState("bend",Shader.uniform_value_float(0))

    local w = LuaWidget()
    w.cache = true

    local rc = RenderContext(genieShader)
    
    if parent ~= nil then
        parent:add(w,drawing)
        w:add(drawing)
    else
        Window.instance().drawing_root:add(w,drawing)
        w:add(drawing)
    end

    w.lua_draw_self = function (self,canvas,bind_texture, vertex, content_change)
        
        canvas:begin_rc(rc)
        
        canvas:add(SetState("transMat",Shader.uniform_value_matrix(realtiveMatrix)))
        canvas:add(SetState("endX",Shader.uniform_value_float(endX)))
        canvas:add(SetState("endY",Shader.uniform_value_float(endY)))
        canvas:add(instTime)
        canvas:add(instBend)
        canvas:add(BindTexture(self.fbo.texture, 0))
        canvas:add(g)
        canvas:end_rc(rc)
    end

    return {widget = w,
            drawing = drawing,
            time = instTime,
            bend = instBend}
end


M.popWidget = function(config)
    config.drawing.visible = true
    
    local timeScale = 1
    
    if config.duration ~= nil then
        timeScale = config.durarion/500
    end

    local dataTime = easing.getEaseArray("easeInOutSine", 500 * timeScale, 0, 1)
    local resTime = new(ResDoubleArray, dataTime)

    local dataBend = easing.getEaseArray("easeInOutSine", 300 * timeScale, 0, 1)
    local resBend = new(ResDoubleArray, dataBend)

    local table = {}

    table.animTime = new(AnimIndex, kAnimNormal, 0, #dataTime - 1, 500 * timeScale, resTime, 0)
    table.animBend = new(AnimIndex, kAnimNormal, 0, #dataBend - 1, 300 * timeScale, resBend, 250 * timeScale)
        
        local t = nil
        local b = nil
        local c = Clock.instance():schedule(function (dt)
            t = 1-table.animTime:getCurValue()
            b = 1-table.animBend:getCurValue()

            config.time.value = Shader.uniform_value_float(t)
            config.bend.value = Shader.uniform_value_float(b)
            config.widget:invalidate()
            Window.instance().root:invalidate()
        end)
   
    table.animBend:setEvent(table,function ()
        c.paused = true 
        delete(table.animTime) 
        delete(table.animBend) 
        delete(resBend)  
        delete(resTime)   
    end)
end



M.hideWidget = function(config)
    local timeScale = 1
    
    if config.duration ~= nil then
        timeScale = config.durarion/500
    end
    
    local dataTime = easing.getEaseArray("easeInOutSine", 500 * timeScale, 0, 1)
    local resTime = new(ResDoubleArray, dataTime)

    local dataBend = easing.getEaseArray("easeInOutSine", 300 * timeScale, 0, 1)
    local resBend = new(ResDoubleArray, dataBend)

    local table = {}

    table.animTime = new(AnimIndex, kAnimNormal, 0, #dataTime - 1, 500 * timeScale, resTime, 100 * timeScale)
    table.animBend = new(AnimIndex, kAnimNormal, 0, #dataBend - 1, 300 * timeScale, resBend, 0)
        
        local t = nil
        local b = nil
        local c = Clock.instance():schedule(function (dt)
            t = table.animTime:getCurValue()
            b = table.animBend:getCurValue()
           
            config.time.value = Shader.uniform_value_float(t)
            config.bend.value = Shader.uniform_value_float(b)
           
            config.widget:invalidate()
            Window.instance().root:invalidate()

        end)

    table.animTime:setEvent(table,function ()
        c.paused = true  
        delete(table.animTime) 
        delete(table.animBend)
        delete(resBend)  
        delete(resTime)  
    end)       
end



return M
end
        

package.preload[ "libEffect.shaders.genieWidget" ] = function( ... )
    return require('libEffect/shaders/genieWidget')
end
            

package.preload[ "libEffect/shaders/glassWidget" ] = function( ... )
 -------脏区域只更新和FBO重合的问题，可以先控制每帧更新glasswidget解决
local M = {}

local blur = require("shaders.blur")
local shaderGlass = require("shaders.glass")


M.createGlassWidget = function(size,radius,samplerScale)
    
    local glInst = LuaInstruction(function ()
        gl.glClearColor(0.0,0.0,0.0,0.5)            ------------must clear before rendering in fbo
        gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    end,true)

    local instsSetBlur = {SetState("horizontalPass",Shader.uniform_value_float(1)),
                          SetState("horizontalPass",Shader.uniform_value_float(0))}
    
    local sysWidth = System:getScreenWidth()
    local sysHeight = System:getScreenHeight()
    
    
    local rectSize = Point(sysWidth/samplerScale,sysHeight/samplerScale)

    local rc = RenderContext(blur)
    local rc1 = RenderContext(blur)
    local rc2 = RenderContext(blur)
    local rc3 = RenderContext(blur)
    local rcGlass = RenderContext(shaderGlass)

    local fboNormal = FBO.create(Point(sysWidth,sysHeight))
    local fboH =  FBO.create(rectSize)
    local fboV =  FBO.create(rectSize)
    local fboH1 = FBO.create(rectSize)
    local fboV1 = FBO.create(rectSize)

    local f = function (p,canvas,rc,fbo,tex,dir)
            canvas:add(PushFBO(fbo))
            canvas:add(glInst)
            canvas:begin_rc(rc)
            canvas:add(BindTexture(tex.texture,0))
            canvas:add(instsSetBlur[dir])
            canvas:add(Rectangle(Rect(0,0,rectSize.x,rectSize.y),Matrix(),Rect(0,0,1,1)))
            canvas:end_rc(rc)
            canvas:add(PopFBO(fbo))
    end

    
    local p = LuaWidget{
        do_draw = function (self,canvas)
            
            canvas:add(PushScissor(Rect(0,0,rectSize.x,rectSize.y)))

            canvas:add(PushFBO(fboNormal))
            canvas:add(glInst)
            canvas:add(BindTexture(Window.instance().root.fbo.texture,0))
            canvas:add(Rectangle(Rect(0,0,rectSize.x,rectSize.y),Matrix(),Rect(0,0,1,1)))
            canvas:add(PopFBO(fboNormal))

            f(self,canvas,rc,fboH,fboNormal,1)

            f(self,canvas,rc1,fboV,fboH,2)
 
            f(self,canvas,rc2,fboH1,fboV,1)
    
            f(self,canvas,rc3,fboV1,fboH1,2)
            
            canvas:add(PopScissor()) 

            canvas:begin_rc(rcGlass)
            canvas:add(SetState("center",Shader.uniform_value_float2(self:to_world(Point(0,0)).x + self.size.x/2,self:to_world(Point(0,0)).y + self.size.y/2)))
            canvas:add(SetState("size",Shader.uniform_value_float2(self.size.x/2 - radius,self.size.y/2 - radius)))
            canvas:add(SetState("radius",Shader.uniform_value_float(radius)))
            canvas:add(BindTexture(fboV1.texture,0))
            
            canvas:add(Rectangle(Rect(0,0,self.size.x,self.size.y),self.relative_matrix,Rect((self:to_world(Point(0,0)).x/sysWidth)  * (rectSize.x/sysWidth),
                                                                     (self:to_world(Point(0,0)).y/sysHeight) * (rectSize.y/sysHeight) ,
                                                                     (self.size.x/sysWidth)                  * (rectSize.x/sysWidth)  ,
                                                                     (self.size.y/sysHeight)                 * (rectSize.y/sysHeight) )))
            canvas:end_rc(rcGlass)  
            
            
        end
    
    }

    p.size = size or Point(sysWidth,sysHeight)
    print(p.size)
    return p
end



return M
end
        

package.preload[ "libEffect.shaders.glassWidget" ] = function( ... )
    return require('libEffect/shaders/glassWidget')
end
            

package.preload[ "libEffect/shaders/glow" ] = function( ... )
--
-- libEffect Version: @@Version@@
--
-- This file is a part of libEffect Library.
--
-- Authors:
-- JoyFang

---
-- `libEffect.shaders.glow`提供了发光效果的实现。通过调用`libEffect.shaders.glow.applyToDrawing()`，将发光效果应用到一个drawing对象上。
-- 注意：如果drawing在已经有父节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到原父节点上，也就是在原有基础上插入一个节点。
--       如果drawing在没有添加节点或者父节点为根节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到根节点上，也就是在原有基础上插入一个节点。
--       由于FBO的特性，如果对drawing本身有transform变化，则请将操作作用在新插入的节点上，而不是drawing本身，对drawing 本身的变化只会影响其在FBO中的位置。 
--
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none">应用效果前</td>
--     <td align="center" style="border-style: none">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818110894_1148680505493681647.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818134443_3991149884181212629.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
-- @module libEffect.shaders.glow
-- @author JoyFang
--
-- @usage local glow = require 'libEffect.shaders.glow'
local GC = require("libutils.gc")
local glow = require("shaders.glow")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local blur2 = require("shaders.blur")
local Glow = { }

local effectName = 'glow'

---
-- @type configType
-- @field [parent=#configType] #number intensity 亮度,范围:[0-1]. intensity越大，被应用的drawing的亮度越大.

---
-- 对drawing应用发光效果.
-- @param core.drawing#DrawingImage drawing 要应用的对象.若不是DrawingImage，则error().
-- @param #configType config  发光效果的配置信息.详见 @{#configType}.
Glow.applyToDrawing = function(drawing, config)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            local instsValue = SetState("intensity",Shader.uniform_value_float(0))
            local instsSetBlurH = SetState("horizontalPass",Shader.uniform_value_float(1))
            local instsSetBlurV = SetState("horizontalPass",Shader.uniform_value_float(0))
            local parent = drawing.parent
            if parent ~=nil then
                parent = parent
            else
                parent = Widget()
                Window.instance().drawing_root:add(parent)
            end

            local effect_changed = true                     -----------------------**********************************

            


            local drawing_w = drawing
            
            drawing.visible = true-- to adapt removeChild bug

            local w = LuaWidget()
            w.cache = true
            parent:add(w,drawing_w)
            w:add(drawing_w)


            local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, {
                instsValue = instsValue,
                parent = parent,
                effect_changed = effect_changed,
                w = w
            })


            local rc_h = FBORenderContext(Point(0,0), blur2)
            local rc_v = FBORenderContext(Point(0,0), blur2)
            local rc_glow = FBORenderContext(Point(0,0), glow)

            w.on_fbo_size_changed = function(self)         -----------------------*********************************
                local size = self.fbo.size
                rc_h.size = size
                rc_v.size = size
                rc_glow.size = size
            end

           
            
             w.lua_draw_self = function(self, canvas, bind_texture, vertex, content_changed)
                 if content_changed or shaderInfo.effect_changed then                   -----------------------**********************************
                     shaderInfo.effect_changed = false                                  -----------------------**********************************

                     if self.dirty_rect then
                         canvas:add(PushScissor(self.dirty_rect))
                     end

                     local fbo_vertex = Rectangle(vertex.rect, Matrix(), vertex.uv_rect)
                     canvas:begin_rc(rc_h)
                     canvas:add(instsSetBlurH)
                     canvas:add(BindTexture(bind_texture.texture, 0))
                     canvas:add(fbo_vertex)
                     canvas:end_rc(rc_h)

                     canvas:begin_rc(rc_v)
                     canvas:add(instsSetBlurV)
                     canvas:add(BindTexture(rc_h.fbo.texture, 0))
                     canvas:add(fbo_vertex)
                     canvas:end_rc(rc_v)

                     canvas:begin_rc(rc_glow)
                     canvas:add(instsValue)
                     canvas:add(BindTexture(bind_texture.texture,0))
                     canvas:add(BindTexture(rc_v.fbo.texture, Shader_Texture_Index.glow))
                     canvas:add(fbo_vertex)
                     canvas:end_rc(rc_glow)
                 
                     if self.dirty_rect then
                         canvas:add(PopScissor(self.dirty_rect))
                     end
                 end
                 canvas:add(BindTexture(rc_glow.fbo.texture, 0))
                 canvas:add(vertex)
             end

            parent.size = w.fbo.size
            

            --drawing:setVisible(false) -- to adapt removeChild bug

        end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)

    shaderInfo.instsValue.value = Shader.uniform_value_float(config.intensity);
    shaderInfo.parent:invalidate()
    shaderInfo.effect_changed = true
    
    GC.setFinalizer(shaderInfo, function()
      local ifExists= drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists~=nil  and ShaderInfo.getShaderInfo(drawing)~=nil then

        end    
    end )

    return shaderInfo.w
end


---
-- 获取当前亮度.
--
-- @param  core.drawing#DrawingBase drawing 已经应用了glow效果的drawing.若该drawing未应用glow效果，则error.
-- @return #number  返回当前亮度.范围为:[0-1]如果没有应用此特效,则返回nil.详见  @{#configType.intensity}.
-- @return #nil 如果drawing为nil，或者没有应用发光效果，则什么都不做，返回nil。
Glow.getIntensity = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.intensity
    else
        return nil
    end
end

Glow.removeGlowEffect = function(drawing)
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
   
    if shaderInfo then
        if shaderInfo.parent ~= nil then
            shaderInfo.parent:add(drawing,shaderInfo.w)
            shaderInfo.parent:remove(shaderInfo.w)
            shaderInfo.w= nil
        else
            Window.instance().drawing_root:add(drawing,shaderInfo.w)
            Window.instance().drawing_root:remove(shaderInfo.w)
            shaderInfo.w= nil
        end
    end

    ShaderInfo.setShaderInfo(drawing, nil)
end

return Glow

end
        

package.preload[ "libEffect.shaders.glow" ] = function( ... )
    return require('libEffect/shaders/glow')
end
            

package.preload[ "libEffect/shaders/grayScale" ] = function( ... )
-- @module libEffect.shaders.grayScale
-- @author Fang Fang
--
-- @usage local grayScale = require 'libEffect.shaders.grayScale'

---
-- `libEffect.shaders.grayScale`提供了变灰效果的实现.通过调用`libEffect.shaders.grayScale.applyToDrawing()`，将变灰效果应用到一个drawing对象上。
-- 
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818110894_1148680505493681647.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1447818610977_1089562062061800631.png"></td>
-- </tr>
-- </table>
-- </p>
-- 
-- @module libEffect.shaders.grayScale
-- @author Fang Fang
--
-- @usage local grayScale = require 'libEffect.shaders.grayScale'

local shader = require("shaders.grayScale")
local GC = require ("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local grayScale = {}

local effectName = 'grayScaleMotion'

---
-- @type configType
-- @field [parent=#configType] #number intensity 灰度值.范围：0-1。当该值为0的时候，被应用效果的drawing呈黑白色；
-- 当该值为1的时候，被应用效果的drawing呈现原本（未应用特效前）的颜色.
-- 该值越接近1，drawing呈现的颜色就越接近原本的颜色.

---
-- 对drawing应用加灰的效果.
-- @param core.drawing#DrawingImage drawing 要应用的对象.若不是DrawingImage，则error().
-- @param #configType config  灰度参数.详见@{#configType}.
grayScale.applyToDrawing = function (drawing,config)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)
      
            drawing.shader = shader;   

            ShaderInfo.setShaderInfo(drawing, effectName, 
            {
    
           })
        end
    end
    
    drawing:invalidate();
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    
    drawing:set_uniform('timer', Shader.uniform_value_float(config.intensity)) 
    
    GC.setFinalizer(shaderInfo, function()
        local ifExists= drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists~=nil  and ShaderInfo.getShaderInfo(drawing)~=nil then
            drawing.shader = -1;
        end
    end )

end
  
return grayScale

end
        

package.preload[ "libEffect.shaders.grayScale" ] = function( ... )
    return require('libEffect/shaders/grayScale')
end
            

package.preload[ "libEffect/shaders/holo" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

---
-- `libEffect.shaders.holo`提供了边缘发亮效果的实现。通过调用`libEffect.shaders.holo.applyToDrawing()`，将边缘发亮效果应用到一个drawing对象上。边缘发亮效果会按一定的规律变化，可以看做是一个动画。
-- 注意：如果drawing在已经有父节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到原父节点上，也就是在原有基础上插入一个节点。
--       如果drawing在没有添加节点或者父节点为根节点的情况下，调用本接口会生成新的节点，并且将drawing作为新节点的子节点，然后将新节点添加到根节点上，也就是在原有基础上插入一个节点。
--       由于FBO的特性，如果对drawing本身有transform变化，则请将操作作用在新插入的节点上，而不是drawing本身，对drawing 本身的变化只会影响其在FBO中的位置。 
-- 
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td>
-- </tr>
-- <tr>
--     <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1448252100971_8925325463053391164.png"></td>
--     <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1448251665450_7631373216744873423.png"></td>
-- </tr>
-- </table>
-- </p>.
--
-- 使用教程
-- 
-- -------------------------------------------------------------------------------------------------------
-- 1.准备DrawingImage对象显示的图片。该图片边缘部分透明度为必须为0。如图所示。<strong>图1</strong><strong>图2</strong>的边缘均为透明，均为符合要求的图片。
-- 
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448279109853_8913624610125370237.png"></td>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448260645669_9068312650102334097.png"></td>
-- </tr>
-- <tr>
--     <td align="center" style="border-style: none;"><strong>图1</strong></td>
--     <td align="center" style="border-style: none;"><strong>图2</strong></td>
-- </tr>
-- </table>
-- </p>
-- 
-- 2.边缘采样图片的准备。
-- 
-- 2.1 用于该特效的图片，必须要与DrawingImage对象显示图片的分辨率大小一致且边缘透明。如图所示,<strong>图3</strong>，大小和<strong>图1</strong>一致；<strong>图4</strong>，大小和<strong>图2</strong>一致。
-- 
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448260645669_9068312650102334097.png"></td>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448260407725_3782633045620264873.png"></td>
-- </tr>
-- <tr>
--     <td align="center" style="border-style: none;"><strong>图3</strong></td>
--     <td align="center" style="border-style: none;"><strong>图4</strong></td>
-- </tr>
-- </table>
-- </p>
-- 
-- 2.2 把图片先经过模糊处理，再经过灰度处理之后得到边缘采样图。这个步骤所得到的图片，最终会用于configType.texturePath。
-- 如图所示。<strong>图5</strong>是<strong>图3</strong>处理后的效果；<strong>图6</strong>是<strong>图4</strong>处理后的效果。<strong>图5</strong>、<strong>图6</strong>都被用于@{#configType.texturePath}。
-- 
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448261108856_7543399390979081263.png"></td>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448259830817_3706952376859809414.png"></td>
-- </tr>
-- <tr>
--     <td align="center" style="border-style: none;"><strong>图5</strong></td>
--     <td align="center" style="border-style: none;"><strong>图6</strong></td>
-- </tr>
-- </table>
-- </p>
-- 
-- 3.把以上步骤得到的图片，应用到DrawingImage上（调用libEffect.shaders.holo.applyToDrawing()），效果如下图所示。
-- 
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448276575873_6961836939808252655.png"></td>
--     <td><img src="http://engine.by.com:8080/hosting/data/1448251665450_7631373216744873423.png"></td>
-- </tr>
-- <tr>
--     <td align="center" style="border-style: none;"><div style="width:380px;word-break:break-all;" ><strong>图7</strong> &nbsp;&nbsp;&nbsp;&nbsp;对一个图片为<strong>图1</strong>的DrawingImage调用libEffect.shaders.holo.applyToDrawing()的效果：参数config的texturePath为<strong>图5</strong>，参数config的color为{0,255,255}。</td>
--     <td align="center" style="border-style: none;"><div style="width:380px;word-break:break-all;" ><strong>图8</strong> &nbsp;&nbsp;&nbsp;&nbsp;对一个图片为<strong>图2</strong>的DrawingImage调用libEffect.shaders.holo.applyToDrawing()的效果：参数config的texturePath为<strong>图6</strong>，参数config的color为{255,0,255}。</td>
-- </tr>
-- </table>
-- </p>
--  
-- @module libEffect.shaders.holo
-- @author LucyWang
--
-- @usage local Holo = require 'libEffect.shaders.holo'





local GC = require ("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local holo = require("shaders.holoShader")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'

local Holo = {}

local effectName = 'holo'
local samplerShaderInfo

---
-- @type configType

---
-- 边缘采样图片路径.
-- 
-- 以此字段指定图片的轮廓来定义边缘发亮的形状。若为nil，则使用内置的方案。 
--边缘采样图片的大小，必须要与drawing的分辨率大小一致且边缘透明。同时，边缘采样图片必须是一个经过“先模糊处理，后再灰度处理”处理过的图片。详见“使用教程“。
-- 
-- @field [parent = #configType] #string texturePath 
-- 

---
-- 边缘发亮的RGB颜色值.
-- color[1]是RGB中的R分量,color[2]是RGB中的G分量,color[3]是RGB中的B分量。单个分量取值范围：0-255。具体取值，可先在holo demo中调整并查看最终效果，再根据具体的效果决定取值。
-- @field [parent = #configType] #table color 

---
-- 将边缘发亮效果应用到drawing上. 
-- 
-- 边缘发亮的部分会按一定的规律变化，可以看做是一个动画。
-- @param core.drawing#DrawingImage drawing 要应用到的对象，若不是DrawingImage，则error().这个drawing的对象边缘部分必须是透明的。
-- 
-- 例：下图是符合要求的drawing对象的图片，其边缘部分透明度为0.
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448260645669_9068312650102334097.png)  
--
-- @param #configType config 边缘发亮效果的配置信息。
-- 
Holo.applyToDrawing = function (drawing, config)
    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end 

    local colorRGB = {}

    for k,v in pairs(config.color) do
        colorRGB[k] = v / 255
    end



    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            local instsSetColorTexcoord = SetState("colorTexcoord",Shader.uniform_value_float(1))
            local instsSetTexcoordScale = SetState("texcoordScale",Shader.uniform_value_float(1))
            local instsSetHoloColor = SetState("holoColor",Shader.uniform_value_float3(colorRGB[1],colorRGB[2],colorRGB[3]))

            local tex = nil; 

            local parent = drawing:getParent()
            if parent ~=nil then
                --parent:removeChild(drawing)-- removeChild has bug
                parent = parent
            else
                parent = Widget()
                Window.instance().drawing_root:add(parent)
            end

            local effect_changed = true

            

            local drawing_w = drawing

            drawing:setVisible(true)-- to adapt removeChil

            local w = LuaWidget()
            w.cache = true
            
            parent:add(w,drawing_w)

            w:add(drawing_w)

            local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, { parent = parent, 
                                                            instsSetHoloColor = instsSetHoloColor,
                                                            tex = tex,
                                                            effect_changed = effect_changed,
                                                            w = w
                                                            })
            
            local rc_h = FBORenderContext(Point(0,0),blurH)
            local rc_v = FBORenderContext(Point(0,0),blurV)
            local rc_h1 = FBORenderContext(Point(0,0),blurH)
            local rc_v1 = FBORenderContext(Point(0,0),blurV)
            local rc_holo = FBORenderContext(Point(0,0),holo)

            w.on_fbo_size_changed = function(self)         -----------------------*********************************
                local size = self.fbo.size
                rc_h.size = size
                rc_v.size = size    
                rc_h1.size = size
                rc_v1.size = size    
                rc_holo.size = size
            end
            
            

            if config.texturePath ~= nil then
                local sampler = TextureUnit(TextureCache.instance():get(config.texturePath))
                
                w.lua_draw_self = function (self, canvas, bind_texture, vertex, content_changed)
                    if content_changed or shaderInfo.effect_changed then
                        shaderInfo.effect_changed = false

                        local fbo_vertex = Rectangle(vertex.rect, Matrix(),vertex.uv_rect)

                        if self.dirty_rect then
                            canvas:add(PushScissor(self.dirty_rect))
                        end

                        canvas:begin_rc(rc_holo)
                        canvas:add(BindTexture(w.fbo.texture,0))
                        canvas:add(BindTexture(sampler.texture,Shader_Texture_Index.holo))
                        canvas:add(instsSetColorTexcoord)
                        canvas:add(instsSetTexcoordScale)
                        canvas:add(instsSetHoloColor)
                        canvas:add(fbo_vertex)
                        canvas:end_rc(rc_holo)

                        if self.dirty_rect then
                            canvas:add(PopScissor(self.dirty_rect))
                        end
                    end

                    canvas:add(BindTexture(rc_holo.fbo.texture, 0))
                    canvas:add(vertex)
                end

            else
                
                local sampler = TextureUnit(TextureCache.instance():get("circle.png"))

                w.lua_draw_self = function (self,canvas,bind_texture, vertex, content_change)
                    if content_changed or shaderInfo.effect_changed then
                        shaderInfo.effect_changed = false

                        local fbo_vertex = Rectangle(vertex.size,Matrix(),vertex.uv_rect)


                        if self.dirty_rect then
                            canvas:add(PushScissor(self.dirty_rect))
                        end


                        canvas:begin_rc(rc_h)
                        canvas:add(BindTexture(w.fbo.texture),0)
                        canvas:add(fbo_vertex)
                        canvas:add(SetState("ratio",Shader.uniform_value_float(3)))
                        canvas:end_rc(rc_h)

                        canvas:begin_rc(rc_v)
                        canvas:add(BindTexture(rc_h.fbo.texture),0)
                        canvas:add(fbo_vertex)
                        canvas:add(SetState("ratio",Shader.uniform_value_float(3)))
                        canvas:end_rc(rc_v)

                        canvas:begin_rc(rc_holo)
                        canvas:add(instsSetColorTexcoord)
                        canvas:add(instsSetTexcoordScale)
                        canvas:add(instsSetHoloColor)
                        canvas:add(BindTexture(w.fbo.texture,0))
                        canvas:add(BindTexture(rc_v.fbo.texture,Shader_Texture_Index.holo))
                        canvas:add(fbo_vertex)
                        canvas:end_rc(rc_holo)

                        if self.dirty_rect then
                            canvas:add(PopScissor(self.dirty_rect))
                        end
                    end

                    canvas:add(BindTexture(rc_holo.fbo.texture, 0))
                    canvas:add(vertex)
                end
 
            end
            parent.size = w.fbo.size

            

            local animColorTexcoord    = new(AnimDouble,kAnimLoop,0,2,2000,0);
            local animTexcoordScale    = new(AnimDouble,kAnimLoop,0,1,2000,0);

            Clock.instance():schedule(function (dt)
                local c = animColorTexcoord:getCurValue()
                local t = animTexcoordScale:getCurValue()
                instsSetColorTexcoord.value = Shader.uniform_value_float(c)
                instsSetTexcoordScale.value = Shader.uniform_value_float(t)
                parent:invalidate()
                shaderInfo.effect_changed = true
            end,0.03)

            --[[Clock.instance():schedule_once(function (dt)
                parent:remove(w)
                local w = LuaWidget{
                    do_draw = function(self, canvas)
                        canvas:begin_rc(rcRect)
                        canvas:add(BindTexture(fboN.texture,0))
                        canvas:add(BindTexture(tex,1))
                        canvas:add(instsSetColorTexcoord)
                        canvas:add(instsSetTexcoordScale)
                        canvas:add(instsSetHoloColor)
                        canvas:add(Rectangle(FBOSize, Matrix(), Rect(0,0,1.0,1.0)))
                        canvas:end_rc(rcRect)
                    end}  
                w.relative = true
                w.size = FBOSize
                parent:add(w,drawing_w)
            end,0.1)]]-- 
        end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    
    shaderInfo.instsSetHoloColor.value = Shader.uniform_value_float3(colorRGB[1],colorRGB[2],colorRGB[3])
    shaderInfo.parent:invalidate()
    shaderInfo.effect_changed = true


    GC.setFinalizer(shaderInfo, function ()   
        local isDrawingExists =  drawingTracer.isDrawingExists(drawing.m_drawingID)

    end)

    return shaderInfo.w
end

---
-- 返回边缘发亮的颜色值。
-- @param  core.drawing#DrawingBase drawing 应用到holo效果的对象。
-- @return #table 边缘发亮的颜色值。
-- @return #nil 如果drawing为nil，或者没有应用holo效果，则什么都不做，返回nil。
Holo.getColor = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.color
	else
	    return nil
	end
end

---
-- 返回边缘采样图片路径。
-- @param  core.drawing#DrawingBase drawing 应用到holo效果的对象。
-- @return #string texturePath 边缘采样图片路径。
-- @return #nil 如果drawing为nil，或者没有应用holo效果，则什么都不做，返回nil。
Holo.getTexturePath = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.texturePath
	else
	    return nil
	end
end

Holo.removeHoloEffect = function(drawing)
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    if shaderInfo then
        if shaderInfo.parent ~= nil then
            shaderInfo.parent:add(drawing,shaderInfo.w)
            shaderInfo.parent:remove(shaderInfo.w)
            shaderInfo.w= nil
        else
            Window.instance().drawing_root:add(drawing,shaderInfo.w)
            Window.instance().drawing_root:remove(shaderInfo.w)
            shaderInfo.w= nil
        end
    end

    ShaderInfo.setShaderInfo(drawing, nil)
end


return Holo

end
        

package.preload[ "libEffect.shaders.holo" ] = function( ... )
    return require('libEffect/shaders/holo')
end
            

package.preload[ "libEffect/shaders/imageMask" ] = function( ... )

-- -
-- libEffect Version: @@Version@@
--
-- This file is a part of libEffect Library.
--
-- Authors:
-- JoyFang

---
-- `libEffect.shaders.imageMask`提供了图片遮罩效果的实现。通过调用`libEffect.shaders.imageMask.applyToDrawing()`,将图片遮罩效果应用到一个drawing上。
--
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1448621499692_7437971044847201393.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1448621518594_6116625090440520669.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
-- @module libEffect.shaders.imageMask
-- @author JoyFang
-- @usage local imageMask = require 'libEffect.shaders.imageMask'
--
require('shaders.shaderConstant')
local ImageMask_Shader = require("shaders.imageMask")
local GC = require("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local M = { }

local effectName = 'imageMask'

---
-- @type configType

--- 图片中心点相对drawing中心点偏移量，该图片用于遮罩drawing.
--
-- ![](http://engine.by.com:8080/hosting/data/1449030190586_4412197580841321348.png)
--
-- 一个{x,y}形式的坐标.
-- 如图所示，①是drawing，中心为O；②是用于遮罩的图片，中心为P.
--
-- 以O为原点建立如图的坐标系，则在该坐标系中，P点的坐标为(x,y).
--
-- @field [parent=#configType] #table position


--- 用于遮罩的图片相对路径.
-- @field [parent=#configType] #string file

---
-- 对drawing应用遮罩效果.
--
-- @param core.drawing#DrawingImage drawing 应用遮罩效果到的对象。若不是DrawingImage，则error().
-- @param #configType config   遮罩效果的配置信息.详见@{#configType}.
M.applyToDrawing = function(drawing, config)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end
    
    local drawing_w = drawing

  

    if config == nil then
        config = {}
    end

    local dir = config.file

    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        Common.removeEffect(drawing)
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then     

            drawing_w.shader = ImageMask_Shader
  

            local unit = TextureUnit(TextureCache.instance():get(dir))
            local sprite = LuaWidget{
                 do_draw = function (self,canvas)
                     canvas:add(BindTexture(unit.texture, Shader_Texture_Index.imageMask))
                                  
                 end
             }
             sprite.size = unit.size   
             drawing_w.parent:add(sprite,drawing_w)
      
             ShaderInfo.setShaderInfo(drawing, effectName,
             {
               
             } )
         end
    end

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)

    ShaderInfo.setShaderInfo(drawing, effectName,
            {
                position = position 
            })
    GC.setFinalizer(shaderInfo, function()
        local ifExists = drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists ~= nil and ShaderInfo.getShaderInfo(drawing) ~= nil then
            drawing_w.shader = -1
           
        end
    end )
end
           
return M

end
        

package.preload[ "libEffect.shaders.imageMask" ] = function( ... )
    return require('libEffect/shaders/imageMask')
end
            

package.preload[ "libEffect/shaders/PSBlend" ] = function( ... )
---
-- `libEffect.shaders.PSBlend` 提供了PS的混合模式的实现。通过调用  libEffect.shaders.PSBlend.applyToDrawing()，将混合模式应用到一个drawing对象上。 
--
-- @module libEffect.shaders.PSBlend
-- @author Qigao Liu
--
-- @usage local PSBlend = require 'libEffect.shaders.PSBlend'
local M = {}

local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
require("shaders.blend")
local effectName = 'blend'

---
-- 给一个drawing对象添加PS的混合模式.
-- 
-- @param engine#Sprite drawing 需要进行混合的带纹理的对象.
-- @param shaders.shaderConstant#Shader_PS_Blend mode 混合模式.
-- @usage 
-- local PSBlend = require 'libEffect.shaders.PSBlend'
-- local s = Sprite()
-- s.unit  = TextureUnit(TextureCache.instance():get('whiteSampler.png'))
-- s.size = s.unit.size
--
-- local bg = Sprite()
-- bg.unit  = TextureUnit(TextureCache.instance():get('dota2.png'))
-- bg.size = bg.unit.size
-- Window.instance().drawing_root:add(bg)
-- Window.instance().drawing_root:add(s)
-- PSBlend.applyToDrawing(s,Shader_PS_Blend.multiply)
M.applyToDrawing = function (drawing,mode)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then 
            local parent = drawing.m_parent

            local w = LuaWidget()

            if parent ~=nil then 
               
                parent:add(w,drawing); 
            else
                Window.instance().drawing_root:add(w,drawing); 
            end 

            w:add(drawing)

            w.shader = createBlend(mode)
            
            w.lua_do_draw = function(self, canvas)       
                canvas:add(BindTexture(Window.instance().root.fbo.texture,1))
		        drawing:draw(canvas)
                return true
            end

            ShaderInfo.setShaderInfo(drawing, effectName,
            {
                parent = parent,              
                w = w,
                mode = mode,    
            })
            
        end
    else
        if drawing.parent ~= nil then
            drawing.parent.shader = createBlend(mode)
        end
    end
    return w
end

---
-- 移除掉混合模式.
-- @param engine#Sprite drawing 添加了PS混合模式的对象.
-- @usage 
-- local PSBlend = require 'libEffect.shaders.PSBlend'
-- PSBlend.removeBlend(s)
M.removeBlend = function (drawing)
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
   
    if shaderInfo then
        if shaderInfo.parent ~= nil then
            shaderInfo.parent:add(drawing,shaderInfo.w)
            shaderInfo.parent:remove(shaderInfo.w)
            shaderInfo.w= nil
        else
            Window.instance().drawing_root:add(drawing,shaderInfo.w)
            Window.instance().drawing_root:remove(shaderInfo.w)
            shaderInfo.w= nil
        end
    end

    ShaderInfo.setShaderInfo(drawing, nil)
end

return M
end
        

package.preload[ "libEffect.shaders.PSBlend" ] = function( ... )
    return require('libEffect/shaders/PSBlend')
end
            

package.preload[ "libEffect/shaders/scratch" ] = function( ... )
local M = {}


local function gc_userdata (ud)
    ud:__gc()
    setudmetatable(ud, {})
end

local circleShader = require("shaders/circle")
local maskBlend = require("shaders.maskBlend")
local image2dMask = require("shaders.image2dMask")

local colorMaskInst = LuaInstruction(function ()
    gl.glColorMask(gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE)
end)

local inst = LuaInstruction(function (_,canvas)
    canvas:print_tree()
end)

M.createScratchWidget = function (bgNode,fgNode,config)

    local bg = bgNode
    local fg = fgNode

    local fgWidget = LuaWidget()
    fgWidget.cache = true
    --fgWidget.fbo.texture.pre_alpha = true
    
    fgWidget:add(fg)





    local maskImg = nil

    if config == nil then
       config = {}
    end

    if config.texFile == nil then
        maskImg = Sprite(TextureUnit.default_unit())
        maskImg.shader = require("shaders.circle")
        maskImg:set_uniform("instensity",Shader.uniform_value_float(config.intensity or 1.0))
        maskImg:set_uniform("softness",Shader.uniform_value_float(config.softness or 0.5))
        maskImg.size = config.size or Point(100,100)
    else
        maskImg = Sprite(TextureUnit(TextureCache.instance():get(config.texFile)))
        if config.size ~= nil then
            maskImg.size = config.size
        end
    end

    local fbo = FBO.create(Point(System.getScreenWidth(),System:getScreenHeight()))
    
    local tex = fbo.texture
    tex.pre_alpha = true

    local texUnit = TextureUnit(tex)

    local mask  = Sprite(texUnit)
    mask.visible = false

    
    local rc2dMask = RenderContext(image2dMask)

    local rcMaskBlend = RenderContext(maskBlend)

    local luaNode = new(LuaNode)
    
    local w = luaNode
    w:add(bg)
    w:add(mask)
    w:add(fgWidget)    

    w.lua_do_draw = function (_, canvas)
        
        canvas:add(PushStencil())          
        canvas:add(colorMaskInst)
        --canvas:begin_rc(rc2dMask)    
        bg:draw(canvas)
        --canvas:end_rc(rc2dMask)
        
        canvas:add(UseStencil(gl.GL_LEQUAL))
        canvas:add(PushBlendFunc(gl.GL_ZERO,gl.GL_ONE,gl.GL_ZERO,gl.GL_ONE_MINUS_SRC_ALPHA))
        mask:draw(canvas)
        canvas:add(PopBlendFunc())

        canvas:add(UnUseStencil())
        bg:draw(canvas)

        canvas:add(PopStencil())  
        --canvas:add(PushBlendFunc(gl.GL_DST_ALPHA,gl.GL_ONE_MINUS_DST_ALPHA, gl.GL_DST_ALPHA,gl.GL_ONE_MINUS_DST_ALPHA))   
        canvas:begin_rc(rcMaskBlend)
        canvas:add(BindTexture(Window.instance().root.fbo.texture,1))
        fgWidget:draw(canvas)
        canvas:end_rc(rcMaskBlend)
        --canvas:add(PopBlendFunc())

        --canvas:add(inst)
        return true
    end
    
    w.pos =  Point(0,0)

    Clock.instance():schedule_once(function ()
        fgWidget.fbo:save("fffffffffffffffffffff.png")
end)


    return {widget = w,
            fbo = fbo,
            tex = tex,
            texUnit = texUnit,
            mask = mask,
            maskImg = maskImg,
            fg = fg},
            function (config,pos,size)
                if config.mask.visible == false then
                    config.mask.visible = true
                end

                config.maskImg.size = size
                
                config.maskImg.pos = Point(config.fg:to_world(Point(0,0)).x + pos.x - config.maskImg.size.x/2, config.fg:to_world(Point(0,0)).y + pos.y - config.maskImg.size.y/2)

                config.fbo:render(config.maskImg)
                config.widget:invalidate()
       
            end
end

M.removeScratchNode = function (config)
    local t = config.tex
    local u = config.texUnit
    local mask = config.mask
    local fbo = config.fbo
    local w = config.widget
    mask:cleanup()

    gc_userdata(t)
    gc_userdata(u)
    gc_userdata(fbo)

    if w == nil then
        return config.widget
    end
    w:remove_all()
    delete(widget)
       
end



return M
end
        

package.preload[ "libEffect.shaders.scratch" ] = function( ... )
    return require('libEffect/shaders/scratch')
end
            

package.preload[ "libEffect/shaders/shatteringWidget" ] = function( ... )
local M = {}

local easing = require("libEffect.easing")
local shatteringShader = require("shaders.shattering")

M.createShatteringWidget = function (drawing,prim)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    local vFormatDefault = VBO.default_format_desc()
    table.insert(vFormatDefault, {'direction', 3, gl.GL_FLOAT})
    vformat = VBO.register_vertex_format(vFormatDefault)

    local parent = drawing.parent

    local gridWidth,gridHeight = drawing.size.x,drawing.size.y
    
    local prim = prim or 0

    local g 
    if prim == 0 then
        g = M.createQuadShards(drawing, gridWidth, gridHeight)
    else 
        g = M.createTriShards(drawing, gridWidth, gridHeight, gl.GL_TRIANGLES)
        --gl = M.createTriShards(drawing, gridWidth,gridHeight, gl.GL_LINE_LOOP)
    end



    local w = LuaWidget()
    if w == nil then
        return drawing
    end
    w.cache = true
                       ------------------------------------------------
    local rc = RenderContext(shatteringShader)
    
    if parent ~= nil then
        parent:add(w,drawing)
        w:add(drawing)
    else
        Window.instance().root:add(w,drawing)
        w:add(drawing)
    end

    local timeInst = SetState("time",Shader.uniform_value_float(0))

    local cullFaceInst = LuaInstruction(function ()

            --gl.glCullFace(gl.GL_FRONT)
            --gl.glDisable(gl.GL_CULL_FACE)
    end,false)

    w.lua_draw_self = function (self,canvas,bind_texture, vertex, content_change)
        
        canvas:begin_rc(rc)
        canvas:add(cullFaceInst)
        canvas:add(BindTexture(self.fbo.texture, 0))
        canvas:add(SetState("widgetSize",Shader.uniform_value_float2(gridWidth,gridHeight)))
        canvas:add(SetState("relativeOffset",Shader.uniform_value_float2(drawing.m_x,drawing.m_y)))
        canvas:add(timeInst)
        canvas:add(g)
        canvas:end_rc(rc)
    end

    local time = 0




    


    return {widget = w,
            timeInst = timeInst}
end


M.shatter = function (config)
    local duration = config.duration or 3000
    local w = config.widget
    local timeInst = config.timeInst
    local dataTime = easing.getEaseArray("easeInOutQuint", duration, 0, 1)
    local resTime = new(ResDoubleArray, dataTime)

    local table = {}

    local c = nil

    table.animTime = new(AnimIndex, kAnimNormal, 0, #dataTime - 1, duration , resTime, 0)
    
    c = Clock.instance():schedule(function (dt)
        time  = table.animTime:getCurValue()
        timeInst.value = Shader.uniform_value_float(time)
        
        w:invalidate()
        Window.instance().root:invalidate()
    end) 

    table.animTime:setEvent(table,function ()
        c:cancel() 
        delete(table.animTime) 
        delete(resTime)   
    end)
end

M.assemble = function (config)
    local duration = config.duration or 3000
    local w = config.widget
    local timeInst = config.timeInst
    local dataTime = easing.getEaseArray("easeInOutQuint", duration, 0, 1)
    local resTime = new(ResDoubleArray, dataTime)

    local table = {}

    local c = nil

    table.animTime = new(AnimIndex, kAnimNormal, 0, #dataTime - 1, duration , resTime, 0)
    
    c = Clock.instance():schedule(function (dt)
        time  = table.animTime:getCurValue()
        timeInst.value = Shader.uniform_value_float(1.0-time)
        
        w:invalidate()
        Window.instance().root:invalidate()
    end)
    
    
    table.animTime:setEvent(table,function ()
        c:cancel() 
        delete(table.animTime) 
        delete(resTime)   
    end)
      
end


M.createTriShards = function (drawing, w, h, primitive)
    local pos = Point(drawing.pos.x,drawing.pos.y)
    local size = Point(drawing.size.x,drawing.size.y)

    local a = pos
    local b = pos + Point(size.x,0)
    local c = pos + size
    local d = pos + Point(0,size.y)

    local shards = 4

    local r1 = {}
    for i=1,shards do
        r1[i] = pos + Point(size.x/2,size.y/2)
    end


    local r2 = {}
    local r3 = {}

    local angle = {}

    angle[1] = math.atan((c.x-r1[1].x)/(c.y-r1[1].y))
    angle[2] = math.atan((b.x-r1[1].x)/(b.y-r1[1].y))
    angle[3] = math.atan((a.x-r1[1].x)/(a.y-r1[1].y))
    angle[4] = math.atan((d.x-r1[1].x)/(d.y-r1[1].y))


    local rad = 0
    
    local dirRays1 = {}
    local radians1 = {}
    local dirRays2 = {}
    local radians2 = {}
    local dirRays3 = {}
    local radians3 = {}

    math.randomseed(os.time())

    
    for i = 1,shards do
        rad = rad + 6.28 / shards + (math.random() * 2 - 1) * 6.28 / shards * 0.1
        radians1[i] = rad
        dirRays1[i] = Point(math.sin(radians1[i]),math.cos(radians1[i]))
        --print("dirRay -----------------------   ",dirRays1[i])
        
        M.createNextPointRay(r2,radians2,dirRays2,r1,radians1,dirRays1,i,360/shards/4,100,20)

        for j = 1, 2 do
            M.createNextPointRay(r3,radians3,dirRays3,r2,radians2,dirRays2,(i-1) * 2 + j,360/shards/4,100,20)
        end
    end


    local intersectPointT = {}
    for i = 1,#dirRays3 do

        
        
        local intersectPoint = nil;
        intersectPoint = M.RayToLineIntersection(a,b,r3[math.modf((i+1)/2)],dirRays3[i])    
        if intersectPoint ~= nil then
            ---------------------若相交点在矩形区域内则保留
            if intersectPoint.x >=pos.x and intersectPoint.x <= pos.x+size.x and intersectPoint.y >= pos.y and intersectPoint.y <= pos.y+size.y then 
                --print("intersectPoint ------------------------------------", intersectPoint)
                table.insert(intersectPointT,intersectPoint)
            end
        end
        intersectPoint = M.RayToLineIntersection(b,c,r3[math.modf((i+1)/2)],dirRays3[i]) 
        if intersectPoint ~= nil then   
            if intersectPoint.x >=pos.x and intersectPoint.x <= pos.x+size.x and intersectPoint.y >= pos.y and intersectPoint.y <= pos.y+size.y then 
                --print("intersectPoint ------------------------------------", intersectPoint)
                table.insert(intersectPointT,intersectPoint)
            end
        end
        intersectPoint = M.RayToLineIntersection(c,d,r3[math.modf((i+1)/2)],dirRays3[i])   
        if intersectPoint ~= nil then 
            if intersectPoint.x >=pos.x and intersectPoint.x <= pos.x+size.x and intersectPoint.y >= pos.y and intersectPoint.y <= pos.y+size.y then 
                --print("intersectPoint ------------------------------------", intersectPoint)
                table.insert(intersectPointT,intersectPoint)
            end
        end
        intersectPoint = M.RayToLineIntersection(d,a,r3[math.modf((i+1)/2)],dirRays3[i])    
        if intersectPoint ~= nil then
            if intersectPoint.x >=pos.x and intersectPoint.x <= pos.x+size.x and intersectPoint.y >= pos.y and intersectPoint.y <= pos.y+size.y then 
                --print("intersectPoint ------------------------------------", intersectPoint)
                table.insert(intersectPointT,intersectPoint)
            end
        end
    end

    local data = {}
    local start1 = 1
    local start2 = shards + 1

    data[1] = struct.pack("ffffffffffffff",r1[1].x,r1[1].y,0,
                                          (r1[1].x-pos.x)/size.x,(r1[1].y-pos.y)/size.y,0,
                                          1,1,1,1,0,0,0,0)

    for i = 1, shards do
        table.insert(data,struct.pack("ffffffffffffff",r2[i].x,r2[i].y,0,
                                                      (r2[i].x-pos.x)/size.x,(r2[i].y-pos.y)/size.y,0,
                                                      1,1,1,1,0,0,0,0))
    end
    
    for i = 1,shards * 3 do
        if i < shards + 1 then
            table.insert(data,struct.pack("ffffffffffffff",r3[(i-1)*2+1].x,r3[(i-1)*2+1].y,0,
                                                          (r3[(i-1)*2+1].x-pos.x)/size.x,(r3[(i-1)*2+1].y-pos.y)/size.y,1,
                                                          1,1,1,1,0,0,0,0))
            table.insert(data,struct.pack("ffffffffffffff",r3[(i-1)*2+2].x,r3[(i-1)*2+2].y,0,
                                                          (r3[(i-1)*2+2].x-pos.x)/size.x,(r3[(i-1)*2+2].y-pos.y)/size.y,1,
                                                          1,1,1,1,0,0,0,0))
        else
            table.insert(data,struct.pack("ffffffffffffff",intersectPointT[(i-start2)*2+1].x,intersectPointT[(i-start2)*2+1].y,0,
                                                          (intersectPointT[(i-start2)*2+1].x-pos.x)/size.x,(intersectPointT[(i-start2)*2+1].y-pos.y)/size.y,1,
                                                          1,1,1,1,0,0,0,0))
            table.insert(data,struct.pack("ffffffffffffff",intersectPointT[(i-start2)*2+2].x,intersectPointT[(i-start2)*2+2].y,0,
                                                          (intersectPointT[(i-start2)*2+2].x-pos.x)/size.x,(intersectPointT[(i-start2)*2+2].y-pos.y)/size.y,1,
                                                          1,1,1,1,0,0,0,0))
        end
    end

    table.insert(data,struct.pack("ffffffffffffff",c.x,c.y,0,
                                                  (c.x-pos.x)/size.x,(c.y-pos.y)/size.y,1,
                                                  1,1,1,1,0,0,0,0))
    table.insert(data,struct.pack("ffffffffffffff",b.x,b.y,0,
                                                  (b.x-pos.x)/size.x,(b.y-pos.y)/size.y,1,
                                                  1,1,1,1,0,0,0,0))
    table.insert(data,struct.pack("ffffffffffffff",a.x,a.y,0,
                                                  (a.x-pos.x)/size.x,(a.y-pos.y)/size.y,1,
                                                  1,1,1,1,0,0,0,0))
    table.insert(data,struct.pack("ffffffffffffff",d.x,d.y,0,
                                                  (d.x-pos.x)/size.x,(d.y-pos.y)/size.y,1,
                                                  1,1,1,1,0,0,0,0))
   
    local g = LuaVertexBuilder(vformat,primitive,function ()
        
        local v = {}
        local index = {}
                

        for i = 1, shards do
            if i ~= shards then
                local a = M.randomZeroToOne()
                table.insert(v,data[1]..a)
                table.insert(v,data[i+2]..a)
                table.insert(v,data[i+1]..a)
            else       
                local a = M.randomZeroToOne()      
                table.insert(v,data[1]..a)
                table.insert(v,data[2]..a)
                table.insert(v,data[i+1]..a)
            end    
        end   

        for i = 1, shards do
            --初始射线四条的话，为165 176 127
            if i ~= shards then
                local a = M.randomZeroToOne() 
                local b = M.randomZeroToOne()
                local c = M.randomZeroToOne() 

                table.insert(v,data[i + 1]..a)
                table.insert(v,data[i * 2 + shards + 1]..a)
                table.insert(v,data[i * 2 + shards]..a) 
                
                 
                table.insert(v,data[i + 1]..b)
                table.insert(v,data[i * 2 + shards + 2]..b)
                table.insert(v,data[i * 2 + shards + 1]..b)
            
                
                table.insert(v,data[i + 1]..c)
                table.insert(v,data[i + 2]..c)
                table.insert(v,data[i * 2 + shards + 2]..c)  
            --最后一个区域要跟第一个相连
            else
                local a = M.randomZeroToOne()
                local b = M.randomZeroToOne()
                local c = M.randomZeroToOne()

                table.insert(v,data[i + 1]..a)
                table.insert(v,data[i * 2 + shards + 1]..a)
                table.insert(v,data[i * 2 + shards]..a) 
            
                table.insert(v,data[i + 1]..b)
                table.insert(v,data[2*start1 + shards]..b)   -- 1 = 起点的序号
                table.insert(v,data[i * 2 + shards + 1]..b)
            
                table.insert(v,data[i + 1]..c)
                table.insert(v,data[start1 + 1]..c)
                table.insert(v,data[2*start1 + shards]..c)  
            end
        end 

        for i = start2, shards * 3 do 
             --初始射线四条的话，为165 176 127
            if i ~= shards * 3 then
                local a = M.randomZeroToOne()
                local b = M.randomZeroToOne()
                local c = M.randomZeroToOne()
                 
                table.insert(v,data[i + 1]..a)
                table.insert(v,data[i * 2 + shards + 1]..a)
                table.insert(v,data[i * 2 + shards]..a) 
            
                table.insert(v,data[i+1]..b)
                table.insert(v,data[i * 2 + shards + 2]..b)
                table.insert(v,data[i * 2 + shards + 1]..b)
            
                table.insert(v,data[i + 1]..c)
                table.insert(v,data[i + 2]..c)
                table.insert(v,data[i * 2 + shards + 2]..c)  
            --最后一个区域要跟第一个相连
            else
                local a = M.randomZeroToOne()
                local b = M.randomZeroToOne()
                local c = M.randomZeroToOne()

                table.insert(v,data[i + 1]..a)
                table.insert(v,data[i * 2 + shards + 1]..a)
                table.insert(v,data[i * 2 + shards]..a) 
            
                table.insert(v,data[i + 1]..b)
                table.insert(v,data[2 * start2 + shards]..b)   -- 1 = 起点的序号
                table.insert(v,data[i * 2 + shards + 1]..b)
            
                table.insert(v,data[i + 1]..c)
                table.insert(v,data[start2 + 1]..c)
                table.insert(v,data[2*start2 + shards]..c)  
            end
        end 
        
        
  

        local mark1,mark2,mark3,mark4;

        for i = 1 , shards * 4 do
            if mark1 == nil and radians3[i]+radians2[math.modf((i+1)/2)] > angle[1] then           
                mark1 = i
            end
            if mark2 == nil and radians3[i]+radians2[math.modf((i+1)/2)] > 3.14 + angle[2] then
                mark2 = i
            end
            if mark3 == nil and radians3[i]+radians2[math.modf((i+1)/2)] > 3.14 + angle[3] then
                mark3 = i
            end
            if mark4 == nil and radians3[i]+radians2[math.modf((i+1)/2)] > 6.28 + angle[4] then
                mark4 = i
            end
        end


        --local mark1,mark2,mark3,mark4 = 1,5,9,13


       --[[ table.insert(data,struct.pack("fffff",c.x,c.y,0,(c.x-pos.x)/size.x,(c.y-pos.y)/size.y))
        table.insert(data,struct.pack("fffff",b.x,b.y,0,(b.x-pos.x)/size.x,(b.y-pos.y)/size.y))
        table.insert(data,struct.pack("fffff",a.x,a.y,0,(a.x-pos.x)/size.x,(a.y-pos.y)/size.y))
        table.insert(data,struct.pack("fffff",d.x,d.y,0,(d.x-pos.x)/size.x,(d.y-pos.y)/size.y))

        table.insert(v, data[mark1+shards * 3 + 1])
        table.insert(v, data[shards * 7 + 2])
        table.insert(v, data[shards * 7 + 1])
                     
        table.insert(v, data[mark2+shards * 3+1])
        table.insert(v, data[shards * 7 + 3])
        table.insert(v, data[mark2+shards * 3])
                        
        table.insert(v, data[mark3+shards * 3+1])
        table.insert(v, data[shards * 7 + 4])
        table.insert(v, data[mark3+shards * 3])
                       
        table.insert(v, data[mark4+shards * 3+1])
        table.insert(v, data[shards * 7 + 5])
        table.insert(v, data[mark4+shards * 3])
        ]]--



        for i = 1,#v do
            table.insert(index,i-1)
        end


       -- Clock.instance():schedule_once(function ()
       --     print(mark1,mark2,mark3,mark4)
       -- end,3) 

        return v, index
    end)


    return g
end






M.createQuadShards = function (drawing,w,h)
    local grids = 20

    local gridVertex = {}
    local gridUV = {}

    for i = 1,grids+1 do
        gridVertex[i] = {}
        gridUV[i] = {}
        for j = 1, grids+1 do
             gridVertex[i][j] = {}
             gridVertex[i][j].x = (i-1) * w/grids
             gridVertex[i][j].y = (j-1) * h/grids  

             gridUV[i][j] = {}
             gridUV[i][j].x = (i-1)/grids
             gridUV[i][j].y = (j-1)/grids       
        end
    end


    local randomTable = {}

    for i = 1, grids * grids do
        randomTable[i] = {}
        randomTable[i].x = math.random() * 2 -1
        randomTable[i].y = math.random() * 2 -1
        randomTable[i].z = math.random() * 2 -1
    end



    local g = LuaVertexBuilder(vformat,gl.GL_TRIANGLES,function ()
        local v = {}
        local index = {}

        for i = 1, grids do
            for j = 1,grids do
                table.insert(v,struct.pack("fffffffffffffffff",gridVertex[i][j].x + drawing.m_x,gridVertex[i][j].y+ drawing.m_y,0,
                                                      gridUV[i][j].x,gridUV[i][j].y,1,
                                                      1,1,1,1,0,0,0,0,
                                                      randomTable[(i-1)*grids + j].x,randomTable[(i-1)*grids + j].y,randomTable[(i-1)*grids + j].z))
                table.insert(v,struct.pack("fffffffffffffffff",gridVertex[i+1][j].x+ drawing.m_x,gridVertex[i+1][j].y+ drawing.m_y,0,
                                                      gridUV[i+1][j].x,gridUV[i+1][j].y,1,
                                                      1,1,1,1,0,0,0,0,
                                                      randomTable[(i-1)*grids + j].x,randomTable[(i-1)*grids + j].y,randomTable[(i-1)*grids + j].z))
                table.insert(v,struct.pack("fffffffffffffffff",gridVertex[i+1][j+1].x+ drawing.m_x,gridVertex[i+1][j+1].y+ drawing.m_y,0,
                                                      gridUV[i+1][j+1].x,gridUV[i+1][j+1].y,1,
                                                      1,1,1,1,0,0,0,0,
                                                      randomTable[(i-1)*grids + j].x,randomTable[(i-1)*grids + j].y,randomTable[(i-1)*grids + j].z))
                table.insert(v,struct.pack("fffffffffffffffff",gridVertex[i][j+1].x+ drawing.m_x,gridVertex[i][j+1].y+ drawing.m_y,0,
                                                      gridUV[i][j+1].x,gridUV[i][j+1].y,1,
                                                      1,1,1,1,0,0,0,0,
                                                      randomTable[(i-1)*grids + j].x,randomTable[(i-1)*grids + j].y,randomTable[(i-1)*grids + j].z))

            
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 0)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 1)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 2)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 2)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 3)
                table.insert(index,(i-1)*4*grids+(j-1)*4 + 0)


                --print(randomTable[(i-1)*grids + j].x,randomTable[(i-1)*grids + j].y,randomTable[(i-1)*grids + j].z)
            end
        end

        return v, index
    end)

    return g
end



M.IntersectPoint = function(pointRay,dirRay,dis)
     return pointRay + Point(dirRay.x * dis, dirRay.y * dis)
end



M.RayToLineIntersection = function(pointA, pointB,
                                pointRay, dirRay)
       
                local d;
               
                local dirAtoB = pointB - pointA;
                local mag = math.sqrt(dirAtoB.x * dirAtoB.x + dirAtoB.y * dirAtoB.y)
                dirAtoB = Point(dirAtoB.x/mag,dirAtoB.y/mag)
                
                local dirRay = dirRay;


                if dirAtoB.x * (-dirRay.y) + dirAtoB.y * dirRay.x ~= 0 then
                
                    if dirAtoB.y / dirAtoB.x ~= dirRay.y / dirRay.x then
               
                        d = dirAtoB.x * dirRay.y - dirAtoB.y * dirRay.x;
                        if d < 0 then   -----------只取其中一个方向的相交点单位
                        
                                local vertexRaytoA = pointA - pointRay;
                                local aDis = (vertexRaytoA.y * dirRay.x  - vertexRaytoA.x * dirRay.y) / d; --点A的距离单位
                                local rDis = (vertexRaytoA.y * dirAtoB.x - vertexRaytoA.x * dirAtoB.y) / d; --射线的距离单位

                                return M.IntersectPoint(pointRay,dirRay,rDis)
                        end
                    end
                end
                return nil;
end

M.createNextPointRay = function(rNext, radianNext, dirRayNext, r,  radian, dirRay, index, angle, dis ,offset)
        rNext[index] = r[math.modf((index+1)/2)] + dirRay[index] * (dis +math.random() * offset) --截取的点的位置需要随着中心点变化
        -- +math.random() * offset

        radianNext[(index - 1) * 2 + 1]  = radian[index] + math.rad(-angle)
        radianNext[(index - 1) * 2 + 2]  = radian[index] + math.rad(angle)

        dirRayNext[(index - 1) * 2 + 1] = Point(math.sin(radianNext[(index - 1) * 2 + 1]), math.cos(radianNext[(index - 1) * 2 + 1]))
        dirRayNext[(index - 1) * 2 + 2] = Point(math.sin(radianNext[(index - 1) * 2 + 2]), math.cos(radianNext[(index - 1) * 2 + 2]))
end

M.randomZeroToOne = function()
    return struct.pack("fff",math.random() * 2 -1,math.random() * 2 -1,math.random() * 2 -1)
end

return M
end
        

package.preload[ "libEffect.shaders.shatteringWidget" ] = function( ... )
    return require('libEffect/shaders/shatteringWidget')
end
            

package.preload[ "libEffect/shaders/stencilMask" ] = function( ... )
-- @module libEffect.shaders.stencilMask
-- @author Fang Fang
--
-- @usage local stencilMask = require 'libEffect.shaders.stencilMask'

---
-- `libEffect.shaders.stencilMask`利用模板遮罩效果来实现drawing的不规则裁剪.通过调用`libEffect.shaders.stencilMask.applyToDrawing()`，对drawing进行不规则裁剪。
-- 注：不支持多个mask重合时，分别对应不同的drawing进行遮罩的情况
-- <p>
-- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1458198302538_6954509064426354223.png"></td>
-- <td><img height="224" width="400" src="http://engine.by.com:8080/hosting/data/1458197963700_5769683861684139635.png"></td>
-- </tr>
-- </table>
-- </p>
-- 
-- @module libEffect.shaders.stencilMask
-- @author Li Heng
--
-- @usage local stencilMask = require 'libEffect.shaders.stencilMask'

local Image2dMask_Shader = require("shaders.image2dMask")
local GC = require ("libutils.gc");
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local stencilMask = {}

local effectName = 'stencilMask'

---
-- 使用模板遮罩来做drawing的不规则裁剪.
-- 应用此效果后，drawing只显示mask中的部分。注意：传进来的drawing和mask不要在外部添加到任何节点中，否则将会绘制两遍。
-- 应用该接口后，在不需要该效果时可以调用@{#libEffect.shaders.stencilMask.removeStencilEffect}接口进行遮罩消除和资源销毁. 
--
-- @param #WidgetBase parent drawing和mask的父节点，遮罩效果将添加在parent下
-- @param core.drawing#DrawingImage drawing 将要被裁剪的drawing
-- @param core.drawing#DrawingImage mask 用mask中像素颜色alpha不为0的部分添加模板遮罩.
stencilMask.applyToDrawing = function (parent, drawing, mask, discardRange)
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    local disRan = discardRange or 0.5

    if disRan < 0 or disRan > 1 then 
        error("disRan must in range 0 ~ 1")
    end

    if not ShaderInfo.getShaderInfo(parent) or ShaderInfo.getShaderName(parent) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(parent)
        if shaderInfo == nil then
                        
            local luaNode = new(LuaNode);

            local rootChild = false

            if parent.parent.parent == nil then
                parent = new(luaNode)
                Window.instance().drawing_root:add(parent) 
                rootChild = true
            end
                parent:add(luaNode);
            
            local imageWg = drawing
            local maskWg = mask

            local w = luaNode
           
            w:add(imageWg);
            w:add(maskWg);

            w.cache = true
            w.fbo.need_stencil = true
            if not Window.instance().root_use_fbo then
                w.size = maskWg.size
                w.clip = true
            end

            local rc = RenderContext(Image2dMask_Shader)
            luaNode.lua_do_draw = function (_, canvas)
            --画模板
                canvas:add(PushStencil())  
                canvas:begin_rc(rc)
                canvas:add(SetState("discardRange",Shader.uniform_value_float(disRan)))
                maskWg:draw(canvas)            
                canvas:end_rc(rc)
            
            --画Drawing    
                canvas:add(UseStencil(gl.GL_EQUAL))
                imageWg:draw(canvas)
                canvas:add(UnUseStencil())
                canvas:add(PopStencil())

                return true
            end

            ShaderInfo.setShaderInfo(parent, effectName,
            {
                luaNode = luaNode,              
                drawing = drawing,
                mask = mask,
                rootChild = rootChild
            } )
            

            local shaderInfo = ShaderInfo.getShaderInfo(parent)

            return parent
        end
    end


    
    
end


---
-- 去掉parent下面的遮罩效果，包括可以销毁drawing和mask.
-- 注意，如果clean为true，drawing和mask将被delete掉，不需要在外部再delete了，如需使用drawing，需要重新new一个。
-- 如果clean为false，需要手动delete掉drawing和mask，如需使用drawing，addChild到某个父节点即可.
--
-- @param #WidgetBase parent 遮罩效果的父节点.
-- @param #boolean clean 是否delete掉drawing和mask，默认为false.
stencilMask.removeStencilEffect = function (parent, clean)

    local shaderInfo = ShaderInfo.getShaderInfo(parent)
    if not shaderInfo then return end 

    if clean then
        if shaderInfo.drawing then
            delete(shaderInfo.drawing)
            shaderInfo.drawing = nil
        end

        if shaderInfo.mask then
            delete(shaderInfo.mask)
            shaderInfo.mask = nil
        end
    end
    
    if shaderInfo.luaNode then
        local w = shaderInfo.luaNode
        w:remove_all()
        delete(shaderInfo.luaNode)
        shaderInfo.luaNode = nil
    end

    if shaderInfo.rootChild == true then
        parent:remove_all()
        delete(parent)
        shaderInfo.rootChild = nil
    end


    ShaderInfo.setShaderInfo(parent, nil)
end
  
return stencilMask

end
        

package.preload[ "libEffect.shaders.stencilMask" ] = function( ... )
    return require('libEffect/shaders/stencilMask')
end
            

package.preload[ "libEffect/shaders/vectorGraph" ] = function( ... )
local function unpackTables(...)
	local arg = {...}
	local merge = {}
	for i,v in ipairs(arg) do
		for i,v in ipairs(v) do
			table.insert(merge, v)
		end
	end
	return unpack(merge)
end

-- 把255的颜色转换为0-1的颜色。
local function convertColor2GL(color)
	local rtn = {}
	for i,v in ipairs(color) do
		table.insert(rtn, v/255)
	end
	return rtn 
end


local nvg = Nanovg(bit.bor(Nanovg.NVG_ANTIALIAS, Nanovg.NVG_DEBUG, Nanovg.NVG_STENCIL_STROKES))
----------------------------------------------------------- 矩形
local Rectangle = class(DrawingEmpty, false)

Rectangle.ctor = function(self, width, height,strokeWidth)

	super(self, width, height)
	self.m_width = width
	self.m_height = height
	self.m_widget = Widget.get_by_id(self.m_drawingID)
	self.m_widget.size = Point(width, height)
    self.m_strokeWidth = strokeWidth or 2

end


Rectangle.setColor = function (self, R,G,B)
	self.m_R = R/255
	self.m_G = G/255
	self.m_B = B/255
end

-- 是否填充
Rectangle.setFill = function(self, fill)
	self.m_isFill = fill
end

Rectangle.isFill = function(self)
	return self.m_isFill
end

--更新绘制
Rectangle.on_update = function (self)

	local draw = function (nvg)

    	nvg:reset()
		local p = self.m_widget.relative_matrix:transform_point(Point(0,0))
        nvg:translate(p)
        
		if self.m_isFill then
            nvg:begin_path()
		    nvg:rect(Rect(0, 0, self.m_width, self.m_height))
            nvg:close_path()
			nvg:fill_color(Colorf(self.m_R,self.m_G,self.m_B,1))
			nvg:fill()
		else
            nvg:begin_path()
		    nvg:rect(Rect(0, 0, self.m_width - self.m_strokeWidth, self.m_height - self.m_strokeWidth))
            nvg:close_path()
			nvg:stroke_color(Colorf(self.m_R,self.m_G,self.m_B,1));
            nvg:stroke_width(self.m_strokeWidth)
    		nvg:stroke()
    	end
	end

	local inst = LuaInstruction(function(self, canvas)
        nvg:begin_frame(canvas)
        draw(nvg)
        nvg:end_frame()
    end, true)

    local node = LuaWidget()
    node.lua_do_draw =function ( self, canvas )
    	canvas:add(inst)
    end
    node.size = Point(self.m_width, self.m_height)
    self.m_widget:add(node)
end


-- 设置4个角的颜色，通过设置不同的颜色，可以有颜色渐变效果。
-- 颜色格式： {rgba}, 如：{1, 0.5, 0, 1}
-- Rectangle.setColors = function(self, topLeft, topRight, bottomLeft, bottomRight)
-- 	self.m_topleft_color = topLeft
-- 	self.m_topright_color = topRight
-- 	self.m_bottomleft_color = bottomLeft
-- 	self.m_bottomright_color = bottomRight
-- end


---------------------------------------------------- 直线
local Line = class(Rectangle, false)
-- local nvggg = Nanovg(bit.bor(Nanovg.NVG_ANTIALIAS, Nanovg.NVG_DEBUG, Nanovg.NVG_STENCIL_STROKES))
Line.ctor = function(self, width)
	super(self, width, 2)
	self.m_isFill = true
end




-- 设置一个颜色渐变。
-- startColor(rgba):左端颜色。(如：{255, 0, 255, 255})
-- endColor:右端颜色。
-- Line.setColors = function(self, startColor, endColor)
-- 	self.m_start_color = startColor 
-- 	self.m_end_color = endColor
-- end

--------------- 点
local Dot = class(Rectangle, false)

-- pointsize:点的大小
Dot.ctor = function(self, pointsize)
	super(self, pointsize, pointsize)
end



------------------------------ 圆
local Circle = class(DrawingEmpty, false)

Circle.ctor = function(self, radius)
	self.m_radius = radius	
	super(self, radius*2, radius*2)

	self.m_widget = Widget.get_by_id(self.m_drawingID)
	self.m_widget.size = Point(radius*2, radius*2)
end

Circle.setColor = function (self, R,G,B)
	self.m_R = R/255
	self.m_G = G/255
	self.m_B = B/255
end


Circle.on_update = function (self)
	local draw = function (nvg)

    	nvg:reset()
		local p = self.m_widget.relative_matrix:transform_point(Point(0,0))
        nvg:translate(p)
        nvg:begin_path()
		nvg:circle(Point(0, 0), self.m_radius)
        nvg:close_path()
		if self.m_isFill then
			nvg:fill_color(Colorf(self.m_R,self.m_G,self.m_B,1))
			nvg:fill()
		else
			nvg:stroke_color(Colorf(self.m_R,self.m_G,self.m_B,1));
    		nvg:stroke()
    	end
	end

	local inst = LuaInstruction(function(self, canvas)
        nvg:begin_frame(canvas)
        draw(nvg)
        nvg:end_frame()
    end, true)

    local node = LuaWidget()
    node.lua_do_draw =function ( self, canvas )
    	canvas:add(inst)
    end
    node.size = Point(self.m_width, self.m_height)
    self.m_widget:add(node)
end

-- Circle.setColors = function(self, centerColor, edgeColor)
-- 	self.m_center_color = centerColor
-- 	self.m_edge_color = edgeColor
	
-- end

Circle.setFill = function(self, fill)
	self.m_isFill = fill
end

Circle.isFill = function(self)
	return self.m_isFill
end

--------------------------------
local graphs = {}
graphs.Rectangle = Rectangle
graphs.Line = Line
graphs.Dot = Dot
graphs.Circle = Circle

return graphs
end
        

package.preload[ "libEffect.shaders.vectorGraph" ] = function( ... )
    return require('libEffect/shaders/vectorGraph')
end
            

package.preload[ "libEffect/shaders/whiteScale" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Zhang zhi peng
--

---
-- `WhiteScale`使图片看起来有些泛白的效果。通过调用 `WhiteScale.applyToDrawing()` 等函数，将效果应用到一个drawing对象上。
--
-- @module WhiteScale
-- @author zhang zhi peng
--
-- @usage local MirrorHorizontal = require 'libEffect.shaders.whiteScale'



local whiteScale_Shader = require("shaders.whiteScale")
local GC = require ("libutils.gc");
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'

local whiteScale = {}
local effectName = 'whiteScale'



--- 
-- 对drawing应用镜像效果（水平）。
--
-- @param core.drawing#DrawingImage drawing 要应用的对象。若不是DrawingImage，则error()。
-- @param number 。(0, 1.0) 数字越大，效果越明显。默认使用0.3
whiteScale.applyToDrawing = function (drawing, config)
    
    if drawing.unit == nil then 
        error("drawing's texture unit doesn't exist ")
    end

    local bright = config.bright

    bright = bright or 0.3

    if bright and type(bright)~="number" then 
        error("bright 必须是数字")
    end

    if bright <= 0 or bright >= 1 then 
        error("bright 必须在0-1.0范围内")
    end

    local w = drawing
    if w == nil then
        return drawing
    end  
    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)              
            w.shader = whiteScale_Shader;
            ShaderInfo.setShaderInfo(drawing, effectName, { bright = bright})                                              
        end
    end

    w:set_uniform("bright", Shader.uniform_value_float(bright))

    w:invalidate();

    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    GC.setFinalizer(shaderInfo, function ()
        local isDrawingExists =  drawingTracer.isDrawingExists(drawing.m_drawingID)
        if isDrawingExists ~= nil and  ShaderInfo.getShaderInfo(drawing)~= nil then
            w.shader = -1;
        end
       
    end)


end

return whiteScale
end
        

package.preload[ "libEffect.shaders.whiteScale" ] = function( ... )
    return require('libEffect/shaders/whiteScale')
end
            

package.preload[ "libEffect/shaders/internal/blurImplementation" ] = function( ... )
--
-- libEffect Version: @@Version@@
--
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang
-- Heng Li
--

-- -
-- Implementation of @{libEffect.shaders.blur#Blur}.
-- @module libEffect.shaders.internal.blurImplementation
-- @extends libEffect.shaders.blur#Blur
local M = { }

require('core/object')
require('core/drawing')

local GC = require("libutils.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local Common = require("libEffect.shaders.common")
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)
local effectName = 'blur'

---
-- See @{libEffect.shaders.blur#Blur.getIntensityRange}.
M.getIntensityRange = function()
    return 0, 12
end
 
-- -
-- 第一个渲染阶段，垂直模糊，将当前的Drawing生成位图资源，并传入shader进行像素运算。
--
-- @param #number drawingId Drawing对象的ID。
-- @param #number rexTexId 将当前屏幕渲染的Drawing对象生成位图资源的ID。
-- @param #number ratioId 对于单个像素的周围像素采样时，采样范围的缩放值的ID
-- @param #number heightId 当前渲染屏幕的高度，影响了采样的距离。
local bindVerticalPassParameters = function(drawing, resTexId, ratio)
    res_create_framebuffer_image(0, resTexId, 0, 1)


    if ShaderIdManager.VBlur ~= nil and ShaderIdManager.VBlur.shaderId ~= nil then
        drawing_set_shader(drawing.m_drawingID,ShaderIdManager.VBlur.shaderId)
end

    drawing_set_shader_float_data(drawing.m_drawingID,ShaderIdManager.VBlur.ratioId,{ratio})
    drawing_set_shader_float_data(drawing.m_drawingID,ShaderIdManager.VBlur.heightId,{720.0})
    drawing_set_shader_texture_data(drawing.m_drawingID,ShaderIdManager.VBlur.verBLurTexId,resTexId)
end

-- -
-- 第二个渲染阶段，水平模糊，将当前的Drawing生成位图资源，并传入shader进行像素运算
--
-- @param #number drawingId Drawing对象的ID。
-- @param #number rexTexId 将当前屏幕渲染的Drawing对象生成位图资源的ID。
-- @param #number ratioId 对于每个像素的周围像素采样时，采样范围的缩放值的ID
-- @param #number widthId 当前渲染屏幕的宽度，影响了采样的距离。
local bindHorizontalPassParameters = function(drawing, resTexId, ratio)
    --[[res_create_framebuffer_image(0, resTexId, 0, 1)

    if ShaderIdManager.HBlur ~= nil and ShaderIdManager.HBlur.shaderId ~= nil then
        drawing_set_shader(drawing.m_drawingID,ShaderIdManager.HBlur.shaderId)
end

    drawing_set_shader_float_data(drawing.m_drawingID,ShaderIdManager.HBlur.ratioId,{ratio})
    drawing_set_shader_float_data(drawing.m_drawingID,ShaderIdManager.HBlur.widthId,{1280.0})
    drawing_set_shader_texture_data(drawing.m_drawingID,ShaderIdManager.HBlur.horBLurTexId,resTexId)]]--  
end

local renderAsImage = function(drawing)
    --local w, h = drawing:getRealSize()
    local resResultId = res_alloc_id()

    res_create_framebuffer_image(0, resResultId, 0, 1)

    --local image2dXId = shader_create(vsImage2dX,fsImage2dX)

    if ShaderIdManager.image2dX ~= nil and ShaderIdManager.image2dX.shaderId ~= nil then
        drawing_set_shader(drawing.m_drawingID,ShaderIdManager.image2dX.shaderId)
    end

    drawing_set_shader_texture_data(drawing.m_drawingID,ShaderIdManager.image2dX.image2dXTexId,resResultId)

    return function()
    end , resResultId
end

local doApplyToDrawing = function(drawing, sampleRatio)
    --local widthId = res_alloc_id()
    --local heightId = res_alloc_id()
    --local sampleRatioId = res_alloc_id()
    --local dynamicResId1 = res_alloc_id()
    --local dynamicResId2 = res_alloc_id()

    --local width = drawing_get_width(drawing.m_drawingID)
    --local height = drawing_get_height(drawing.m_drawingID)

    --res_create_double_array(0, widthId, { width })
    --res_create_double_array(0, heightId, { height })
    --res_create_double_array(0, sampleRatioId, { sampleRatio })

    local delay = 2000
    local animDealy = new(AnimInt,kAnimNormal,0,1,delay*1,0)
    local animDealy2 = new(AnimInt,kAnimNormal,0,1,delay*2,0)
    animDealy:setEvent(nil,function ()
    local dynamicResId1 = res_alloc_id()
        bindVerticalPassParameters(drawing, dynamicResId1, sampleRatio)
        
        local time = sys_get_int("frame_time",-1)
        print_string("1: "..time)
    end)

    animDealy2:setEvent(nil,function ()
    local dynamicResId2 = res_alloc_id()
        bindHorizontalPassParameters(drawing, dynamicResId2, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("2: "..time)
    end)
    local animDealy3 = new(AnimInt,kAnimNormal,0,1,delay*3,0)
    local animDealy4 = new(AnimInt,kAnimNormal,0,1,delay*4,0)
    animDealy3:setEvent(nil,function ()
        local dynamicResId1 = res_alloc_id()
        bindVerticalPassParameters(drawing, dynamicResId1, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("3: "..time)
    end)

    animDealy4:setEvent(nil,function ()
        local dynamicResId2 = res_alloc_id()
        bindHorizontalPassParameters(drawing, dynamicResId2, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("4: "..time)
    end)
    local animDealy5 = new(AnimInt,kAnimNormal,0,1,delay*5,0)
    local animDealy6 = new(AnimInt,kAnimNormal,0,1,delay*6,0)
    animDealy5:setEvent(nil,function ()
        local dynamicResId1 = res_alloc_id()
        bindVerticalPassParameters(drawing, dynamicResId1, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("5: "..time)
    end)

    animDealy6:setEvent(nil,function ()
        local dynamicResId2 = res_alloc_id()
        bindHorizontalPassParameters(drawing, dynamicResId2, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("6: "..time)
    end)
    local animDealy7 = new(AnimInt,kAnimNormal,0,1,delay*7,0)
    local animDealy8 = new(AnimInt,kAnimNormal,0,1,delay*8,0)
    animDealy7:setEvent(nil,function ()
        local dynamicResId1 = res_alloc_id()
        bindVerticalPassParameters(drawing, dynamicResId1, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("7: "..time)
    end)

    animDealy8:setEvent(nil,function ()
        local dynamicResId2 = res_alloc_id()
        bindHorizontalPassParameters(drawing, dynamicResId2, sampleRatio)
        local time = sys_get_int("frame_time",-1)
        print_string("8: "..time)
    end)

    

    return function()
       --[[ res_delete(widthId)
        res_delete(heightId)
        res_delete(sampleRatioId)
        res_delete(dynamicResId1)
        res_delete(dynamicResId2)
        res_free_id(widthId)
        res_free_id(heightId)
        res_free_id(sampleRatioId)
        res_free_id(dynamicResId1)
        res_free_id(dynamicResId2)]]--

    end
end


M.doEffect = function(drawing, intensity, finalizers)
    if not typeof(drawing, DrawingImage) then
       -- error("The type of `drawing' should be DrawingImage.")
    end

    if intensity == nil then
        intensity = 2.0
    end

    if (intensity < 0) or(intensity > 12) then
        error("The value of `intensity' should be in range 0..12.")
    end

    local resultId = 0

    doApplyToDrawing(drawing, 2)
    --[[ local count = 1
    if intensity > 0 then
        local x = intensity
        while true do
            if x > 2 then
                local anim = new(AnimInt,kAnimNormal,0,1,(intensity-x) * 100,0)
                anim:setEvent(nil,function ()
                local fn, id = doApplyToDrawing(drawing, 2)
                if finalizers ~= nil then
                    table.insert(finalizers, fn)
                end
                    count = count + 1
                    print_string(tostring(count))      
                end)
                x = x - 2
                
            elseif x > 0 then
                -- 0 - 2
                local anim = new(AnimInt,kAnimNormal,0,1,(intensity-x) * 100,0)
                anim:setEvent(nil,function ()
                local fn, id = doApplyToDrawing(drawing, 1)
                if finalizers ~= nil then
                    table.insert(finalizers, fn)
                end
                    print_string("lastStep")
                end)
                
                break
            else
                -- do nothing
                break
            end
        end

        local fn = { }
        fn, resultId = renderAsImage(drawing)
        if finalizers ~= nil then
            table.insert(finalizers, fn)
        end
    end]]--
    return resultId
end

---
-- See @{libEffect.shaders.blur#Blur.applyToDrawing}.
M.applyToDrawing = function(drawing, intensity)

    local finalizers = { }

    local resultId = M.doEffect(drawing, intensity, finalizers)

    -- whether the finalizers are called

   --[[ local doFree =( function()
        local freed = false
        return function()
            if not freed then
                for _, fn in ipairs(finalizers) do
                    fn()
                end

                freed = true
            end
        end
    end )()
    local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, {
        intensity = intensity,
        resultId = resultId,
        __cleanup = ( function()
            if intensity > 0 then
                return function()
                    doFree()

                    if drawing.m_res.m_subTexY and drawing.m_res.m_subTexX and drawing.m_res.m_subTexH and drawing.m_res.m_subTexW then
                        drawing_set_image_res_rect(drawing.m_drawingID, 0, drawing.m_res.m_subTexX, drawing.m_res.m_subTexY, drawing.m_res.m_subTexW, drawing.m_res.m_subTexH)
                    end
                end
            else
                return function() end
                -- dummy
            end
        end )()
    } )

    GC.setFinalizer(shaderInfo, function()
        local ifExists = drawing and drawingTracer.isDrawingExists(drawing.m_drawingID)
        if ifExists ~= nil and ShaderInfo.getShaderInfo(drawing) ~= nil then
            drawing_set_shader(drawing.m_drawingID, 1)
        end

        doFree()

    end )]]--
end


---
-- See @{libEffect.shaders.blur#Blur.getIntensity}.
M.getIntensity = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.intensity
    else
        return nil
    end
end

-- -
-- 获得当前应用到drawing的模糊效果的动态贴图资源。
--
-- @param core.drawing#DrawingImage drawing 应用了模糊效果的对象。
-- @return #number 动态贴图资源的ID。
-- @return #nil 如果drawing为nil，或者没有应用模糊效果，则什么都不做，返回nil。
M.getResultId = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.resultId
    else
        return nil
    end
end

return M

end
        

package.preload[ "libEffect.shaders.internal.blurImplementation" ] = function( ... )
    return require('libEffect/shaders/internal/blurImplementation')
end
            

package.preload[ "libEffect/shaders/internal/drawingTracer" ] = function( ... )

local M = {}

local current_drawings = {}

local enabled = false

M.enable = function ()
    if enabled then 
        return 
    end 


    -- hack 
    local orig_drawing_create_image = drawing_create_image
    drawing_create_image = function (iGroup, iDrawingId, ...)
	    current_drawings[iDrawingId] = true
        --print_string('creating drawing: ' .. iDrawingId)
	    return orig_drawing_create_image(iGroup, iDrawingId, ...)
    end

    -- hack 
    local orig_drawing_create_node = drawing_create_node
    drawing_create_node = function (iGroup, iDrawingId, ...)
	    current_drawings[iDrawingId] = true 
        --print_string('creating drawing: ' .. iDrawingId)
	    return orig_drawing_create_node(iGroup, iDrawingId, ...)
    end 

    -- hack
    local orig_drawing_delete = drawing_delete
    drawing_delete = function (iDrawingId)
	    current_drawings[iDrawingId] = nil
       -- print_string('removing drawing: ' .. iDrawingId)
	    return orig_drawing_delete(iDrawingId)
    end 

    -- hack 
    local orig_drawing_delete_all = drawing_delete_all 
    drawing_delete_all = function ()
	    current_drawings = {}
        --print_string('removing all drawings')
	    return orig_drawing_delete_all ()	
    end 

    enabled = true
end

M.printAllDrawings = function ()
    local count = 0
    for k,v in pairs(current_drawings) do 
        count = count + 1
        --print_string(tostring(k))
    end
    --print_string('total: ' .. tostring(count))
end


M.isDrawingExists = function (drawing_id)
	return current_drawings[drawing_id]
end

return M
end
        

package.preload[ "libEffect.shaders.internal.drawingTracer" ] = function( ... )
    return require('libEffect/shaders/internal/drawingTracer')
end
            

package.preload[ "libEffect/shaders/internal/matrix" ] = function( ... )


local path = ... .. "."
local mat = {};

local PI=3.1415926;

--rules----matrix in our engine's opengl for matrix[16]-----------------------------------------
 --[[ 1 5 9  13
      2 6 10 14
      3 7 11 15
      4 8 12 16]]--



mat.mat44to33 = function(mat44)
    local mat33 = {};
    mat33[1] = mat44[1];
    mat33[2] = mat44[2];
    mat33[3] = mat44[3];
    mat33[4] = mat44[5];
    mat33[5] = mat44[6];
    mat33[6] = mat44[7];
    mat33[7] = mat44[9];
    mat33[8] = mat44[10];
    mat33[9] = mat44[11];

    return mat33
end

mat.transpose33 = function(mat33)
 
    local transposeMat33 = {};
    transposeMat33[1] = mat33[1];
    transposeMat33[2] = mat33[4];
    transposeMat33[3] = mat33[7];
    transposeMat33[4] = mat33[2];
    transposeMat33[5] = mat33[5];
    transposeMat33[6] = mat33[8];
    transposeMat33[7] = mat33[3];
    transposeMat33[8] = mat33[6];
    transposeMat33[9] = mat33[9];


    return transposeMat33;
end

mat.transpose44 = function(mat44)
 
    local transposeMat44 = {};
    transposeMat44[1] = mat44[1];
    transposeMat44[2] = mat44[5];
    transposeMat44[3] = mat44[9];
    transposeMat44[4] = mat44[13];
    transposeMat44[5] = mat44[2];
    transposeMat44[6] = mat44[6];
    transposeMat44[7] = mat44[10];
    transposeMat44[8] = mat44[14];
    transposeMat44[9] = mat44[3];
    transposeMat44[10] = mat44[7];
    transposeMat44[11] = mat44[11];
    transposeMat44[12] = mat44[15];
    transposeMat44[13] = mat44[4];
    transposeMat44[14] = mat44[8];
    transposeMat44[15] = mat44[12];
    transposeMat44[16] = mat44[16];

    return transposeMat44;
end


mat.inverse33 = function(mat33)
    
    
    local det = mat.determinant(mat33);

    local invertMat33 = {};

    invertMat33[1] =   (mat33[5] * mat33[9] - mat33[8] * mat33[6])/ det;
    invertMat33[4] = - (mat33[4] * mat33[9] - mat33[7] * mat33[6])/ det;
    invertMat33[7] =   (mat33[4] * mat33[8] - mat33[7] * mat33[5])/ det;
    invertMat33[2] = - (mat33[2] * mat33[9] - mat33[8] * mat33[3])/ det;
    invertMat33[5] =   (mat33[1] * mat33[9] - mat33[7] * mat33[3])/ det;
    invertMat33[8] = - (mat33[1] * mat33[8] - mat33[7] * mat33[2])/ det;
    invertMat33[3] =   (mat33[2] * mat33[6] - mat33[5] * mat33[3])/ det;
    invertMat33[6] = - (mat33[1] * mat33[6] - mat33[4] * mat33[3])/ det;
    invertMat33[9] =   (mat33[1] * mat33[5] - mat33[4] * mat33[2])/ det;
    

    return invertMat33
end

mat.determinant = function(mat33)
  return 
          mat33[1] * (mat33[5] * mat33[9] - mat33[8] * mat33[6])
        - mat33[4] * (mat33[2] * mat33[9] - mat33[8] * mat33[3])
        + mat33[7] * (mat33[2] * mat33[6] - mat33[5] * mat33[3]);
end

mat.setTranslate = function(x,y,z)
        local matTrans = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        matTrans[13] = x or 0;
        matTrans[14] = y or 0;
        matTrans[15] = z or 0;
       
        
        return matTrans;
end

--rules---------the translate matirx---------------- 
--[[ 1 0 0 x
     0 1 0 y
     0 0 1 z
     0 0 0 1          {1,0,0,0,0,1,0,0,0,0,1,0,x,y,z,1}      ]]--  

mat.mulTrans = function(matrix,tx,ty,tz)
       
       matrix[13] =matrix[13] + (matrix[1] * tx + matrix[5] * ty + matrix[9] * tz);
       matrix[14] =matrix[14] + (matrix[2] * tx + matrix[6] * ty + matrix[10] * tz);
       matrix[15] =matrix[15] + (matrix[3] * tx + matrix[7] * ty + matrix[11] * tz);
       matrix[16] =matrix[16] + (matrix[4] * tx + matrix[8] * ty + matrix[12] * tz);
                      
       return matrix;
end

mat.mulRotate = function (matrix,angle,x,y,z)
   local sinAngle,cosAngle;
   local mag = math.sqrt(x*x+y*y+z*z);
   sinAngle = math.sin(angle*PI/180.0);
   cosAngle = math.cos(angle*PI/180.0);

   if mag>0 then
      local xx, yy, zz, xy, yz, zx, xs, ys, zs;
      local oneMinusCos;
      local rotMat = {};
   
      x = x/mag;
      y = y/mag;
      z = z/mag;

      xx = x * x;
      yy = y * y;
      zz = z * z;
      xy = x * y;
      yz = y * z;
      zx = z * x;
      xs = x * sinAngle;
      ys = y * sinAngle;
      zs = z * sinAngle;
      oneMinusCos = 1.0 - cosAngle;

      rotMat[1] = (oneMinusCos * xx) + cosAngle;
      rotMat[2] = (oneMinusCos * xy) - zs;
      rotMat[3] = (oneMinusCos * zx) + ys;
      rotMat[4] = 0.0; 

      rotMat[5] = (oneMinusCos * xy) + zs;
      rotMat[6] = (oneMinusCos * yy) + cosAngle;
      rotMat[7] = (oneMinusCos * yz) - xs;
      rotMat[8] = 0.0;

      rotMat[9] = (oneMinusCos * zx) - ys;
      rotMat[10] = (oneMinusCos * yz) + xs;
      rotMat[11] = (oneMinusCos * zz) + cosAngle;
      rotMat[12] = 0.0; 

      rotMat[13] = 0.0;
      rotMat[14] = 0.0;
      rotMat[15] = 0.0;
      rotMat[16] = 1.0;
      return mat.matrix44Mul(matrix,rotMat );
   end
      
   
   
   
   
end

mat.setRotateMatrixX = function(angle)
        local matRotate = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        matRotate[1] = 1;
        matRotate[6] = math.cos(3.14/180*angle);
        matRotate[7] = math.sin(3.14/180*angle);
        matRotate[10] = -math.sin(3.14/180*angle);
        matRotate[11] = math.cos(3.14/180*angle);
        matRotate[16] = 1;
        
        return matRotate;
end

mat.setRotateMatrixY = function(angle)
        local matRotate = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        matRotate[1] = math.cos(3.14/180*angle);
        matRotate[3] = math.sin(3.14/180*angle);
        matRotate[6] = 1
        matRotate[9] = -math.sin(3.14/180*angle);
        matRotate[11] = math.cos(3.14/180*angle);
        matRotate[16] = 1;
        
        return matRotate;
end

mat.setRotateMatrixZ = function(angle)
        local matRotate = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
        matRotate[1] = math.cos(3.14/180*angle);
        matRotate[2] = math.sin(3.14/180*angle);      
        matRotate[5] = -math.sin(3.14/180*angle);
        matRotate[6] = math.cos(3.14/180*angle);
        matRotate[11] = 1
        matRotate[16] = 1;
        
        return matRotate;
end



mat.setProjection = function(fov,zNear,zFar)
    projectionMatrix = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    xscale = math.cos(fov*0.5)/math.sin(fov*0.5)*480/800;
    yscale = math.cos(fov*0.5)/math.sin(fov*0.5);
    projectionMatrix[1] = xscale;
    projectionMatrix[6] = yscale;
    projectionMatrix[11] = (zFar+zNear)/(zNear-zFar);
    projectionMatrix[12] = 2*zNear*zFar/(zNear-zFar);
    projectionMatrix[15] = -1;

    return projectionMatrix;

end

mat.loadMatIdentity = function(mat)
end

mat.matrix44Mul = function (mat1,mat2)
    local matTemp = {};
   -- matTemp[4+1] = mat1[4+1]*mat2[4+1] + mat1[4+2]*mat2[4+1] + mat1[4+3]*mat2[4+1] + mat1[4+4]*mat2[4+1];
    --[[for i=0, 3 do 
        matTemp[i*4+1] = mat1[i*4+1]*mat2[1]+mat1[i*4+2]*mat2[2]+mat1[i*4+3]*mat2[3]+mat1[i*4+4]*mat2[4];
        matTemp[i*4+2] = mat1[i*4+1]*mat2[5]+mat1[i*4+2]*mat2[6]+mat1[i*4+3]*mat2[7]+mat1[i*4+4]*mat2[8];
        matTemp[i*4+3] = mat1[i*4+1]*mat2[9]+mat1[i*4+2]*mat2[10]+mat1[i*4+3]*mat2[11]+mat1[i*4+4]*mat2[12];
        matTemp[i*4+4] = mat1[i*4+1]*mat2[13]+mat1[i*4+2]*mat2[14]+mat1[i*4+3]*mat2[15]+mat1[i*4+4]*mat2[16];
    end]]--

    for i=0, 3 do 
        matTemp[i*4+1] = mat1[1]*mat2[i*4+1]+mat1[5]*mat2[i*4+2]+mat1[9]*mat2[i*4+3]+mat1[13]*mat2[i*4+4];
        matTemp[i*4+2] = mat1[2]*mat2[i*4+1]+mat1[6]*mat2[i*4+2]+mat1[10]*mat2[i*4+3]+mat1[14]*mat2[i*4+4];
        matTemp[i*4+3] = mat1[3]*mat2[i*4+1]+mat1[7]*mat2[i*4+2]+mat1[11]*mat2[i*4+3]+mat1[15]*mat2[i*4+4];
        matTemp[i*4+4] = mat1[4]*mat2[i*4+1]+mat1[8]*mat2[i*4+2]+mat1[12]*mat2[i*4+3]+mat1[16]*mat2[i*4+4];
    end
    return matTemp;
end

mat.matrix44MulVector4 = function (mat,vec)
    local vecTemp = {};

    
       --vecTemp[1] = mat[1]  *vec[1] + mat[2]  * vec[2] + mat[3]  * vec[3] + mat[4]  * vec[4];
       --vecTemp[2] = mat[5]  *vec[1] + mat[6]  * vec[2] + mat[7]  * vec[3] + mat[8]  * vec[4];
       --vecTemp[3] = mat[9]  *vec[1] + mat[10] * vec[2] + mat[11] * vec[3] + mat[12] * vec[4];
       --vecTemp[4] = mat[13] *vec[1] + mat[14] * vec[2] + mat[15] * vec[3] + mat[16] * vec[4];

       vecTemp[1] = mat[1] *vec[1] + mat[5]  * vec[2] + mat[9]  * vec[3] + mat[13]  * vec[4];
       vecTemp[2] = mat[2] *vec[1] + mat[6]  * vec[2] + mat[10]  * vec[3] + mat[14]  * vec[4];
       vecTemp[3] = mat[3] *vec[1] + mat[7] * vec[2] + mat[11] * vec[3] + mat[15] * vec[4];
       vecTemp[4] = mat[4] *vec[1] + mat[8] * vec[2] + mat[12] * vec[3] + mat[16] * vec[4];
    
    return vecTemp;
end


mat.vec3Minus = function(vec1,vec2) return {x = vec1.x-vec2.x, y = vec1.y-vec2.y, z = vec1.z-vec2.z} end
    
mat.vec3Mul = function(vec1,vec2) return {x = vec1.x*vec2.x, y = vec1.y*vec2.y, z = vec1.z*vec2.z} end

mat.vec3NumMul = function(vec,num) return {x = vec.x*num, y = vec.y*num, z = vec.z*num} end

mat.createTB = function(object)
    local tangent = {};
    local binormal = {};

    for i,v in ipairs(object.f) do 
        
        local index1 = object.f[i][1].v
        local index2 = object.f[i][2].v
        local index3 = object.f[i][3].v

        local vecPos1 = {};
        local vecPos2 = {};
        local vecPos3 = {};

        vecPos1 = object.v[index1];
        vecPos2 = object.v[index2];
        vecPos3 = object.v[index3];
              
        index1 = object.f[i][1].vt
        index2 = object.f[i][2].vt
        index3 = object.f[i][3].vt

        local vecUV1 = {};
        local vecUV2 = {};
        local vecUV3 = {};

        vecUV1 = object.vt[index1];
        vecUV2 = object.vt[index2];
        vecUV3 = object.vt[index3];



        local deltaPos1 = mat.vec3Minus(vecPos1,vecPos2);
        local deltaPos2 = mat.vec3Minus(vecPos3,vecPos2);

        local deltaUV1 = { u = vecUV1.u-vecUV2.u, v = vecUV1.v-vecUV2.v};
        local deltaUV2 = {u = vecUV3.u-vecUV2.u, v = vecUV3.v-vecUV2.v};

        local r = 1.0/(deltaUV1.u*deltaUV2.v-deltaUV1.v*deltaUV2.u);

        local resultT = {};
        resultT = mat.vec3Minus(mat.vec3NumMul(deltaPos1,deltaUV2.v),mat.vec3NumMul(deltaPos2,deltaUV1.v));

        local resultB = {};
        resultB = mat.vec3Minus(mat.vec3NumMul(deltaPos2,deltaUV1.u),mat.vec3NumMul(deltaPos1,deltaUV2.u));

        for k = 1,3 do
            table.insert(tangent,resultT.x*r);
            table.insert(tangent,resultT.y*r);
            table.insert(tangent,resultT.z*r);

            table.insert(binormal,resultB.x*r);
            table.insert(binormal,resultB.y*r);
            table.insert(binormal,resultB.z*r);
        end

    --[[tangent[3*(i-1)+1] = {resultT.x*r,resultT.y*r,resultT.z*r};
        tangent[3*(i-1)+2] = {resultT.x*r,resultT.y*r,resultT.z*r};
        tangent[3*(i-1)+3] = {resultT.x*r,resultT.y*r,resultT.z*r};

        binormal[3*(i-1)+1] = {resultB.x*r,resultB.y*r,resultB.z*r};
        binormal[3*(i-1)+2] = {resultB.x*r,resultB.y*r,resultB.z*r};
        binormal[3*(i-1)+3] = {resultB.x*r,resultB.y*r,resultB.z*r};

        tangent[3*(i-1)+1] = (mat.vec3NumMul(deltaPos1,deltaUV2.v)-mat.vec3NumMul(deltaPos2,deltaUV1.v))*r;
        tangent[3*(i-1)+2] = (mat.vec3NumMul(deltaPos1,deltaUV2.v)-mat.vec3NumMul(deltaPos2,deltaUV1.v))*r;
        tangent[3*(i-1)+3] = (mat.vec3NumMul(deltaPos1,deltaUV2.v)-mat.vec3NumMul(deltaPos2,deltaUV1.v))*r;

        
        binormal[3*(i-1)+1] = (mat.vec3NumMul(deltaPos2,deltaUV1.u)-mat.vec3NumMul(deltaPos1,deltaUV2.u))*r;
        binormal[3*(i-1)+2] = (mat.vec3NumMul(deltaPos2,deltaUV1.u)-mat.vec3NumMul(deltaPos1,deltaUV2.u))*r;
        binormal[3*(i-1)+3] = (mat.vec3NumMul(deltaPos2,deltaUV1.u)-mat.vec3NumMul(deltaPos1,deltaUV2.u))*r;]]--

        
       
    end

  --[[  for i,v in ipairs(tangent) do
        print_string(tostring(v));
    end

    print_string("----------------------------")

    for i,v in ipairs(binormal) do
        print_string(tostring(v));
    end

    print_string("----------------------------")]]--
   

    return tangent,binormal;
end

return mat;
end
        

package.preload[ "libEffect.shaders.internal.matrix" ] = function( ... )
    return require('libEffect/shaders/internal/matrix')
end
            

package.preload[ "libEffect/shaders/internal/MatrixCOCO" ] = function( ... )
local path = ... .. "."
local matCOCO = {};

local PI = 3.14
matCOCO.loadIdentity = function() 
    local mat = {1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, 0.0,0.0,0.0,1.0};

    return mat;
end

matCOCO.setMat = function(m11,m12,m13,m14, m21,m22,m23,m24, m31,m32,m33,m34, m41,m42,m43,m44)
    mat[1] = m11;
    mat[2] = m21;
    mat[3] = m31;
    mat[4] = m41;
    mat[5] = m12;
    mat[6] = m22;
    mat[7] = m32;
    mat[8] = m42;
    mat[9] = m13;
    mat[10] = m23;
    mat[11] = m33;
    mat[12] = m43;
    mat[13] = m41;
    mat[14] = m42;
    mat[15] = m43;
    mat[16] = m43;

end


matCOCO.createLookAt = function ( eyePositionX,  eyePositionY,  eyePositionZ,
                                  targetPositionX,  targetPositionY,  targetPositionZ,
                                  upX,  upY,  upZ)   
    local mat = {};
    local eye = {x = eyePositionX, y = eyePositionY, z = eyePositionZ};
    local target = {x = targetPositionX,y = targetPositionY,z =  targetPositionZ};
    local up = {x =upX, y = upY, z = upZ};
    matCOCO.normalize(up);

    
    local zaxis = matCOCO.subtract(eye, target);
    matCOCO.normalize(zaxis);

    
    local xaxis = matCOCO.cross(up, zaxis);
    matCOCO.normalize(xaxis);

    
    local yaxis = matCOCO.cross(zaxis, xaxis);
    matCOCO.normalize(yaxis);

    mat[1] = xaxis.x;
    mat[2] = yaxis.x;
    mat[3] = zaxis.x;
    mat[4] = 0.0;

    mat[5] = xaxis.y;
    mat[6] = yaxis.y;
    mat[7] = zaxis.y;
    mat[8] = 0.0;

    mat[9] = xaxis.z;
    mat[10] = yaxis.z;
    mat[11] = zaxis.z;
    mat[12] = 0.0;
    eye.x = -eye.x;
    eye.y = -eye.y;
    eye.z = -eye.z;

    mat[13] = matCOCO.dot(xaxis, eye);
    mat[14] = matCOCO.dot(yaxis, eye);
    mat[15] = matCOCO.dot(zaxis, eye);
    mat[16] = 1.0;

    return mat;
end

matCOCO.createPerspective = function(fov,asp,near,far)
    local mat = {0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0};
    local fn = 1.0/(far-near);
    local theta = math.rad(fov)*0.5;--need to make sure--
    local divisor = math.tan(theta); 
    local factor =  1.0/divisor

    mat[1] = (1.0/asp)*factor;
    mat[6] = factor;
    mat[11] = (-(far + near)) * fn;
    mat[12] = -1.0;
    mat[15] = -2.0 * far * near * fn;

    return mat;

end

matCOCO.createOthro = function(w,h,near,far)
    local mat = {0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0};

    mat[1] = 2/w;
    mat[6] = 2/h;
    mat[11] = 2/(near - far);
    mat[15] = (near + far)/(near - far);
    mat[16] = 1;

    return mat;

end


matCOCO.determinant = function(mat) 

    local a0 = mat[1] * mat[6] - mat[2] * mat[5];
    local a1 = mat[1] * mat[7] - mat[3] * mat[5];
    local a2 = mat[1] * mat[8] - mat[4] * mat[5];
    local a3 = mat[2] * mat[7] - mat[3] * mat[6];
    local a4 = mat[2] * mat[8] - mat[4] * mat[6];
    local a5 = mat[3] * mat[8] - mat[4] * mat[7];
    local b0 = mat[9] * mat[14] - mat[10] * mat[13];
    local b1 = mat[9] * mat[15] - mat[11] * mat[13];
    local b2 = mat[9] * mat[16] - mat[12] * mat[13];
    local b3 = mat[10] * mat[15] - mat[11] * mat[14];
    local b4 = mat[10] * mat[16] - mat[12] * mat[14];
    local b5 = mat[11] * mat[16] - mat[12] * mat[15];

    
    return (a0 * b5 - a1 * b4 + a2 * b3 + a3 * b2 - a4 * b1 + a5 * b0);
end

matCOCO.inverse = function (mat)

    local a0 = mat[1] * mat[6] - mat[2] * mat[5];
    local a1 = mat[1] * mat[7] - mat[3] * mat[5];
    local a2 = mat[1] * mat[8] - mat[4] * mat[5];
    local a3 = mat[2] * mat[7] - mat[3] * mat[6];
    local a4 = mat[2] * mat[8] - mat[4] * mat[6];
    local a5 = mat[3] * mat[8] - mat[4] * mat[7];
    local b0 = mat[9] * mat[14] - mat[10] * mat[13];
    local b1 = mat[9] * mat[15] - mat[11] * mat[13];
    local b2 = mat[9] * mat[16] - mat[12] * mat[13];
    local b3 = mat[10] * mat[15] - mat[11] * mat[14];
    local b4 = mat[10] * mat[16] - mat[12] * mat[14];
    local b5 = mat[11] * mat[16] - mat[12] * mat[15];

    
    local det =  (a0 * b5 - a1 * b4 + a2 * b3 + a3 * b2 - a4 * b1 + a5 * b0);

    
    if math.abs(det) <= 0.0005 then
        return false;
    end
    
    local  inverse = {};
    inverse[1]  = ( mat[6] * b5 -  mat[7] * b4 +  mat[8] * b3)/det;
    inverse[2]  = (-mat[2] * b5 +  mat[3] * b4 -  mat[4] * b3)/det;
    inverse[3]  = ( mat[14] * a5 - mat[15] * a4 + mat[16] * a3)/det;
    inverse[4]  = (-mat[10] * a5 + mat[11] * a4 - mat[12] * a3)/det;

    inverse[5]  = (-mat[5] * b5 +  mat[7] * b2 -  mat[8] * b1)/det;
    inverse[6]  = ( mat[1] * b5 -  mat[3] * b2 +  mat[4] * b1)/det;
    inverse[7]  = (-mat[13] * a5 + mat[15] * a2 - mat[16] * a1)/det;
    inverse[8]  = ( mat[9] * a5 -  mat[11] * a2 + mat[12] * a1)/det;

    inverse[9]  = ( mat[5] * b4 -  mat[6] * b2 +  mat[8] * b0)/det;
    inverse[10]  = (-mat[1] * b4 + mat[2] * b2 -  mat[4] * b0)/det;
    inverse[11] = ( mat[13] * a4 - mat[14] * a2 + mat[16] * a0)/det;
    inverse[12] = (-mat[9] * a4 +  mat[10] * a2 - mat[12] * a0)/det;

    inverse[13] = (-mat[5] * b3 +  mat[6] * b1 -  mat[7] * b0)/det;
    inverse[14] = ( mat[1] * b3 -  mat[2] * b1 +  mat[3] * b0)/det;
    inverse[15] = (-mat[13] * a3 + mat[14] * a1 - mat[15] * a0)/det;
    inverse[16] = ( mat[9] * a3 -  mat[10] * a1 + mat[11] * a0)/det;

    return inverse;

end

matCOCO.normalize = function(vec)
    local n = vec.x*vec.x+vec.y*vec.y+vec.z*vec.z;
    if n == 1 then 
        return true;
    else 
        n =math.sqrt(n);
        n = 1.0/n;
        vec.x = vec.x*n;
        vec.y = vec.y*n;
        vec.z = vec.z*n;
    end
end

matCOCO.cross = function(vec1,vec2)
    return { x = vec1.y*vec2.z-vec1.z*vec2.y , y = vec1.z*vec2.x+vec1.x*vec1.z, z = vec1.x*vec2.y-vec1.y*vec2.x };
end

matCOCO.subtract = function(vec1,vec2)
   return {x = vec1.x-vec2.x, y = vec1.y-vec2.y, z = vec1.z-vec2.z}
end

matCOCO.dot = function(vec1,vec2)
    return (vec1.x*vec2.x+vec1.y*vec2.y+vec1.z*vec2.z);
end



return matCOCO;

end
        

package.preload[ "libEffect.shaders.internal.MatrixCOCO" ] = function( ... )
    return require('libEffect/shaders/internal/MatrixCOCO')
end
            

package.preload[ "libEffect/shaders/internal/shaderInfo" ] = function( ... )
--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

---
-- 内部模块，对特效的信息进行设定和获得，包括特效的名字以及参数的信息等。
--
-- @module libEffect.shaders.internal.shaderInfo
-- @author Xiaofeng Yang

local M = {}

local fieldName = '__shaderInfo'

---
-- 获得field的名字。
--
-- @return 返回field的名字。
M.getFieldName = function ()
    return fieldName
end

---
-- 设定Drawing对象的特效信息，如果info和name不为空则返回储存特效信息的table，否则table为空，返回nil。
--
-- @param #Drawing drawing Drawing对象。
-- @param #string name 特效的名字。
-- @param #table 特效的相关参数和ID。
-- @return #table drawing[fieldName] 如果info和name不为空则返回储存特效信息的table，否则table为空，返回nil。
M.setShaderInfo = function ( drawing, name, info )
    if name then
        if info then
            drawing[fieldName] = info
        else
            drawing[fieldName] = {}
        end
        drawing[fieldName].name = name

        return drawing[fieldName]
    else
        drawing[fieldName] = nil

        return nil
    end
end

---
-- 获得存放该Drawing使用的特效信息的table，如果Drawing对象不为空且类型是table，则返回储存特效信息的table，否则返回nil。
--
-- @param #table drawing Drawing对象。
-- @return #table drawing[fieldName] 如果Drawing对象不为空且类型是table，则返回储存特效信息的table，否则返回nil。
M.getShaderInfo = function ( drawing ) 
        if drawing[fieldName] then
            return drawing[fieldName]
        else
            return nil
        end
end

---
-- 获得当前Drawing对象的特效名字。
--
-- @param #table drawing Drawing对象。
-- @return #table shaderInfo.name 如果特效信息存在则返回特效名字，否则返回nil。
M.getShaderName = function ( drawing )
    local shaderInfo = M.getShaderInfo(drawing)

    if shaderInfo then
        return shaderInfo.name
    else
        return nil
    end
end


return M
end
        

package.preload[ "libEffect.shaders.internal.shaderInfo" ] = function( ... )
    return require('libEffect/shaders/internal/shaderInfo')
end
            

package.preload[ "shaders/blend" ] = function( ... )
local vs = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform mat4 projection;
    uniform mat4 modelview;

    attribute vec3 position;
    attribute vec3 texcoord0;
    attribute vec3 texcoord1;
    attribute vec4 vcolor;
    attribute vec4 vcolor_offset;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;



    void main() 
    {
        vec4 pos = projection * modelview *  vec4(position,1.0);

        gl_Position = pos;

        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexcoord = texcoord0;
        varyTexcoord1 = pos.xyz * 0.5 + 0.5;
    }
]=]

local fsHead = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform sampler2D texture0;
    uniform sampler2D texture1;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
]=]


local fsBody = [=[
    void main() 
    {   
        vec4 src = texture2D(texture0,varyTexcoord.xy);
        vec4 dst = texture2D(texture1,varyTexcoord1.xy);
        
        if (src.a > 0.0) src.rgb /= src.a;
       
        src = src * varyColor + varyColorOffset;

        vec4 C = vec4(0.0,0.0,0.0,0.0);
]=]


local fsEnd = [=[
    gl_FragColor = vec4(C.rgb * src.a * dst.a, src.a * dst.a);     
    }
]=]

local func = {}

for i = 1,27 do
    func[i] = {}
end

func[1].body = [=[    
    vec4 Normal(vec4 A,vec4 B)
    {return A;}
]=]

func[1].excute = [=[
     C = Normal(src,dst);
]=]

func[2].body = [=[    
    vec4 Darken(vec4 A,vec4 B)
    {return min(A,B);}
]=]

func[2].excute = [=[
     C = Darken(src,dst);
]=]

func[3].body = [=[    
    vec4 Multiply(vec4 A,vec4 B)
    {return (A*B);}
]=]

func[3].excute = [=[
     C = Multiply(src,dst);
]=]

func[4].body = [=[    
    vec4 ColorBurn(vec4 A,vec4 B)      
    {return (1.0-(1.0-B)/A);}
]=]

func[4].excute = [=[
     C = ColorBurn(src,dst);
]=]

func[5].body = [=[    
    vec4 LinearBurn(vec4 A,vec4 B)
    {return (A+B-1.0);}
]=]

func[5].excute = [=[
     C = LinearBurn(src,dst);
]=]

func[6].body = [=[    
    vec4 DarkerColor(vec4 A,vec4 B)    
    {return (A.r + A.g + A.b < B.r + B.g + B.b) ? A : B;}
]=]

func[6].excute = [=[
     C = DarkerColor(src,dst);
]=]

func[7].body = [=[    
    vec4 Lighten(vec4 A,vec4 B)
    {return vec4(max(A.rgb,B.rgb),1.0);}
]=]

func[7].excute = [=[
     C = Lighten(src,dst);
]=]

func[8].body = [=[    
    vec4 Screen(vec4 A,vec4 B)
    {return (1.0-(1.0-A)*(1.0-B));}
]=]

func[8].excute = [=[
     C = Screen(src,dst);
]=]

func[9].body = [=[    
    vec4 ColorDodge(vec4 A,vec4 B)            
    {return (B/(1.0-A));}
]=]

func[9].excute = [=[
     C = ColorDodge(src,dst);
]=]

func[10].body = [=[    
    vec4 LinearDodge(vec4 A,vec4 B)
    {return (A+B);}
]=]

func[10].excute = [=[
     C = LinearDodge(src,dst);
]=]

func[11].body = [=[    
    vec4 LighterColor(vec4 A,vec4 B)           
    {return (A.r + A.g + A.b > B.r + B.g + B.b) ? A : B;}
]=]

func[11].excute = [=[
     C = LighterColor(src,dst);
]=]

func[12].body = [=[    
    vec4 Overlay(vec4 B,vec4 A)            
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r = (A.r > 0.5) ? R.r = 1.0-(1.0-2.0*(A.r-0.5))*(1.0-B.r) : (2.0*A.r)*B.r; 
        
        R.g = (A.g > 0.5) ? R.g = 1.0-(1.0-2.0*(A.g-0.5))*(1.0-B.g) : (2.0*A.g)*B.g; 
        
        R.b = (A.b > 0.5) ? R.b = 1.0-(1.0-2.0*(A.b-0.5))*(1.0-B.b) : (2.0*A.b)*B.b; 
        
        return R;
    }
]=]

func[12].excute = [=[
     C = Overlay(src,dst);
]=]

func[13].body = [=[    
    vec4 SoftLight(vec4 B,vec4 A)          
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r = (B.r < 0.5) ? A.r - (1.0 - 2.0 * B.r) * A.r * (1.0 - A.r) 
		: (A.r < 0.25) ? A.r + (2.0 * B.r - 1.0) * A.r * ((16.0 * A.r - 12.0) * A.r + 3.0) 
					 : A.r + (2.0 * B.r - 1.0) * (sqrt(A.r) - A.r);

        R.g = (B.g < 0.5) ? A.g - (1.0 - 2.0 * B.g) * A.g * (1.0 - A.g) 
		: (A.g < 0.25) ? A.g + (2.0 * B.g - 1.0) * A.g * ((16.0 * A.g - 12.0) * A.g + 3.0) 
					 : A.g + (2.0 * B.g - 1.0) * (sqrt(A.g) - A.g);

        R.b = (B.b < 0.5) ? A.b - (1.0 - 2.0 * B.b) * A.b * (1.0 - A.b) 
		: (A.b < 0.25) ? A.b + (2.0 * B.b - 1.0) * A.b * ((16.0 * A.b - 12.0) * A.b + 3.0) 
					 : A.b + (2.0 * B.b - 1.0) * (sqrt(A.b) - A.b);

        return R;
    }
]=]

func[13].excute = [=[
     C = SoftLight(src,dst);
]=]

func[14].body = [=[    
    vec4 HardLight(vec4 B,vec4 A)          
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r =  (B.r < 0.5) ? 2.0 * A.r * B.r : 1.0 - 2.0 * (1.0 - A.r) * (1.0 - B.r);

        R.g =  (B.g < 0.5) ? 2.0 * A.g * B.g : 1.0 - 2.0 * (1.0 - A.g) * (1.0 - B.g);

        R.b =  (B.b < 0.5) ? 2.0 * A.b * B.b : 1.0 - 2.0 * (1.0 - A.b) * (1.0 - B.b);
   
        return R;
    }
]=]

func[14].excute = [=[
     C = HardLight(src,dst);
]=]

func[15].body = [=[    
    vec4 VividLight(vec4 B,vec4 A)         
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r = (B.r < 0.5) ? 1.0 - (1.0 - A.r) / (2.0 * B.r) : A.r / (2.0 * (1.0 - B.r)); 

        R.g = (B.g < 0.5) ? 1.0 - (1.0 - A.g) / (2.0 * B.g) : A.g / (2.0 * (1.0 - B.g));

        R.b = (B.b < 0.5) ? 1.0 - (1.0 - A.b) / (2.0 * B.b) : A.b / (2.0 * (1.0 - B.b));

        return R;
    }
]=]

func[15].excute = [=[
     C = VividLight(src,dst);
]=]

func[16].body = [=[    
    vec4 LinearLight(vec4 B,vec4 A)          
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r = (B.r > 0.5) ? A.r + 2.0 * (B.r - 0.5) : A.r + 2.0 * B.r - 1.0; 

        R.g = (B.g > 0.5) ? A.g + 2.0 * (B.g - 0.5) : A.g + 2.0 * B.g - 1.0; 

        R.b = (B.b > 0.5) ? A.b + 2.0 * (B.b - 0.5) : A.b + 2.0 * B.b - 1.0; 

        return R;
    }
]=]

func[16].excute = [=[
     C = LinearLight(src,dst);
]=]

func[17].body = [=[    
    vec4 PinLight(vec4 B,vec4 A)
    {    
        vec4 R = vec4(0.0,0.0,0.0,1.0);
        
        R.r = (B.r > 0.5) ? max(A.r, 2.0*(B.r-0.5)) : min(A.r, 2.0*B.r); 

        R.g = (B.g > 0.5) ? max(A.g, 2.0*(B.g-0.5)) : min(A.g, 2.0*B.g);

        R.b = (B.b > 0.5) ? max(A.b, 2.0*(B.b-0.5)) : min(A.b, 2.0*B.b);

        return R;
    }
]=]

func[17].excute = [=[
     C = PinLight(src,dst);
]=]

func[18].body = [=[    
    vec4 HardMix(vec4 A,vec4 B)
    {return floor(A+B);}
]=]

func[18].excute = [=[
     C = HardMix(src,dst);
]=]

func[19].body = [=[    
    vec4 Diff(vec4 A,vec4 B)
    {return vec4((abs(A.rgb-B.rgb)),1.0);}
]=]

func[19].excute = [=[
     C = Diff(src,dst);
]=]

func[20].body = [=[    
    vec4 Exclusion(vec4 A,vec4 B)
    {return vec4(A.rgb+B.rgb-2.0*A.rgb*B.rgb,1.0);}
]=]

func[20].excute = [=[
     C = Exclusion(src,dst);
]=]

func[21].body = [=[    
    vec4 Subtract(vec4 A,vec4 B)
    {return vec4(B.rgb-A.rgb,1.0);}
]=]

func[21].excute = [=[
     C = Subtract(src,dst);
]=]

func[22].body = [=[    
     vec4 Divide(vec4 A,vec4 B)       
    {   
        vec4 C = vec4(0.0,0.0,0.0,1.0);
            
        C.rgb = B.rgb/A.rgb;

        return C;}
]=]

func[22].excute = [=[
     C = Divide(src,dst);
]=]

func[23].body = [=[    
    vec3 rgb2hsv(vec3 c)
    {
	    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 1.0e-10;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c)
    {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }
    
    vec4 Hue( vec4 B, vec4 A )
    {
	    A.rgb = rgb2hsv(A.rgb);
	    A.r = rgb2hsv(B.rgb).r;
	    return vec4(hsv2rgb(A.rgb),1.0);
    }
]=]

func[23].excute = [=[
     C = Hue(src,dst);
]=]

func[24].body = [=[    
    vec3 rgb2hsv(vec3 c)
    {
	    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 1.0e-10;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c)
    {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec4 Saturation( vec4 B, vec4 A)
    {
	    A.rgb = rgb2hsv(A.rgb);
	    A.g = rgb2hsv(B.rgb).g;
	    return vec4(hsv2rgb(A.rgb),1.0);
    }
]=]

func[24].excute = [=[
     C = Saturation(src,dst);
]=]

func[25].body = [=[    
    vec3 rgb2hsv(vec3 c)
    {
	    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 1.0e-10;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c)
    {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec4 Color( vec4 B, vec4 A)
    {
	    B.rgb = rgb2hsv(B.rgb);
	    B.b = rgb2hsv(A.rgb).b;
	    return vec4(hsv2rgb(B.rgb),1.0);
    }
]=]

func[25].excute = [=[
     C = Color(src,dst);
]=]

func[26].body = [=[    
    vec3 rgb2hsv(vec3 c)
    {
	    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 1.0e-10;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c)
    {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec4 Luminosity( vec4 B, vec4 A)
    {
	    float ALum = dot(A.rgb, vec3(0.3, 0.59, 0.11));
	    float BLum = dot(B.rgb, vec3(0.3, 0.59, 0.11));
	    float lum = BLum - ALum;
	    vec3 c = A.rgb + lum;
	    float minC = min(min(c.x, c.y), c.z);
	    float maxC = max(max(c.x, c.y), c.z);
	    if(minC < 0.0) return vec4(BLum + ((c - BLum) * BLum) / (BLum - minC),1.0);
	    else if(maxC > 1.0) return vec4(BLum + ((c - BLum) * (1.0 - BLum)) / (maxC - BLum),1.0);
	    else return vec4(c,1.0);
    }
]=]

func[26].excute = [=[
     C = Luminosity(src,dst);
]=]

func[27].body = [=[    
    vec4 Add( vec4 A, vec4 B)
    {return (A+B);}
]=]

func[27].excute = [=[
     C = Add(src,dst);
]=]


local shader = -1

function createBlend(mode)
    
    local fs = fsHead..func[mode+1].body..fsBody..func[mode+1].excute..fsEnd

    local _,_,uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms,{"texture1",gl.GL_INT,1,Shader.uniform_value_int(1)})
    shader = ShaderRegistry.instance():register_shader_desc{vs,fs,uniforms}

    return shader
end
end
        

package.preload[ "shaders.blend" ] = function( ... )
    return require('shaders/blend')
end
            

package.preload[ "shaders/blur" ] = function( ... )
require('shaders.shaderConstant')

local fsBlur = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
 
    uniform sampler2D texture;

    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
    
    uniform int horizontalPass; // 0 or 1 to indicate vertical or horizontal pass
    //uniform int blurSize;    
    uniform vec2 texOffset;
    uniform float sigma;        // The sigma value for the gaussian function: higher value means more blur
                                // A good value for 9x9 is around 3 to 5
                                // A good value for 7x7 is around 2.5 to 4
                                // A good value for 5x5 is around 2 to 3.5
                                
 
    const float pi = 3.14159265;
 
    void main() {  
      vec2 uv = vec2(varyTexCoord.x,varyTexCoord.y);

      vec2 uvC = uv * 2.0 - 1.0;

      float dis = distance(vec2(0.0,0.0), uvC);
      
      //float numBlurPixelsPerSide = float(blurSize / 2); 
 
      vec2 blurMultiplyVec = 0 < horizontalPass ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
 
      vec3 incrementalGaussian;
      incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
      incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
      incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;
 
      vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
      float coefficientSum = 0.0;
 
      avgValue += texture2D(texture, varyTexCoord.xy) * incrementalGaussian.x;
      coefficientSum += incrementalGaussian.x;
      incrementalGaussian.xy *= incrementalGaussian.yz;
 
      for (float i = 1.0; i <= 7.0; i++) { 
        avgValue += texture2D(texture, varyTexCoord.xy - i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        avgValue += texture2D(texture, varyTexCoord.xy + i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        coefficientSum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
      }
 
      gl_FragColor = avgValue / coefficientSum * varyColor + varyColorOffset;
    }
]=];

local blur = -1;
local function createBlur()
    local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {"horizontalPass", gl.GL_INT, 1, Shader.uniform_value_int(0)})
    --table.insert(uniforms, {"blurSize",  gl.GL_INT, 1, Shader.uniform_value_int(40)})
    table.insert(uniforms, {"texOffset", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(1/1280,1/720)})
    table.insert(uniforms, {"sigma", gl.GL_FLOAT, 1, Shader.uniform_value_float(10)})
    blur = ShaderRegistry.instance():register_shader_desc{vs, fsBlur, uniforms}

    return blur
end

return createBlur()
end
        

package.preload[ "shaders.blur" ] = function( ... )
    return require('shaders/blur')
end
            

package.preload[ "shaders/blurHorizontal" ] = function( ... )
require('shaders.shaderConstant')
local vsHBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float ratio;
    uniform float width;
    varying vec2 vblurtexcoord[15];

    void main()
    {
        gl_Position =  projection * modelview * vec4(position, 1.0);
        
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord =  texcoord0;

        for (int i = 0; i < 15; ++i)
        {
            vblurtexcoord[i] = varyTexCoord.xy + vec2((float(i) - 7.0)/width,0.0) * ratio;
        }
    }
]=];

local fsHBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform sampler2D texture;
    uniform sampler2D texture1;
    uniform vec4 color;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;


    varying vec2 vblurtexcoord[15];

    void main()
    {   
        
        float weight[15];   
        weight[0]  = 0.00787353515625;    
        weight[1]  = 0.013290405273438;    
        weight[2]  = 0.035247802734375;    
        weight[3]  = 0.0506591796875;    
        weight[4]  = 0.08953857421875;
        weight[5]  = 0.10693359375;    
        weight[6]  = 0.1287841796875;    
        weight[7]  = 0.13534545898438;    
        weight[8]  = 0.1287841796875;
        weight[9]  = 0.10693359375;
        weight[10] = 0.08953857421875;
        weight[11] = 0.0506591796875;
        weight[12] = 0.035247802734375; 
        weight[13] = 0.013290405273438;   
        weight[14] = 0.00787353515625;  
        
        vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);

        for (int i = 0; i < 15; ++i)
        {
             sample += texture2D(texture, vblurtexcoord[i]) * weight[i];   
        }
        
        vec2 coord = varyTexCoord.xy;

        gl_FragColor = sample * varyColor + varyColorOffset;
        gl_FragColor.rgb *= gl_FragColor.a;
    }
]=];

local blurH = -1;
local function createBlurShaderHorizontal ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'ratio', gl.GL_FLOAT, 1, Shader.uniform_value_float(4)})
    table.insert(uniforms, {'width', gl.GL_FLOAT, 1, Shader.uniform_value_float(1280)})
    blurH = ShaderRegistry.instance():register_shader_desc{vsHBlur, fsHBlur, uniforms}

    return blurH
end

return createBlurShaderHorizontal()
end
        

package.preload[ "shaders.blurHorizontal" ] = function( ... )
    return require('shaders/blurHorizontal')
end
            

package.preload[ "shaders/blurShaderHorizontal" ] = function( ... )
require('shaders.shaderConstant')
local vsHBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float ratio;
    uniform float width;
    varying vec2 vblurtexcoord[15];

    void main()
    {
        gl_Position =  projection * modelview * vec4(position, 1.0);
        
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord =  texcoord0;

        for (int i = 0; i < 15; ++i)
        {
            vblurtexcoord[i] = varyTexCoord.xy + vec2((float(i) - 7.0)/width,0.0) * ratio;
        }
    }
]=];

local fsHBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform sampler2D texture;
    uniform sampler2D texture1;
    uniform vec4 color;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;


    varying vec2 vblurtexcoord[15];

    void main()
    {   
        
        float weight[15];   
        weight[0]  = 0.00787353515625;    
        weight[1]  = 0.013290405273438;    
        weight[2]  = 0.035247802734375;    
        weight[3]  = 0.0506591796875;    
        weight[4]  = 0.08953857421875;
        weight[5]  = 0.10693359375;    
        weight[6]  = 0.1287841796875;    
        weight[7]  = 0.13534545898438;    
        weight[8]  = 0.1287841796875;
        weight[9]  = 0.10693359375;
        weight[10] = 0.08953857421875;
        weight[11] = 0.0506591796875;
        weight[12] = 0.035247802734375; 
        weight[13] = 0.013290405273438;   
        weight[14] = 0.00787353515625;  
        
        vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);

        for (int i = 0; i < 15; ++i)
        {
             sample += texture2DProj(texture, vblurtexcoord[i]) * weight[i];   
        }
        
        vec2 coord = varyTexCoord.xy;

        gl_FragColor = sample * varyColor + varyColorOffset;
    }
]=];

local blurH = -1;
local function createBlurShaderHorizontal ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'ratio', gl.GL_FLOAT, 1, Shader.uniform_value_float(2)})
    table.insert(uniforms, {'width', gl.GL_FLOAT, 1, Shader.uniform_value_float(960)})
    blurH = ShaderRegistry.instance():register_shader_desc{vsHBlur, fsHBlur, uniforms}

    return blurH
end

return createBlurShaderHorizontal()
end
        

package.preload[ "shaders.blurShaderHorizontal" ] = function( ... )
    return require('shaders/blurShaderHorizontal')
end
            

package.preload[ "shaders/blurShaderVertical" ] = function( ... )
require('shaders.shaderConstant')

local vsVBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float ratio;
    uniform float height;
    varying   vec2 vblurtexcoord[15];

    void main()
    {
        gl_Position =  projection * modelview * vec4(position, 1.0);
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord =  texcoord0;

        for (int i = 0; i < 15; ++i)
        {
            vblurtexcoord[i] = varyTexCoord.xy + vec2(0.0, (float(i) - 7.0)/height) * ratio;
        }

    }
]=];

local fsVBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    varying vec2 vblurtexcoord[15];

    uniform float weight[15];

    void main()
    {    
        float weight[15];   
        weight[0]  = 0.00787353515625;    
        weight[1]  = 0.013290405273438;    
        weight[2]  = 0.035247802734375;    
        weight[3]  = 0.0506591796875;    
        weight[4]  = 0.08953857421875;
        weight[5]  = 0.10693359375;    
        weight[6]  = 0.1287841796875;    
        weight[7]  = 0.13534545898438;    
        weight[8]  = 0.1287841796875;
        weight[9]  = 0.10693359375;
        weight[10] = 0.08953857421875;
        weight[11] = 0.0506591796875;
        weight[12] = 0.035247802734375; 
        weight[13] = 0.013290405273438;   
        weight[14] = 0.00787353515625;  

        vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);

        for (int i = 0; i < 15; ++i)
        {
             sample += texture2DProj(texture, vblurtexcoord[i]) * weight[i];   
        }
        
        vec2 coord = varyTexCoord.xy;

        gl_FragColor = sample * varyColor + varyColorOffset;
    }
]=];


local blurV = -1;
local function createBlurShaderVertical ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'ratio', gl.GL_FLOAT, 1, Shader.uniform_value_float(4)})
    table.insert(uniforms, {'height', gl.GL_FLOAT, 1, Shader.uniform_value_float(720)})
    blurV = ShaderRegistry.instance():register_shader_desc{vsVBlur, fsVBlur, uniforms}

    return blurV
end

return createBlurShaderVertical()
end
        

package.preload[ "shaders.blurShaderVertical" ] = function( ... )
    return require('shaders/blurShaderVertical')
end
            

package.preload[ "shaders/blurVertical" ] = function( ... )
require('shaders.shaderConstant')

local vsVBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float ratio;
    uniform float height;
    varying   vec2 vblurtexcoord[15];

    void main()
    {
        gl_Position =  projection * modelview * vec4(position, 1.0);
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord =  texcoord0;

        for (int i = 0; i < 15; ++i)
        {
            vblurtexcoord[i] = varyTexCoord.xy + vec2(0.0, (float(i) - 7.0)/height) * ratio;
        }

    }
]=];

local fsVBlur = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    varying vec2 vblurtexcoord[15];

    uniform float weight[15];

    void main()
    {    
        float weight[15];   
        weight[0]  = 0.00787353515625;    
        weight[1]  = 0.013290405273438;    
        weight[2]  = 0.035247802734375;    
        weight[3]  = 0.0506591796875;    
        weight[4]  = 0.08953857421875;
        weight[5]  = 0.10693359375;    
        weight[6]  = 0.1287841796875;    
        weight[7]  = 0.13534545898438;    
        weight[8]  = 0.1287841796875;
        weight[9]  = 0.10693359375;
        weight[10] = 0.08953857421875;
        weight[11] = 0.0506591796875;
        weight[12] = 0.035247802734375; 
        weight[13] = 0.013290405273438;   
        weight[14] = 0.00787353515625;  

        vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);

        for (int i = 0; i < 15; ++i)
        {
             sample += texture2D(texture, vblurtexcoord[i]) * weight[i];   
        }
        
        vec2 coord = varyTexCoord.xy;

        gl_FragColor = sample * varyColor + varyColorOffset;

    }
]=];


local blurV = -1;
local function createBlurShaderVertical ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'ratio', gl.GL_FLOAT, 1, Shader.uniform_value_float(4)})
    table.insert(uniforms, {'height', gl.GL_FLOAT, 1, Shader.uniform_value_float(720)})
    blurV = ShaderRegistry.instance():register_shader_desc{vsVBlur, fsVBlur, uniforms}

    return blurV
end

return createBlurShaderVertical()
end
        

package.preload[ "shaders.blurVertical" ] = function( ... )
    return require('shaders/blurVertical')
end
            

package.preload[ "shaders/circle" ] = function( ... )
local circle_fragment_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform float softness;
    uniform float intensity;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {   
        vec2 uv = varyTexCoord.xy;
        
        float dis = length(vec2(0.5,0.5)-uv);
      
        float color = smoothstep(0.5-softness, 0.5, dis);

        gl_FragColor = vec4(1.0 - color,1.0 - color,1.0 - color,(1.0 - color) * intensity);
    }
]]


local _circle_shader = -1;

local function get_circle_shader()
    if _circle_shader == -1 then
        local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms,{"softness",gl.GL_FLOAT,1,Shader.uniform_value_float(0.1)})
        table.insert(uniforms,{"intensity",gl.GL_FLOAT,1,Shader.uniform_value_float(0.5)})
        _circle_shader = ShaderRegistry.instance():register_shader_desc{
            vs, circle_fragment_shader, uniforms
        }
    end

    return _circle_shader 
end


return get_circle_shader()
end
        

package.preload[ "shaders.circle" ] = function( ... )
    return require('shaders/circle')
end
            

package.preload[ "shaders/circleScan" ] = function( ... )


local circleScan_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;          
    uniform float progress;
    uniform float displayClickWiseArea; 
    uniform vec4 offsetMatrix; 
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {   
        mat2 rotMat;

        rotMat[0][0] = offsetMatrix.x; 
        rotMat[0][1] = offsetMatrix.y;
        rotMat[1][0] = offsetMatrix.z;
        rotMat[1][1] = offsetMatrix.w;
    
        vec4 colorbg = texture2D(texture, vec2(varyTexCoord.x,varyTexCoord.y)); 
        vec2 uv = varyTexCoord.xy * 2.0 - 1.0;

        uv = uv * rotMat;
        float angle  = 6.284*(-progress+0.5); 

        float colorC = -displayClickWiseArea * sign(angle - atan(uv.x, uv.y));

        gl_FragColor = vec4(colorC*colorbg.xyz,colorC * colorbg.a) * varyColor + varyColorOffset;
    }
]]

local _circleScan_shader = -1

local function get_circleScan_shader()
    if _circleScan_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms, {"progress", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)});
        table.insert(uniforms, {"displayClickWiseArea", gl.GL_FLOAT, 1, Shader.uniform_value_float(1)});
        table.insert(uniforms, {'offsetMatrix', gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(0, 0, 0, 1))});

        _circleScan_shader = ShaderRegistry.instance():register_shader_desc{
            vs, circleScan_fragemt_shader, uniforms
        }
    end

    return _circleScan_shader
end

return get_circleScan_shader();

end
        

package.preload[ "shaders.circleScan" ] = function( ... )
    return require('shaders/circleScan')
end
            

package.preload[ "shaders/colorOffset" ] = function( ... )

local color_offset_fragment_shader = [[
#ifdef GL_ES
precision highp float;
#endif

uniform     sampler2D   texture0;
varying     vec3        varyTexCoord;
varying     vec4        varyColor;
varying     vec4        varyColorOffset;

void main (void)
{
    vec4 c = texture2DProj(texture0, varyTexCoord);
    c = vec4(c.r/c.a, c.g/c.a, c.b/c.a, c.a);
    c = clamp(c * varyColor + varyColorOffset, 0.0, 1.0);
    c.rgb *= c.a;
    gl_FragColor = c;
}
]]

local _color_offset_shader = -1;

local function get_color_offset_shader()
    if _color_offset_shader == -1 then
        local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
        _color_offset_shader = ShaderRegistry.instance():register_shader_desc{
            vs, color_offset_fragment_shader, uniforms
        }
    end
    return _color_offset_shader
end

return	get_color_offset_shader()

end
        

package.preload[ "shaders.colorOffset" ] = function( ... )
    return require('shaders/colorOffset')
end
            

package.preload[ "shaders/fire" ] = function( ... )
local fsFire = [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform sampler2D texture0;
    uniform sampler2D texture1;
    uniform sampler2D texture2;

    varying   vec3 varyTexCoord;
    varying   vec4 varyColor;
    varying   vec4 varyColorOffset;

    uniform float time;
   
    void main()
    {
        vec4 noise1 = texture2D(texture0,varyTexCoord.xy       - vec2(0.0,time * 0.2 )) * 2.0 - 1.0;
        vec4 noise2 = texture2D(texture0,varyTexCoord.xy * 2.0 - vec2(0.0,time * 0.15 )) * 2.0 - 1.0;
        vec4 noise3 = texture2D(texture0,varyTexCoord.xy * 3.0 - vec2(0.0,time * 0.1)) * 2.0 - 1.0;
        noise1.xy *= vec2(0.1,0.2);
        noise2.xy *= vec2(0.1,0.3);
        noise3.xy *= vec2(0.1,0.1);
    
        vec4 finalNoise = noise1+noise2+noise3;
    
        float perturb = ((1.0 - varyTexCoord.y) * 0.8) + 0.5;
    
        vec2 noiseCoords = (finalNoise.xy * perturb) + varyTexCoord.xy;
        
        vec4 fireColor  = texture2D(texture1,noiseCoords);
        vec4 alphaColor = texture2D(texture2,noiseCoords);

        gl_FragColor = fireColor * varyColor + varyColorOffset;

        gl_FragColor.a = alphaColor.r;
        gl_FragColor.rgb *= gl_FragColor.a;

    }
]=];

local fire = -1;

local function createFire ()
    local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {"time", gl.GL_FLOAT, 1, Shader.uniform_value_float(1)})
    table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.fireColor)});
    table.insert(uniforms, {"texture2", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.fireAlpha)});
    fire = ShaderRegistry.instance():register_shader_desc{vs, fsFire, uniforms}

    return fire
end

return createFire()
end
        

package.preload[ "shaders.fire" ] = function( ... )
    return require('shaders/fire')
end
            

package.preload[ "shaders/flash2" ] = function( ... )

local flash2_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;                                 
    uniform float offset;
    uniform vec4 inColor;
    uniform float width; 
    uniform vec4 offsetMatrix; 
                          
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()                                
    {                                          
        vec2 uv = vec2(varyTexCoord.x,varyTexCoord.y);        
        vec3 wave_color = vec3(0.0,0.0,0.0);

        mat2 rotMat;

        rotMat[0][0] = offsetMatrix.x; 
        rotMat[0][1] = offsetMatrix.y;
        rotMat[1][0] = offsetMatrix.z;
        rotMat[1][1] = offsetMatrix.w;

        uv = 2.0 * uv - 1.0;

        uv = uv * rotMat;
    
        uv = uv - vec2(offset,0);

  

        uv.y = uv.x; 
        float wave_width = abs(1.0/(width * uv.y));                
        wave_width = clamp(0.0, 1.0, wave_width);    
        wave_color = vec3(wave_width, wave_width, wave_width) * vec3(inColor.xyz); 
        vec4 colorBack = texture2D(texture,varyTexCoord.xy);
        gl_FragColor = vec4(wave_color* colorBack.a+colorBack.xyz, colorBack.a) * varyColor + varyColorOffset;      
    }


]]

local _flash2_shader = -1;

local function get_flash2_shader()
    if _flash2_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms, {"offsetMatrix", gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(0, 0, 0, 1))});
        table.insert(uniforms, {"inColor", gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(0, 0, 0, 0))});
        table.insert(uniforms, {"offset", gl.GL_FLOAT, 1, Shader.uniform_value_float(0.0)});
        table.insert(uniforms, {"width", gl.GL_FLOAT, 1, Shader.uniform_value_float(0.0)});

        _flash2_shader = ShaderRegistry.instance():register_shader_desc{
            vs, flash2_fragemt_shader, uniforms
        }
    end

    return _flash2_shader
end


return get_flash2_shader()
end
        

package.preload[ "shaders.flash2" ] = function( ... )
    return require('shaders/flash2')
end
            

package.preload[ "shaders/flashShader" ] = function( ... )
require('shaders.shaderConstant')


local flash1_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    
    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    uniform vec4 color;
    uniform float offset;
    uniform vec2 direction;
    uniform vec4 inColor;
    uniform float scale;
    uniform vec2 pos;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {   
  
        vec3 dir = normalize(vec3(-direction.x,direction.y,0.0));
        dir = dir * 1.2 * scale;
     
        vec2 flashUV = ((varyTexCoord.xy-pos)/direction.xy*2.0-1.0) * scale * 0.9;
        flashUV = flashUV + dir.xy * offset;
        vec4 colorSampler = texture2D(texture1,(flashUV*0.5+0.5))*inColor;
        vec4 colorBack = texture2D(texture,varyTexCoord.xy);
        gl_FragColor = vec4((colorBack.xyz+sin(((offset+1.0)*1.57)*color.xyz*colorBack.a)*0.1)*color.xyz+(colorSampler.xyz*colorBack.a),colorBack.a) * varyColor + varyColorOffset;
    }

]]


local _flash1_shader = -1;

local function get_flash1_shader()
    if _flash1_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);    
        
        table.insert(uniforms, {'color', gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(1.0,1.0,1.0,1.0))})
        table.insert(uniforms, {"offset", gl.GL_FLOAT, 1, Shader.uniform_value_float(0.0)});
        table.insert(uniforms, {"direction", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)});
        table.insert(uniforms, {"inColor", gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(0.0, 0.0, 0.0, 1.0))})
        table.insert(uniforms, {"scale", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)});
        table.insert(uniforms, {"pos", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)});
        table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.flash1)});

        _flash1_shader = ShaderRegistry.instance():register_shader_desc{
            vs, flash1_fragemt_shader, uniforms
        }

    end

    return _flash1_shader
end


return get_flash1_shader()
end
        

package.preload[ "shaders.flashShader" ] = function( ... )
    return require('shaders/flashShader')
end
            

package.preload[ "shaders/frostShader" ] = function( ... )
require('shaders.shaderConstant')
local frost_fragemt_shader =[[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    uniform float intensity;
    uniform vec2 screenSize;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    
    vec4 spline(float x, vec4 c1, vec4 c2, vec4 c3, vec4 c4, vec4 c5, vec4 c6, vec4 c7, vec4 c8, vec4 c9)
    {
        float w1, w2, w3, w4, w5, w6, w7, w8, w9;
        w1 = 0.0;
        w2 = 0.0;
        w3 = 0.0;
        w4 = 0.0;
        w5 = 0.0;
        w6 = 0.0;
        w7 = 0.0;
        w8 = 0.0;
        w9 = 0.0;
        float tmp = x * 8.0;
        if (tmp<=1.0) {
        w1 = 1.0 - tmp;
        w2 = tmp;
        }
        else if (tmp<=2.0) {
        tmp = tmp - 1.0;
        w2 = 1.0 - tmp;
        w3 = tmp;
        }
        else if (tmp<=3.0) {
        tmp = tmp - 2.0;
        w3 = 1.0-tmp;
        w4 = tmp;
        }
        else if (tmp<=4.0) {
        tmp = tmp - 3.0;
        w4 = 1.0-tmp;
        w5 = tmp;
        }
        else if (tmp<=5.0) {
        tmp = tmp - 4.0;
        w5 = 1.0-tmp;
        w6 = tmp;
        }
        else if (tmp<=6.0) {
        tmp = tmp - 5.0;
        w6 = 1.0-tmp;
        w7 = tmp;
        }
        else if (tmp<=7.0) {
        tmp = tmp - 6.0;
        w7 = 1.0 - tmp;
        w8 = tmp;
        }
         else
        {

        tmp = clamp(tmp - 7.0, 0.0, 1.0);
        w8 = 1.0-tmp;
        w9 = tmp;
        }
        return w1*c1 + w2*c2 + w3*c3 + w4*c4 + w5*c5 + w6*c6 + w7*c7 + w8*c8 + w9*c9;
    }

    vec3 noise(vec2 p)
    {
      return texture2D(texture1,p).xyz;
    }

    void main()
    {
        vec2 uv = varyTexCoord.xy;
        vec3 tc = vec3(1.0, 0.0, 0.0);

        float DeltaX = 4.0 /screenSize.x;
        float DeltaY = 4.0 /screenSize.y;
        vec2 ox = vec2(DeltaX,0.0);
        vec2 oy = vec2(0.0,DeltaY);
        vec2 PP = uv - oy;
        vec4 C00 = texture2D(texture,PP - ox);
        vec4 C01 = texture2D(texture,PP);
        vec4 C02 = texture2D(texture,PP + ox);
        PP = uv;
        vec4 C10 = texture2D(texture,PP - ox);
        vec4 C11 = texture2D(texture,PP);
        vec4 C12 = texture2D(texture,PP + ox);
        PP = uv + oy;
        vec4 C20 = texture2D(texture,PP - ox);
        vec4 C21 = texture2D(texture,PP);
        vec4 C22 = texture2D(texture,PP + ox);

        float n = noise(1.0*uv).x*abs(intensity);
        n = mod(n, 0.111111)/0.111111;
        vec4 result = spline(n,C00,C01,C02,C10,C11,C12,C20,C21,C22);
        tc = result.rgb;

        gl_FragColor = vec4(tc*C11.a,C11.a) * varyColor + varyColorOffset;
    }

]]


local _frost_shader = -1;

local function get_frost_shader()
    if _frost_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms, {"intensity", gl.GL_FLOAT, 1, Shader.uniform_value_float(1.0)});
        table.insert(uniforms, {"screenSize", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(1280,720)});
        table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.frost)});

        _frost_shader = ShaderRegistry.instance():register_shader_desc{
            vs, frost_fragemt_shader, uniforms
        }  
    end

    return _frost_shader
end


return get_frost_shader()
end
        

package.preload[ "shaders.frostShader" ] = function( ... )
    return require('shaders/frostShader')
end
            

package.preload[ "shaders/genie" ] = function( ... )
local vsGenie = [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;
   

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying   vec3 varyTexCoord;
    varying   vec4 varyColor;
    varying   vec4 varyColorOffset;


    uniform mat4  transMat;
    uniform float time;
    uniform float bend;
    uniform float endX;
    uniform float endY;

    void main()
    {   
        
        vec4 pos = vec4(position, 1.0);
        pos.y = mix(position.y, endY, time);
        highp float t = pos.y / endY;
        t = (3.0 - 2.0 * t) * t * t;
        pos.x = mix(position.x, endX ,  t * bend);    
        
        gl_Position = projection * transMat * modelview * pos;
            
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord = texcoord0;
    }
]=];

local fsGenie = [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform sampler2D texture;

    varying   vec3 varyTexCoord;
    varying   vec4 varyColor;
    varying   vec4 varyColorOffset;

    void main()
    {
        vec4 colorTex = texture2D(texture, varyTexCoord.xy);
        gl_FragColor = colorTex * varyColor + varyColorOffset;
    }
]=];

local genie = -1;
local function createGenie ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {"time", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
    table.insert(uniforms, {"bend", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
    table.insert(uniforms, {"endX", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
    table.insert(uniforms, {"endY", gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
    table.insert(uniforms, {"transMat", gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(Matrix())})
    genie = ShaderRegistry.instance():register_shader_desc{vsGenie, fsGenie, uniforms}

    return genie
end

return createGenie()

end
        

package.preload[ "shaders.genie" ] = function( ... )
    return require('shaders/genie')
end
            

package.preload[ "shaders/glass" ] = function( ... )
local fsColor = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform vec2 center;
    uniform vec2 size;
    uniform float radius;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    float udRoundRect(vec2 p, vec2 b, float r)
    {
	    return length(max(abs(p) - b, 0.0)) - r;
    }
    void main()
    {
        vec4 colorTex = texture2D(texture, varyTexCoord.xy) * varyColor + varyColorOffset;
        float a = clamp(udRoundRect(gl_FragCoord.xy - center, size, radius),0.0,1.0);
 
        gl_FragColor = pow(colorTex, vec4(1.0/1.5,1.0/1.5,1.0/1.5,1.0/1.5));
        gl_FragColor.a *= 1.0-a;
        gl_FragColor.rgb *= gl_FragColor.a;
    }
]]


local glass = -1;

local function glassShader()
    if glass == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
        table.insert(uniforms,{"center",gl.GL_FLOAT_VEC2,1,Shader.uniform_value_float2(0,0)})
        table.insert(uniforms,{"size",gl.GL_FLOAT_VEC2,1,Shader.uniform_value_float2(0,0)})
        table.insert(uniforms,{"radius",gl.GL_FLOAT,1,Shader.uniform_value_float(0)})
        glass = ShaderRegistry.instance():register_shader_desc{
            vs, fsColor, uniforms
        }
    end
    return glass
end

return glassShader()
end
        

package.preload[ "shaders.glass" ] = function( ... )
    return require('shaders/glass')
end
            

package.preload[ "shaders/glassBlend" ] = function( ... )
local vs = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform mat4 projection;
    uniform mat4 modelview;

    attribute vec3 position;
    attribute vec3 texcoord0;
    attribute vec3 texcoord1;
    attribute vec4 vcolor;
    attribute vec4 vcolor_offset;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;



    void main() 
    {
        vec4 pos = projection * modelview *  vec4(position,1.0);

        gl_Position = pos;

        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexcoord = texcoord0;
        varyTexcoord1 = pos.xyz * 0.5 + 0.5;
    }
]=]


local fs = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform sampler2D texture0;
    uniform sampler2D texture1;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;





     void main() 
    {   
        vec4 src = texture2D(texture0,varyTexcoord.xy);
      
        vec4 dst = texture2D(texture1,vec2(varyTexcoord1.x,1.0-varyTexcoord1.y));

        gl_FragColor = vec4((dst.rgb+0.1)*src.a*dst.a,src.a*dst.a);     
    }
]=]


local shader = -1

local function createMaskBlend()
 
    local _,_,uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms,{"texture1",gl.GL_INT,1,Shader.uniform_value_int(1)})
    shader = ShaderRegistry.instance():register_shader_desc{vs,fs,uniforms}

    return shader
end

return createMaskBlend()


end
        

package.preload[ "shaders.glassBlend" ] = function( ... )
    return require('shaders/glassBlend')
end
            

package.preload[ "shaders/glow" ] = function( ... )
require('shaders.shaderConstant')

local fsGlow = [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float intensity;
   
    void main()
    {
        vec4 colorTex = texture2D(texture, varyTexCoord.xy);
        vec4 colorGlow = texture2D(texture1, varyTexCoord.xy);
        gl_FragColor = (colorTex + colorGlow * intensity) * varyColor + varyColorOffset;
    }
]=];

local glow = -1;
local function createGlow ()
    local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {"intensity", gl.GL_FLOAT, 1, Shader.uniform_value_float(1.0)})
    table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.glow)});
    glow = ShaderRegistry.instance():register_shader_desc{vs, fsGlow, uniforms}

    return glow
end

return createGlow()
end
        

package.preload[ "shaders.glow" ] = function( ... )
    return require('shaders/glow')
end
            

package.preload[ "shaders/grayScale" ] = function( ... )
local gray_fragment_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    
    uniform float timer;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {
        vec4 colorTex = texture2D(texture, varyTexCoord.xy);
        float gray = dot(colorTex.rgb, vec3(0.299, 0.587, 0.114));
        gl_FragColor = vec4(gray, gray, gray, colorTex.a)*(1.0-timer)+colorTex*timer * varyColor + varyColorOffset;
    }
]]


local _gray_shader = -1;

local function get_gray_shader()
    if _gray_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
        table.insert(uniforms, {'timer', gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
        _gray_shader = ShaderRegistry.instance():register_shader_desc{
            vs, gray_fragment_shader, uniforms
        }
    end
    return _gray_shader
end

return	get_gray_shader()
end
        

package.preload[ "shaders.grayScale" ] = function( ... )
    return require('shaders/grayScale')
end
            

package.preload[ "shaders/holoShader" ] = function( ... )
require('shaders.shaderConstant')
 local fsHolo = [=[
     #ifdef GL_ES
     precision highp float;
     #endif
     uniform sampler2D texture;
     uniform sampler2D texture1;
     uniform vec4 color;
     
     varying vec3 varyTexCoord;
     varying vec4 varyColor;
     varying vec4 varyColorOffset;

     uniform float colorTexcoord;
     uniform float texcoordScale;
     uniform vec3 holoColor;

     void main()
     {   
         vec4 colorBack = texture2D(texture, varyTexCoord.xy);
         vec2 scaleTc = (varyTexCoord.xy * 2.0 - 1.0) * vec2(1.0-0.1*texcoordScale,1.0-0.1*texcoordScale); 
         vec2 Tc = (varyTexCoord.xy * 2.0 - 1.0) * vec2(0.50,0.50); 
         vec4 colorT = texture2D(texture1, scaleTc * 0.5 + 0.5);     
         vec4 colorA = texture2D(texture1, Tc * 0.5 + 0.5);        
         vec2 p = 2.0 * varyTexCoord.xy - 1.0;
         float tau = 3.1415926535*2.0;
         float a = atan(p.x,p.y);
         float r = length(p)*0.75;
         vec2 uv = vec2(a/tau,r);

         float xCol = (uv.x - (colorTexcoord * 2.0 / 3.0)) * 3.0;
         xCol = mod(xCol, 3.0);
         vec3 horColour = holoColor;

         if (xCol < 1.0) {
             horColour.r += 1.0 - xCol;
             horColour.g += xCol;
         } else if (xCol < 2.0) {
             xCol -= 1.0;
             horColour.g += 1.0 - xCol;
             horColour.b += xCol;
         } else {
             xCol -= 2.0;
             horColour.b += 1.0 - xCol;
             horColour.r += xCol;
         }

         float gray = dot(colorT.rgb, vec3(0.299, 0.587, 0.114));
         float newColor = gray * 1.5;

         //gl_FragColor = colorA;      
         gl_FragColor = vec4(newColor,newColor,newColor,colorA.a) * vec4(horColour,colorA.a)* varyColor * color * 1.5 * (1.0 - colorBack.a) + colorBack + varyColorOffset;
     }
 ]=];


local holo = -1;
local function createHolo ()
    local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'color', gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(1.0,1.0,1.0,1.0))})
    table.insert(uniforms, {'colorTexcoord', gl.GL_FLOAT, 1, Shader.uniform_value_float(1)})
    table.insert(uniforms, {'texcoordScale', gl.GL_FLOAT, 1, Shader.uniform_value_float(1)})
    table.insert(uniforms, {'holoColor', gl.GL_FLOAT_VEC3, 1, Shader.uniform_value_float3(1,1,1)})
    table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.holo)});
    holo = ShaderRegistry.instance():register_shader_desc{vs, fsHolo, uniforms}

    return holo
end

return createHolo()
end
        

package.preload[ "shaders.holoShader" ] = function( ... )
    return require('shaders/holoShader')
end
            

package.preload[ "shaders/image2dColor" ] = function( ... )
require('shaders.shaderConstant')


local image2dColor_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform vec4 color;  
    uniform vec4 o_color; 
      
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {
        vec4 colorT = texture2D(texture, varyTexCoord.xy);           
        vec4 r_color = colorT * color * varyColor + o_color/255.0 + varyColorOffset;
        gl_FragColor = clamp(r_color,0.0,1.0);
    }
]]


local _image2dColor_shader = -1;

local function get_image2dColor_shader()
    if _image2dColor_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms, {'color', gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(1.0,1.0,1.0,1.0))})
        table.insert(uniforms, {"o_color", gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_color(Colorf(0, 0, 0, 0))});

        _image2dColor_shader = ShaderRegistry.instance():register_shader_desc{
            vs, image2dColor_fragemt_shader, uniforms
        }
    end

    return _image2dColor_shader
end


return get_image2dColor_shader()
end
        

package.preload[ "shaders.image2dColor" ] = function( ... )
    return require('shaders/image2dColor')
end
            

package.preload[ "shaders/image2dMask" ] = function( ... )
local image2dMask_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform sampler2D texture1;
    uniform float discardRange;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {   
        vec4 colorT = texture2D(texture, varyTexCoord.xy); 
        if (colorT.a <= discardRange)  
            {discard;}                        
        else
            gl_FragColor = vec4(0.0,0.0,0.0,0.0);
    }

]]

local _image2dMask_shader = -1;

local function get_image2dMask_shader()
    if _image2dMask_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms,{"discardRange",gl.GL_FLOAT,1,Shader.uniform_value_float(0.0)})
        _image2dMask_shader = ShaderRegistry.instance():register_shader_desc{
            vs, image2dMask_fragemt_shader, uniforms
        }
    end

    return _image2dMask_shader
end

return get_image2dMask_shader()

end
        

package.preload[ "shaders.image2dMask" ] = function( ... )
    return require('shaders/image2dMask')
end
            

package.preload[ "shaders/imageMask" ] = function( ... )
require('shaders.shaderConstant')


local imageMask_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;
    uniform sampler2D texture1;
    
    uniform vec2 offset;      
    uniform vec2 direction;
    uniform vec2 pos;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;
    
    void main()
    {                                                             
        vec4 colorSampler = texture2D(texture1,varyTexCoord.xy) * varyColor + varyColorOffset;
        vec4 colorBack = texture2D(texture,varyTexCoord.xy);
        gl_FragColor = vec4((colorBack.xyz*colorSampler.a),colorSampler.a);
    }

]]

local _imageMask_shader = -1;

local function get_imageMask_shader()
    if _imageMask_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);
        table.insert(uniforms, {"offset", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0, 0)});
        table.insert(uniforms, {"direction", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0, 0)});
        table.insert(uniforms, {"pos", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0, 0)});
        table.insert(uniforms, {"texture1", gl.GL_INT, 1, Shader.uniform_value_int(Shader_Texture_Index.imageMask)});

        _imageMask_shader = ShaderRegistry.instance():register_shader_desc{
            vs, imageMask_fragemt_shader, uniforms
        } 
    end

    return _imageMask_shader
end

return get_imageMask_shader()
end
        

package.preload[ "shaders.imageMask" ] = function( ... )
    return require('shaders/imageMask')
end
            

package.preload[ "shaders/maskBlend" ] = function( ... )
local vs = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform mat4 projection;
    uniform mat4 modelview;

    attribute vec3 position;
    attribute vec3 texcoord0;
    attribute vec3 texcoord1;
    attribute vec4 vcolor;
    attribute vec4 vcolor_offset;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;



    void main() 
    {
        vec4 pos = projection * modelview *  vec4(position,1.0);

        gl_Position = pos;

        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexcoord = texcoord0;
        varyTexcoord1 = pos.xyz * 0.5 + 0.5;
    }
]=]


local fs = [=[
    #ifdef GL_ES
    precision lowp float;
    precision lowp int;
    #endif

    uniform sampler2D texture0;
    uniform sampler2D texture1;

    varying vec3 varyTexcoord;
    varying vec3 varyTexcoord1;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;





     void main() 
    {   
        vec4 src = texture2D(texture0,varyTexcoord.xy);
        vec4 dst = texture2D(texture1,varyTexcoord1.xy);
        
        if (src.a > 0.0) src.rgb /= src.a;

        src = clamp(src * varyColor + varyColorOffset,0.0,1.0);

        gl_FragColor = vec4(src.rgb*src.a*dst.a,src.a*dst.a);     
    }
]=]


local shader = -1

local function createMaskBlend()
 
    local _,_,uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms,{"texture1",gl.GL_INT,1,Shader.uniform_value_int(1)})
    shader = ShaderRegistry.instance():register_shader_desc{vs,fs,uniforms}

    return shader
end

return createMaskBlend()


end
        

package.preload[ "shaders.maskBlend" ] = function( ... )
    return require('shaders/maskBlend')
end
            

package.preload[ "shaders/perspective" ] = function( ... )
require('shaders.shaderConstant')
local matrix     = require "libEffect.shaders.internal.matrix"
local coco = require "libEffect.shaders.internal.MatrixCOCO"


local z = 0.0       --设定z

local viewMat = coco.createLookAt(0,0,z*2+2, 0,0,0, 0,1,0); 
local proMat = coco.createPerspective(45,Window.instance().size.x/Window.instance().size.y,1,100);

local perspMatrix = Matrix()
local viewMatrix = Matrix()


perspMatrix:load(unpack(proMat))
viewMatrix:load(unpack(viewMat))

--顶点的恢复和变化是基于NDC的而不是3D的，顶点旋转显示是摄像机位置在中心的样子

local vsPersp = [=[
    #ifdef GL_ES
    precision highp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec2  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec2 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform mat4 perspMatrix;
    uniform mat4 viewMatrix;
    uniform mat4 perspMatrixInv;
    uniform mat4 viewMatrixInv;
    uniform mat4 modelViewPersp;
    uniform vec2 relativeOffset;
    uniform vec2 widgetSize;
    uniform vec2 Resolution;


    void main()
    {   
        //引擎设定2D顶点  顶点 * relative_matrix
        vec4 relateivePos = vec4(position,1.0);
        vec4 pos;
        
        //转化为NDC坐标 将顶点中心放到原点
        pos.xy = (relateivePos.xy/Resolution * 2.0 - 1.0) - (widgetSize/Resolution) - (relativeOffset/Resolution * 2 -1) ;
        
        //NDC--->3D坐标--->3D变换--->NDC
        vec4 pos2 = perspMatrix * viewMatrix *modelViewPersp* viewMatrixInv * perspMatrixInv * vec4(pos.xy, 0.0, 1.0);
        
        //NDC下将顶点位置还原
        pos2.xy = pos2.xy + (widgetSize/Resolution) + (relativeOffset/Resolution * 2 -1) ;
        gl_Position = pos2;
        
        
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
        varyTexCoord =  texcoord0;

    }
]=];

local fsPersp = [=[
    #ifdef GL_ES
    precision highp float;
    #endif

    uniform sampler2D texture0;
      
    varying vec2 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    void main()
    {
        gl_FragColor = texture2D(texture0, varyTexCoord) * varyColor + varyColorOffset;
    }
]=];

local persp = -1;
local function createPersp ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'perspMatrix', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(perspMatrix)})
    table.insert(uniforms, {'viewMatrix', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(viewMatrix)})
    table.insert(uniforms, {'perspMatrixInv', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(perspMatrix:getInversed())})
    table.insert(uniforms, {'viewMatrixInv', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(viewMatrix:getInversed())})
    table.insert(uniforms, {'modelViewPersp', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(Matrix())})
    table.insert(uniforms, {'widgetSize', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)})
    table.insert(uniforms, {'relativeOffset', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)})
    table.insert(uniforms, {'Resolution', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(Window.instance().size.x,Window.instance().size.y)})
    persp = ShaderRegistry.instance():register_shader_desc{vsPersp, fsPersp, uniforms}
    return persp
end

return createPersp()
end
        

package.preload[ "shaders.perspective" ] = function( ... )
    return require('shaders/perspective')
end
            

package.preload[ "shaders/psMotionBlur" ] = function( ... )
require('shaders.shaderConstant')

--[[local fsBlur = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
    
    #define NUM 15.0

    uniform sampler2D texture;

    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
    
    uniform int horizontalPass; // 0 or 1 to indicate vertical or horizontal pass
    //uniform int blurSize;    
    uniform vec2 texOffset;
    uniform float sigma;        // The sigma value for the gaussian function: higher value means more blur
                                // A good value for 9x9 is around 3 to 5
                                // A good value for 7x7 is around 2.5 to 4
                                // A good value for 5x5 is around 2 to 3.5
                                
 
    const float pi = 3.14159265;
 
    void main() {  
      vec2 uv = vec2(varyTexCoord.x,varyTexCoord.y);

      vec2 uvC = uv * 2.0 - 1.0;

      float dis = distance(vec2(0.0,0.0), uvC);
      
      //float numBlurPixelsPerSide = float(blurSize / 2); 
 
      vec2 blurMultiplyVec = 0 < horizontalPass ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
 
      vec3 incrementalGaussian;
      incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
      incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
      incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;
 
      vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
      float coefficientSum = 0.0;
 
      avgValue += texture2D(texture, varyTexCoord.xy) * incrementalGaussian.x;
      coefficientSum += incrementalGaussian.x;
      incrementalGaussian.xy *= incrementalGaussian.yz;
 
      for (float i = 1.0; i <= NUM; i++) { 
        avgValue += texture2D(texture, varyTexCoord.xy - i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        avgValue += texture2D(texture, varyTexCoord.xy + i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        coefficientSum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
      }
 
      gl_FragColor = avgValue / coefficientSum * varyColor + varyColorOffset;
    }
]=];

]]

local fsHead = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
]=]

local fsEnd = [=[
    
    uniform sampler2D texture;
    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
    
    uniform int horizontalPass; // 0 or 1 to indicate vertical or horizontal pass
    //uniform int blurSize;    
    uniform vec2 texOffset;
    uniform float sigma;        // The sigma value for the gaussian function: higher value means more blur
                                // A good value for 9x9 is around 3 to 5
                                // A good value for 7x7 is around 2.5 to 4
                                // A good value for 5x5 is around 2 to 3.5
                                
 
    const float pi = 3.14159265;
 
    void main() {  
      vec2 uv = vec2(varyTexCoord.x,varyTexCoord.y);

      vec2 uvC = uv * 2.0 - 1.0;

      float dis = distance(vec2(0.0,0.0), uvC);
      
      //float numBlurPixelsPerSide = float(blurSize / 2); 
 
      vec2 blurMultiplyVec = 0 < horizontalPass ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
 
      vec3 incrementalGaussian;
      incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
      incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
      incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;
 
      vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
      float coefficientSum = 0.0;
 
      avgValue += texture2D(texture, varyTexCoord.xy) * incrementalGaussian.x;
      coefficientSum += incrementalGaussian.x;
      incrementalGaussian.xy *= incrementalGaussian.yz;
 
      for (float i = 1.0; i <= NUM; i++) { 
        avgValue += texture2D(texture, varyTexCoord.xy - i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        avgValue += texture2D(texture, varyTexCoord.xy + i * texOffset *// dis * 2.0 *
                              blurMultiplyVec) * incrementalGaussian.x;         
        coefficientSum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
      }
 
      gl_FragColor = avgValue / coefficientSum * varyColor + varyColorOffset;
    }
]=];

local shader = -1;

local function createPSMotionBlur(distance)
    
    local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    local fs = fsHead.."#define NUM "..distance..fsEnd

    table.insert(uniforms, {"horizontalPass", gl.GL_INT, 1, Shader.uniform_value_int(0)})
    --table.insert(uniforms, {"blurSize",  gl.GL_INT, 1, Shader.uniform_value_int(40)})
    table.insert(uniforms, {"texOffset", gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(1/1280,1/720)})
    table.insert(uniforms, {"sigma", gl.GL_FLOAT, 1, Shader.uniform_value_float(30)})
    shader = ShaderRegistry.instance():register_shader_desc{vs, fs, uniforms}

    return shader
end
end
        

package.preload[ "shaders.psMotionBlur" ] = function( ... )
    return require('shaders/psMotionBlur')
end
            

package.preload[ "shaders/radialBlurSpin" ] = function( ... )
local fsHead = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
]=]

local fsEnd = [=[

    uniform sampler2D texture;

    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
 
    void main() {  
        mat2 rotMat;
            
        vec2 uv2 = vec2(varyTexCoord.x,varyTexCoord.y);

        vec2 uvC = uv2 - 0.5;

        vec4 c = vec4(0.0,0.0,0.0,0.0);
        for(int i=0; i <INTENSITY * 2; i++) {
            

            rotMat[0][0] =  cos(float(i)*3.14/720.0);
            rotMat[0][1] =  sin(float(i)*3.14/720.0);
            rotMat[1][0] = -sin(float(i)*3.14/720.0);
            rotMat[1][1] =  cos(float(i)*3.14/720.0);
            c += texture2D(texture, uvC * rotMat + 0.5);

            rotMat[0][0] =  cos(float(-i)*3.14/720.0);
            rotMat[0][1] =  sin(float(-i)*3.14/720.0);
            rotMat[1][0] = -sin(float(-i)*3.14/720.0);
            rotMat[1][1] =  cos(float(-i)*3.14/720.0);
            c += texture2D(texture, uvC * rotMat + 0.5);
   	    }
   	    gl_FragColor = c/float(INTENSITY) / 4.0;
    }
]=];





local radialBlurSpin = -1;
local function createRadialBlurSpin(intensity)
    local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    local fs = fsHead.."#define INTENSITY "..intensity..fsEnd
    radialBlurSpin = ShaderRegistry.instance():register_shader_desc{vs, fs, uniforms}

    return radialBlurSpin
end
end
        

package.preload[ "shaders.radialBlurSpin" ] = function( ... )
    return require('shaders/radialBlurSpin')
end
            

package.preload[ "shaders/radialBlurZoom" ] = function( ... )
local fsHead = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
]=]

local fsEnd = [=[

    uniform sampler2D texture;
    uniform float scaleRatio;

    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
 
    void main() {  
        vec2 uv2 = vec2(varyTexCoord.x,varyTexCoord.y);

        vec2 uvC = uv2 * 2.0 - 1.0;

        vec4 c = vec4(0.0,0.0,0.0,0.0);
        for(int i=0; i <INTENSITY; i++) {
    	    float scale = 1.0 - scaleRatio * (float(i)/(float(INTENSITY)-1.0));
    	    c += texture2D(texture, uvC * scale * 0.5 + 0.5);
   	    }
   	    gl_FragColor = c/float(INTENSITY);
    }
]=]

local radialBlurZoom = -1;
local function createRadialBlurZoom(intensity)
    local vs, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    local fs = fsHead.."#define INTENSITY "..intensity..fsEnd
    table.insert(uniforms,{"scaleRatio",gl.GL_FLOAT,1,Shader.uniform_value_float(0.2)})
    radialBlurZoom = ShaderRegistry.instance():register_shader_desc{vs, fs, uniforms}

    return radialBlurZoom
end
end
        

package.preload[ "shaders.radialBlurZoom" ] = function( ... )
    return require('shaders/radialBlurZoom')
end
            

package.preload[ "shaders/radicalBlur" ] = function( ... )
local fsRadicalBlur = [=[
    #ifdef GL_ES
    precision mediump float;
    precision mediump int;
    #endif
 
    uniform sampler2D texture;
    uniform float intensity;

    varying vec4 varyColor;
    varying vec3 varyTexCoord;
    varying vec4 varyColorOffset;
 
    void main() {  
        vec2 uv2 = vec2(varyTexCoord.x,varyTexCoord.y);

        vec2 uvC = uv2 * 2.0 - 1.0;

        float dis = distance(vec2(0.0,0.0), uvC);

        vec2 uv = varyTexCoord.xy -vec2(0.5,0.5);
        vec4 c = vec4(0.0,0.0,0.0,0.0);
        for(int i=0; i <10; i++) {
    	    float scale = 1.0 - intensity * (float(i)/(10.0-1.0));
    	    c += texture2D(texture, uv * scale  + vec2(0.5,0.5));
   	    }
   	    gl_FragColor = c/10.0;
    }
]=];

local radicalBlur = -1;
local function createRadicalBlur()
    local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms,{"intensity",gl.GL_FLOAT,1,Shader.uniform_value_float(0.1)})
    radicalBlur = ShaderRegistry.instance():register_shader_desc{vs, fsRadicalBlur, uniforms}

    return radicalBlur
end

return createRadicalBlur()
end
        

package.preload[ "shaders.radicalBlur" ] = function( ... )
    return require('shaders/radicalBlur')
end
            

package.preload[ "shaders/shaderConstant" ] = function( ... )
 ---
 -- @module shaders.shaderConstant
 -- @author QigaoLiu
 
 Shader_Texture_Index = 
 {
    flash1 = 1,
    frost = 2,
    imageMask = 3,
    image2dX = 4,
    glow = 5,
    holo = 6,
    fireColor = 7,
    fireAlpha = 8
 };



---
-- PS 的混合模式.
-- @type Shader_PS_Blend

---
-- 供外部使用的PS 的混合模式的枚举值.
-- @field [parent=#global] #Shader_PS_Blend Shader_PS_Blend 
 Shader_PS_Blend = 
 { 
     --- 
     -- 正常.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{src} 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897563670_5780836234717990924.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number normal 
     normal       = 0,      --正常
     
     ---
     -- 变暗.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= \min(C_{src},C_{dst}) 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该模式通过比较上下层像素后取相对较暗的像素作为输出*注意，每个不同的颜色通道的像素都是独立的进行比较，色彩值相对较小的作为输出结果。*<br/>
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899284016_5405470186962343899.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number darken 
     darken       = 1,      --变暗  
     
     ---
     -- 正片叠底.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{src}C_{dst} 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该效果将两层像素的值相乘后输出，其效果可以形容成：两个幻灯片叠加在一起然后放映， 透射光需要分别通过这两个幻灯片，从而被削弱了两次。 <br/>
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899333331_5334850214618648244.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number multiply 
     multiply     = 2,      --正片叠底
     
     ---
     -- 颜色加深.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{src} - (1-C_{src})(1-C_{dst})/C_{dst} 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 如果源颜色越暗，则目标获取的光越少，加深效果越明显。 *如果上层为全黑色，则下层颜色值不是255的像素全变成0*，如果上层为全白色，则根本不会影响下层。 结果最亮的地方不会高于下层的像素值。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899359800_8727458020132958010.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>  
     -- @field [parent=#Shader_PS_Blend] #number colorBurn 
     colorBurn    = 3,      --颜色加深
     
     ---
     -- 线性加深.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{dst} + C_{src} - 1 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 如果源和目标的像素值之和小于1，输出结果将会是纯黑色。如果将源颜色反相，结果将是纯粹的数学减。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899379850_7672868570152012056.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number linearBrun 
     linearBrun   = 4,      --线性加深
     
     ---
     -- 深色.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     --  C_{out} &=
     -- \begin{cases}
     -- \ C_{src}      & C_{src}\cdot r + C_{src}\cdot g + C_{src}\cdot b < C_{dst}\cdot r + C_{dst}\cdot g + C_{dst}\cdot b  \\
     -- \ C_{dst}       &  other
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- *该模式通过比较源和目标像素后取相对较暗的像素作为输出.*注意，是取三个通道的像素的之和进行比较。 *
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899462262_8309742849047643334.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number darkerColor 
     darkerColor  = 5,      --深色
     
     ---
     -- 变亮.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= \max(C_{dst},C_{src}) 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- *该模式通过比较上下层像素后取相对较亮的像素作为输出*注意，每个不同的颜色通道的像素都是独立的进行比较，色彩值相对较大的作为输出结果。*
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899504134_6664750963325499631.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number lighten
     lighten      = 6,      --变亮 
     
     ---
     -- 滤色.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= 1-(1-C_{dst})(1-C_{src}) 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该模式和@{#Shader_PS_Blend.multiply}相反,上下层像素的标准色彩值反相后相乘后输出，输出结果比两者的像素值都将要亮 就好像两台投影机分别对其中一个图层进行投影后，然后投射到同一个屏幕上。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899529119_5808649109686969355.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number screen
     screen       = 7,      --滤色
     
     ---
     -- 颜色减淡.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{dst} /(1-C_{src}) 
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该模式和@{#Shader_PS_Blend.colorBurn}相反,该模式下，上层的亮度决定了下层的暴露程度。 如果上层越亮，下层获取的光越多，也就是越亮。如果上层是纯黑色，也就是没有亮度，则根本不会影响下层， *如果上层是纯白色，则下层颜色值不是0的像素全变成255*。 结果最黑的地方不会低于下层的像素值。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899553616_2171214097216030311.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number colorDodge
     colorDodge   = 8,      --颜色减淡
     
     ---
     -- 线性减淡.
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &= C_{src} +  C_{dst}  
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 将上下层的色彩值相加。结果将更亮。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899586743_6114363778824482184.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number linearDodge 
     linearDodge  = 9,      --线性减淡（添加）
     
     ---
     -- 浅色 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     --  C_{out} &=
     -- \begin{cases}
     -- \ C_{dst}      & C_{src}\cdot r + C_{src}\cdot g + C_{src}\cdot b < C_{dst}\cdot r + C_{dst}\cdot g + C_{dst}\cdot b  \\
     -- \C_{src}       &  other
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该模式和@{#Shader_PS_Blend.darkerColor}相反,不同的是取色彩值较大的（也就是较亮的）作为输出结果。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899629304_780190541029580930.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number lighterColor 
     lighterColor = 10,     --浅色
     
     ---
     -- 浅色 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &=
     -- \begin{cases}
     -- \ 2*(C_{src}C_{dst})      & C_{src} \leq 0.5     \\
     -- \ 1-2*((1-C_{src})(1-C_{dst}))          &  C_{src} >0.5 
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- *注意，每个不同的颜色通道的像素都是独立的进行比较。*
     -- 依据下层色彩值的不同，该模式可能是@{#Shader_PS_Blend.multiply}，也可能是@{#Shader_PS_Blend.screen}。 
     -- 上层决定了下层中间色调偏移的强度。 
     -- 如果上层为50%灰，则结果将完全为下层像素的值。 
     -- 如果上层比50%灰暗，则下层的中间色调的将向暗地方偏移， 
     -- 如果上层比50%灰亮，则下层的中间色调的将向亮地方偏移。 
     -- 对于上层比50%灰暗，下层中间色调以下的色带变窄（原来为0~2×0.4×0.5，现在为0~2×0.3×0.5）， 
     -- 中间色调以上的色带变宽（原来为2×0.4×0.5~1，现在为2×0.3×0.5~1）。 
     -- 反之亦然。 
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899649731_8105116806314582503.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number overLay 
     overLay      = 11,     --叠加
     
     ---
     -- 柔光 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &=
     -- \begin{cases}
     -- \ C_{src} - C_{src}(1 - 2C_{dst})(1.0 - C_{src})      & C_{dst} \leq 0.5     \\
     -- \ C_{src} + (2C_{dst} - 1)(D(C_{src}) - C_{src})          &  C_{dst} >0.5 
     -- \end{cases}
     -- \end{eqnarray}
     -- \begin{eqnarray}
     -- D(x) &=
     -- \begin{cases}
     -- \((16x-12)x+4)x      & x \leq 0.25     \\
     -- \ \sqrt{x}          &  x > 0.25 
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- *注意，每个不同的颜色通道的像素都是独立的进行计算。*
     -- 使颜色变暗或变亮，具体取决于混合色。 此效果与发散的聚光灯照在图像上相似。
     -- 如果混合色（光源）比50% 灰色亮，则图像变亮，就像被减淡了一样。
     -- 如果混合色（光源）比 50%灰色暗，则图像变暗，就像被加深了一样。
     -- 使用纯黑色或纯白色上色，可以产生明显变暗或变亮的区域，但不能生成纯黑色或纯白色。 
     -- 该模式类似上层以Gamma值范围为2.0到0.5的方式来调制下层的色彩值。 结果将是一个非常柔和的组合。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899667842_6755832309005809890.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number softLight 
     softLight    = 12,     --柔光
     
     ---
     -- 强光 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &=
     -- \begin{cases}
     -- \ 2C_{src}C_{dst}      & C_{dst} \leq 0.5     \\
     -- \ 1- 2((1-C_{src})(1-C_{dst}))          &  C_{dst} >0.5 
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- *注意，每个不同的颜色通道的像素都是独立的进行计算。*
     -- 该模式完全相对应于@{#Shader_PS_Blend.overLay}模式下，两个图层进行次序交换的情况。
     -- 如过上层的颜色高于50%灰，则下层越亮，反之越暗。 
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899791142_4316085767024157893.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number hardLight 
     hardLight    = 13,     --强光
     
     ---
     -- 亮光 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?\begin{document}
     -- \begin{eqnarray}
     -- C_{out} &=
     -- \begin{cases}
     -- \ 1- (1-C_{src})/(2C_{dst})      & C_{dst} \leq 0.5     \\
     -- \ C_{src}/(2(1-C_{dst}))         &  C_{dst} >0.5 
     -- \end{cases}
     -- \end{eqnarray}
     -- \end{document}"><br/>
     -- 该模式非常强烈的增加了对比度，特别是在高亮和阴暗处。
     -- 可以认为是阴暗处应用@{#Shader_PS_Blend.colorBurn}和高亮处应用@{#Shader_PS_Blend.colorDodge}。
     -- 如果混合色（光源）比 50%灰色亮，则通过减小对比度使图像变亮。如果混合色比 50% 灰色暗，则通过增加对比度使图像变暗。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899813198_4231901908900251565.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number vividLight 
     vividLight   = 14,     --亮光
     
     ---
     -- 线性光 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &= C_{src}+2C_{dst} -1   
     -- \end{eqnarray}"><br/>
     -- 通过减小或增加亮度来加深或减淡颜色，具体取决于混合色。 
     -- 如果混合色（光源）比 50%灰色亮，则通过增加亮度使图像变亮。如果混合色比 50% 灰色暗，则通过减小亮度使图像变暗。 
     -- 其类似于@{#Shader_PS_Blend.colorBurn}只不过是加深了上层的影响力。 
     -- *由于将目标颜色值加倍，所以结果比线性加深亮很多。*
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899836386_8206699581400438762.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number linearLight 
     linearLight  = 15,     --线性光
     
     ---
     -- 点光 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &=
     -- \begin{cases}
     -- \ \min(C_{src},2C_{dst})      & C_{dst} \leq 0.5     \\
     -- \ \max(C_{src},2C_{dst} -1 )          &  C_{dst} >0.5 
     -- \end{cases} 
     -- \end{eqnarray}"><br/>
     -- 根据混合色替换颜色。如果混合色（光源）比50% 灰色亮，则替换比混合色暗的像素，而不改变比混合色亮的像素。
     -- 如果混合色比 50%灰色暗，则替换比混合色亮的像素，而比混合色暗的像素保持不变。这对于向图像添加特殊效果非常有用。 
     -- 该模式结果就是导致中间调几乎是不变的， 但是两边是@{#Shader_PS_Blend.darken}和@{#Shader_PS_Blend.lighten}模式的组合。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899873640_2171761968630219820.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number pinLight
     pinLight     = 16,     --点光
     
     ---
     -- 实色混合 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &= \lfloor C_{src}+C_{dst}\rfloor      
     -- \end{eqnarray}"><br/>
     -- 该模式导致了最终结果仅包含6种基本颜色，每个通道要么就是0，要么就是1。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899891048_3549479183119967065.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number hardMix
     hardMix      = 17,     --实色混合
     
     ---
     -- 差值 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &= \left|C_{src}-C_{dst}\right|    
     -- \end{eqnarray}"><br/>
     -- 上下层色彩值之差的绝对值。 该模式主要用于比较两个不同版本的图片。 如果两者完全一样，则结果为全黑。 与白色混合将反转基色值；与黑色混合则不产生变化。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899914676_7776866859371219334.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/> 
     -- @field [parent=#Shader_PS_Blend] #number diff
     diff         = 18,     --差值
     
     ---
     -- 排除 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &=   C_{src} +  C_{dst} - 2C_{src}C_{dst}
     -- \end{eqnarray}"><br/>
     -- 亮的图片区域将导致另一层的反相，很暗的区域则将导致另一层完全没有改变。 与@{#Shader_PS_Blend.diff}模式相似但对比度更低的效果（偏灰）。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899942635_8744951508951814114.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number exclusion
     exclusion    = 19,     --排除
     
     ---
     -- 减去 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &= C_{src}-C_{dst}  
     -- \end{eqnarray}"><br/>
     -- 查看各通道的颜色信息，并从基色中减去混合色。如果出现负数就剪切为零。与基色相同的颜色混合得到黑色；白色与基色混合得到黑色；黑色与基色混合得到基色。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468899992265_4776950521815918498.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number subtract
     subtract     = 20,     --减去
     
     ---
     -- 划分 .
     -- 源颜色:= C<sub>src</sub>  <br/>
     -- 目标颜色:= C<sub>dst</sub> <br/>
     -- 输出的颜色:= C<sub>out</sub><br/>
     -- <img src="http://www.forkosh.com/mathtex.cgi?
     -- \begin{eqnarray}
     -- C_{out} &= C_{src}/C_{dst}  
     -- \end{eqnarray}"><br/>
     -- 查看每个通道的颜色信息，并用基色分割混合色。基色数值大于或等于混合色数值，混合出的颜色为白色。基色数值小于混合色，结果色比基色更暗。因此结果色对比非常强。白色与基色混合得到基色，黑色与基色混合得到白色。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900034773_5896493744618199662.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number divide
     divide       = 21,     --划分
     
     ---
     -- 色相 .
     -- 输出图像的色调为上层，饱和度和亮度保持为下层。 对于灰色上层，结果为去色的下层。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900059945_4471567480324422458.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number hue
     hue          = 22,     --色相
     
     ---
     -- 饱和度 .
     -- 输出图像的饱和度为上层，色调和亮度保持为下层。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900082193_70825412764058117.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number saturation
     saturation   = 23,     --饱和度
     
     ---
     -- 颜色 .
     -- 输出图像的亮度为下层，色调和饱和度保持为上层。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900092457_4274910272818297899.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number color
     color        = 24,     --颜色
     
     ---
     -- 明度  .
     -- 输出图像的亮度为上层，色调和饱和度保持为下层。
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900103385_1554622345054328418.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number luminosity
     luminosity   = 25,      --明度
     
     ---
     -- 叠加.
     -- 与@{#Shader_PS_Blend.linearDodge}相同.
     -- <p>
     -- <table   border="1" align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
     -- <tr>
     --     <td align="center" style="border-style: none;">背景图片</td>
     --     <td align="center" style="border-style: none;">使用混合后效果</td>
     --     <td align="center" style="border-style: none;">前景图片</td>
     -- </tr>
     -- <tr>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897488399_4116527267919363717.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468900115258_4740027205896674053.png"></td>
     -- <td><img src="http://engine.by.com:8080/hosting/data/1468897500446_7264887903782093858.png"></td>
     -- </tr>
     -- </table>
     -- </p><br/>
     -- @field [parent=#Shader_PS_Blend] #number add
     add          = 26      --明度
 }
end
        

package.preload[ "shaders.shaderConstant" ] = function( ... )
    return require('shaders/shaderConstant')
end
            

package.preload[ "shaders/shattering" ] = function( ... )
require('shaders.shaderConstant')
local matrix     = require "libEffect.shaders.internal.matrix"
local coco = require "libEffect.shaders.internal.MatrixCOCO"


local z = 0.0       --设定z

local viewMat = coco.createLookAt(0,0,z*2+2, 0,0,0, 0,1,0); 
local proMat = coco.createPerspective(45,Window.instance().size.x/Window.instance().size.y,1,100);

local perspMatrix = Matrix()
local viewMatrix = Matrix()


perspMatrix:load(unpack(proMat))
viewMatrix:load(unpack(viewMat))

local vsShattering = [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform mat4  projection;
    uniform mat4  modelview;

    attribute vec3  position;
    attribute vec3  texcoord0;
    attribute vec4  vcolor;
    attribute vec4  vcolor_offset;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform mat4 perspMatrix;
    uniform mat4 viewMatrix;
    uniform mat4 perspMatrixInv;
    uniform mat4 viewMatrixInv;
    uniform mat4 modelViewPersp;
    uniform vec2 relativeOffset;
    uniform vec2 widgetSize;
    uniform vec2 Resolution;

    attribute vec3  direction;
    uniform float time;

    void main()
    {   
        mat4 matRotX = mat4(1.0,0.0,0.0,0.0,
                            0.0,1.0,0.0,0.0,
                            0.0,0.0,1.0,0.0,
                            0.0,0.0,0.0,1.0);
        float radX = radians(direction.x * time*1000.0);
        matRotX[0][0] = 1.0;
        matRotX[1][1] = cos(radX);
        matRotX[1][2] = sin(radX);
        matRotX[2][1] = -sin(radX);
        matRotX[2][2] = cos(radX);
        matRotX[3][3] = 1.0;
        
        
        
        
        mat4 matRotY = mat4(1.0,0.0,0.0,0.0,
                           0.0,1.0,0.0,0.0,
                           0.0,0.0,1.0,0.0,
                           0.0,0.0,0.0,1.0);

        float radY = radians(direction.y * time*100.0);
        matRotY[0][0] = cos(radY);
        matRotY[0][2] = sin(radY);
        matRotY[1][1] = 1.0;
        matRotY[2][0] = -sin(radY);
        matRotY[2][2] = cos(radY);
        matRotY[3][3] = 1.0;

       



        //引擎设定2D顶点  顶点 * relative_matrix
        vec4 relateivePos = vec4(position.xy,0.0,1.0);
        vec4 pos;
        
        //转化为NDC坐标 将顶点中心放到原点
        pos.xy = (relateivePos.xy/Resolution * 2.0 - 1.0) - (widgetSize/Resolution) - (relativeOffset/Resolution * 2 -1) ;
        
        //NDC--->3D坐标--->3D变换--->NDC
        vec4 pos2 = perspMatrix * viewMatrix *modelViewPersp * matRotY * matRotX * viewMatrixInv * perspMatrixInv * vec4(pos.xy, 0.0, 1.0);
        
        //NDC下将顶点位置还原
        pos2.xy = pos2.xy + (widgetSize/Resolution) + (relativeOffset/Resolution * 2 -1)+direction.xy * time;
        //pos2.z = pos2.z + direction.z * time;
        gl_Position = pos2;
        
        varyTexCoord = texcoord0 ;
        varyColor = vcolor;
        varyColorOffset = vcolor_offset;
    }
]=];

local fsShattering= [=[
    #ifdef GL_ES
    precision lowp float;
    #endif
    uniform sampler2D texture;
    
    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    uniform float time;
   
    void main()
    {
        vec4 colorTex = texture2D(texture, varyTexCoord.xy);
        gl_FragColor = colorTex * varyColor + varyColorOffset;
        gl_FragColor.a = 1.0 - time;
        gl_FragColor.rgb *=gl_FragColor.a;
    }
]=];

local shattering = -1;
local function createShattering ()
    local _, _, uniforms = unpack(ShaderRegistry.instance().default_desc)
    table.insert(uniforms, {'perspMatrix', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(perspMatrix)})
    table.insert(uniforms, {'viewMatrix', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(viewMatrix)})
    table.insert(uniforms, {'perspMatrixInv', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(perspMatrix:getInversed())})
    table.insert(uniforms, {'viewMatrixInv', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(viewMatrix:getInversed())})
    table.insert(uniforms, {'modelViewPersp', gl.GL_FLOAT_MAT4, 1, Shader.uniform_value_matrix(Matrix())})
    table.insert(uniforms, {'widgetSize', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)})
    table.insert(uniforms, {'relativeOffset', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)})
    table.insert(uniforms, {'Resolution', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(Window.instance().size.x,Window.instance().size.y)})
    table.insert(uniforms, {'time', gl.GL_FLOAT,1,Shader.uniform_value_float(0)})
    shattering = ShaderRegistry.instance():register_shader_desc{vsShattering, fsShattering, uniforms}

    return shattering
end

return createShattering()

end
        

package.preload[ "shaders.shattering" ] = function( ... )
    return require('shaders/shattering')
end
            

package.preload[ "shaders/whiteScale" ] = function( ... )
local whiteScale_fragemt_shader = [[
    #ifdef GL_ES
        precision highp float;
    #endif

    uniform sampler2D texture;       
    uniform float bright;

    varying vec3 varyTexCoord;
    varying vec4 varyColor;
    varying vec4 varyColorOffset;

    void main()
    {   

        vec4 tColor = texture2D(texture, varyTexCoord.xy);
        vec3 c = tColor.rgb *0.7 + bright * tColor.a;
        gl_FragColor = vec4(c, tColor.a) * varyColor + varyColorOffset;
        
    }
]]

local _whiteScale_shader = -1


local function get_whiteScale_shader()
    if _whiteScale_shader == -1 then
        local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc);

        table.insert(uniforms, {"bright", gl.GL_FLOAT, 1, Shader.uniform_value_float(0.4)});

        _whiteScale_shader = ShaderRegistry.instance():register_shader_desc{
            vs, whiteScale_fragemt_shader, uniforms
        }

    end

    return _whiteScale_shader
end

return get_whiteScale_shader()
end
        

package.preload[ "shaders.whiteScale" ] = function( ... )
    return require('shaders/whiteScale')
end
            
require("libEffect.easing");
require("libEffect.version");
require("libEffect.shaders.blur");
require("libEffect.shaders.blurWidget");
require("libEffect.shaders.circleScan");
require("libEffect.shaders.colorTransform");
require("libEffect.shaders.common");
require("libEffect.shaders.fireWidget");
require("libEffect.shaders.flash");
require("libEffect.shaders.flash2");
require("libEffect.shaders.frost");
require("libEffect.shaders.genieWidget");
require("libEffect.shaders.glassWidget");
require("libEffect.shaders.glow");
require("libEffect.shaders.grayScale");
require("libEffect.shaders.holo");
require("libEffect.shaders.imageMask");
require("libEffect.shaders.PSBlend");
require("libEffect.shaders.scratch");
require("libEffect.shaders.shatteringWidget");
require("libEffect.shaders.stencilMask");
require("libEffect.shaders.vectorGraph");
require("libEffect.shaders.whiteScale");
require("libEffect.shaders.internal.blurImplementation");
require("libEffect.shaders.internal.drawingTracer");
require("libEffect.shaders.internal.matrix");
require("libEffect.shaders.internal.MatrixCOCO");
require("libEffect.shaders.internal.shaderInfo");
require("shaders.blend");
require("shaders.blur");
require("shaders.blurHorizontal");
require("shaders.blurShaderHorizontal");
require("shaders.blurShaderVertical");
require("shaders.blurVertical");
require("shaders.circle");
require("shaders.circleScan");
require("shaders.colorOffset");
require("shaders.fire");
require("shaders.flash2");
require("shaders.flashShader");
require("shaders.frostShader");
require("shaders.genie");
require("shaders.glass");
require("shaders.glassBlend");
require("shaders.glow");
require("shaders.grayScale");
require("shaders.holoShader");
require("shaders.image2dColor");
require("shaders.image2dMask");
require("shaders.imageMask");
require("shaders.maskBlend");
require("shaders.perspective");
require("shaders.psMotionBlur");
require("shaders.radialBlurSpin");
require("shaders.radialBlurZoom");
require("shaders.radicalBlur");
require("shaders.shaderConstant");
require("shaders.shattering");
require("shaders.whiteScale");