
package.preload[ "core/anim" ] = function( ... )
-- anim.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2015-12-08
-- Description: provide basic wrapper for anim variables


--------------------------------------------------------------------------------
-- anim是一个动态值，在引擎运行期间动态变化的整数或浮点数值。可以理解为是一个“随时间不断变化的值”。  
-- 常用于做定时器和动画， 或者与@{core.prop}、shader等结合使用.
-- 
-- 概念介绍：
-- ---------------------------------------------------------------------------------------
--
--<a name="001" id="001" ></a>
-- **1.anim的当前值**
-- 
-- anim是一个随时间不断变化的值，某一时刻anim的取值即为当前值。可以通过@{#AnimBase.getCurValue}来获得。
--
--
-- **2.anim 中的类**
-- 
-- （1）@{#AnimBase}（anim的基类，**无法直接使用**）：定义了一些通用的接口。
-- 
-- （2）@{#AnimInt}：继承自@{#AnimBase}，其当前值是随时间均匀变化的**整数值**。
-- 
-- （3）@{#AnimDouble}：继承自@{#AnimBase}，其当前值是随时间均匀变化的**浮点值**。
-- 
-- （4）@{#AnimIndex}：继承自@{#AnimBase}，需要自定义数组，其数组的索引值是随时间均匀变化，但是当前值是取此刻的索引值所对应的值。
-- 
-- <a name="003" id="003" ></a>
-- **3.anim的变化类型**
-- 
-- anim会指定起始值和结束值，然后根据anim的变化类型来变化当前值。anim有以下三种变化类型：
-- 
-- * [```kAnimNormal```](core.constants.html#kAnimNormal)：从起始值变化到结束值即结束。整个过程只执行一次。 
-- 
-- * [```kAnimRepeat```](core.constants.html#kAnimRepeat)：从起始值变化到结束值，再从起始值变化到结束值，如此反复。
-- 
-- * [```kAnimLoop```](core.constants.html#kAnimLoop)：从起始值变化到结束值，再变化到起始值，再变化到结束值，如此反复。 
-- 
-- 
-- <a name="004" id="004" ></a>
-- **4.anim的回调函数的参数及意义**
-- 
-- 回调函数的参数 ```func(object,anim_type, anim_id, repeat_or_loop_num)```
-- 
-- * ```object``` :  @{#AnimBase.setEvent}的obj传入。
-- 
-- * ```anim_type```: anim的变化类型。由注册该回调函数的对象的构造函数传入。
-- 
-- * ```anim_id```:注册该回调的anim对象的id，此id由引擎自动分配。
-- 
-- * ```repeat_or_loop_num``` :循环的次数，此值由引擎传回。
-- 
-- 
-- 
-- @module core.anim
-- @return #nil 
-- @usage require("core/anim")

require("core/object");
require("core/constants");
require("core/global");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimBase------------------------------------------
---------------------------------------------------------------------------------------------

---
-- AnimBase提供一个“随时间不断变化的值”. 
-- 包含唯一标识、获取当前值、当前值变化的事件的函数.常用于做定时器或者UI动画.  
-- **这是个可变值类的基类，无法直接使用.**
--
-- @type AnimBase
AnimBase = class();

---
-- 返回AnimBase对象的唯一标识Id.
-- 
-- 每个AnimBase对象都有自己唯一的Id，是一个32位带符号整数，在创建对象的时候由引擎自动分配；
-- 可以用此Id对AnimBase对象进行操作.
--
-- @function [parent=#AnimBase] getID
-- @param self
-- @return #number AnimBase对象的Id.
property(AnimBase,"m_animID","ID",true,false);

---
-- 构造函数.
--
-- @param self
AnimBase.ctor = function(self)
	self.m_animID = anim_alloc_id();
	self.m_eventCallback = {};
end

---
-- 析构函数.
--
-- @param self
AnimBase.dtor = function(self)
	anim_free_id(self.m_animID);
end

---
-- 设置一个DebugName,便于调试.如果出现错误日志中会打印出这个名字，便于定位问题.
-- 
-- @param self
-- @param #string name 设置的debugName.
AnimBase.setDebugName = function(self, name)	
    self.m_debugName=name or ""
	anim_set_debug_name(self.m_animID,self.m_debugName);
end

---
-- 返回DebugName,便于调试.
-- 
-- @param self
-- @return #string DebugName.
AnimBase.getDebugName = function(self)
    return self.m_debugName
end


---
-- 获取AnimBase对象的当前值.<a href="#001">详见：anim的当前值。</a>
--
-- @param self
-- @param #number defaultValue 默认值。如果无法获取当前值，则返回这个默认值.    
-- @return #number AnimBase对象的当前值.如果当前值获取失败则返回默认值。如果默认值（```defaultValue```）为nil，获取失败返回0.    
AnimBase.getCurValue = function(self, defaultValue)
	return anim_get_value(self.m_animID,defaultValue or 0)
end

---
-- 设置AnimBase对象回调函数. 
--
-- @param self
-- @param obj 会在回调的时候当做回调函数的第一个参数传入,obj为任意类型.
-- @param #function func  当AnimBase对象当前值完成一次变化后，就会回调此函数.  <a href="#004">详见：anim的回调函数的参数及意义。</a>   
-- 
AnimBase.setEvent = function(self, obj, func)
	anim_set_event(self.m_animID,kTrue,self,self.onEvent);
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

--------------- private functions, don't use these functions in your code -----------------------

---
-- 向引擎底层注册的回调函数.
--**此方法被标记为private,开发者不应直接使用此方法，**
--而是使用@{#AnimBase.setEvent}来注册自己的回调函数.
--
-- @param self
-- @param #number anim_type anim的变化类型.<a href="#003">详见：anim的变化类型。</a>       
-- 
-- @param #number anim_id AnimBase对象的唯一标识Id.
-- @param #number repeat_or_loop_num 循环的次数，此值由引擎传回.  
AnimBase.onEvent = function(self, anim_type, anim_id, repeat_or_loop_num)
	if self.m_eventCallback.func then
		 self.m_eventCallback.func(self.m_eventCallback.obj,anim_type, anim_id, repeat_or_loop_num);
	end
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimDouble----------------------------------------
---------------------------------------------------------------------------------------------

---
-- AnimDouble提供一个其当前值是随时间**均匀**变化的**浮点值**。      
--
-- @type AnimDouble
-- @extends #AnimBase
AnimDouble = class(AnimBase);

---
-- 构造函数.   
-- @param self
-- @param #number animType anim的变化类型.<a href="#003">详见：anim的变化类型。</a>.      
-- @param #number startValue 起始值。当前值从startValue开始变化, 取值范围(double)`[－1.797693E+308,1.797693E+308]`(十进制表示).
-- @param #number endValue 结束值。当前值在endValue终止或进入下一循环,  取值范围(double)`[－1.797693E+308,1.797693E+308]`(十进制表示).
-- @param #number duration 持续时间。即当前值变化从startValue变化到endValue时长。单位：毫秒。  取值范围(int) `[-2147483648，2147483647]`.
-- @param #number delay 延迟多长时间开始变化当前值。单位：毫秒。若delay为负或为空，则默认为0.  取值范围(int)`[-2147483648，2147483647]`.  
-- 
-- 
-- 例，当startValue=1，endValue=10，duration=10,delay=1000 时，```animType```不同取值所对应的情况如下：
--     
-- 1.```animType```取值为[```kAnimNormal```](core.constants.html#kAnimNormal)时，当前值在时间范围内从起始值线性变化到结束值后即停止。其当前值的变化如下：
-- 
-- &nbsp;&nbsp; 1.0、2.0…9.0、10.0;  
--    
-- 2.```animType```取值为[```kAnimRepeat```](core.constants.html#kAnimRepeat)时，当前值在时间范围内从起始值线性变化到结束值后,再从起始值线性变化到结束值，一直循环直到手动停止。其当前值的变化如下： 
--      
-- &nbsp;&nbsp; 1.0、2.0…9.0、10.0、1.0、2.0…10.0、1.0、2.0…10.0……;    
-- 
-- 3.```animType```取值为[```kAnimLoop```](core.constants.html#kAnimLoop)时，当前值在时间范围内从起始值线性变化到结束值后，再从结束值变化到起始值，一直反复直到手动停止。其当前值的变化如下：
--   
-- &nbsp;&nbsp; 1.0、2.0…9.0、10.0、9.0、8.0…2.0、1.0、2.0、3.0……10.0……;
AnimDouble.ctor = function(self, animType, startValue, endValue, duration, delay)
	anim_create_double(0, self.m_animID, animType, startValue, endValue, duration,delay or 0);
end

---
-- 析构函数.
--
-- @param self
AnimDouble.dtor = function(self)
	anim_delete(self.m_animID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimInt-------------------------------------------
---------------------------------------------------------------------------------------------

---
-- AnimInt提供一个其当前值是随时间**均匀**变化的**整数值**。
--
-- @type AnimInt
-- @extends #AnimBase
AnimInt = class(AnimBase);

---
-- 构造函数.   
-- @param self
-- @param #number animType anim的变化类型.<a href="#003">详见：anim的变化类型。</a>.       
-- @param #number startValue 起始值。当前值从startValue开始变化,取值范围(int) `[-2147483648，2147483647]` (十进制表示)。 
-- @param #number endValue 结束值。当前值在endValue终止或进入下一循环, 取值范围(int) `[-2147483648，2147483647]` (十进制表示)。 
-- @param #number duration 持续时间。即当前值变化从startValue变化到endValue时长。单位：毫秒。  取值范围(int) `[-2147483648，2147483647]`.
-- @param #number delay 延迟多长时间开始变化当前值。单位：毫秒。若delay为负或为空，则默认为0.  取值范围(int)`[-2147483648，2147483647]`.   
-- 
-- 
-- 例，当startValue=1，endValue=10，duration=10,delay=1000 时，```animType```不同取值所对应的情况如下：
--     
-- 1.```animType```取值为[```kAnimNormal```](core.constants.html#kAnimNormal)时，当前值在时间范围内从起始值线性变化到结束值后即停止。其当前值的变化如下：
-- 
-- &nbsp;&nbsp; 1、2…9、10;  
--    
-- 2.```animType```取值为[```kAnimRepeat```](core.constants.html#kAnimRepeat)时，当前值在时间范围内从起始值线性变化到结束值后,再从起始值线性变化到结束值，一直循环直到手动停止。其当前值的变化如下： 
--      
-- &nbsp;&nbsp; 1、2…9、10、1、2…10、1、2…10……;    
-- 
-- 3.```animType```取值为[```kAnimLoop```](core.constants.html#kAnimLoop)时，当前值在时间范围内从起始值线性变化到结束值后，再从结束值变化到起始值，一直反复直到手动停止。其当前值的变化如下：
--   
-- &nbsp;&nbsp; 1、2…9、10、9、8…2、1、2、3……10……;
-- 
AnimInt.ctor = function(self, animType, startValue, endValue, duration, delay)
	anim_create_int(0, self.m_animID, animType, startValue, endValue, duration,delay or 0);
end

---
-- 析构函数.
-- 
-- @param self
AnimInt.dtor = function(self)
	anim_delete(self.m_animID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimIndex-----------------------------------------
---------------------------------------------------------------------------------------------

---
-- AnimIndex是自定义的对象.该对象由用户提供一个数组，其索引值随时间均匀变化，而当前值是索引所对应的值 .  
-- 
-- 当前值不断从此数组中依次取出 ,用户可以在某一时刻来获取此值.      
-- 常用于做定时器或者UI动画.适用于动画不是匀速变化的情况.
--
-- @type AnimIndex
-- @extends #AnimBase
AnimIndex = class(AnimBase);

---
-- 构造函数.
-- @param self
-- @param #number animType anim的变化类型.<a href="#003">详见：anim的变化类型。</a>.     
-- @param #number startValue **索引**的起始值。  取值范围(int)`[-2147483648，2147483647]`.
-- @param #number endValue **索引**终止值。  取值范围(int)`[-2147483,648，2147483647]`.
-- @param #number duration **索引**值从startValue变化到endValue时长(单位：毫秒)。 取值范围(int)`[-2147483648，2147483647]`.
-- @param core.res#ResBase res 使用者提供可供取值的数组.  类型包括[```ResIntArray```](core.res.html#ResIntArray)、
-- [```ResDoubleArray```](core.res.html#ResDoubleArray)、
-- [```ResUShortArray```](core.res.html#ResUShortArray).  
-- @param #number delay 延迟多少时间开始索引值的变化.若delay为负或为空，则默认为0.  取值范围(int)`[-2147483648，2147483647]`.  
-- 
-- 
-- 例，当startValue=1，endValue=10，duration=10,delay=1000 时，res为[```ResDoubleArray```](core.res.html#ResDoubleArray)，其所对应的数组为{1.2,2.5,0.1,0.8,4.6,3.1,5.0,1.3,9.0,1.0}。 ```animType```不同取值所对应的情况如下：
--     
-- 1.```animType```取值为[```kAnimNormal```](core.constants.html#kAnimNormal)时，索引值在时间范围内从起始值线性变化到结束值后即停止。其**索引值**的变化如下：
-- 
-- &nbsp;&nbsp; 1、2…9、10;  
--    
-- **当前值**的变化如下：
-- 
-- &nbsp;&nbsp; 1.2、2.5、… 9.0、 1.0;
--    
-- 2.```animType```取值为[```kAnimRepeat```](core.constants.html#kAnimRepeat)时，索引值在时间范围内从起始值线性变化到结束值后,再从起始值线性变化到结束值，一直循环直到手动停止。其**索引值**的变化如下： 
--      
-- &nbsp;&nbsp; 1、2 … 9、10、1、2  …  9、10……;
-- 
-- **当前值**的变化如下：   
-- 
-- &nbsp;&nbsp;1.2、2.5、… 9.0、 1.0、1.2、2.5、… 9.0、1.0…… 
-- 
-- 3.```animType```取值为[```kAnimLoop```](core.constants.html#kAnimLoop)时，索引值在时间范围内从起始值线性变化到结束值后，再从结束值变化到起始值，一直反复直到手动停止。其**索引值**的变化如下：
--   
-- &nbsp;&nbsp; 1、2  … 9、10、9、 8  … 2、1、 2……
-- 
-- **当前值**的变化如下：
-- 
-- &nbsp;&nbsp; 1.2、2.5、… 9.0、1.0、 9.0、1.3、… 2.5、1.2、2.5……
-- 
AnimIndex.ctor = function(self, animType, startValue, endValue, duration, res, delay)
	anim_create_index(0, self.m_animID, animType, startValue, endValue, duration, res.m_resID,delay or 0); 
end


---
-- 析构函数.
-- 
-- @param self
AnimIndex.dtor = function(self)
	anim_delete(self.m_animID);
end
end
        

package.preload[ "core.anim" ] = function( ... )
    return require('core/anim')
end
            

package.preload[ "core/blend" ] = function( ... )
---
-- 设置drawing的混合模式
--
-- @param #number iDrawingId 
-- @param #number src 取值：(`kZero`, `kOne`, `kDstColor`等)。见@{core.constants} 
-- @param #number dst 取值：(`kZero`, `kOne`, `kSrcColor`等)。见@{core.constants} 
function drawing_set_blend_mode ( iDrawingId, src, dst )
	if dst == 7 then 
		print_string("==========目标因子不能为kSrcColor, 请修正==========");
		return
	end
	drawing_set_blend_factor ( iDrawingId,  src, dst );
end
end
        

package.preload[ "core.blend" ] = function( ... )
    return require('core/blend')
end
            

package.preload[ "core/class" ] = function( ... )
--local inspect = require('inspect')

local function objget(self, name)
    if type(self) == 'userdata' then
        return Widget.get_uservalue(self, name)
    else
        return rawget(self, name)
    end
end

local function objset(self, name, value)
    if type(self) == 'userdata' then
        Widget.set_uservalue(self, name, value)
    else
        rawset(self, name, value)
    end
end

local function index(self, name, meta)
    local result = objget(self, name)
    if result ~= nil then
        return result
    end
    if meta == nil then
        meta = getmetatable(self)
    end
    while true do
        result = rawget(meta, name)
        if result ~= nil then
            return result
        end
        local getters = rawget(meta, '___getters')
        if getters ~= nil then
            result = getters[name]
            if result ~= nil then
                return result(self)
            end
        end

        meta = rawget(meta, '___super')
        if meta == nil then
            return
        end
    end
end

local function newindex(self, name, value, meta)
    local v = objget(self, name)
    if v ~= nil then
        objset(self, name, value)
    end
    if meta == nil then
        meta = getmetatable(self)
    end
    while true do
        local setters = rawget(meta, '___setters')
        if setters ~= nil then
            local result = setters[name]
            if result ~= nil then
                result(self, value)
                return
            end
        end
        meta = rawget(meta, '___super')
        if meta == nil then
            objset(self, name, value)
            return
        end
    end
end

local function is_property(t)
    return type(t) == 'table' and type(t[1]) == 'function' and (#t==1 or (#t==2 and type(t[2]) == 'function'))
end

local function process_meta(meta)
    local new_meta = {}
    local getters = {}
    local setters = {}
    for k, v in pairs(meta) do
        if is_property(v) then
            getters[k] = v[1]
            setters[k] = v[2]
        else
            rawset(new_meta, k, v)
        end
    end
    rawset(new_meta, '___getters', getters)
    rawset(new_meta, '___setters', setters)
    return new_meta
end

local function find_native_class(meta)
    if meta.___lua == true then
        if meta.___super == nil then
            return
        end
        return find_native_class(meta.___super)
    else
        return meta
    end
end

local function class(name, super, meta)
    meta = process_meta(meta)
    if super ~= nil then
        meta.___super = super.___class
    end
    local type_name = string.format('class(%s)', name)
    meta.___lua = true
    meta.___native = find_native_class(meta)
    local native = meta.___native ~= nil

    -- auto-call super's gc
    local self_gc = meta.__gc
    function meta.__gc(self)
        if self_gc then
            self_gc(self)
        end
        if meta.___super ~= nil then
            rawget(meta.___super, '__gc')(self)
        end
    end

    local cls = {
        ___name = name,
        ___type = 'static_' .. type_name,
        ___class = meta,
        __call = function(_, ...)
            local obj
            if native then
                if meta.__new__ then
                    obj = meta.__new__(...)
                else
                    obj = meta.___native.class()
                end
                obj.metatable = meta
                obj.contain_children = true
                assert(type(obj) == 'userdata')
                setudmetatable(obj, meta)
            else
                obj = setmetatable({}, meta)
            end
            obj:__init__(...)
            return obj
        end
    }
    setmetatable(cls, cls)
    meta.class = cls
    meta.___type = type_name
    meta.__index = index
    meta.__newindex = newindex
    setmetatable(meta, {
        __index = meta.___super
    })
    return cls
end

local function mixin(...)
    local tt = {...}
    assert(#tt >= 1)
    local r = tt[#tt]
    if #tt == 1 then
        return r
    end
    for i, t in ipairs(tt) do
        if i < #tt then
            table.merge(r, t, false)
        end
    end
    return r
end

local function super(cls, obj)
    assert(cls.___class.___super ~= nil)
    return setmetatable({}, {
        __index = function(_, name)
            return index(obj, name, cls.___class.___super)
        end,
        __newindex = function(_, name, value)
            newindex(obj, name, value, cls.___class.___super)
        end,
    })
end

return {class, mixin, super, {
    index = index,
    newindex = newindex,
}}

end
        

package.preload[ "core.class" ] = function( ... )
    return require('core/class')
end
            

package.preload[ "core/constants" ] = function( ... )
-- constants.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-07-02
-- Description: Babe kernel Constants and Definition

--------------------------------------------------------------------------------
-- 常用常量
--
-- @module core.constants
-- @return #nil 
-- @usage require("core/constants")


---------------------------------------Anim---------------------------------------

--- anim完成后即停止。
kAnimNormal	= 0;
--- anim会无限重复。
kAnimRepeat	= 1;
--- anim完成一次后倒序一次，如此反复。
kAnimLoop	    = 2;
----------------------------------------------------------------------------------

---------------------------------------Res----------------------------------------
--format

--- RGBA8888（32位像素格式）。
kRGBA8888	= 0;
--- RGBA4444（16位像素格式）。
kRGBA4444	= 1;
--- RGBA5551（16位像素格式）。
kRGBA5551	= 2;
--- RGB565 （16位像素格式）。
kRGB565		= 3;

--filter

--- 最临近插值。
kFilterNearest	= 0;
--- 线性过滤。
kFilterLinear	= 1;
----------------------------------------------------------------------------------

---------------------------------------Prop---------------------------------------
--for rotate/scale

--- 用于PropRotate/PropScale，以drawing的左上角为中心点。
kNotCenter		= 0;
--- 以drawing中心点为中心。
kCenterDrawing	= 1;
--- 自定义中心点的位置，中心点的位置由坐标(x,y)决定。x,y的值是相对应drawing左上角的位置。
kCenterXY		= 2;
----------------------------------------------------------------------------------

--------------------------------------Align--------------------------------------

--- 居中对齐。
kAlignCenter		= 0;
--- 顶部居中对齐。
kAlignTop			= 1;
--- 右上角对齐。
kAlignTopRight		= 2;
--- 右部居中对齐。
kAlignRight	    = 3;
--- 右下角对齐。
kAlignBottomRight	= 4;
--- 下部居中对齐。
kAlignBottom		= 5;
--- 左下角对齐。
kAlignBottomLeft	= 6;
--- 左部居中对齐。
kAlignLeft			= 7;
--- 左上角对齐。
kAlignTopLeft		= 8;
---------------------------------------------------------------------------------

---------------------------------------Text---------------------------------------
--TextMulitLines

--- 单行文字。
kTextSingleLine	= 0;
--- 多行文字。
kTextMultiLines = 1;

--- 默认的字体名。
kDefaultFontName	= ""
--- 默认字号大小。
kDefaultFontSize 	= 24;

--- 默认文字颜色(红色分量)。
kDefaultTextColorR 	= 0;
--- 默认文字颜色(绿色分量)。
kDefaultTextColorG 	= 0;
--- 默认文字颜色(蓝色分量)。
kDefaultTextColorB 	= 0;
----------------------------------------------------------------------------------

---------------------------------------Touch--------------------------------------

--- 手指按下事件。
kFingerDown		= 0;
--- 手指移动事件。
kFingerMove		= 1;
--- 手指抬起事件。
kFingerUp		= 2;
--- 特殊事件。
kFingerCancel	= 3;
----------------------------------------------------------------------------------

---------------------------------------Focus--------------------------------------

--- 获得焦点。
kFocusIn 	= 0;
--- 失去焦点。
kFocusOut 	= 1;
----------------------------------------------------------------------------------

---------------------------------------Scroll-------------------------------------

--- scroller开始滚动。
kScrollerStatusStart	= 0;
--- scroller正在滚动。
kScrollerStatusMoving	= 1;
--- scroller停止滚动。
kScrollerStatusStop		= 2;
----------------------------------------------------------------------------------



-------------------------------------Bool values-----------------------------------

---对应c++的true。
kTrue 	= 1;
---对应c++的false。
kFalse 	= 0;
-----------------------------------------------------------------------------------


-------------------------------------Direction-------------------------------------

--- 水平方向(用于部分滚动类控件)。
kHorizontal 	= 1;
--- 竖直方向(用于部分滚动类控件)。
kVertical 		= 2;
-----------------------------------------------------------------------------------

---------------------------------------Platform------------------------------------
--ios

---480x320分辨率。
kScreen480x320		= "480x320"
---960x640分辨率。
kScreen960x640		= "960x640"
---1024x768分辨率。
kScreen1024x768	= "1024x768"
---2048x1536分辨率。
kScreen2048x1536	= "2048x1536"

--android

---1280x720分辨率。
kScreen1280x720	= "1280x720"
---1280x800分辨率。
kScreen1280x800	= "1280x800"
---1024x600分辨率。
kScreen1024x600	= "1024x600"
---960x540分辨率。
kScreen960x540		= "960x540"
---854x480分辨率。
kScreen854x480		= "854x480"
---800x480分辨率。
kScreen800x480		= "800x480"

--platform

--- ios平台(@{core.system#System.getPlatform}的返回值)
kPlatformIOS 		= "ios";
--- android平台(@{core.system#System.getPlatform}的返回值)
kPlatformAndroid 	= "android";
--- wp8平台(@{core.system#System.getPlatform}的返回值)
kPlatformWp8 		= "wp8";
--- win32平台(@{core.system#System.getPlatform}的返回值)
kPlatformWin32 		= "win32";
-----------------------------------------------------------------------------------



---------------------------------------Custom Blend--------------------------------

--- blend混合，见 [```drawing_set_blend_mode```](core.blend.html#drawing_set_blend_mode)
-- 
 
---取引擎默认的混合模式。不同情况下此取值可能不同。
kDefault  = 0;
---混合因子全置零。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kZero = 1;
---混合因子全置1。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kOne = 2;
---取源像素的Alpha作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kSrcAlpha = 3;
---取目标像素的Alpha作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kDstAlpha = 4;
---取（1-源像素的Alpha）作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kOneMinusSrcAlpha = 5;
---取（1-目标像素的Alpha）作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kOneMinusDstAlpha = 6;
---取源像素的RGB和Alpha作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kSrcColor = 7;
---取目标像素的RGB和Alpha作为混合因子。详见：[blend的公式。](http://engine.by.com:8080/hosting/data/1454473133632_6371758722883492571.html)
kDstColor = 8;

----------------------------------------------------------------------------------

----------------------------------Input ------------------------------------------

--- 文字输入：任意内容(不应完全依赖于这些控制，因为部分输入法不会严格遵循这些规则)
kEditBoxInputModeAny  		= 0;
--- 文字输入：email地址
kEditBoxInputModeEmailAddr	= 1;
--- 文字输入：数字
kEditBoxInputModeNumeric	= 2;
--- 文字输入：电话号码
kEditBoxInputModePhoneNumber= 3;
--- 文字输入：网址
kEditBoxInputModeUrl		= 4;
--- 文字输入：小数
kEditBoxInputModeDecimal	= 5;
--- 文字输入：单行任意内容
kEditBoxInputModeSingleLine	= 6;


--- 文字输入：密码
kEditBoxInputFlagPassword					= 0;
--- 文字输入：关闭输入法单词联想
kEditBoxInputFlagSensitive					= 1;
--- 文字输入：单词首字母大写
kEditBoxInputFlagInitialCapsWord			= 2;
--- 文字输入：句子子首字母大写
kEditBoxInputFlagInitialCapsSentence		= 3;
--- 文字输入：所有字母大写
kEditBoxInputFlagInitialCapsAllCharacters	= 4;


--- 输入法确定按键显示为：(输入法的默认设置，一般为确定).
-- 这些文字一般会在strings.xml文件内重新定义
kKeyboardReturnTypeDefault = 0;
--- 输入法确定按键显示为：(不显示此按键)
kKeyboardReturnTypeDone = 1;
--- 输入法确定按键显示为：发送
kKeyboardReturnTypeSend = 2;
--- 输入法确定按键显示为：搜索
kKeyboardReturnTypeSearch = 3;
--- 输入法确定按键显示为：开始
kKeyboardReturnTypeGo = 4;


-----------------------------------------------------------------------------------


------------------------------------Android Keys-----------------------------------

---android上的back键的key。
kBackKey="BackKey";
---android的home键的key。
kHomeKey="HomeKey";
---暂停程序。
kEventPause="EventPause";
---恢复程序。
kEventResume="EventResume";
---退出程序。
kExit="Exit";
-----------------------------------------------------------------------------------



----------------------------------模板测试参数取值相关--------------------------------


---表示这次绘制区域中的像素片段总是通过模板测试。
kGL_ALWAYS      = 0
---表示这次绘制区域中的像素片段永不通过模板测试。
kGL_NEVER 	     = 1
---参考值小于模板缓冲区的对应的值则通过模板测试。
kGL_LESS        = 2
---参考值小于等于模板缓冲区的对应的值则通过模板测试。
kGL_LEQUAL      = 3
---参考值大于模板缓冲区的对应的值则通过模板测试。
kGL_GREATER     = 4
---参考值大于等于模板缓冲区的对应的值则通过模板测试。
kGL_GEQUAL      = 5
---参考值等于模板缓冲区的对应的值则通过模板测试。
kGL_EQUAL       = 6
---参考值不等于模板缓冲区的对应的值则通过模板测试。
kGL_NOTEQUAL    = 7


---保持当前的模板值不变。
kGL_KEEP		   = 0
---将当前的模板值设为0。
kGL_ZERO		   = 1
---将当前的模板值设置为参考值。
kGL_REPLACE	   = 2
---在当前的模板值上加1。
kGL_INCR	       = 3
---在当前的模板值上减1。
kGL_DECR   	   = 4



---------------------------------------Http---------------------------------------
--http get/post

--- http请求类型：get
kHttpGet		= 0;
--- http请求类型：post
kHttpPost		= 1;
--- http返回类型(这是唯一可用的类型)
kHttpReserved	= 0;
end
        

package.preload[ "core.constants" ] = function( ... )
    return require('core/constants')
end
            

package.preload[ "core/dict" ] = function( ... )
-- dict.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for dict functions

------------------------------------------------------------------------------
-- Dict 用于存储数据(程序内临时使用、与java/c++之间传数据、保存到文件内供下次使用等).
--
-- @module core.dict 
-- @return #nil
-- @usage require("core/dict")
require("core/object");
require("core/constants");

---
--Dict是用于在游戏中存储数据的类.
-- 数据可以临时使用，也可以直接保存到文件内供下次启动游戏继续使用。数据已key-value的方式保存在文件中。
-- @type Dict
Dict = class();

---
-- 构造函数.
-- 
-- win32下生成的文件在$(SolutionDir)/Resource/dict/中。
-- Android下生成的文件存储在SDCard/{package_name}/dict/中,以隐藏文件的形式存在。
-- 在Android中存储在扩展卡中，如果扩展卡不能访问应用程序将无法访问此文件。
-- 
-- @param self，调用者本身。
-- @param #string dictName dict的名字。此名字必全局唯一。
Dict.ctor = function(self, dictName)
	self.m_name = dictName;
end

---
-- 析构函数.
-- 
-- 只会释放Lua的的对象，不会删除本地文件。
-- @param self，调用者本身。
Dict.dtor = function(self)
	self.m_name = nil;
end

---
-- 从文件内加载上次保存的内容.
--
-- @param self，调用者本身。
Dict.load = function(self)
	return dict_load(self.m_name);
end

---
-- 将内容保存到文件内，以便下次启动程序还可以再取出.
-- 
-- @param self，调用者本身。
Dict.save = function(self)
	return dict_save(self.m_name);
end

---
-- 删除该dict的所有数据.
--
-- @param self，调用者本身。
Dict.delete = function(self)
	return dict_delete(self.m_name);
end

---
-- 存入一个boolean值.
--
-- @param self，调用者本身。
-- @param #string key 键(必须是一个合法的变量命名。必须是字母开头)。
-- @param #boolean value 值(除nil与false外其余都为存储为true)。
Dict.setBoolean = function(self, key, value)
	return dict_set_int(self.m_name,key,value and kTrue or kFalse);
end

---
-- 取出一个boolean值.
--
-- @param self，调用者本身。
-- @param #string key 键。
-- @param #boolean defaultValue 如果不存在此key，则返回defaultValue。
-- @return #boolean 如果key存在则返回对应的值，如果key值对应的值不存在且defaultValue为nil或false则返回为false，其余值返回true。 
Dict.getBoolean = function(self, key, defaultValue)
	local ret =  dict_get_int(self.m_name,key,defaultValue and kTrue or kFalse);
	return (ret == kTrue);
end

---
-- 存入一个int值.
--
-- @param self，调用者本身。
-- @param #string key 键(必须是一个合法的变量命名。必须是字母开头)。
-- @param #number value 值(必须是整型)。
Dict.setInt = function(self, key, value)
	return dict_set_int(self.m_name,key,value);
end

---
-- 取出一个int值.
-- 
-- @param self，调用者本身。
-- @param #string key 键。
-- @param #number defaultValue 如果不存在，则返回此默认值。
-- @return #number 值(整型)。如果不存在则返回defaultValue，如果defaultValue为nil，则返回0。
Dict.getInt = function(self, key, defaultValue)
	return dict_get_int(self.m_name,key,defaultValue or 0);
end

---
-- 存入一个double值. 
--
-- @param self，调用者本身。
-- @param #string key 键(必须是一个合法的变量命名。必须是字母开头)。
-- @param #number value 值(必须是number或者是可以转换为number的string)。
Dict.setDouble = function(self, key, value)
	return dict_set_double(self.m_name,key,value);
end

---
-- 取出一个double值. 
-- 
-- @param self，调用者本身。
-- @param #string key 键。
-- @param #number defaultValue 如果不存在，则返回此默认值。
-- @return #number 值(number)。如果不存在则返回defaultValue，如果defaultValue为nil，则返回0.0。
Dict.getDouble = function(self, key, defaultValue)
	return dict_get_double(self.m_name,key,defaultValue or 0.0);
end

---
-- 存入一个string值. 
--
-- @param self，调用者本身。
-- @param #string key 键(必须是一个合法的变量命名。必须是字母开头)。
-- @param #string value 值(必须是string或者是number)。
Dict.setString = function(self, key, value)
	return dict_set_string(self.m_name,key,value);
end

---
-- 取出一个string值. 
--
-- @param self，调用者本身。
-- @param #string key 键。
-- @return #string 取到的值，如果不存在，则返回""。
Dict.getString = function(self, key)
	return dict_get_string(self.m_name,key) or "";
end


---
--更改Dict文件夹下文件的后缀为extensionName.(接口不稳定，不建议使用)  
--每次调用Dict.setFileExtension将覆盖之前的调用.
--若加载的Dict文件（例如xxx.t)存在，则将该文件内容迁移到xxx.extensionName,  
--同时保留xxx.t.
--若加载文件不存在，则创建新文件.
--@param #string extensionName 新的后缀.
Dict.setFileExtension =  function (extensionName)
    dict_set_fileextension(extensionName)
end
end
        

package.preload[ "core.dict" ] = function( ... )
    return require('core/dict')
end
            

package.preload[ "core/drawing" ] = function( ... )
require("core/object");
require("core/constants");
require("core/anim");
require("core/prop");
require("core/system");
require("core/global");
local AL = require 'byui/autolayout'

local function table_remove(tbl, vv)
    for i, v in ipairs(tbl) do
        if v == vv then
            table.remove(tbl, i)
            break
        end
    end
end

DrawingBaseMixin = {
    ctor = function(self)
        self:initId()
        self.m_drawingID = self:getId()
        self.m_pickable = true
        self.m_eventCallbacks = {
            touch = {},
            drag = {},
            doubleClick = {},
        }
        self.m_props = {}
		self._animations = {}
    end,
    dtor = function(self)
        for k,v in pairs(self.m_props) do 
            delete(v["prop"]);
            for _,anim in pairs(v["anim"]) do 
                delete(anim);
            end
        end

        --This is safe, only because the drawing is going to release;
        --Otherwise it should remove the prop first then release it.
        delete(self.m_doubleClickAnim);
        self.m_doubleClickAnim = nil;

        for _,v in ipairs(self.children) do 
            delete(v);
        end

        self.m_touchEventCallbacks = {
            touch = {};
            drag = {};
            doubleClick = {};
        };

		self:stopAllAnimations()

        --This drawing_delete should actually be in derivded class dtor,
        --It is here because the children release.
        --It is ugly but useful,so keep it for now.
        drawing_delete(self.m_drawingID);
        --drawing_free_id(self.m_drawingID);
    end,

    setPickable = function(self, pickable, iLeftMargin, iRightMargin, iTopMargin, iBottomMargin)
        self.m_pickable = pickable

        if iLeftMargin then 
            drawing_set_pickable(
                self.m_drawingID,
                pickable and kTrue or kFalse,
                iLeftMargin or 0,
                iRightMargin or 0,
                iTopMargin or 0,
                iBottomMargin or 0
            )
        else
            drawing_set_pickable(self.m_drawingID,
                pickable and kTrue or kFalse,
                0,0,0,0
            )
        end 
    end,

    getPickable = function(self)
        return self.m_pickable
    end,

    setEventTouch = function(self, obj, func)
        drawing_set_touchable(
            self.m_drawingID,
            (func or self.m_registedDoubleClick) and kTrue or kFalse, 
            self,
            DrawingBaseMixin.touchEventHandler
        )

        self.m_eventCallbacks.touch.obj = obj
        self.m_eventCallbacks.touch.func = func
    end,
    setEventDrag = function(self, obj, func)
        drawing_set_dragable(
            self.m_drawingID,
            func and kTrue or kFalse,
            self,
            DrawingBaseMixin.onEventDrag
        )
        self.m_eventCallbacks.drag.obj = obj
        self.m_eventCallbacks.drag.func = func
    end,
    setEventDoubleClick = function(self, obj, func)
        self.m_registedDoubleClick = func and true or false

        self.m_eventCallbacks.doubleClick.obj = obj
        self.m_eventCallbacks.doubleClick.func = func

        drawing_set_touchable(
            self.m_drawingID,
            (self.m_eventCallbacks.touch.func or self.m_registedDoubleClick) and kTrue or kFalse, 
            self,
            self.touchEventHandler
        )
    end,
    setVisible = function(self, visible)
        self.visible = visible
    end,
    getVisible = function(self)
        return self.visible
    end,
    setLevel = function(self, level)
        self.zorder = level or self.m_level
    end,
    getLevel = function(self)
        return self.zorder
    end,
    setName = function(self, name)
        self.name = name
    end,
    getName = function(self)
        return self.name
    end,
    getFullName = function(self)
        return DrawingBaseMixin.getRelativeName(self, nil)
    end,
    getRelativeName = function(self, relativeRoot)
        local ret = {}
        local drawing = self
        while drawing and drawing ~= relativeRoot do 
            ret[#ret+1] = drawing:getName()
            drawing = drawing:getParent()
        end

        if drawing ~= relativeRoot then
            return nil
        end

        if relativeRoot then
            ret[#ret+1] = relativeRoot:getName()
        end

        local nNames = #ret
        for i=1,math.floor(nNames/2) do 
            ret[i],ret[nNames+1-i] = ret[nNames+1-i],ret[i]
        end

        return ret
    end,
    addChild = function(self, child)
        if not child then
            return
        end

        self:add(child)
    end,
    removeChild = function(self, child, doCleanup)
        if not child then
            return false
        end
        self:remove(child)
        if doCleanup then
            delete(child)
            child = nil
        end
        return true
    end,
    removeAllChildren = function(self, doCleanup)
        doCleanup = (doCleanup == nil) or doCleanup; -- default is true

        local allChildren = {}
        for _,v in pairs(self.children) do 
            DrawingBaseMixin.removeChild(self,v)
            if doCleanup then
                delete(v)
            else
                allChildren[#allChildren+1] = v
            end
        end
        if not doCleanup then
            return allChildren
        end
    end,
    getParent = function(self)
        return self.parent
    end,
    getChildren = function(self)
        return self.children
    end,
    addToRoot = function(self)
        Widget.get_by_id(0):add(self)
    end,
    setEventMsgChain = function(self, obj, func)
        self.on_msg_chain = function(...)
            func(obj, ...)
        end
    end,
    setForceMatrix = function (self, m00, m01, m02, m03,
                                     m10, m11, m12, m13,
                                     m20, m21, m22, m23,
                                     m30, m31, m32, m33)
        local m = Matrix()
        m:load(m00, m01, m02, m03,
               m10, m11, m12, m13,
               m20, m21, m22, m23,
               m30, m31, m32, m33)
        self.user_matrix = m
    end,
    setPreMatrix =function (self, m00, m01, m02, m03,
                                  m10, m11, m12, m13,
                                  m20, m21, m22, m23,
                                  m30, m31, m32, m33)
        local m = Matrix()
        m:load(m00, m01, m02, m03,
               m10, m11, m12, m13,
               m20, m21, m22, m23,
               m30, m31, m32, m33)
        self.pre_matrix = m
    end,
    setPostMatrix =function (self, m00, m01, m02, m03,
                                   m10, m11, m12, m13,
                                   m20, m21, m22, m23,
                                   m30, m31, m32, m33)
        local m = Matrix()
        m:load(m00, m01, m02, m03,
               m10, m11, m12, m13,
               m20, m21, m22, m23,
               m30, m31, m32, m33)
        self.post_matrix = m
    end,
    setParent = function(self, parent)
        self.parent = parent
    end,
    touchEventHandler = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
        if not self.m_registedDoubleClick then 
            --continue the event routing or not 
            DrawingBaseMixin.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
            return
        end

        --Double click considered
        if finger_action == kFingerDown then 
            --retain the down pos
            self.m_touching = true

            self.m_touchDownX = x
            self.m_touchDownY = y

            --start timing the double click event
            if not self.m_doubleClickAnim then 
                self.m_doubleClickAnim = new(AnimInt,kAnimNormal,0,1,500)
                self.m_doubleClickAnim:setEvent(self,self.onDoubleClickEnd)
                self.m_douleClickDelayTimes = 0
            end
            --respond the touch event and test if continue the event routing or not

            DrawingBaseMixin.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)

        else
            if not self.m_touching then
                return
            end

            -- retain the last pos
            self.m_lastTouchX = x
            self.m_lastTouchY = y

            -- if move the touch pos ,then not double click
            if math.abs(self.m_touchDownX - x) > 10 
                or math.abs(self.m_touchDownY - y) > 10 then
                delete(self.m_doubleClickAnim)
                self.m_doubleClickAnim = nil
            end

            --if not double click ,response the move event
            if not self.m_doubleClickAnim then 
                DrawingBaseMixin.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
            end

            --if not move ,then up or cancle
            if finger_action ~= kFingerMove then
                -- retain the touch stuff
                self.m_touching = false

                self.m_lastTouchX = x
                self.m_lastTouchY = y
                self.m_lastDrawing_id_first = drawing_id_first
                self.m_lastDrawing_id_current = drawing_id_current
                self.m_lastTouchEventTime = event_time

                if self.m_doubleClickAnim then 
                    self.m_douleClickDelayTimes = self.m_douleClickDelayTimes + 1

                    --test double or not
                    if self.m_douleClickDelayTimes > 1 then
                        if drawing_id_first == drawing_id_current then 
                            DrawingBaseMixin.onEventDoubleClick(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
                        end
                        self.m_douleClickDelayTimes = 0
                        delete(self.m_doubleClickAnim)
                        self.m_doubleClickAnim = nil
                    end
                end
            end
        end
    end,
    onEvent = function(self, eventType, ...)
        local eventCallback = self.m_eventCallbacks[eventType]
        if eventCallback and eventCallback.func then 
            return eventCallback.func(eventCallback.obj,...)
        else -- this else branch is only for "continue touch",for others the return value has no meanings
            return true
        end
    end,
    onEventDoubleClick = function(self, finger_action, x, y, drawing_id, event_time)
        DrawingBaseMixin.onEvent(self,"doubleClick",finger_action,x,y,drawing_id, event_time)
    end,
    onDoubleClickEnd = function(self)
        delete(self.m_doubleClickAnim)
        self.m_doubleClickAnim = nil
        --if not catch the double click ,then response a touch up event
        if self.m_douleClickDelayTimes > 0 then 
            DrawingBaseMixin.onEventTouch(self,kFingerUp,self.m_lastTouchX,self.m_lastTouchY,self.m_lastDrawing_id_first,self.m_lastDrawing_id_current, self.m_lastTouchEventTime)
        end
    end,
    onEventDrag = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
        DrawingBaseMixin.onEvent(self,"drag",finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
    end,
    onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
        return DrawingBaseMixin.onEvent(self,"touch",finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
    end,
    addAnimProp = function(self, sequence, propClass, center, x, y, animType, duration, delay, ...)
        if not DrawingBaseMixin.checkAddProp(self,sequence) then 
            self:removeProp(sequence)
        end

        delay = delay or 0

        local nAnimArgs = select("#",...)
        local nAnims = math.floor(nAnimArgs/2)

        local anims = {}

        for i=1,nAnims do 
            local startValue,endValue = select(i*2-1,...)
            anims[i] = DrawingBaseMixin.createAnim(self,animType,duration,delay,startValue,endValue)
        end

        if nAnims == 1 then
            local prop = new(propClass,anims[1],center,x,y)
            if DrawingBaseMixin.doAddProp(self,prop,sequence,anims[1]) then
                return anims[1]
            end
        elseif nAnims == 2 then
            local prop = new(propClass,anims[1],anims[2],center,x,y)
            if DrawingBaseMixin.doAddProp(self,prop,sequence,anims[1],anims[2]) then
                return anims[1],anims[2]
            end
        elseif nAnims == 3 then
            local prop = new(propClass,anims[1],anims[2],anims[3],center,x,y)
            if DrawingBaseMixin.doAddProp(self,prop,sequence,anims[1],anims[2],anims[3]) then
                return anims[1],anims[2],anims[3]
            end
        elseif nAnims == 4 then
            local prop = new(propClass,anims[1],anims[2],anims[3],anims[4],center,x,y)
            if DrawingBaseMixin.doAddProp(self,prop,sequence,anims[1],anims[2],anims[3],anims[4]) then
                return anims[1],anims[2],anims[3],anims[4]
            end
        else
            for _,v in pairs(anims) do 
                delete(v)
            end
            error("There is not such a prop that requests more than 4 anims")
        end
    end,
    addSolidProp = function(self, sequence, propClass, ...)
        if not DrawingBaseMixin.checkAddProp(self,sequence) then 
            return
        end

        local prop = new(propClass, ...)
        DrawingBaseMixin.doAddProp(self,prop,sequence)
    end,
    createAnim = function(self, animType, duration, delay, startValue, endValue)
        local anim
        if startValue and endValue then
            anim = new(AnimDouble,animType,startValue,endValue,duration,delay)
            return anim
        end
    end,
    checkAddProp = function(self, sequence)
        if self.m_props[sequence] then
            return false
        end
        return true
    end,
    doAddProp = function(self, prop, sequence, ...)
        local anims = {select(1,...)}
        if DrawingBaseMixin.addProp(self,prop,sequence) then 
            self.m_props[sequence] = {["prop"] = prop;["anim"] = anims}
            return true
        else
            delete(prop)
            for _,v in pairs(anims) do 
                delete(v)
            end
            return false
        end
    end,
    addProp = function(self, prop, sequence)
        local ret = drawing_prop_add(self.m_drawingID, prop:getID(), sequence)
        return ret == 0
    end,
    removeProp = function(self, sequence)
        if drawing_prop_remove(self.m_drawingID, sequence) ~= 0 then
            return false
        end

        if self.m_props[sequence] then
            delete(self.m_props[sequence]["prop"])
            for _,v in pairs(self.m_props[sequence]["anim"]) do 
                delete(v)
            end
            self.m_props[sequence] = nil
        end
        return true
    end,
    removePropByID = function(self, propId)
        if drawing_prop_remove_id(self.m_drawingID, propId) ~= 0 then
            return false
        end

        for k,v in pairs(self.m_props) do 
            if v["prop"]:getID() == propId then
                delete(v["prop"])
                for _,anim in pairs(v["anim"]) do 
                    delete(anim)
                end
                self.m_props[k] = nil
                break
            end
        end

        return true
    end,
    addPropColor = function(self, sequence, animType, duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd)
        return DrawingBaseMixin.addAnimProp(self,sequence,PropColor,nil,nil,nil,animType,duration,delay,rStart,rEnd,gStart,gEnd,bStart,bEnd)
    end,
    addPropTransparency = function(self, sequence, animType, duration, delay, startValue, endValue)
        return DrawingBaseMixin.addAnimProp(self,sequence,PropTransparency,nil,nil,nil,animType,duration,delay,startValue,endValue)
    end,
    addPropTranslate = function(self, sequence, animType, duration, delay, startX, endX, startY, endY)
        startX = startX or startX
        endX = endX or endX
        startY = startY or startY
        endY = endY or endY
        return DrawingBaseMixin.addAnimProp(self,sequence,PropTranslate,nil,nil,nil,animType,duration,delay,startX,endX,startY,endY)
    end,
    addPropRotate = function(self, sequence, animType, duration, delay, startValue, endValue, center, x, y)
        return DrawingBaseMixin.addAnimProp(self,sequence,PropRotate,center, x, y,animType,duration,delay,startValue,endValue)
    end,
    addPropScale = function(self, sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y)
        return DrawingBaseMixin.addAnimProp(self,sequence,PropScale,center, x, y,animType,duration,delay,startX,endX,startY,endY)
    end,
    addPropTranslateSolid = function(self, sequence, x, y)
        DrawingBaseMixin.addSolidProp(self,sequence,PropTranslateSolid,x,y)
    end,
    addPropRotateSolid = function(self, sequence, angle360, center, x, y)
        DrawingBaseMixin.addSolidProp(self,sequence,PropRotateSolid,angle360,center,x,y)
    end,
    addPropScaleSolid = function(self, sequence, scaleX, scaleY, center, x, y)
        DrawingBaseMixin.addSolidProp(self,sequence,PropScaleSolid,scaleX, scaleY,center,x,y)
    end,
    setColor = function(self, r, g, b)
        self.colorf = Colorf(r/255,g/255,b/255)
    end,
    getColor = function(self)
        local c = self.colorf
        if c == nil then
            return 255,255,255
        else
            return c.r * 255, c.g * 255, c.b * 255
        end
    end,
    setTransparency = function(self, val)
        self.opacity = val
    end,
    getTransparency = function(self)
        return self.opacity
    end,
    setClip = function(self, x, y, w, h)
        _drawing_set_clip_rect_parent_based(self.m_drawingID, x,y,w,h)
    end,
    setClip2 = function(self, enable, x, y, w, h)
        drawing_set_clip_rect(self.m_drawingID, enable and 1 or 0, 
        x,y,w,h)
    end,
    setDebugName = function(self, name)
        self.m_debugName = name;
        drawing_set_debug_name(self.m_drawingID,name or "");
    end,
    getDebugName = function(self)
        return self.m_debugName;
    end,
    animate = function(self, action, on_stop)
        local Anim = require('animation')
        local anim = Anim.Animator(action, Anim.updator(self))
        table.insert(self._animations, anim)
        anim.on_stop = function()
            table_remove(self._animations, anim)
            if on_stop then
                on_stop(self, anim)
            end
        end
        anim:start()
        return anim
    end,
    stopAllAnimations = function(self)
        local anims = self._animations
        self._animations = {}
        for _, anim in ipairs(anims) do
            anim:stop()
        end
    end
}

DrawingBase = class(Drawing.___class)
table.merge(DrawingBase, DrawingBaseMixin, false)
DrawingBase.ctor = function(self)
    DrawingBaseMixin.ctor(self)
end

LuaNode = class(LuaWidget.___class)
table.merge(LuaNode, DrawingBaseMixin, false)
LuaNode.ctor = function(self)
    DrawingBaseMixin.ctor(self)
end

DrawingImage = class(DrawingBase)
DrawingImage.ctor = function(self, res, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_res = res
    self.m_resID = res:getID()
    DrawingImage.setSize(self, res:getWidth(), res:getHeight())

    self.m_isGrid9 = (leftWidth or rightWidth or bottomWidth or topWidth) and true or false

    local realWidth,realHeight = DrawingImage.getRealSize(self)
    if self.m_isGrid9 then
        local b = { leftWidth or 0,
                    topWidth or 0,
                    rightWidth or 0,
                    bottomWidth or 0
                  }
        self:set9grid(b, b)
    end

    self:AddBitmap(0, self.m_resID);
    DrawingImage.setResRect(self, 0, res)
    DrawingImage.setResTrimAndRotate(self, 0, res)
end

DrawingImage.setImageIndex = function(self, idx)
    drawing_set_image_index(self.m_drawingID, idx)
end
DrawingImage.addImage = function(self, res, index)
    drawing_set_image_add_image(self.m_drawingID, res:getID(), index)
    DrawingImage.setResRect(self,index,res)
    DrawingImage.setResTrimAndRotate(self,index,res);
end
DrawingImage.removeImage = function(self, index)
    drawing_set_image_remove_image(self.m_drawingID, index)
end
DrawingImage.removeAllImage = function(self)
    drawing_set_image_remove_all_images(self.m_drawingID)
end
DrawingImage.dtor = function(self)
    --drawing_delete(self.m_drawingID)
end
DrawingImage.setResRect = function(self, index, res)
    if typeof(res,ResImage) then
        local subTexX,subTexY,subTexW,subTexH = res:getSubTextureCoord();                                                    
        if subTexX and subTexY and subTexW and subTexH then 
            drawing_set_image_res_rect(self.m_drawingID,index,subTexX,subTexY,subTexW,subTexH)
        else
            local width,height = res:getWidth(),res:getHeight()
            drawing_set_image_res_rect(self.m_drawingID,index,0,0,width,height)
        end
    end
end

---
-- (设置一个位图资源应该被用来显示的的部分。主要用在经过拼图的图片.)
-- 是对DrawingImage.setResRect 的补充，为了支持拼图的Trim 和 Rotate 模式
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
-- 
-- @param self
-- @param core.res#ResImage res 图片资源。
DrawingImage.setResTrimAndRotate = function(self,res)
    if typeof(res,ResImage) then
        local _,_,subTexW,subTexH,subOffsetX,subOffsetY,subTexUtW,subTexUtH,subTexRotated = res:getSubTextureCoord();
        if subTexRotated ~= nil then
            drawing_set_rotated(self.m_drawingID,index,subTexRotated);
        end
        if subTexW and subTexH and subOffsetX and subOffsetY and subTexUtW and subTexUtH then
            if subTexRotated == true then
                drawing_set_trim_border(self.m_drawingID, index, subOffsetX, subOffsetY,
                    subTexUtW - subTexH - subOffsetX,
                    subTexUtH - subTexW - subOffsetY)
            else
                drawing_set_trim_border(self.m_drawingID, index, subOffsetX, subOffsetY,
                    subTexUtW - subTexW - subOffsetX,
                    subTexUtH - subTexH - subOffsetY)
            end
        end
    end
end
DrawingImage.setResRectPlain = function(self, index, x, y, w, h)
    if x and y and w and h then 
        drawing_set_image_res_rect(self.m_drawingID,index,x,y,w,h)
    end
end
DrawingImage.setMirror = function(self,mirrorX,mirrorY)
    if type(mirrorX)~= "boolean" or type(mirrorY)~= "boolean" then
        error("ERROR type is not boolean")
    end

    return  drawing_set_mirror(self.m_drawingID,mirrorX==true and kTrue or kFalse,mirrorY==true and kTrue or kFalse)>0
end
DrawingImage.setShader = function (self,shaderId)
    assert(false, 'invalid api')
end

DrawingEmpty = class(DrawingBase)
DrawingEmpty.ctor = function(self)
end

end
        

package.preload[ "core.drawing" ] = function( ... )
    return require('core/drawing')
end
            

package.preload[ "core/eventDispatcher" ] = function( ... )
-- evnetDispatcher.lua
-- Author: Vicent.Gong
-- Date: 2012-07-11
-- Last modification : 2013-05-29
-- Description: Implemented a evnet dispatcher to handle default event.

--------------------------------------------------------------------------------
-- 一个全局的事件分发的消息系统，为了支持不同模块或子模块之间的无耦合或弱耦合通信.
-- 
-- 对事件的发生感兴趣的可以注册这个事件的消息，此事件发生会进行消息派发，注册过此事件的会响应这个消息。
-- 
-- 概念介绍：
-- ---------------------------------------------------------------------
-- **1.事件类型**
-- 
-- * 预定义类型：系统已经定义好的，由系统分发的事件。详见：@{#Event}。
-- 
-- * 自定义类型：客户端自己定义的消息类型，客户端的不同模块分别负责分发和接收。
-- 
-- 
-- @module core.eventDispatcher
-- @return #nil 
-- @usage require("core/eventDispatcher")

require("core/object");
require("core/global");

---
-- 预定义事件.
-- 
-- @type Event
Event = {
	---
	-- 手指事件。详见：[`event_touch_raw`](core.systemEvent.html#event_touch_raw)。
    RawTouch    = 1,
    ---
    -- 收到native层的调用，用于原生代码和lua代码通信。详见：[`event_call`](core.systemevent.html#event_call)。
	Call    	= 2,
	---
	-- 键盘按下事件。
	KeyDown    	= 3,
	---
	-- 程序进入后台。(如跳转到别的程序，或按home键回到桌面。)
	Pause 		= 4,
	---
	-- 程序进入前台。(重新回到游戏。)
	Resume 		= 5,
    ---
    -- 暂未使用。
    Set         = 6,
    ---
    -- 暂未使用。
    Network     = 7,
    ---
    -- 按下返回键。
    Back        = 8,
    ---
    -- 系统定时器到达。
    Timeout     = 9,
    ---
    -- 结束标识。
    End         = 10,
};

---
-- 事件状态.
-- @type EventState
EventState = 
{
	---
	-- 事件将被移除
	RemoveMarked = 1,
};

local s_instance = nil

---
-- 用于派发和接收消息.
-- @type EventDispatcher
EventDispatcher = class();

---
-- 获取单例，@{#EventDispatcher}所包含的接口都要通过获取其相应的实例之后来调用.
--
-- @return #EventDispatcher 唯一实例。
EventDispatcher.getInstance = function()
	if not s_instance then 
		s_instance = new(EventDispatcher);
	end
	return s_instance;
end

---
-- 释放单例.
-- 请留意：如果调用过此方法，之后再使用getUserEvent来生成事件ID，生成的ID会和释放单例之前生成的出现重复。
EventDispatcher.releaseInstance = function()
	delete(s_instance);
	s_instance = nil;
end

---
-- 构造函数.
EventDispatcher.ctor = function(self)
	self.m_listener = {};
	self.m_tmpListener = {};
	self.m_userKey = Event.End;
end

---
-- 生成一个事件ID.
-- 在定义事件名时可以使用此方法来生成一个唯一的事件id。
-- 事件id是一个整型。
--
-- @paran self
-- @return #number ID 唯一的事件ID。
EventDispatcher.getUserEvent = function(self)
	self.m_userKey = self.m_userKey + 1;
	return self.m_userKey;
end

---
-- 注册消息.
-- 
-- 调用此方法后，当事件出现时，回调函数会得到调用。
-- 
-- **如果在事件处理函数里再调用此方法来注册其他事件，则会等到这次事件完全传播完成后才会生效。**
--
-- @param self
-- @param #number event 事件名 建议使用 @{#EventDispatcher.getUserEvent} 来生成。
-- @param obj 任何对象。在回收到事件通知时传回此对象。
-- @param #function func 事件的回调函数。传入参数为 (obj, ...) 其中...为分发时传入的其他参数。
EventDispatcher.register = function(self, event, obj, func)
	local arr;
	if self.m_dispatching then
		self.m_tmpListener[event] = self.m_tmpListener[event] or {};
		arr = self.m_tmpListener[event];
	else
		self.m_listener[event] = self.m_listener[event] or {};
		arr = self.m_listener[event];
	end
	
	arr[#arr+1] = {["obj"] = obj,["func"] = func,};
end

---
-- 清除注册事件.
-- 必须当obj和func都和注册事件时的相同时，才会取消注册。
-- 也就是说，可使用同一个函数与不同的obj配合注册多次。
-- 如：
--
--		local event = EventDispatcher.getInstance():getUserEvent()
--		local function eventResolver(obj,...)
--		
--		end
--		
--		local objA = {}
--		local objB = {}
--		EventDispatcher.getInstance():register(event, objA, eventResolver)
--		EventDispatcher.getInstance():register(event, objB, eventResolver)
--		EventDispatcher.getInstance():unregister(event, objA, eventResolver) -- 此步操作后，objB注册的事件依然有效
--
-- @param self
-- @param #number event 事件ID。
-- @param obj 注册事件时传入的obj。
-- @param #function func 注册事件时传入的回调函数。
EventDispatcher.unregister = function(self, event, obj, func)
	if not self.m_listener[event] then return end; 

	local arr = self.m_listener[event] or {};
	--for k,v in pairs(arr) do 
	for i=1,table.maxn(arr) do 
		local listerner = arr[i];
		if listerner then
			if (listerner["func"] == func) and (listerner["obj"] == obj) then 
				arr[i].mark = EventState.RemoveMarked;
				if not self.m_dispatching then
					arr[i] = nil;
				end

				--don't break so fast now,take care of the dump event listener
				--return
			end
		end
	end
end

---
-- 派发消息事件.
-- 
-- @param self
-- @param #number event 事件ID。
-- @param ... 其他需要携带的参数，这些参数会传给@{#EventDispatcher.register}所注册的事件的回调函数。
-- @return #boolean 如果有此事件的接收者，并且所有处理函数都返回了true，则dispatch方法返回true。可以用来标识是否有回调函数实际响应这个消息。
EventDispatcher.dispatch = function(self, event, ...)
	if not self.m_listener[event] then return end;

	self.m_dispatching = true;

	local ret = false;
	local listeners = self.m_listener[event] or {};
	--for _,v in pairs(listeners) do 
	for i=1,table.maxn(listeners) do 
		local listener = listeners[i]
		if listener then
			if listener["func"] and  listener["mark"] ~= EventState.RemoveMarked then 
				ret = ret or listener["func"](listener["obj"],...);
			end
		end
	end

	self.m_dispatching = false;

	EventDispatcher.cleanup(self);

	return ret;
end

---
-- 完成在“发送事件期间”注册的事件的添加操作，并移除在此期间被移除的事件.
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self
EventDispatcher.cleanup = function(self)
	for event,listeners in pairs(self.m_tmpListener) do 
		self.m_listener[event] = self.m_listener[event] or {};
		local arr = self.m_listener[event];
		--for k,v in pairs(listeners) do 
		for i=1,table.maxn(listeners) do 
			local listener = listeners[i];
			if listener then
				arr[#arr+1] = listener;
			end
		end
	end

	self.m_tmpListener = {};

	for _,listeners in pairs(self.m_listener) do
		--for k,v in pairs(listeners) do 
		for i=1,table.maxn(listeners) do 
			local listener = listeners[i];
			if listener and (listener.mark == EventState.RemoveMarked or listener.func == nil) then 
				listeners[i] = nil;
			end
		end
	end
end

---
-- 析构函数
EventDispatcher.dtor = function(self)
	self.m_listener = nil;
end

end
        

package.preload[ "core.eventDispatcher" ] = function( ... )
    return require('core/eventDispatcher')
end
            

package.preload[ "core/gameString" ] = function( ... )
-- gameString.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for game string handler

--------------------------------------------------------------------------------
-- 用于文字国际化和一些编码转换.
--
-- @module core.gameString
-- @return #nil
-- @usage require("core.gameString")


require("core.object");
require("core.system")

---
-- @type GameString
GameString = class();

local s_platform = System.getPlatform();
local s_win32Code = "utf-8";

---
-- 设置win32环境下的文字编码.
-- 如果在win32下出现中文乱码，可尝试使用此来解决。
--
-- @param #string win32Code 编码格式。
GameString.setWin32Code = function(win32Code)
  s_win32Code = win32Code or s_win32Code;
end

---
-- 加载一个string文件.
-- string文件中写有游戏里需要用到的文字，所有文字全部都是全局变量，如：
--
--		login_btn_text = "登录"
--		title_money = "金币"
--
--
-- @param #string filename lua文件名。
-- @param #string lang 语言类型。如果lang为nil，在win32平台下，编码格式为```'gbk'```时，则会将语言指定为 ```zw```；
-- 否则，则会使用System.getLanguage()获得的语言。
--
-- 如传入`("text/string", "zh")`，则会加载`text/string_zh.lua`文件。
GameString.load = function(filename, lang)
  if not lang then
    if s_platform == kPlatformWin32 and s_win32Code == "gbk" then
      lang = "zw";
    else
      lang = System.getLanguage();
    end
  end

  local languageLuaFile = string.format("%s_%s",filename,lang);
  if pcall(require,languageLuaFile) == false then
    if pcall(require,filename) == false then
      error("load string file failed, not default string file exist");
    end
  end
end

---
-- 通过key得到文字字符串.
--
-- @param #string key  键值字符串。
GameString.get = function(key)
  local str= _G[key];
  return str;
end

---
-- 将字符串转换为utf8编码.
--
-- @param #string str 源字符串。
-- @param #string sourceCode 源字符串的编码格式。
-- @return #string 转换为UTF8编码的字符串。
GameString.convert2UTF8 = function(str, sourceCode)
  if not sourceCode then
    if s_platform == kPlatformWin32 then
      sourceCode = s_win32Code;
    else
      sourceCode = "utf-8";
    end
  end

  if sourceCode == "utf-8" then
    return str;
  else
    return string_encoding(sourceCode,"utf-8",str);
  end
end



GameString.convert2Platform = function(str, sourceCode)
  sourceCode = sourceCode or "utf-8";
  local platformCode = (s_platform == kPlatformWin32) 
              and s_win32Code or "utf-8";

  if sourceCode == platformCode then
    return str;
  else
    return string_encoding(sourceCode,platformCode,str);
  end
end

end
        

package.preload[ "core.gameString" ] = function( ... )
    return require('core/gameString')
end
            

package.preload[ "core/global" ] = function( ... )
-- global.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-30
-- Description: provide some global functions

--------------------------------------------------------------------------------
-- 一些常用的全局函数。
--
-- @module core.global
-- @return #nil
-- @usage require("core.global")


---
-- 完全等同于print_string.
-- 用于打印日志。
--
-- @param #string logStr 日志信息。
FwLog = function(logStr)
  print_string(logStr);
end

---
-- 深度拷贝.
-- 如果是table类型，则会深度拷贝，包括metatable也会被拷贝一份。
--
-- @param t 任意类型。
-- @return t的拷贝。
Copy = function(t)
  local lookup_table = {}

  local  function _copy(t)
    if type(t) ~= "table" then
      return t;
    elseif lookup_table[t] then
      return lookup_table[t];
    end

    local ret = {};
    lookup_table[t] = ret;
    for k,v in pairs(t) do
      ret[_copy(k)] =_copy(v);
    end

    local mt = getmetatable(t);
    setmetatable(ret,_copy(mt));
    return ret;
  end
  return _copy(t);
end

---
-- 将多个table合并为一个使用下标的形式的table.
-- 参数里的非table数据会被忽略。
-- 使用key-value形式的table的value也会被放入结果中，但顺序可能是不确定的。
--
-- **此方法只适合用来合并使用下标形式的table。**
--
-- 如：
--
-- MegerTables({1,2,3},nil,{name="peter",age=0},{{11,12},nil,"2008"})
-- 得到的结果是：{1,2,3,"peter",0,{11,12},"2008"} ，其中```'peter'```和0的顺序可能是不一定的。
--
-- 注意：最终结果里的{11,12}和传入参数里的{11,12}实际指向同一个对象.
--
-- 参见[core.global#CombineTables](#CombineTables)
--
-- @param ... 需要合并的tables。
-- @return #table 合并后的table。
MegerTables = function(...)
  local ret = {};
  local count = select("#",...);
  for i=1,count do
    local t = select(i,...);
    if type(t) == "table" then
      for _,v in pairs(t) do
        ret[#ret+1] = v;
      end
    end
  end
  return ret;
end


---
-- 将多个table合并为一个使用key-value的形式table，如果key值相同，会覆盖之前的数据.
-- 参数里的非table数据会被忽略。
--
-- **此方法只适合用来合并使用key-value形式的table。**
--
-- 如:
--
-- CombineTables({1,2,3},nil,{name="peter",age=0},{{11,12},nil,"2008"})
-- 得到的结果是：{{11,12},2,"2008",name="peter",age=0}。 因为1和{11,12}这两个数据的index都是1，所以后面的会覆盖前面的。
--
-- 参见[core.global#MegerTables](#MegerTables)
-- @param ... 需要合并的tables。
-- @return #table 合并后的table。
CombineTables = function(...)
  local ret = {};
  local count = select("#",...);
  for i=1,count do
    local t = select(i,...);
    if type(t) == "table" then
      for k,v in pairs(t) do
        ret[k] = v;
      end
    end
  end
  return ret;
end

---
-- 创建一个使用弱引用的table.
-- 弱引用：当某一个对象的所有引用都是弱引用时，该对象会被释放。
--
-- 例1：
--
--      t=CreateTable("v")
--      a={1,2,3}
--      t.key = a
--      a=nil
--      之后t.key会变为nil (当然，gc并不是实时的)
--
-- 例2:
--
--      t=CreateTable("k")
--      key={}
--      t[key]=123
--      key=nil
--      之后t会变为一个空table
--
-- @param #string weakOption 取值(```'k'/'v'/'kv'```)。
-- @return #table  使用弱引用的table。
CreateTable = function(weakOption)
  if not weakOption or (weakOption ~= "k" and weakOption ~= "v" and weakOption ~= "kv") then
    return {};
  end

  local ret = {};
  setmetatable(ret,{__mode = weakOption});
  return ret;
end


---
-- 计算两个array(使用下标形式的table)的差.
-- 也就是除去arry1中的value值和array2中的value值相同的数据，当arry1中有m个相同值的value与array2中的n个相同值的value，则arry2中有多少个，arry1就去除多少个，直到arry1中没有相同的value值。
-- 仅比较使用数字下标的值，key-value形式的会被忽略。
--
-- 例：
--
--      t1={2,3,4,5,6,5}
--      t2={1,3,5}
--      则SubTractArray(t1, t2)的结果是{2,4,6,5}
--
-- @param #table arr1 被减数。
-- @param #table arr2 减数。
-- @return #table arr1-arr2 的结果。
SubtractArray = function(arr1,arr2)
  local ret = {};

  local kvRevertArr2 = {};
  for k,v in ipairs(arr2) do
    kvRevertArr2[v] = kvRevertArr2[v] or 0;
    kvRevertArr2[v] = kvRevertArr2[v] + 1;
  end

  for k,v in ipairs(arr1) do
    if not kvRevertArr2[v] then
      ret[#ret+1] = v;
    else
      kvRevertArr2[v] = kvRevertArr2[v] - 1;
      kvRevertArr2[v] = kvRevertArr2[v] > 0 and kvRevertArr2[v] or nil;
    end
  end
  return ret;
end

---
-- 这是一个table的迭代器，使用此迭代器，可以按key的从小到大的顺序对table进行遍历.
--
-- key大小排序规则如下：
--
-- * 如果两个key的类型不一样，则按照类型的大小来排序。
--
-- * 如果两个key的都是number或者都是string类型，则按照number，或者string的大小来排序。
--
-- * 如果两个key都是boolean类型，则按照boolean的大小来比较。
--
-- * 如果两个key不是以上的情况，则按照其转换为字符串的大小来比较。
--
-- 如这样一个table: {1,2,name="zzp",age="0"}， 使用此迭代器将按照1,2,"0","zzp"的顺序得到遍历结果。
--
-- 使用方法为：
--
--      for k,v in orderedPairs(t) do
--          print(k,v)
--      end
--
-- @param #table t 要被迭代的table。
--
-- @return #function,#table,#nil 返回迭代函数，和被迭代的table，和nil。
--
orderedPairs = function(t)
  local cmpMultitype = function(op1, op2)
    local type1, type2 = type(op1), type(op2)
    if type1 ~= type2 then --cmp by type
      return type1 < type2
    elseif type1 == "number" and type2 == "number"
      or type1 == "string" and type2 == "string" then
      return op1 < op2 --comp by default
    elseif type1 == "boolean" and type2 == "boolean" then
      return op1 == true
    else
      return tostring(op1) < tostring(op2)
    end
  end

  local genOrderedIndex = function(t)
    local orderedIndex = {}
    for key in pairs(t) do
      table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex, cmpMultitype ) --### CANGE ###
    return orderedIndex
  end

  local orderedIndex = genOrderedIndex( t );
  local i = 0;
  return function(t)
    i = i + 1;
    if orderedIndex[i]~=nil then
      return orderedIndex[i],t[orderedIndex[i]];
    end
  end,t, nil;
end


end
        

package.preload[ "core.global" ] = function( ... )
    return require('core/global')
end
            

package.preload[ "core/gzip" ] = function( ... )
-- gzip.lua
-- Author: JoyFang
-- Date: 2015-12-23


--------------------------------------------------------------------------------
-- 这个模块提供了加密、解码字符串的方法。
--
-- @module core.gzip
-- @usage local gZip= require 'core.gzip' 

local M={}

---
--对字符串先做gzip压缩，然后base64.
--@param #string str 需要加密的字符串.
--@return #string 对str经过gzip和Base64加密后的字符串.
--@return #nil str为nil/内容为空/加密失败，均返回nil.
M.encodeGzipBase64 = function(str)  
  if str==nil or string.len(str)<1 then
     return nil
  end

   return gzip_compress_base64_encode(str)
end

---
--解码字符串.  
--
--@param #string str str必须是经过encodeGzipBase64加密后的字符串.
--@return #string str经过base64、gzip解码后的字符串.
--@return #nil str为nil/空字符串/未经过encodeGzipBase64加密后的字符串，均返回nil.
M.decodeBase64Gzip = function (str)
   if str==nil or string.len(str)<1 then
     return nil
    end
   return base64_decode_gzip_decompress(str)
end

M.encodeBase64 = function(str)
  if str==nil or string.len(str)<1 then
     return nil
  end
  return base64_encode(str)
end

M.decodeBase64 = function(str)
  if str==nil or string.len(str)<1 then
     return nil
  end
  return base64_decode(str)
end


return M

end
        

package.preload[ "core.gzip" ] = function( ... )
    return require('core/gzip')
end
            

package.preload[ "core/md5" ] = function( ... )
-- md5.lua
-- Author: JoyFang
-- Date: 2015-12-22


--------------------------------------------------------------------------------
-- 这个模块提供了md5加密文件的方法
--
-- @module core.md5
-- @usage local Md5= require 'core.md5' 

local M={}

---
--计算文件的md5。  
--
--@param #string file 文件的绝对路径。
--@return #string 文件的md5。
--@return nil 如果文件的file为nil/file为空字符串/路径不存在/路径包含中文，返回nil。
M.md5File =  function (file)
   if file==nil or string.len(file)<1 then
     return nil 
   end

   return md5_file(file)
end

return M


end
        

package.preload[ "core.md5" ] = function( ... )
    return require('core/md5')
end
            

package.preload[ "core/object" ] = function( ... )
local class_, _, super_ = unpack(require('core/class'))

--------------------------------------------------------------------------------
-- 用于模拟面向对象
--
-- @module core.object
-- @return #nil
-- @usage require("core/object")

-- object.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-5-29
-- Description: Provide object mechanism for lua


-- Note for the object model here:
--		1.The feature like C++ static members is not support so perfect.
--		What that means is that if u need something like c++ static members,
--		U can access it as a rvalue like C++, but if u need access it
--		as a lvalue u must use [class.member] to access,but not [object.member].
--		2.The function delete cannot release the object, because the gc is based on
--		reference count in lua.If u want to relase all the object memory, u have to
--      set the obj to nil to enable lua gc to recover the memory after calling delete.


---------------------Global functon class ---------------------------------------------------
--Parameters:   super               -- The super class
--              autoConstructSuper   -- If it is true, it will call super ctor automatic,when
--                                      new a class obj. Vice versa.
--Return    :   return an new class type
--Note      :   This function make single inheritance possible.
---------------------------------------------------------------------------------------------

---
-- 用于定义一个类.
--
-- @param #table super 父类。如果不指定，则表示不继承任何类，如果指定，则该指定的对象也必须是使用class()函数定义的类。
-- @param #boolean autoConstructSuper 是否自动调用父类构造函数，默认为true。如果指定为false，若不在ctor()中手动调用super()函数则不会执行父类的构造函数。
-- @return #table class 返回定义的类。
-- @usage
-- Human = class()
-- Human.ctor = function(self)
--  self.m_type = "human"
-- end
-- Human.dtor = function(self)
--  print_string("deleted")
-- end
-- Human.speak = function(self)
--  print_string("I am a " .. self.m_type)
-- end
--
-- Man = class(Human, true)
-- Man.ctor = function(self, name)
--  self.m_sex = "m"
--  self.m_name = name
-- end
function class(super, autoConstructSuper)
    autoConstructSuper = autoConstructSuper or (autoConstructSuper == nil)
    local klass = class_('', super and super.class, {})
    klass.autoConstructSuper = autoConstructSuper
    local meta = klass.___class
    rawset(meta, 'super', super)
    setmetatable(meta, {
        __call = rawget(klass, '__call'),
        __index = meta.___super,
    })
    function meta.__init__(self, ...)
        if autoConstructSuper and rawget(meta, '___super') ~= nil then
            local super_init = super_(klass, self).__init__
            if super_init ~= nil then
                super_init(self, ...)
            end
        end
        if not autoConstructSuper then
            self.currentSuper = super
        end
        local ctor = rawget(meta, 'ctor')
        if ctor then
            ctor(self, ...)
        end
        self.currentSuper = nil
    end
    if super == nil or not rawget(super, '___lua') then
        rawset(meta, 'setDelegate', function(self, d)
            self.m_delegate = d
        end)
    end
    return meta
end

---------------------Global functon super ----------------------------------------------
--Parameters:   obj         -- The current class which not contruct completely.
--              ...         -- The super class ctor params.
--Return    :   return an class obj.
--Note      :   This function should be called when newClass = class(super,false).
-----------------------------------------------------------------------------------------

---
-- 手动调用父类的构造函数.
-- 只有当定义类时采用class(super,false)的调用方式时才可以调用此方法，若此时不手动调用则不会执行父类的构造函数。
-- **只能在子类的构造函数中调用。**
-- @param #table obj 类的实例。
-- @param ... 父类构造函数需要传入的参数。
-- @usage
-- local baseClass = class()
-- local derivedClass = class(baseClass,false)
-- derivedClass.ctor = function()
--     super(self) - -此处如果不手动调用super()则不会执行基类的ctor()
-- end
function super(obj, ...)
    obj.currentSuper.__init__(obj, ...)
end

---------------------Global functon new -------------------------------------------------
--Parameters: 	classType -- Table(As Class in C++)
-- 				...		   -- All other parameters requisted in constructor
--Return 	:   return an object
--Note		:	This function is defined to simulate C++ new function.
--				First it called the constructor of base class then to be derived class's.
-----------------------------------------------------------------------------------------

---
-- 创建一个类的实例.
-- 调用此方法时会按照类的继承顺序，自上而下调用每个类的构造函数，并返回新创建的实例。
--
-- @param #table classType 类名。  使用class()返回的类。
-- @param ... 构造函数需要传入的参数。
-- @return #table obj 新创建的实例。
-- @usage
-- local me = new(Man, "zzp")
-- me:speak()
function new(meta, ...)
    return meta.class(...)
end

---------------------Global functon delete ----------------------------------------------
--Parameters: 	obj -- the object to be deleted
--Return 	:   no return
--Note		:	This function is defined to simulate C++ delete function.
--				First it called the destructor of derived class then to be base class's.
-----------------------------------------------------------------------------------------

---
-- 删除某个实例.
-- 类似c++里的delete ，会按照继承顺序，依次自下而上调用每个类的析构方法。
--
-- **需要留意的是，删除此实例后，lua里该对象的引用(obj)依然有效，再次使用可能会发生无法预知的意外。**
--
-- @param #table obj 需要删除的实例。
function delete(obj)
    local meta = getmetatable(obj)
    while meta do
        local fn = rawget(meta, 'dtor')
        if fn ~= nil then
            fn(obj)
        end
        meta = rawget(meta, '___super')
    end
end

---------------------Global functon delete ----------------------------------------------
--Parameters:   class       -- The class type to add property
--              varName     -- The class member name to be get or set
--              propName    -- The name to be added after get or set to organize a function name.
--              createGetter-- if need getter, true,otherwise false.
--              createSetter-- if need setter, true,otherwise false.
--Return    :   no return
--Note      :   This function is going to add get[PropName] / set[PropName] to [class].
-----------------------------------------------------------------------------------------

---
-- 为类定义一个property (java里的getter/setter).
-- 会自动为类生成getter/setter方法。
--
-- @param #table class 使用class()方法定义的类。
-- @param #string varName 类里的成员变量名。
-- @param #string propName 属性名，也就是生成的方法setXX/getXX里的'XX'。
-- @param #boolean createGetter 是否生成getter。
-- @param #boolean createSetter 是否生成setter。<br>
-- 如果createGetter不为false或nil，则给class生成一个get#propName()方法,可以获取class的varName的值。<br>
-- 如果createSetter不为false或nil，则给class生成一个set#propName(Value)方法，可以设置class的varName为Value。
-- @usage
-- property(Man, "m_name", "Name", true, false)
-- local me = new(Man, "zzp")
-- print_string(me:getName())
function property(class, varName, propName, createGetter, createSetter)
  createGetter = createGetter or (createGetter == nil);
  createSetter = createSetter or (createSetter == nil);

  if createGetter then
    class[string.format("get%s",propName)] = function(self)
      return self[varName];
    end
  end

  if createSetter then
    class[string.format("set%s",propName)] = function(self,var)
      self[varName] = var;
    end
  end
end

---------------------Global functon delete ----------------------------------------------
--Parameters:   obj         -- A class object
--              classType   -- A class
--Return    :   return true, if the obj is a object of the classType or a object of the
--              classType's derive class. otherwise ,return false;
-----------------------------------------------------------------------------------------

---
-- 判断一个对象是否是某个类(包括其父类)的实例.
-- 类似java里的instanceof。
--
-- @param obj 需要判断的对象。
-- @param classType 使用class()方法定义的类。
-- @return #boolean 若obj是classType的实例，则返回true；否则，返回false。
-- @usage
-- local me = new(Man, "zzp")
-- if typeof(me, Man) == true then
--     print_string("me is instance of Man")
-- end
function typeof(m, meta)
    if (type(m) ~= 'userdata' and type(m) ~= 'table') or type(meta) ~= 'table' then
        return type(m) == type(meta)
    end
    if type(m) == 'userdata' or rawget(m, 'class') == nil then
        -- object instance
        m = getmetatable(m)
    end
    while true do
        if m == nil then
            return false
        end
        if m == meta then
            return true
        end
        m = rawget(m, '___super')
    end
end

---------------------Global functon delete ----------------------------------------------
--Parameters:   obj         -- A class object
--Return    :   return the object's type class.
-----------------------------------------------------------------------------------------

---
-- 通过一个对象反向得到此对象的类.
--
-- @param obj 对象。
-- @return class 此对象的类。
-- @return #nil 如果obj不是某个类的对象，则返回nil。
function decltype(obj)
    return obj.class.___class
end

local native_pairs = pairs
function pairs(tbl)
    local nxt = native_pairs(tbl)
    return function(t, var)
        while true do
            var, value = nxt(t, var)
            if var == nil then
                break
            end
            if type(var) ~= 'string' or string.sub(var,1,3) ~= '___' then
                return var, value
            end
        end
    end, tbl, nil
end

end
        

package.preload[ "core.object" ] = function( ... )
    return require('core/object')
end
            

package.preload[ "core/prop" ] = function( ... )

--------------------------------------------------------------------------------
-- prop是应用在drawing上的属性.
--
-- 引擎内的属性prop对象是用于对控件特性的描述，包括了颜色、点大小、线宽、透明度、2D变化（平移、旋转、缩放）、索引、起止点等等，属性的值可以是固定值，也可以是动态变化的值。
--
-- @module core.prop
-- @return #nil
-- @usage require("core/prop")

-- prop.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-5-29
-- Description: provide basic wrapper for attributes which will be attached to a drawing

require("core/object");
require("core/constants");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropBase------------------------------------------
---------------------------------------------------------------------------------------------

---
-- prop的基类，无法直接使用.它是所有其它属性类的父类。
--
-- @type PropBase
PropBase = class();

---
-- 返回prop的唯一id.
--
-- @function [parent=#PropBase] getID
-- @param self
-- @return #number 属性的Id。
property(PropBase,"m_propID","ID",true,false);


---
-- 构造函数.
--
-- @param self
PropBase.ctor = function(self)
  self.m_propID = prop_alloc_id();
end


---
-- 析构函数.
--
-- @param self
PropBase.dtor = function(self)
  prop_free_id(self.m_propID);
end


---
-- 设置一个debugName,便于调试.
--
-- 在出错的时候所打印出来的错误信息，会把debugName也给打印出来。
--
-- @param self
-- @param #string name debugName。
PropBase.setDebugName = function(self, name)
  self.m_debugName = name;
  prop_set_debug_name(self.m_propID,name or "");
end

---
-- 返回debugName.
--
-- @param self
-- @param #string name debugName。
PropBase.getDebugName = function(self)
  return self.m_debugName;
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTranslate-------------------------------------
---------------------------------------------------------------------------------------------


---
-- PropTranslate是对平移属性的一个简单封装，只要传入必要的参数就可创建一个2D平移属性.
--
-- @type PropTranslate
-- @extends #PropBase
PropTranslate = class(PropBase);


---
-- 构造函数.
--
-- @param self
-- @param core.anim#AnimBase animX x轴方向的平移变换的动画。详见： @{core.anim#AnimBase}
-- @param core.anim#AnimBase animY y轴方向的平移变换的动画。详见： @{core.anim#AnimBase}
PropTranslate.ctor = function(self, animX, animY)
  prop_create_translate(0, self.m_propID,
    animX and animX:getID() or -1,
    animY and animY:getID() or -1
  );
end

---
-- 析构函数.
--
-- @param self
PropTranslate.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropRotate----------------------------------------
---------------------------------------------------------------------------------------------

---
-- 旋转属性.
--
-- 根据指定的中心点来顺时针旋转。
-- @type PropRotate
-- @extends #PropBase
PropRotate = class(PropBase);

---
-- 构造函数.
--
-- 根据指定的中心点来顺时针旋转的属性。
--
-- @param self
-- @param core.anim#AnimBase anim 角度变化的动画。
-- @param #number center 旋转的中心点。取值：[```kNotCenter```](core.constants.html#kNotCenter)（取此值时，不需要传入x,y的值）、[```kCenterDrawing```](core.constants.html#kCenterDrawing)（取此值时，不需要传入x,y的值）、[```kCenterXY```](core.constants.html#kCenterXY)（取此值时，要传入x,y的值，默认为0，0）。详见：<a href="core.drawing.html#00703">指定drawing的中心点。</a>
-- @param #number x 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
-- @param #number y 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
PropRotate.ctor = function(self, anim, center, x, y)
  prop_create_rotate(0, self.m_propID, anim:getID(),
    center or kNotCenter, x or 0, y or 0);
end

---
-- 析构函数.
--
-- @param self
PropRotate.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropScale-----------------------------------------
---------------------------------------------------------------------------------------------


---
-- 缩放属性.
--
-- 根据指定的中心点来缩放。
-- @type PropScale
-- @extends #PropBase
PropScale = class(PropBase);


---
-- 构造函数.
--
-- @param self
-- @param core.anim#AnimBase animX x轴方向的缩放动画。
-- @param core.anim#AnimBase animY y轴方向的缩放动画。
-- @param #number center 缩放的中心点。取值：[```kNotCenter```](core.constants.html#kNotCenter)（取此值时，不需要传入x,y的值）、[```kCenterDrawing```](core.constants.html#kCenterDrawing)（取此值时，不需要传入x,y的值）、[```kCenterXY```](core.constants.html#kCenterXY)（取此值时，要传入x,y的值，默认为0，0）。详见：<a href="core.drawing.html#00703">指定drawing的中心点。</a>
-- @param #number x 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
-- @param #number y 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
PropScale.ctor = function(self, animX, animY, center, x, y)
  prop_create_scale(0, self.m_propID,
    animX and animX:getID() or -1,
    animY and animY:getID() or -1,
    center or kNotCenter, x or 0, y or 0);
end

---
-- 析构函数.
--
-- @param self
PropScale.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTranslateSolid--------------------------------
---------------------------------------------------------------------------------------------

---
-- 静态的位移属性。直接达到最终值，不会有动画展示。
--
-- @type PropTranslateSolid
-- @extends #PropBase
PropTranslateSolid = class(PropBase);

---
-- 构造函数.
--
-- @param self
-- @param #number x 相对于drawing当前位置的左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴的偏移。
-- @param #number y 相对于drawing当前位置的左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴的偏移。
PropTranslateSolid.ctor = function(self, x, y)
  prop_create_translate_solid(0, self.m_propID, x, y);
end

---
-- 设置平移属性，即在x轴，和y轴方向上的平移。
--
-- @param self
-- @param #number x  相对于drawing当前位置的左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴的偏移。
-- @param #number y  相对于drawing当前位置的左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴的偏移。
PropTranslateSolid.set = function(self, x, y)
  prop_set_translate_solid(self.m_propID, x, y);
end

---
-- 析构函数.
--
-- @param self
PropTranslateSolid.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropRotateSolid-----------------------------------
---------------------------------------------------------------------------------------------


---
-- 静态的旋转属性。没有旋转的过程.
--
-- 根据指定的中心点来顺时针旋转。
-- @type PropRotateSolid
-- @extends #PropBase
PropRotateSolid = class(PropBase)

---
-- 构造函数.
--
-- @param self
-- @param #number angle360 旋转角度。
-- @param #number center 旋转的中心点。取值：[```kNotCenter```](core.constants.html#kNotCenter)（取此值时，不需要传入x,y的值）、[```kCenterDrawing```](core.constants.html#kCenterDrawing)（取此值时，不需要传入x,y的值）、[```kCenterXY```](core.constants.html#kCenterXY)（取此值时，要传入x,y的值，默认为0，0）。详见：<a href="core.drawing.html#00703">指定drawing的中心点</a>
-- @param #number x 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
-- @param #number y 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
PropRotateSolid.ctor = function(self, angle360, center, x, y)
  prop_create_rotate_solid(0, self.m_propID, angle360,
    center or kNotCenter,x or 0,y or 0);
end

---
-- 重新设置旋转角度.
--
-- @param self
-- @param #number angle360 旋转角度。
PropRotateSolid.set = function(self, angle360)
  prop_set_rotate_solid(self.m_propID, angle360);
end

---
-- 析构函数.
--
-- @param self
PropRotateSolid.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropScaleSolid------------------------------------
---------------------------------------------------------------------------------------------


---
-- 静态的缩放属性。直接达到最终值，没有动画。
--
-- @type PropScaleSolid
-- @extends #PropBase
PropScaleSolid = class(PropBase)


---
-- 构造函数.
--
-- @param self
-- @param #number scaleX x轴的缩放比例。1.0为drawing原始的大小。该值越大，看到的drawing越大。
-- @param #number scaleY y轴的缩放比例。1.0为drawing原始的大小。该值越大，看到的drawing越大。
-- @param #number center 缩放的中心点。取值：[```kNotCenter```](core.constants.html#kNotCenter)（取此值时，不需要传入x,y的值）、[```kCenterDrawing```](core.constants.html#kCenterDrawing)（取此值时，不需要传入x,y的值）、[```kCenterXY```](core.constants.html#kCenterXY)（取此值时，要传入x,y的值，默认为0，0）。详见：<a href="core.drawing.html#00703">指定drawing的中心点</a>
-- @param #number x 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的x轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
-- @param #number y 相对于drawing左上角(详见：<a href="core.drawing.html#0070301">drawing的左上角</a> )的y轴偏移。只有center的取值为[```kCenterXY```](core.constants.html#kCenterXY)的时候才有效。默认值为0。
PropScaleSolid.ctor = function(self, scaleX, scaleY, center, x, y)
  prop_create_scale_solid(0, self.m_propID, scaleX, scaleY,
    center or kNotCenter,x or 0,y or 0);
end

---
-- 重新设置缩放比例.
--
--
-- @param self
-- @param #number scaleX x轴的缩放比例。1.0为drawing原始的大小。该值越大，看到的drawing越大。
-- @param #number scaleY y轴的缩放比例。1.0为drawing原始的大小。该值越大，看到的drawing越大。
PropScaleSolid.set = function(self, scaleX, scaleY)
  prop_set_scale_solid(self.m_propID, scaleX, scaleY);
end


---
-- 析构函数.
PropScaleSolid.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropColor-----------------------------------------
---------------------------------------------------------------------------------------------

---
-- 颜色变化的属性.
--
-- @type PropColor
-- @extends #PropBase
PropColor = class(PropBase);

---
-- 构造函数.
--
-- @param self
-- @param core.anim#AnimBase animR RGB颜色中的R分量的值的动画。详见：@{core.anim#AnimBase}。
-- @param core.anim#AnimBase animG RGB颜色中的G分量的值的动画。详见：@{core.anim#AnimBase}。
-- @param core.anim#AnimBase animB RGB颜色中的B分量的值的动画。详见：@{core.anim#AnimBase}。
--
-- 如果以上Anim可变值为double类型，则颜色范围为[0.0,1.0]；
--
--如果以上Anim可变值为int类型，则颜色范围为[0,255]；
--
--如果以上Anim可变值为index类型，则颜色范围为[0.0,1.0]；
PropColor.ctor = function(self, animR, animG, animB)
  prop_create_color(0, self.m_propID,
    animR and animR:getID() or -1,
    animG and animG:getID() or -1,
    animB and animB:getID() or -1);
end

---
-- 析构函数.
--
-- @param self
PropColor.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTransparency----------------------------------
---------------------------------------------------------------------------------------------

---
-- 透明度变化的属性.
--
-- @type PropTransparency
-- @extends #PropBase
PropTransparency = class(PropBase);


---
-- 构造函数.
--
-- @param self
-- @param core.anim#AnimBase anim 透明度变化的动画。详见：@{core.anim#AnimBase}。透明度的取值：[0,1]。0表示透明，1表示不透明，0.5表示半透明。
-- 如果添加了多个此属性，最终只有sequence值最大的有效。详见[sequence的影响]( http://engine.by.com:8080/hosting/data/1451465498787_8655701166692189097.html)第一点的第三条。
PropTransparency.ctor = function(self, anim)
  prop_create_transparency(0, self.m_propID, anim:getID());
end

---
-- 析构函数.
-- @param self
PropTransparency.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropClip------------------------------------------
---------------------------------------------------------------------------------------------


---
-- 裁剪的属性。
--
-- @type PropClip
-- @extends #PropBase
PropClip = class(PropBase)


---
-- 构造函数.
--
-- @param self
-- @param core.anim#AnimBase animX x值变化的动画。x值参照@{core.drawing#DrawingBase.setClip}方法里的x。
-- @param core.anim#AnimBase animY y值变化的动画。y值参照@{core.drawing#DrawingBase.setClip}方法里的y。
-- @param core.anim#AnimBase animW w值变化的动画。y值参照@{core.drawing#DrawingBase.setClip}方法里的w。
-- @param core.anim#AnimBase animH h值变化的动画。y值参照@{core.drawing#DrawingBase.setClip}方法里的h。
--
--
-- 如果添加了多个此属性，最终只有sequence值最大的有效。详见[sequence的影响]( http://engine.by.com:8080/hosting/data/1451465498787_8655701166692189097.html)第一点的第三条。
PropClip.ctor = function(self, animX, animY, animW, animH)
  prop_create_clip(0, self.m_propID,
    animX and animX:getID() or -1,
    animY and animY:getID() or -1,
    animW and animW:getID() or -1,
    animH and animH:getID() or -1);
end

---
-- 析构函数.
--
-- @param self
PropClip.dtor = function(self)
  prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropImageIndex------------------------------------
---------------------------------------------------------------------------------------------



---
-- 索引属性.
-- 每一个DrawingImage可以包含多个image，指定显示某一张。使用此特性可以很容易实现一个帧动画。
-- 参考： @{core.drawing#DrawingImage}
--
-- @type PropImageIndex
-- @extends #PropBase
PropImageIndex = class(PropBase)

---
-- 构造函数.
--
-- 当一个drawing对象添加了多个贴图资源时，可以用来实现帧动画。
--
-- @param self
-- @param core.anim#AnimBase anim 指定索引变化的动画。详见：@{core.anim#AnimBase}
PropImageIndex.ctor = function(self, anim)
  prop_create_image_index(0, self.m_propID, anim:getID());
end


---
-- 析构函数.
--
-- @param self
PropImageIndex.dtor = function(self)
  prop_delete(self.m_propID);
end

end
        

package.preload[ "core.prop" ] = function( ... )
    return require('core/prop')
end
            

package.preload[ "core/res" ] = function( ... )

--------------------------------------------------------------------------------
--
-- Res 全部都是用于加载资源的，其中包括图片、文本、以及给引擎内部使用的部分数组数据.
-- 
-- 概念介绍：
-- ---------------------------------------------------------------------------------------
--
-- <a name="001" id="001" ></a>
-- **1.纹理的像素格式**
-- 
-- 纹理的像素格式描述了像素数据存储所用的格式,定义了像素在内存中的编码方式,是标识图片加载到内存之后各部分的所占的位数。
--  
-- 引擎中有以下取值：
-- 
-- * [```kRGBA8888```](core.constants.html#kRGBA8888)（32位像素格式）: 支持透明，最占用内存，但显示画面效果最佳。
-- 
-- * [```kRGBA4444```](core.constants.html#kRGBA4444)（16位像素格式）: 支持透明，比[```kRGBA8888```](core.constants.html#kRGBA8888)节约一半内存，画面效果差一些。
-- 
-- * [```kRGBA5551```](core.constants.html#kRGBA5551)（16位像素格式）: 支持透明，比[```kRGBA8888```](core.constants.html#kRGBA8888)节约一半内存，画面效果差一些。
-- 
-- * [```kRGB565```](core.constants.html#kRGB565)（16位像素格式）:不支持透明，比[```kRGBA8888```](core.constants.html#kRGBA8888)节约一半内存，画面效果差一些。
-- 
--  纹理的像素格式的取值决定OpenGl读取位图资源时所用的像素格式，参考[glTexImage2D](https://www.khronos.org/opengles/sdk/docs/man/xhtml/glTexImage2D.xml)函数的 ```type``` 参数。
-- 
-- <a name="002" id="002" ></a>
-- **2.纹理的过滤方式**
-- 
-- 贴图时，三维空间里面的多边形经过坐标变换、投影、光栅化等过程，变成二维屏幕上的一组象素时，对每个象素需要到相应位图中进行采样，这个过程就称为过滤.     
--    
-- 引擎中有以下取值：
-- 
-- [```kFilterNearest```](core.constants.html#kFilterNearest): 最临近插值。对应opengl的[glTexParameter](https://www.khronos.org/opengles/sdk/docs/man/xhtml/glTexParameter.xml)中param对应的取值```GL_NEAREST```。
--  
-- [```kFilterLinear```](core.constants.html#kFilterLinear):线性过滤。对应opengl的[glTexParameter](https://www.khronos.org/opengles/sdk/docs/man/xhtml/glTexParameter.xml)中param对应的取值```GL_LINEAR```。
-- 
-- **最临近插值**一般用于位图大小与贴图的三维图形的大小差不多的时候。
-- 
-- **线性过滤**采用的计算方法比最临近插值复杂，但是能取得更为平滑的效果。
--
-- @module core.res
-- @return #nil
-- @usage require("core/res")

-- res.lua
-- Author: Vicent Gong
-- Date: 2012-09-20
-- Last modification : 2015-12-7
-- Description: provide basic wrapper for resources manager

require("core/object");
require("core/constants");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResBase-------------------------------------------
---------------------------------------------------------------------------------------------
local s_pathPickerFunc = nil
local s_formatPickerFunc = nil
local s_filterPickerFunc = nil
local s_align = nil
local s_fontName = nil
local s_fontSize = nil
local s_g = nil
local s_r = nil
local s_b = nil
---
-- res基类.**本身无法直接使用.**
--
-- @type ResBase
ResBase = class();

---
-- 返回ResBase对象的id.    
-- 每个ResBase对象都有自己唯一的Id，是一个32位带符号整数，在创建对象的时候由引擎自动分配;  
-- @function [parent=#ResBase] getID
-- @param self
-- @return #number 返回res的id.

property(ResBase, "m_resID", "ID", true, false);

---
-- 构造函数.
--
-- @param self
ResBase.ctor = function(self)
    self.m_resID = res_alloc_id();
end

---
-- 析构函数.
--
-- @param self
ResBase.dtor = function(self)
    res_free_id(self.m_resID);
end


---
-- 设置一个debugName，便于调试.如果出现错误日志中会打印出这个名字，便于定位问题.
--
-- @param self
-- @param #string name 设置的debugName.
ResBase.setDebugName = function(self, name)
    res_set_debug_name(self.m_resID, name or "");
    self.m_debugName=name or ""
end


---
-- 返回debugName.
-- @return #string 返回debugName.
ResBase.getDebugName = function(self)
    return self.m_debugName
end

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResImage------------------------------------------
---------------------------------------------------------------------------------------------


---
-- 引擎位图资源.
-- 
-- @type ResImage
-- @extends #ResBase
ResImage = class(ResBase);

---
-- 获得位图资源的宽度.
--
-- @function [parent=#ResImage] getWidth
-- @param self
-- @return #number 位图资源的宽度.
property(ResImage, "m_width", "Width", true, false);

---
-- 获得位图资源的高度.
--
-- @function [parent=#ResImage] getHeight
-- @param self
-- @return #number 返回位图资源的高度.
property(ResImage, "m_height", "Height", true, false);


---
-- 设置图片的默认纹理像素格式.  
-- @param #function func 设置纹理像素格式的函数.  
-- 函数定义如下：  
--     function(configPath, fileName)
--         return kRGBA8888
--     end  
-- **configPath**:图片的目录。 
-- **fileName**:图片的路径。  
-- 
-- 此函数的作用是设置configPath目录下的名为fileName的图片的默认纹理像素格式(仅支持png格式)。
--   
-- func的返回值可取值 [```kRGBA8888```](core.constants.html#kRGBA8888)、 [```kRGBA4444```](core.constants.html#kRGBA4444)、[```kRGBA5551```](core.constants.html#kRGBA5551)、[```kRGB565```](core.constants.html#kRGB565).
--   
-- ResImage.setFormatPicker在@{#ResImage.ctor}或@{#ResImage.setFile}执行前调用有效.
--   
ResImage.setFormatPicker = function(func)
    s_formatPickerFunc = func;
end

---
-- 设置图片的默认纹理过滤方式.   
-- @param #function func 设置过滤方式的函数.  
--    函数定义如下:   
--      function(configPath, fileName)            
--          return kFilterLinear    
--      end   
-- **configPath**:图片的目录。
-- **fileName**:图片的路径。
-- 
-- 此函数的作用是设置configPath目录下的名为fileName的图片的默认纹理过滤方式(仅支持png格式),
--   
-- func的返回值可取值[```kFilterNearest```](core.constants.html#kFilterNearest)、[```kFilterLinear```](core.constants.html#kFilterLinear).   
ResImage.setFilterPicker = function(func)
    s_filterPickerFunc = func;
end

---
-- 设置图片的默认目录.  
-- 
-- 引擎会在此设置的目录下去搜索相应的图片。
-- 
-- 此函数会在@{#ResImage.ctor}时被调用.
--
-- @param #function func 设置图片的目录的函数.
--   
--  函数定义如下：  
--     function(fileName) 
--         return `old_version/images_backup/`
--     end  
-- 
ResImage.setPathPicker = function(func)
    s_pathPickerFunc = func;
end

---
--构造函数调用此函数.
local ResImage__onInit = function (self, file, format, filter)
    local fileName;
    if type(file) == "table" then
        fileName = file.file;
        self.m_subTexX = file.x;
        self.m_subTexY = file.y;
        self.m_subTexW = file.width;
        self.m_subTexH = file.height;
        self.m_subOffsetX = file.offsetX;
        self.m_subOffsetY = file.offsetY;
        self.m_subTexUtW = file.utWidth;
        self.m_subTexUtH = file.utHeight;
        self.m_subTexRotated = file.rotated;
    else
        fileName = file;
    end

    local configPath = s_pathPickerFunc and s_pathPickerFunc(fileName) or "";

    self.m_fileName = configPath .. fileName;
    self.m_filter = self.m_filter
    or filter
    or(s_filterPickerFunc and s_filterPickerFunc(configPath, fileName))
    or kFilterNearest;
    self.m_format = self.m_format
    or format
    or(s_formatPickerFunc and s_formatPickerFunc(configPath, fileName))
    or kRGBA8888;

    if res_create_image(0, self.m_resID, self.m_fileName, self.m_format, self.m_filter) == 0 then
        if self.m_subTexRotated == true and self.m_subTexUtW == nil then
            self.m_width = self.m_subTexH
            self.m_height = self.m_subTexW
        else
            self.m_width = self.m_subTexUtW or self.m_subTexW or res_get_image_width(self.m_resID);
            self.m_height = self.m_subTexUtH or self.m_subTexH or res_get_image_height(self.m_resID);
        end
    else
        self.m_width = -1
        self.m_height = -1
    end
end

---
-- 构造函数.
--
-- @param self
-- @param file 图片路径，可以传入string和table两种类型的参数.
-- 
-- 1.当file类型是string时,即图片的路径.仅支持png格式.
--
-- 2.当file类型为table时，表示截取图片上某一矩形区域作为资源，此时file必须包含以下字段：    
-- <a name="0001" id="0001" ></a>    
-- 
-- * file：文件路径。类型string.
-- 
-- 若通过@{#ResImage.setPathPicker}设置过默认目录，则会去此目录下搜名为```file```的图片。
--       
-- 若从未调用过@{#ResImage.setPathPicker}，则会在引擎默认的目录下寻找名为```file```的图片;  
--       
-- 其中，func为最后一次调用@{#ResImage.setPathPicker}所传的参数.   
-- 
-- * x: 相对于图片左上角的横坐标。类型number.取值范围：x>=0且x+width<=图片的宽度.
-- 
-- * y: 相对于图片左上角的纵坐标。类型number.取值范围：y>=0且y+height<=图片的高度.
--
-- * width：图片上矩形截取区域的宽度，类型number.取值范围：w>=0且x+width<=图片的宽度.
-- 
-- * height: 图片上矩形截取区域的高度，类型number.取值范围：h>=0且y+height<=图片的高度.
-- 
-- 如下图，假设O为图片坐标原点，P的坐标(40,80)，传入的file为{file="bg/cards.png", x=40, y=80, width=120, height=90}:  
-- 
-- ![](http://engine.by.com:8080/hosting/data/1450235731994_5827158023213736441.png)  
-- 
-- 则会以P为起点截取宽高分别为w、h(单位像素)的矩形区域作为图片资源使用.  
-- 
-- @param #number format 纹理的像素格式.详见：<a href = "#001">纹理的像素格式。</a>   
-- 
-- ```format```若为nil,则取@{#ResImage.setFomatPicker}设置的默认值，若未通过@{#ResImage.setFomatPicker}设置，则默认取值[```kRGBA8888```](core.constants.html#kRGBA8888).         
-- 其中，func为最后一次调用@{#ResImage.setFomatPicker}所传的参数.  
--    
-- @param #number filter 纹理的过滤方式.详见：<a href = "#002">纹理的过滤方式。</a> 
-- 
-- ```filter```若为nil，则取@{#ResImage.setFilterPicker}设置的默认值，若未通过@{#ResImage.setFilterPicker}设置，则默认取值为[```kFilterNearest```](core.constants.html#kFilterNearest);      
-- 其中，func为最后一次调用@{#ResImage.setFilterPicker}所传的参数.  
--   
ResImage.ctor = function(self, file, format, filter)
    ResImage__onInit(self,file, format, filter)
end

ResImage.isValid = function(self)
    return self.m_width >= 0 and self.m_height >= 0
end


---
-- 获取位图资源的信息.
-- 
-- @param self
-- @return #number, #number, #number, #number  若构造时@{#ResImage.ctor}的```file```参数的类型为table，则返回```file.x, file.y,file.width, file.height, file.offsetX, file.offsetY, file.utWidth, file.utHeight, file.rotated```的值.
-- @return #nil,#nil,#nil,#nil 若构造时@{#ResImage.ctor}的```file```参数的类型不是table，则全部返回nil.
ResImage.getSubTextureCoord = function(self)
    return self.m_subTexX, self.m_subTexY, self.m_subTexW, self.m_subTexH,self.m_subOffsetX,self.m_subOffsetY,self.m_subTexUtW,self.m_subTexUtH,self.m_subTexRotated;
end

---
-- 更换所用的位图.  
-- 注：尽管此过程会在引擎内部重新创建新的位图资源对象，但是由于位图资源的ID不变，所以通常无需处理相关对象。
--
-- @param self
-- @param file 图片路径.可以传入string和table两种类型的参数.
-- 
-- 1.当file类型是string时,即图片的路径.仅支持png格式.
--
-- 2.当file类型为table时，表示截取图片上某一矩形区域作为资源，此时file必须包含以下字段：    
-- <a name="0001" id="0001" ></a>    
-- 
-- * file：文件路径。类型string.
-- 
-- 若通过@{#ResImage.setPathPicker}设置过默认目录，则会去此目录下搜名为```file```的图片。
--       
-- 若从未调用过@{#ResImage.setPathPicker}，则会在引擎默认的目录下寻找名为```file```的图片;  
--       
-- 其中，func为最后一次调用@{#ResImage.setPathPicker}所传的参数.   
-- 
-- * x: 相对于图片左上角的横坐标。类型number.取值范围：x>=0且x+width<=图片的宽度.
-- 
-- * y: 相对于图片左上角的纵坐标。类型number.取值范围：y>=0且y+height<=图片的高度.
--
-- * width：图片上矩形截取区域的宽度，类型number.取值范围：w>=0且x+width<=图片的宽度.
-- 
-- * height: 图片上矩形截取区域的高度，类型number.取值范围：h>=0且y+height<=图片的高度.
-- 
-- 如下图，假设O为图片坐标原点，P的坐标(40,80)，传入的file为{file="bg/cards.png", x=40, y=80, width=120, height=90}:  
-- 
-- ![](http://engine.by.com:8080/hosting/data/1450235731994_5827158023213736441.png)  
-- 
-- 则会以P为起点截取宽高分别为w、h(单位像素)的矩形区域作为图片资源使用. 
-- @param #number format 纹理的像素格式.详见：<a href = "#001">纹理的像素格式。</a>   
-- 
-- ```format```若为nil,则取@{#ResImage.setFomatPicker}设置的默认值，若未通过@{#ResImage.setFomatPicker}设置，则默认取值[```kRGBA8888```](core.constants.html#kRGBA8888).         
-- 其中，func为最后一次调用@{#ResImage.setFomatPicker}所传的参数.      
-- @param #number filter 纹理的过滤方式.详见：<a href = "#002">纹理的过滤方式。</a> 
-- 
-- ```filter```若为nil，则取@{#ResImage.setFilterPicker}设置的默认值，若未通过@{#ResImage.setFilterPicker}设置，则默认取值为[```kFilterNearest```](core.constants.html#kFilterNearest);      
-- 其中，func为最后一次调用@{#ResImage.setFilterPicker}所传的参数.   
ResImage.setFile = function(self, file, format, filter)
    ResImage.dtor(self);

    self.m_subTexX = nil;
    self.m_subTexY = nil;
    self.m_subTexW = nil;
    self.m_subTexH = nil;
    self.m_subOffsetX = nil;
    self.m_subOffsetY = nil;
    self.m_subTexUtW = nil;
    self.m_subTexUtH = nil;
    self.m_subTexRotated = nil;

    ResImage.ctor(self, file, format, filter)
end

---
-- 析构函数.
-- 在析构的过程中，会删除此位图资源，清理位图资源所占用的内存.
ResImage.dtor = function(self)
    res_delete(self.m_resID);
end



--------------------------------------------------------------------------------------------
---------------------------------[CLASS] ResCapturedImage-----------------------------------
--------------------------------------------------------------------------------------------

---
--截取屏幕并生成位图.
--
-- @type ResCapturedImage
-- @extends #ResImage
ResCapturedImage = class(ResImage,false)

---
--构造函数调用此方法.
local ResCapturedImage__onInit = function (self)
    self.m_subTexX =nil;
    self.m_subTexY =nil;
    self.m_subTexW =nil;
    self.m_subTexH =nil;
    self.m_subOffsetX = nil;
    self.m_subOffsetY = nil;
    self.m_subTexUtW = nil;
    self.m_subTexUtH = nil;
    self.m_subTexRotated = nil;
 
    self.m_filter = self.m_filter
    or filter
    or kFilterNearest;
    self.m_format = self.m_format
    or format
    or kRGBA8888;
      
    if res_create_framebuffer_image(0, self.m_resID,self.m_format, self.m_filter) == 0 then
        self.m_width = res_get_image_width(self.m_resID) or System.getLayoutWidth();
        self.m_height =  res_get_image_height(self.m_resID) or System.getLayoutHeight();
    else
        self.m_width = -1
        self.m_height = -1
    end
end


---
-- 构造函数.
--
-- @param self
-- @param #number format OpenGl读取位图资源时所用的像素格式.     
-- ResImage.setFormatPicker函数在此无效.
-- @param #number filter 位图资源的过滤方式.   
-- ResImage.setFilterPicker函数在此无效.
ResCapturedImage.ctor = function (self, format, filter)
    self.m_resID = res_alloc_id();
    ResCapturedImage__onInit(self)
end

---
-- override父类方法.  
--
-- @param self 
ResCapturedImage.setFile = function(self)
     
end

---
-- 析构函数.
ResCapturedImage.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResText-------------------------------------------
---------------------------------------------------------------------------------------------

---
-- 引擎文字位图.
-- 
-- @type ResText
-- @extends #ResBase
ResText = class(ResBase);


---
-- 获取文字位图的宽度.
--
-- @function [parent=#ResText] getWidth
-- @param self
-- @return #number 文字位图的宽度.
property(ResText, "m_width", "Width", true, false);

---
-- 获取文字位图的高度.
--
-- @function [parent=#ResText] getHeight
-- @param self
-- @return #number 文字位图的高度.
property(ResText, "m_height", "Height", true, false);

---
-- 设置默认的文字颜色.
-- 
-- 如未使用此函数进行设置，则会使用引擎自己设置的默认值。
--
-- @param #number r 文字的RGB颜色的R分色.取值范围：[0,255].
-- @param #number g 文字的RGB颜色的G分色.取值范围：[0,255].
-- @param #number b 文字的RGB颜色的B分色.取值范围：[0,255].
ResText.setDefaultColor = function(r, g, b)
    s_r = r;
    s_g = g;
    s_b = b;
end

---
-- 设置字体和字号.在构造函数@{#ResText.ctor}之前调用.
--
--调用时机无限制;一旦调用，则文字的有默认字体名称、字体大小.直到再次调用更改.
-- @param #string fontName 字体名称.
-- (需要有对应文件名的字体文件,放在fonts目录下).
-- @param #number fontSize 字体大小.实际大小依据不同的平台而定，例如Windows和Android平台大小可能会不同.
ResText.setDefaultFontNameAndSize = function(fontName, fontSize)
    s_fontName = fontName;
    s_fontSize = fontSize;
end

---
-- 设置文字默认对齐方式 .  
--
-- @param #number align 文字对齐方式。有以下取值：
-- 
-- <a name = "0002" id = "0002"></a>
-- 
-- * [```kAlignCenter```](core.constants.html#kAlignCenter)居中对齐。  
-- * [```kAlignTop```](core.constants.html#kAlignTop)　顶部居中对齐。   
-- * [```kAlignTopRight```](core.constants.html#kAlignTopRight)右上角对齐。    
-- * [```kAlignRight```](core.constants.html#kAlignRight)右部居中对齐。   
-- * [```kAlignBottomRight```](core.constants.html#kAlignBottomRight)右下角对齐。    
-- * [```kAlignBottom```](core.constants.html#kAlignBottom)下部居中对齐。   
-- * [```kAlignBottomLeft```](core.constants.html#kAlignBottomLeft)左下角对齐。  
-- * [```kAlignLeft```](core.constants.html#kAlignLeft)左部居中对齐。    
-- * [```kAlignTopLeft```](core.constants.html#kAlignTopLeft)顶部居中对齐。  
-- 对齐方式如下图：     
-- ![](http://engine.by.com:8080/hosting/data/1450267951324_840123041012274695.png) 
ResText.setDefaultTextAlign = function(align)
    s_align = align;
end

---
-- 构造函数.
--
-- @param self
-- @param #string str 文字位图展示的文字.
-- @param #number width 指定文字位图的宽度 ,取值不小于0.  
-- @param #number height 指定文字位图的高度,取值不小于0.  
-- @param #number align 文字对齐方式.取值见：<a href = "#0002">文字对齐方式。</a> 
--  
--  注：只有所有文字没有完全占满width*height的矩形空间，即空出的行高>=一行的高度且max(每行空出的宽度)>=max(每个文字的宽度)，align的设置才有效。
-- @param #string fontName 字体名称.
-- 
-- ```fontName```为nil时,如果通过@{#ResText.setDefaultFontNameAndSize}设置过默认值，则取其设置的默认值；
-- 
-- 若未通过@{#ResText.setDefaultFontNameAndSize}设置，则为默认值[```kDefaultFontName```](core.constants.html#kDefaultFontName)。 
--  
-- **默认名称依据不同的平台而定，例如Windows和Android平台默认字体名称可能会不同**.
-- 
-- @param #number fontSize 字体大小.
-- 
-- ```fontSize```若为nil,如果通过@{#ResText.setDefaultFontNameAndSize}设置过默认值，则取其设置的默认值；
-- 
-- 若未通过@{#ResText.setDefaultFontNameAndSize}设置，则为默认值[```kDefaultFontSize```](core.constants.html#kDefaultFontSize)。 
-- 
-- **默认字体大小依据不同的平台而定，例如Windows和Android平台默认字体大小可能会不同；且即使默认大小相同，显示效果也依平台会略有不同**.
-- @param #number r 文字的RGB颜色的R分色.取值范围：[0,255].
-- 
-- r为nil时,如果通过@{#ResText.setDefaultColor}设置过默认值，则取其设置的默认值；
-- 
-- 若未通过@{#ResText.setDefaultColor}设置，则默认值为[```kDefaultTextColorR```](core.constants.html#kDefaultTextColorR)。
-- 
-- @param #number g 文字的RGB颜色的G分色.取值范围：[0,255].
-- 
-- g为nil时,如果通过@{#ResText.setDefaultColor}设置过默认值，则取其设置的默认值；
-- 
-- 若未通过@{#ResText.setDefaultColor}设置，则默认值为[```kDefaultTextColorG```](core.constants.html#kDefaultTextColorG)。
--  
-- @param #number b 文字的RGB颜色的B分色.取值范围：[0,255].
-- 
-- b为nil时,如果通过@{#ResText.setDefaultColor}设置过默认值，则取其设置的默认值；
-- 
-- 若未通过@{#ResText.setDefaultColor}设置，则默认值为[```kDefaultTextColorB```](core.constants.html#kDefaultTextColorB)。
-- 
-- @param #number multiLines 是否多行:0表示单行;1表示多行，如果一行不足以展示所有的文字，则自动换行. 
-- 
-- **单行文字**：  
-- 根据fontSize和str计算一行能容纳所有文字的最小宽度和最小高度，则
-- 文字位图的实际宽度=Max(最小宽度,width); 实际高度=Max(最小高度,height);   
-- 
-- **多行文字**：  
-- 根据fontSize和width计算出一行能容纳的最小字数，若width<8，则默认为8；若未能容纳，则自动换行并扩充高度直至填满.  
-- 
-- 扩充的高度即为最小高度.
-- 
-- 1.文字位图实际宽度为width，但width不得小于8. 
--  
-- 2.文字位图实际高度=Max(最小高度,height).  
-- 
-- 单行和双行，多余部分均为透明.
ResText.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b, multiLines)
    self.m_str = str;
    self.m_width = width;
    self.m_height = height;
    self.m_r = r or s_r or kDefaultTextColorR;
    self.m_g = g or s_g or kDefaultTextColorG;
    self.m_b = b or s_b or kDefaultTextColorB;
    self.m_align = align or s_align or kAlignLeft;
    self.m_font = fontName or s_fontName or kDefaultFontName;
    self.m_fontSize = fontSize or s_fontSize or kDefaultFontSize;
    self.m_multiLines = multiLines;

    if res_create_text_image(0, self.m_resID, self.m_str, self.m_width, self.m_height,
    self.m_r, self.m_g, self.m_b, self.m_align, self.m_font, self.m_fontSize, self.m_multiLines) == 0 then
        self.m_width = res_get_image_width(self.m_resID);
        self.m_height = res_get_image_height(self.m_resID);
    else
        self.m_width = -1
        self.m_height = -1
    end
end

---
-- 更换展示的文字.
-- 注：尽管此过程会在引擎内部重新创建新的位图资源对象，但是由于位图资源的ID不变，所以通常无需处理相关对象.  
-- @param self
-- @param #string str 文字位图展示的文字.
-- @param #number width 指定文字位图的宽度 ,取值不小于0.  
-- @param #number height 指定文字位图的高度，取值不小于0.     
-- @param #string fontName 字体名称.```fontName```若为nil,则为构造时所建立的值.  
-- @param #number fontSize 字体大小.```fontSize```若为nil,则为构造时所建立的值..  
-- @param #number r 文字的RGB颜色的R分色.取值范围：[0,255].r若为nil,则为构造时所建立的值.
-- @param #number g 文字的RGB颜色的G分色.取值范围：[0,255].g若为nil,则为构造时所建立的值.
-- @param #number b 文字的RGB颜色的B分色.取值范围：[0,255].b若为nil,则为构造时所建立的值.
ResText.setText = function(self, str, width, height, r, g, b)
    ResText.dtor(self);
    ResText.ctor(self,
    str or self.m_str,
    width or self.m_width,
    height or self.m_height,
    self.m_align,
    self.m_font,
    self.m_fontSize,
    r or self.m_r,
    g or self.m_g,
    b or self.m_b,
    self.m_multiLines);
end


---
-- 析构函数.
ResText.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResDoubleArray------------------------------------
---------------------------------------------------------------------------------------------


---
-- 封装了引擎的double数组.  
-- 
-- @type ResDoubleArray
-- @extends #ResBase
ResDoubleArray = class(ResBase);


---
-- 构造函数.    
-- 初始化一个ResDoubleArray对象，该对象封装了引擎内部的一个double数组；引擎内部创建数组后，用lua数组nums对引擎内部数组进行填充.
-- 
-- @param self.
-- @param #list<#number> 无空洞的数组,如：{1.1, 1.2, 1.3, 1.4}.  
ResDoubleArray.ctor = function(self, nums)
    res_create_double_array(0, self.m_resID, nums);
end

---
-- 清空ResDoubleArray对象的数组,然后用nums的内容填充.    
-- @param self.
-- @param #list<#number> 无空洞的数组,如：{1.1, 1.2, 1.3, 1.4}.  
ResDoubleArray.setData = function(self, nums)
    ResDoubleArray.dtor(self);
    ResDoubleArray.ctor(self, nums);
end

---
-- 析构函数.
--
-- @param self
ResDoubleArray.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResIntArray---------------------------------------
---------------------------------------------------------------------------------------------


---
-- 封装了引擎的int数组. 
-- @type ResIntArray
-- @extends #ResBase
ResIntArray = class(ResBase);


---
-- 构造函数.    
-- 初始化一个ResIntArray对象，该对象封装了引擎内部的一个int数组；引擎内部创建数组后，用lua数组nums对引擎内部数组进行填充.  
-- 
-- @param self
-- @param #list<#number> nums 无空洞的数组，如:{1,3,5,7}.    
-- 每个数的取值范围为 `[-2147483648,2147483647]`,且必须是整数.
ResIntArray.ctor = function(self, nums)
    res_create_int_array(0, self.m_resID, nums);
end

---
-- 清空ResIntArray对象的数组,然后用nums的内容填充.  
--
-- @param self
-- @param #list<#number> nums 无空洞的int数组，如:{1,3,5,7}.
-- 每个数的取值范围为 `[-2147483648,2147483647]`,且必须是整数.
-- 
ResIntArray.setData = function(self, nums)
    ResIntArray.dtor(self);
    ResIntArray.ctor(self, nums);
end

---
-- 析构函数.
-- @param self
ResIntArray.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResUShortArray---------------------------------------
---------------------------------------------------------------------------------------------



---
-- 封装了引擎的ushort数组.
-- 
-- @type ResUShortArray
-- @extends #ResBase
ResUShortArray = class(ResBase);


---
-- 构造函数.  
-- 初始化一个ResUShortArray对象，该对象封装了引擎内部的一个ushort数组；引擎内部创建数组后，用lua数组nums对引擎内部数组进行填充.
-- 
-- @param self
-- @param #list<#number> nums 无空洞的ushort数组.如 {1,2,3,4}.
-- 每个数的取值范围为:`[0,65535]`,且必须是整数.
ResUShortArray.ctor = function(self, nums)
    res_create_ushort_array(0, self.m_resID, nums);
end


---
-- 清空ResUShortArray对象的数组,然后用nums的内容填充.    
-- 
-- @param self
-- @param #list<#number> nums 无空洞的数组.如 {1,2,3,4}.  
-- 每个数的取值范围为:`[0,65535]`,且必须是整数.
ResUShortArray.setData = function(self, nums)
    ResUShortArray.dtor(self);
    ResUShortArray.ctor(self, nums);
end

---
-- 析构函数.
--
-- @param self
ResUShortArray.dtor = function(self)
    res_delete(self.m_resID);
end

end
        

package.preload[ "core.res" ] = function( ... )
    return require('core/res')
end
            

package.preload[ "core/sound" ] = function( ... )

--------------------------------------------------------------------------------
-- 播放背景音乐与音效.
-- 音乐(music)：可以是很长的一段声音，一般用于游戏的背景音乐。
--
-- 音效(effect)：是比较短的音乐，一般用于按钮点击、互动表情等声音效果。
--
-- 音量(volume)：描述音乐或者音效的声压大小，声压即声音震动时所产生的压力。
--
-- @module core.sound
-- @return #nil
-- @usage require("core/sound")

-- sound.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2015-12-14
-- Description: provide basic wrapper for sound functions

require("core/constants")
require("core/object")

---
-- Sound类提供的全部都是静态接口，实际上只是对引擎接口的简单封装。
-- 该类主要包含两部分的接口，即对音乐和对音效的操作。
-- 值得注意的是，音乐只能同时存在一个，音效则可以同时存在多个，音乐和音效可以同时存在。
-- 使用方式为Sound.FuncName(), 不必new一个对象再使用。
-- 引擎支持的声音文件格式为：win32下支持mp3, android下支持mp3/ogg, ios下支持mp3/ogg。
--
--
-- @type Sound
Sound = class();

---
-- 预加载音乐.一次只能预加载、播放一个音乐文件。
-- 音乐加载可能需要一些时间，所以可以提前加载(但这不是必须的)。
-- 如在加载界面时预加载音乐文件，之后便可以在显示界面时流畅地播放音乐，避免因加载音乐文件而卡顿。
--
-- @param #string fileName 文件路径+文件名，这个文件路径默认是以 /Resource/audio为根目录的。
Sound.preloadMusic = function(fileName)
  audio_music_preload(fileName);
end

---
-- 播放音乐.
-- 如果之前预加载过或上次加载的没释放就不会再加载了，否则，就会先加载再从头开始播放。
--
-- @param #string fileName 文件路径+文件名，这个文件路径默认是以 /Resource/audio为根目录的。
-- @param #boolean loop 是否循环播放。
Sound.playMusic = function(fileName, loop)
  audio_music_play(fileName,loop and kTrue or kFalse);
end

---
-- 停止播放音乐.
--
-- @param #boolean doUnload 是否释放音乐内存，取值true则释放占用的内存，下次再播放需要重新加载。
Sound.stopMusic = function(doUnload)
  audio_music_stop(doUnload and kTrue or kFalse);
end

---
-- 暂停正在播放的音乐.
-- 如果想从暂停位置恢复播放，则需要调用@{#Sound.resumeMusic}。
-- 如果想从头开始播放，则调用@{#Sound.playMusic}。
Sound.pauseMusic = function()
  audio_music_pause();
end

---
-- 恢复音乐播放.
-- 从上次暂停的位置恢复播放，一般和@{#Sound.pauseMusic}配合使用。
-- 如果音乐没有被暂停，则无效果。
Sound.resumeMusic = function()
  audio_music_resume();
end

---
-- 是否有音乐正在播放.
-- @return #boolean 正在播放则返回true, 否则返回false。
Sound.isMusicPlaying = function()
  return audio_music_is_playing() == 1 and true or false;
end

---
-- 获得音乐的音量值.
-- @return #number 音乐的当前音量值。
Sound.getMusicVolume = function()
  return audio_music_get_volume();
end

---
-- 获得当前系统音乐允许的最大音量.
-- 不同设备上值可能不一样，可以根据这个值去设置实际播放音乐的音量值。
--
-- @return #number 音乐的最大音量值。
Sound.getMusicMaxVolume = function()
  return audio_music_get_max_volume();
end

---
-- 设置音乐的音量.
-- 最灵活的用法是根据@{#Sound.getMusicMaxVolume}返回的值乘以一个百分比作为实参。
--
-- @param #number volume 指定的音量值。
Sound.setMusicVolume = function(volume)
  audio_music_set_volume(volume);
end

---
-- 预加载音效.可以同时预加载、播放多个音效文件 。
-- 音效加载可能需要一些时间，所以可以提前加载(但这不是必须的)。
-- 如在加载界面时预加载音效文件，之后便可以在显示界面时流畅地播放音效，避免因加载音效文件而卡顿。
--
-- @param #string fileName 文件路径+文件名，这个文件路径默认是以 /Resource/audio为根目录的。
Sound.preloadEffect = function(fileName)
  audio_effect_preload(fileName);
end

---
-- 卸载音效.
-- 可释放该音效所占用的内存。
-- @param #string fileName 文件路径+文件名，这个文件路径默认是以 /Resource/audio为根目录的。
Sound.unloadEffect = function(fileName)
  audio_effect_unload(fileName);
end

---
-- 播放音效.
-- 如果之前预加载过或上次加载的没释放就不会再加载了，否则，就会先加载再播放。
--
-- @param #string fileName 文件路径+文件名，这个文件路径默认是以 /Resource/audio为根目录的。
-- @param #boolean loop 是否无限循环播放。
-- @return #number 此音效的唯一id，可使用此id来停止音效的播放。
Sound.playEffect = function(fileName, loop)
  return audio_effect_play(fileName,loop and kTrue or kFalse);
end

---
-- 停止播放音效.
-- 一般情况下都不需要手动调用这个接口停止音效，只有在循环播放音效时才会用到，不会释放对应的内存。
--
-- @param #number id 音效的唯一id，默认id=0，该值是调用@{#Sound.playEffect}返回的。
Sound.stopEffect = function(id)
  audio_effect_stop(id or 0);
end

---
-- 获得音效的音量值.
--
-- @return #number 音效的当前音量值。
Sound.getEffectVolume = function()
  return audio_effect_get_volume();
end


---
-- 获得当前系统音效允许的最大音量.
-- 不同设备上可能不一样，同一种设备的最大音量也是可以修改的，可以根据这个值去设置实际播放音效的音量值。
--
-- @return #number 音效的最大音量值。
Sound.getEffectMaxVolume = function()
  return audio_effect_get_max_volume();
end

---
-- 设置音效的音量.
-- 最灵活的用法是根据@{#Sound.getEffectMaxVolume}返回的值乘以一个百分比作为实参。
--
-- @param #number volume 指定的音量值。
Sound.setEffectVolume = function(volume)
  audio_effect_set_volume(volume);
end

end
        

package.preload[ "core.sound" ] = function( ... )
    return require('core/sound')
end
            

package.preload[ "core/state" ] = function( ... )

--------------------------------------------------------------------------------
-- state是一个状态类，是所有状态的基类。可以理解为一个游戏“场景”，类似于android里的Activity.
-- @{core.stateMachine#StateMachine}会用来管理这些状态。
--
--游戏状态完整的生命周期为：
--
-- ctor -> load -> run -> resume -> pause -> stop -> unload -> dtor
-- @module core.state
-- @return #nil
-- @usage
-- require("core/state")
--
-- HallState = class(State)
--
-- HallState.ctor = function(self)
-- end
--
-- HallState.load = function(self)
--  --仅为演示，实际开发时一般是使用SceneLoader来加载UI编辑器设计的界面
-- 	local root = new(Node)
-- 	root:addToRoot()
-- 	self.m_root_node = root
-- 	return true
-- end
--
-- HallState.unload = function(self)
-- 	delete(self.m_root_node)
-- 	self.m_root_node = nil
-- end
--
-- HallState.stop = function(self)
-- 	self.m_root_node:setVisible(false)
-- end
--
-- HallState.run = function(self)
-- 	self.m_root_node:setVisible(true)
-- end
--
-- HallState.dtor = function(self)
-- end

require("core/object");

-- stateMachine.lua
-- Author: Vicent Gong
-- Date: 2012-11-21
-- Last modification : 2013-05-30
-- Description: Implement base state

---
-- State
--
-- @type State
State = class();

---
-- 构造函数.
-- 创建State实例时调用，此时进入@{#StateStatus.Unloaded}状态。
--
-- 构造函数中不应该包含大量的资源加载。
-- @param self
State.ctor = function(self)
  self.m_status = StateStatus.Unloaded;
end

---
-- 加载state的资源.
-- 此时进入@{#StateStatus.Loading}状态。
-- state的实例创建后，该方法会被不断调用，直至返回true为止，此时进入@{#StateStatus.Loaded}状态。
-- 如果state里的东西过多，可使用此特性来进行分步加载，这样游戏就不会有“卡住”的感觉。
--
-- **该方法不应被手动调用。**
--
-- @param self
State.load = function(self)
  self.m_status = StateStatus.Loading;
end

---
-- state即将进入前台显示，此时进入@{#StateStatus.Started}状态.
--
-- **该方法不应被手动调用。**
--
-- @param self
State.run = function(self)
  self.m_status = StateStatus.Started;
end

---
-- 该方法被调用后进入前台显示状态.
-- 此时进入@{#StateStatus.Resumed}状态。
--
-- 应在此方法中来启动动画，注册事件。
-- **该方法不应被手动调用。**
--
-- @param self
State.resume = function(self)
  self.m_status = StateStatus.Resumed;
end

---
-- state即将进入后台时被调用.
-- 此时进入@{#StateStatus.Paused}状态。
--
-- 应在此方法中暂停动画，取消事件注册。
-- **该方法不应被手动调用。**
--
-- @param self
State.pause = function(self)
  self.m_status = StateStatus.Paused;
end

---
-- state已经进入后台时被调用.
-- 此时进入@{#StateStatus.Stoped}状态。
--
-- **该方法不应被手动调用。**
--
-- @param self
State.stop = function(self)
  self.m_status = StateStatus.Stoped;
end

---
-- state即将退出时被调用.
-- 可在这里进行资源清理操作。此时进入@{#StateStatus.Unloaded}状态。
-- 此方法被调用后state的实例会被delete，之后将无法再被使用。
--
-- **该方法不应被手动调用。**
--
-- @param self
State.unload = function(self)
  self.m_status = StateStatus.Unloaded;
end

---
-- 析构函数.
-- 彻底释放状态资源。
--
-- @param self
State.dtor = function(self)
  self.m_status = StateStatus.Droped;
end

---
-- 获得当前state的状态.
--
-- @param self
-- @return #number 返回当前的state的状态。值为：@{#StateStatus.Unloaded}、@{#StateStatus.Loading}、@{#StateStatus.Loaded}、@{#StateStatus.Started}、@{#StateStatus.Resumed}、@{#StateStatus.Paused}、@{#StateStatus.Stoped}、@{#StateStatus.Droped}。
State.getCurStatus = function(self)
  return self.m_status;
end

---
-- 设置state的状态.
-- **该方法不应被手动调用。**
--
-- @param self
-- @param #number state 状态 取值：@{#StateStatus.Unloaded}、@{#StateStatus.Loading}、@{#StateStatus.Loaded}、@{#StateStatus.Started}、@{#StateStatus.Resumed}、@{#StateStatus.Paused}、@{#StateStatus.Stoped}、@{#StateStatus.Droped}。
State.setStatus = function(self, state)
  self.m_status = state;
end

---
-- state的状态.
--
-- @type StateStatus
-- @field #number Unloaded 未加载(实例刚刚创建)。
-- @field #number Loading 正在加载资源。
-- @field #number Loaded 已经完成资源加载。
-- @field #number Started 即将进入前台显示 (参考android的onStart)。
-- @field #number Resumed 已经进入前台显示，开始启动动画，事件注册。 (参考android的OnResume)。
-- @field #number Paused 进入后台，暂停动画，取消注册事件。 (参考android的onPause)。
-- @field #number Stoped 进入后台，隐藏界面 (参考android的onStop)。
-- @field #number Droped 已经调用delete方法进行销毁 (参考android的onDestroy)。
StateStatus =
  {
    Unloaded  	= 1;
    Loading	  	= 2;
    Loaded		= 3;
    Started		= 4;
    Resumed		= 5;
    Paused		= 6;
    Stoped		= 7;
    Droped		= 8;
  };


---
-- 释放函数的映射表.
State.s_releaseFuncMap =
  {
    [StateStatus.Unloaded] 	= {};
    [StateStatus.Loading] 	= {"unload"};
    [StateStatus.Loaded] 	= {"unload"};
    [StateStatus.Started] 	= {"stop","unload"};
    [StateStatus.Resumed] 	= {"pause","stop","unload"};
    [StateStatus.Paused] 	= {"stop","unload"};
    [StateStatus.Stoped] 	= {"unload"};
    [StateStatus.Droped] 	= {};
  };

end
        

package.preload[ "core.state" ] = function( ... )
    return require('core/state')
end
            

package.preload[ "core/stateMachine" ] = function( ... )

--------------------------------------------------------------------------------
-- 用于管理不同的state（详见：@{core.state}）之间的切换.
--
-- * 一个游戏有很多个state，但特定时间内只有一个state是处于活动状态。state可以理解为舞台或者场景。
--
-- * 开发者只需要关注@{#StateMachine.getInstance}, @{#StateMachine.changeState},@{#StateMachine.pushState},@{#StateMachine.popState}这几个方法，使用这几个方法来进行状态的切换。
--
-- * stateMachine是一个单例模式，二次开发者不能手动创建一个对象，必须通过@{#StateMachine.getInstance}去获得一个全局实例，然后再调用其相应的方法。
--
-- <br/>
-- 下面说明在三种不同的方式切换场景时state各方法被执行的流程。
--
-- 1..**changeState：** 在currentState场景下使用changeState进入到newState场景时，方法执行流程如下：<br/>
-- ![changeState](http://engine.by.com:8080/hosting/data/1452248525715_5519090001263735005.png)<br/>
--
-- 2.**pushState：**  在currentState场景下使用pushState进入到newState场景时，方法执行顺序流程如下：<br/>
-- ![pushState](http://engine.by.com:8080/hosting/data/1452246737566_8837580739284487918.bmp)<br/>
--
-- 3.**popState：** 当前的场景，假设currentState为当前的活动状态，lasteState为currentState之前的状态，popState执行流程如下：<br/>
-- ![popState](http://engine.by.com:8080/hosting/data/1452242842585_1165089751546056283.png)<br/>
--
--
-- Create :创建这个State。<br/>
-- load   :加载State所需要的资源，如果没有加载完会一直加载直到加载完成。<br/>
-- run    :将已经加载好的State显示在屏幕上。<br/>
-- resume :启动动画以及注册事件。<br/>
-- pasue  :暂停动画以及取消事件注册。<br/>
-- stop   : 隐藏界面。  <br/>
-- unload :卸载State所需要的资源。<br/>
-- delete :删除State对象。<br/>
-- @module core.stateMachine
-- @return #nil
-- @usage require("core/stateMachine")

-- stateMachine.lua
-- Author: Vicent Gong
-- Date: 2012-07-09
-- Last modification : 2013-05-30
-- Description: Implement a stateMachine to handle state changing in global

require("core/object");
require("core/state");
require("core/anim");
require("core/constants");

local s_instance = nil
---
--
-- @type StateMachine
StateMachine = class();

---
-- 获得实例，StateMachine以单例形式使用.
--
-- @return #StateMachine 唯一实例。
StateMachine.getInstance = function()
  if not s_instance then
    s_instance = new(StateMachine);
  end

  return s_instance;
end

---
-- 释放单例.
-- 调用此方法会清理所有已经存在的State实例，
-- 此方法不需要关心，无需被使用。
StateMachine.releaseInstance = function()
  delete(s_instance);
  s_instance = nil;
end

---
-- 注册一个场景切换动画处理器.
--
-- @param self 调用者对象。
-- @param #number style 切换动画函数的键值，切换场景时传入该值即使用这种切换效果。
-- @param #function func 处理场景切换动画的函数。
--
-- 在场景切换的时候会调用此函数，函数传入参数为：```func(newStateObj, lastStateObj, callbackObj, callbackFunc)```。
--
-- * newStateObj: 新State的实例对象。
--
-- * lastStateObj: 上一个State的实例对象，如果是刚进入游戏切入第一个场景，则lastStateObj为nil。
--
-- * callbackObj: 状态切换回调函数的对象。
--
-- * callbackFunc: 动画完成后**必须**要手动调用此函数，调用形式为 ```callbackFunc(callbackObj)```。
StateMachine.registerStyle = function(self, style, func)
  self.m_styleFuncMap[style] = func;
end

---
-- 切换到新场景，旧场景会被释放.
-- 现有的所有场景会根据其当前的状态和@{core.state#State.s_releaseFuncMap}的映射表来释放相应的场景。
--
-- @param self 调用者对象。
-- @param #number state 需要被切换到的state。
--	StateMachine在创建一个State的实例时,
--	会以state为索引值，去名为StatesMap的全局变量中找到该state对应的State类，然后创建该类的实例。
--	通常用法如下：
--	通常在statesConfig.lua文件中。
--	States = {
--		Hall = 1,
--		Room = 2
--	}
--	StatesMap = {
--		[States.Hall] = HallState,
--		[States.Room] = RoomState,
--	}
--	在切换到Hall时则调用 StateMachine.getInstance():changeState(States.Hall)。
--	@param #number style 场景切换动画 详见@{#StateMachine.registerStyle}。
--	@param ... 其他参数，创建state的实例时传入构造方法。
StateMachine.changeState = function(self, state, style, ...)
  if not StateMachine.checkState(self,state) then
    return
  end

  local newState,needLoad = StateMachine.getNewState(self,state,...);
  local lastState = table.remove(self.m_states,#self.m_states);

  --release all useless states
  for k,v in pairs(self.m_states) do
    StateMachine.cleanState(self,v);
  end

  --Insert new state
  self.m_states = {};
  self.m_states[#self.m_states+1] = newState;
  StateMachine.switchState(self,needLoad,false,lastState,true,style);
end

---
-- 切换到新场景，旧场景不会被释放.
-- 原有的场景会进入后台，但不会被释放。
--
-- @param self 调用者对象。
-- @param #number state 需要被切换到的state。
-- @param #number style  场景切换动画 详见@{#StateMachine.registerStyle}。
-- @param #boolean isPopupState 如果此值为true，则现处于活动状态的场景的stop方法不会被调用，即不隐藏当前活动的场景。
-- @param ... 其他参数，创建新的state实例时传入构造函数。
StateMachine.pushState = function(self, state, style, isPopupState, ...)
  if not StateMachine.checkState(self,state) then
    return
  end

  local newState,needLoad = StateMachine.getNewState(self,state,...);
  local lastState = self.m_states[#self.m_states];

  self.m_states[#self.m_states+1] = newState;

  StateMachine.switchState(self,needLoad,isPopupState,lastState,false,style);
end

---
-- 切换到上一个保存的场景.
-- 清理当前场景，并恢复上一个场景。
-- 如果当前并没有其他后台状态的场景，则调用此方法会error。
-- 一般使用方法是：使用pushState来进入一个新场景，退出时调用popState则会回到上一个场景。
--
-- @param self 调用者对象。
-- @param #number style 场景切换动画 详见@{#StateMachine.registerStyle}。
StateMachine.popState = function(self, style)
  if not StateMachine.canPop(self) then
    error("Error,no state in state stack\n");
  end

  local lastState = table.remove(self.m_states,#self.m_states);
  StateMachine.switchState(self,false,false,lastState,true,style);
end

---------------------------------private functions-----------------------------------------

---
-- 构造函数.
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
StateMachine.ctor = function(self)
  self.m_states 			= {};
  self.m_lastState 		= nil;
  self.m_releaseLastState = false;

  self.m_loadingAnim		= nil;
  self.m_isNewStatePopup	= false;

  self.m_styleFuncMap = {};
end

--Check if the current state is the new state and clean unloaded states

---
-- 检测是否需要切换到指定的状态.
-- 如果将要切换到的状态是正在运行的状态，则不会进行任何切换场景的操作。
-- 如果前一个state并没有完成加载，则会被清理掉。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #number state 需要被检查的State。
-- @return #boolean 返回true即当前的state不是正在运行的State需要进行场景切换操作；返回false则当前的state是正在运行的State，不需要进行场景切换操作。
StateMachine.checkState = function(self, state)
  delete(self.m_loadingAnim);
  self.m_loadingAnim = nil;

  local lastState = self.m_states[#self.m_states];
  if not lastState then
    return true;
  end
  if lastState.state == state then
    return false;
  end

  local lastStateObj = lastState.stateObj;
  if lastStateObj:getCurStatus() <= StateStatus.Loaded then
    StateMachine.cleanState(self,lastState);
    self.m_states[#self.m_states] = nil;
    return StateMachine.checkState(self,state);
  else
    return true;
  end
end

---
-- 获取一个新的State实例.
-- 如果已经存在，则会直接使用，不会创建新的。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #number state 需要被获取的State。
-- @param ... 新实例的构造参数。
-- @return #table,#boolean 新的State，是否需要加载新的State实例对象（返回true,需要加载新的State，返回false不需要加载新的State）。
StateMachine.getNewState = function(self, state, ...)
  local nextStateIndex;
  for i,v in ipairs(self.m_states) do
    if v.state == state then
      nextStateIndex = i;
      break;
    end
  end

  local nextState;
  if nextStateIndex then
    nextState = table.remove(self.m_states,nextStateIndex);
  else
    nextState = {};
    nextState.state = state;
    nextState.stateObj = new(StatesMap[state],...);
  end

  return nextState,(not nextStateIndex);
end

---
-- 是否有处于后台状态的state用来进行popState操作.
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @return #boolean  返回true表示可以进行popState操作，返回false表示不能进行popState操作。
StateMachine.canPop = function(self)
  if #self.m_states < 2 then
    return false;
  else
    return true;
  end
end

---
-- 开始进行state切换操作.
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #boolean needLoadNewState 新的state是否需要进行load操作。needLoadNewState为true则需要加载；needLoadNewState为false则不需要加载。
-- @param #boolean isNewStatePopup 切换前的state是否执行stop操作。isNewStatePopup为true，则切换前的state不会被stop即不会被隐藏；isNewStatePopup为false，则切换前的state会执行stop，即会被隐藏。
-- @param #table lastState 切换前的state。
-- @param #boolean needReleaseLastState 是否需要释放切换前的state。
-- @param #number style 场景切换动画 详见@{#StateMachine.registerStyle}。
StateMachine.switchState = function(self, needLoadNewState, isNewStatePopup,
  lastState, needReleaseLastState,
  style)

  self.m_isNewStatePopup = isNewStatePopup;

  self.m_lastState = lastState;
  self.m_releaseLastState = needReleaseLastState;
  self.m_style = style;

  StateMachine.pauseState(self,self.m_lastState);

  if needLoadNewState then
    self.m_loadingAnim = new(AnimInt,kAnimRepeat,0,1,1);
    self.m_loadingAnim:setEvent(self,StateMachine.loadAndRun);
  else
    StateMachine.run(self);
  end
end

---
-- 对新切入的state执行load和run操作.
-- 该方法是一个每帧循环调用的AnimInt的回调函数。
-- 每帧调用一次state的load函数，直至返回true时再调用state的run函数。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
StateMachine.loadAndRun = function(self)
  local stateObj = self.m_states[#self.m_states].stateObj;
  if stateObj:load() then
    delete(self.m_loadingAnim);
    self.m_loadingAnim = nil;
    stateObj:setStatus(StateStatus.Loaded);
    StateMachine.run(self);
  end
end

---
-- 执行需要切入的state的run方法.
-- 在@{#StateMachine.loadAndRun}之后，调用state的run方法。
-- 随后调用场景切换动画的处理函数(如果有)。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
StateMachine.run = function(self)
  StateMachine.runState(self,self.m_states[#self.m_states]);

  local newStateObj = self.m_states[#self.m_states].stateObj;
  if self.m_lastState and self.m_style and self.m_styleFuncMap[self.m_style] then
    self.m_styleFuncMap[self.m_style](newStateObj,self.m_lastState.stateObj,self,StateMachine.onSwitchEnd);
  else
    StateMachine.onSwitchEnd(self);
  end
end

---
-- 切换场景的最后一步，处理当前场景和上一场景的最终状态.
-- 处理切换前的场景，可能有3种情况：
--
-- 1.changeState时，切换前的场景进行释放。
--
-- 2.pushState时，isPopupState参数为false时，执行切换前的场景的stop函数。
--
-- 3.pushState，并且isPopupState参数为true时，参考@{#StateMachine.pushState}，什么也不做。
--
--
-- 最后执行新场景的resume函数。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
StateMachine.onSwitchEnd = function(self)
  if self.m_lastState then
    if self.m_releaseLastState then
      StateMachine.cleanState(self,self.m_lastState);
    elseif self.m_isNewStatePopup then

    else
      self.m_lastState.stateObj:stop();
    end
  end

  self.m_lastState = nil;
  self.m_releaseLastState = false;

  local newState = self.m_states[#self.m_states].stateObj;
  newState:resume();
end

---
-- 对一个state执行清理工作.
--
-- 现有的所有场景会根据其当前的状态和@{core.state#State.s_releaseFuncMap}的映射表来执行相应的函数并释放场景。
--
-- 如：
--
-- 一个state处于 @{core.state#StateStatus.Resumed}状态，则会执行pause->stop->unload->delete。
--
-- 一个state处于 @{core.state#StateStatus.Paused}状态，则会执行stop->unload->delete。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #table state 需要被清理的state。
StateMachine.cleanState = function(self, state)
  if not (state and state.stateObj) then
    return
  end

  local obj = state.stateObj;
  for _,v in ipairs(State.s_releaseFuncMap[obj:getCurStatus()]) do
    obj[v](obj);
  end
  delete(obj);
end

---
-- 执行一个state的run函数.
-- 只有当处于StateStatus.Loaded或StateStatus.Stoped状态时才会执行。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #table state 将要被运行的state。
StateMachine.runState = function(self, state)
  if not (state and state.stateObj) then
    return
  end

  local obj = state.stateObj;
  if obj:getCurStatus() == StateStatus.Loaded
    or obj:getCurStatus() == StateStatus.Stoped  then
    obj:run();
  end
end

---
-- 执行一个state的pause方法.
-- 只有当state处于StateStatus.Resumed状态时才会执行。
--
-- **注：该函数被标记为“private function”，不建议直接调用该函数。**
--
-- @param self 调用者对象。
-- @param #table state 将要被暂停的state。
StateMachine.pauseState = function(self, state)
  if not (state and state.stateObj) then
    return
  end

  local obj = state.stateObj;
  if obj:getCurStatus() == StateStatus.Resumed then
    obj:pause();
  end
end

---
-- 析构函数.
-- 会清理掉所有已经存在的state。
--
-- @param self 调用者对象。
StateMachine.dtor = function(self)
  for i,v in pairs(self.m_states) do
    StateMachine.cleanState(self,v);
  end

  self.m_states = {};
end

end
        

package.preload[ "core.stateMachine" ] = function( ... )
    return require('core/stateMachine')
end
            

package.preload[ "core/system" ] = function( ... )

--------------------------------------------------------------------------------
-- 用于一些系统设置或获得系统配置.
-- 如获得图片路径、设置设计分辨率等。
--
-- @module core.system
-- @return #nil
-- @usage require("core/system")

-- system.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-30
-- Description: provide basic wrapper for system functions

require("core/object");
require("core/constants")
require("core/res")

local s_resolution   = nil
local s_screenWidth  = nil
local s_screenHeight = nil
local s_layoutWidth  = nil
local s_layoutHeight = nil
local s_layoutScale  = nil
local s_screenScaleWidth = nil
local s_screenScaleHeight = nil
local s_platform = nil
local s_language = nil
local s_country = nil

---
-- @type System
System = {}

---
-- 获得屏幕分辨率.
--
-- @return #string resolution 格式如：1280x720。
System.getResolution = function()
    s_resolution = s_resolutions or sys_get_string("resolution");
    return s_resolution
end


---
-- 获得屏幕宽。
--
-- @return #number width 屏幕宽(像素)。
System.getScreenWidth = function()
    s_screenWidth = s_screenWidth or sys_get_int("screen_width",0);
    return s_screenWidth;
end

---
-- 获得屏幕高。
--
-- @return #number height 屏幕高。
System.getScreenHeight = function()
    s_screenHeight = s_screenHeight or sys_get_int("screen_height",0);
    return s_screenHeight;
end

---
-- 设置设计分辨率的宽(用于进行屏幕适配)。
--
-- @param #number width 设计分辨率的宽。
System.setLayoutWidth = function(width)
    s_layoutWidth = width;
end

---
-- 设置设计分辨率的高(用于进行屏幕适配)。
--
-- @param #number height 设计分辨率的高。
System.setLayoutHeight = function(height)
    s_layoutHeight = height;
end

---
-- 获得设计分辨率的宽。
--
-- @param #number width 如果未设置过，则返回屏幕宽。
System.getLayoutWidth = function()
    return s_layoutWidth or System.getScreenWidth();
end

---
-- 获得设计分辨率的高。
--
-- @param #number height 如果未设置过，则返回屏幕高。
System.getLayoutHeight = function()
    return s_layoutHeight or System.getScreenHeight();
end

---
-- 重新计算layoutScale.
System.updateLayout = function()
  local xScale = System.getScreenWidth() / System.getLayoutWidth();
  local yScale = System.getScreenHeight() / System.getLayoutHeight();
  s_layoutScale = xScale>yScale and yScale or xScale;

  Window.instance().drawing_root.size = Point(System.getScreenWidth()/s_layoutScale,System.getScreenHeight()/s_layoutScale);
  Window.instance().drawing_root.scale = Point(s_layoutScale,s_layoutScale);

end

---
-- 获得适配缩放比例.
-- 如果未设置过设计分辨率，则比例为1。
-- 否则为屏幕大小和设计分辨率大小的比例，以宽高中小的为准。
--
-- @return #number 适配缩放比例。
System.getLayoutScale = function()
    return s_layoutScale;
end

---
-- 获得经过缩放计算后的屏幕宽.
-- 屏幕实际宽/缩放比例。
--
-- @return #number 经过缩放计算后的屏幕宽。
System.getScreenScaleWidth = function()
    s_screenScaleWidth = System.getScreenWidth() / s_layoutScale;
    return s_screenScaleWidth;
end

---
-- 获得经过缩放计算后的屏幕高.
-- 屏幕实际高度/缩放比例。
--
-- @return #number 经过缩放计算后的屏幕高。
System.getScreenScaleHeight = function()
    s_screenScaleHeight = System.getScreenHeight() / s_layoutScale;
    return s_screenScaleHeight;
end


---
-- 获得当前平台类型.
-- win32/android/ios/wp8。
--
-- @return #string 平台类型。
System.getPlatform = function()
    s_platform = s_platform or sys_get_string("platform");
    return s_platform;
end

---
-- 获得当前系统的语言.
-- 此值根据各平台的接口获取。
--
-- @return #string 系统的语言。如在win32中文系统下，返回值是zh。
System.getLanguage = function()
    s_language = s_language or sys_get_string("language");
    return s_language;
end

---
-- 获得当前系统的国家.
-- 此值根据各平台的接口获取。
--
-- @return #string country 如在win32下返回为CN。
System.getCountry = function()
    s_country = s_country or sys_get_string("country");
    return s_country;
end

---
-- 获得在执行此代码之前已经创建的res(@{core.res})的数量。
--
-- @return #number res的数量。
System.getResNum = function()
    return sys_get_int("res_num",0);
end

---
-- 获得在执行此代码之前已经创建的anim(@{core.anim})的数量。
--
-- @return #number anim的数量。
System.getAnimNum = function()
    return sys_get_int("anim_num",0);
end

---
-- 获得在执行此代码之前已经创建的prop(@{core.prop})的数量。
--
-- @return #number prop的数量。
System.getPropNum = function()
    return sys_get_int("prop_num",0);
end

---
-- 获得在执行此代码之前已经创建的drawing(@{core.drawing})的数量。
--
-- @return #number drawing的数量。
System.getDrawingNum = function()
    return sys_get_int("drawing_num",0);
end

---
-- 获得一个唯一的uuid.
-- 此uuid在第一次启动时生成
--
-- @return #string 唯一的uuid。
System.getGuid = function()
    return sys_get_string("uuid");
end

---
-- 设置上一次的lua错误信息.
-- 此方法一般不应该手动调用。
-- @param #string strValue 错误信息。
-- @return #string 上一次的lua错误信息。
System.setLuaError = function(strValue)
    return sys_set_string("last_lua_error",strValue);
end

---
-- 获得上一次lua的错误信息。
--
-- @return #string 上一次lua的错误信息。
System.getLuaError = function()
    return sys_get_string("last_lua_error");
end

---
-- ---
-- 当前这一帧循环花了多少时间。
--
-- @return #number 当前帧循环所花的世界（单位：毫秒）。
System.getTickTime = function()
    return sys_get_int("tick_millseconds",0);
end

---
-- 获取windows_guid，同@{#System.getGuid}。
-- @return #string 获取windows的uid.
System.getWindowsGuid = function()
    return sys_get_string("windows_guid");
end

---
-- 设置win32环境下的文字编码.
--
-- @param #string code 编码格式。
System.setWin32TextCode = function(code)
    GameString.setWin32Code(code);
end

---
-- 设置默认文字的字体名和字号.
-- 详见： @{core.res#ResText.setDefaultFontNameAndSize}。
--
-- @param #string fontName 字体名称。
-- @param #number fontSize 字体大小.实际大小依据不同的平台而定，例如Windows和Android平台大小可能会不同.
System.setDefaultFontNameAndSize = function(fontName, fontSize)
    ResText.setDefaultFontNameAndSize(fontName,fontSize);
end

---
-- 设置默认文字的颜色.
-- 详见： @{core.res#ResText.setDefaultColor}。
--
-- @param #number r 文字的RGB颜色的R分色.取值范围：[0,255].
-- @param #number g 文字的RGB颜色的G分色.取值范围：[0,255].
-- @param #number b 文字的RGB颜色的B分色.取值范围：[0,255].
System.setDefaultTextColor = function(r, g, b)
    ResText.setDefaultColor(r,g,b);
end

---
-- 设置文字默认对齐方式 .
-- 
-- @param #number align 文字对齐方式。
-- 详见：@{core.res#ResText.setDefaultTextAlign}。
System.setDefaultTextAlign = function(align)
    ResText.setDefaultTextAlign(align);
end

---
-- 设置图片的默认目录.  
-- 
-- @param #function func 设置图片的目录的函数。
-- 详见：@{core.res#ResImage.setPathPicker}。
System.setImagePathPicker = function(func)
    ResImage.setPathPicker(func);
end

---
-- 设置图片的默认纹理像素格式.
--   
-- @param #function func 设置纹理像素格式的函数.
-- 详见：@{core.res#ResImage.setFormatPicker}。
System.setImageFormatPicker = function(func)
    ResImage.setFormatPicker(func);
end

---
-- 设置图片的默认纹理过滤方式. 
-- 
-- @param #function func 设置过滤方式的函数.  
-- 
-- 详见：@{core.res#ResImage.setFilterPicker}。
System.setImageFilterPicker = function(func)
    ResImage.setFilterPicker(func);
end

-------------------------------------------------

---
-- 获得外部存储里scripts的目录.
-- android环境下是 /sdcard/.PACKAGENAME/scripts/。
--
-- @return #string scripts目录。
System.getStorageScriptPath = function()
    return sys_get_string("storage_user_scripts") or "";
end

---
-- 获得外部存储里images的目录.
-- android环境下是 /sdcard/.PACKAGENAME/images/。
--
-- @return #string images的目录。
System.getStorageImagePath = function()
    return sys_get_string("storage_user_images") or "";
end

---
-- 获得外部存储里audio的目录.
-- android环境下是 /sdcard/.PACKAGENAME/audio/。
--
-- @return #string audio的目录。
System.getStorageAudioPath = function()
    return sys_get_string("storage_user_audio") or "";
end

---
-- 获得外部存储里font的路径.
-- android环境下是 /sdcard/.PACKAGENAME/fonts/。
--
-- @return #string font的路径。
System.getStorageFontPath = function()
    return sys_get_string("storage_user_fonts") or "";
end

---
-- 获得外部存储里xml的路径.
-- android环境下是 /sdcard/.PACKAGENAME/xml/。
--
-- @return #string xml的路径。
System.getStorageXmlPath = function()
    return sys_get_string("storage_xml") or "";
end

---
-- 获得外部存储里update的路径.
-- android环境下是 /sdcard/.PACKAGENAME/update/。
--
-- @return #string update的路径。
System.getStorageUpdatePath = function()
    return sys_get_string("storage_update_zip") or "";
end

---
-- 获得外部存储里dict的路径.
-- android环境下是 /sdcard/.PACKAGENAME/dict/。
--
-- @return #string dict的路径。
System.getStorageDictPath = function()
    return sys_get_string("storage_dic") or "";
end

---
-- 获得外部存储里log的路径.
-- android环境下是 /sdcard/.PACKAGENAME/log/。
--
-- @return #string log的路径。
System.getStorageLogPath = function()
    return sys_get_string("storage_log") or "";
end


---
-- 获得外部存储里user的路径.
-- android环境下是 /sdcard/.PACKAGENAME/user/
--
-- @return #string user的路径。
System.getStorageUserPath = function()
    return sys_get_string("storage_user_root") or "";
end


---
-- 获得外部存储里temp的路径.
-- android环境下是 /sdcard/.PACKAGENAME/tmp/。
--
-- @return #string temp的路径。
System.getStorageTempPath = function()
    return sys_get_string("storage_tmp") or "";
end

---
-- win32下返回Resource所在目录。
-- Android下返回Activity.getInstance().getApplication().getFilesDir().getAbsolutePath()，路径是/data/data/com.boyaa.xxx/files/。
--
-- @return #string app的路径。
System.getStorageAppRoot = function()
    return sys_get_string("storage_app_root") or "";
end

---
-- win32下返回Resource\Inner所在目录。
-- Android下返回Activity.getInstance().getApplication().getFilesDir().getAbsolutePath()，路径是/data/data/com.boyaa.xxx/files/。
--
-- @return #string app的inner路径。
System.getStorageInnerRoot = function()
    return sys_get_string("storage_inner_root") or "";
end

---
--win32下返回Resource\Outer所在目录；
--Android下返回: 某些设备上路径是/mnt/sdcard/.PACKAGENAME/，也有些是/storage/emulated/0/，后者比较多。
--
-- @return #string 路径。
System.getStorageOuterRoot = function()
    return sys_get_string("storage_outer_root") or "";
end


---
-- 删除一个文件。
--
-- @param #string filePath 文件全路径。
-- @return #boolean  是否删除成功。返回true则删除成功，返回false则删除失败。
System.removeFile = function(filePath)
    if os.isexist(filePath) == false then
        return false
    end
    return os.remove(filePath);
end


---
-- 复制一个文件。
--
-- @param #string srcFilePath 要复制的文件的全路径。
-- @param #string destFilePath 目标路径。
-- @return #boolean  是否复制成功。返回true复制成功，返回false复制失败。
System.copyFile = function(srcFilePath,destFilePath)
    return os.cp(srcFilePath,destFilePath);
end

---
-- 获得文件的大小.
-- 需要确保有权限访问此文件。
-- @param #string filePath 文件全路径。
-- @return #number 文件大小(字节)。如果文件不存在或无权限访问，则返回-1。
System.getFileSize = function(filePath)
    if os.isexist(filePath)== false then
        return -1
    end
    return  os.filesize(filePath)
end

---
-- 添加一个图片搜索路径.
-- 添加的路径优先级会放到最高。
--
-- @param #string path 完整的路径。
System.pushFrontImageSearchPath = function(path)
    sys_set_string("push_front_images_path", path);
end

---
-- 添加一个声音搜索路径.
-- 添加的路径优先级会放到最高。
--
-- @param #string path 完整的路径。
System.pushFrontAudioSearchPath = function(path)
    sys_set_string("push_front_audio_path", path);
end

---
-- 添加一个字体搜索路径.
-- 添加的路径优先级会放到最高。
--
-- @param #string path 完整的路径。
System.pushFrontFontSearchPath = function(path)
    sys_set_string("push_front_fonts_path", path);
end

---
-- 获得版本号.
--
-- @return #string 版本号。
System.getVersion = function()
    return sys_get_string("version")
end


---
-- 是否启用模板测试.
-- 用到模板相关的功能需要先开启模板测试，否则无效。
--
-- @param #boolean state 是否打开模板测试，true为打开，false为关闭.
System.setStencilState = function (state)
    Window.instance().root.fbo.need_stencil = state
end

System.startTextureAutoCleanup = function (multiply)
    local totalMemory = Application.instance():getTotalMemory()
    local threshold = totalMemory * (multiply or (1 / 4))
    if System.getPlatform() == kPlatformAndroid and threshold > 0 then
        local _paused = false
        MemoryMonitor.instance():add_listener(threshold, function(size)
            if not _paused then
                _paused = true
                TextureCache.instance():clean_unused()
                Clock.instance():schedule_once(function()
                    if MemoryMonitor.instance().size > threshold then
                        TextureCache.instance():clean_unused()
                    end
                    _paused = false
                end, 5)
            end
        end)
    end
end

System.onInit = function ()
    collectgarbage("setpause", 100);
    collectgarbage("setstepmul", 5000);
    System.startTextureAutoCleanup();
    Label.config(System.getLayoutScale(), 24, false)
    Window.instance().root.fbo.need_stencil = true
end

end
        

package.preload[ "core.system" ] = function( ... )
    return require('core/system')
end
            

package.preload[ "core/systemEvent" ] = function( ... )

--------------------------------------------------------------------------------
-- 一些系统底层事件的调用.
-- **这里的方法都不应该被手动调用。**
--
-- @module core.systemEvent
-- @return #nil 
-- @usage require("core/systemEvent")

require 'core.eventDispatcher'


-- systemEvnet.lua
-- Author: Vicent.Gong
-- Date: 2013-01-25
-- Last modification : 2012-05-30
-- Description: Default engine event listener

-- raw touch 

---
-- 收到屏幕触摸事件，并派发触摸事件的消息.
--
-- @param #number finger_action 手指事件类型 取值:([```kFingerDown```](core.constants.html#kFingerDown)/[```kFingerMove```](core.constants.html#kFingerMove)/[```kFingerUp```](core.constants.html#kFingerUp)/[```kFingerCancel```](core.constants.html#kFingerCancel))
-- @param #number x 屏幕上的绝对x坐标。
-- @param #number y 屏幕上的绝对y坐标。 
-- @param #number drawing_id 手指触摸到的drawing对象的id。
function event_touch_raw(finger_action, x, y, drawing_id)
	EventDispatcher.getInstance():dispatch(Event.RawTouch,finger_action,x,y,drawing_id);
end

-- native call callback function

---
-- 收到native层(android/win32/ios等)的调用，并派发相应的消息.
-- 在native层使用`call_native("event_call")`会调用到这个方法。
function event_call()
	EventDispatcher.getInstance():dispatch(Event.Call);
end

---
-- 收到android上按返回键的事件，并派发此消息.
function event_backpressed()
	EventDispatcher.getInstance():dispatch(Event.Back);
end

---
-- 收到win32上的键盘按键事件，并派发此消息。
--
-- @param #number key 键盘码。
function event_win_keydown(key)
	EventDispatcher.getInstance():dispatch(Event.KeyDown,key);
end

-- application go to background

---
-- 收到应用程序进入后台的事件，并派发此消息.
-- 详见：@{core.system#System.setEventPauseEnable}。
function event_pause()
	EventDispatcher.getInstance():dispatch(Event.Pause);
end

-- application come to foreground

---
-- 收到应用程序进入前台的事件，并派发此消息.
-- 参见@{core.system#System.setEventResumeEnable}。
-- 留意：第一次启动程序时此事件并不会被触发。
function event_resume()
	EventDispatcher.getInstance():dispatch(Event.Resume); 
end       

-- system timer time up callback

---
-- 
-- 该方法是一个基于java层定时器的回调，
function event_system_timer()
	local timerId = dict_get_int("SystemTimer", "Id", -1);
	if timerId == -1 then
		return
	end
	
	EventDispatcher.getInstance():dispatch(Event.Timeout,timerId);
end
end
        

package.preload[ "core.systemEvent" ] = function( ... )
    return require('core/systemEvent')
end
            

package.preload[ "core/version" ] = function( ... )

--返回core版本号
return '3.1(d320db408d31cd3250ca811a969b70fcab7db33f)'

end
        

package.preload[ "core.version" ] = function( ... )
    return require('core/version')
end
            

package.preload[ "core/zip" ] = function( ... )
-- zip.lua
-- Author: JoyFang
-- Date: 2015-12-23


--------------------------------------------------------------------------------
-- 这个模块提供了解压缩```.zip```文件（夹）的方法。
--
-- @module core.zip
-- @usage local Zip= require 'core.zip' 

local M={}

---
--覆盖解压.zip文件.    
--文件名（路径）不支持中文. 
--@param #string zipFileName 需解压的zip文件，绝对路径.
--@param #string extractDir 解压的目标目录，绝对路径.**这个目录必须是存在的，引擎不会去创建。**
--@return #boolean true或false.  
--若文件路径有误或解压失败，则返回false；若解压成功，返回true.
M.unzipWholeFile =  function (zipFileName, extractDir)
    if zipFileName==nil or string.len(zipFileName)<1 then
     return false
    end
     if extractDir==nil or string.len(extractDir)<1 then
     return false
    end
   
    return  unzipWholeFile(zipFileName, extractDir,nil)==1
end


---
--覆盖解压.zip文件，支持解压zip的特定目录.
--文件名（路径）不支持中文. 
--@param #string zipFileName 需解压的zip文件.
--@param #string extractDirInZip 相对于zip文件某一级目录.若为空字符串则表示根目录.
--@param #string extractDir 解压的目标目录.
--@return #boolean true或false.  
--若文件路径有误或解压失败，则返回false；若解压成功，返回true.
M.unzipDir = function (zipFileName,extractDirInZip,extractDir)
    if zipFileName==nil or string.len(zipFileName)<1 then
     return false
    end

  if extractDir==nil or string.len(extractDir)<1 then
     return false
    end

    return unzipDir(zipFileName,extractDirInZip,extractDir,nil)==1
end
return M


end
        

package.preload[ "core.zip" ] = function( ... )
    return require('core/zip')
end
            
require("core.anim");
require("core.blend");
require("core.class");
require("core.constants");
require("core.dict");
require("core.drawing");
require("core.eventDispatcher");
require("core.gameString");
require("core.global");
require("core.gzip");
require("core.md5");
require("core.object");
require("core.prop");
require("core.res");
require("core.sound");
require("core.state");
require("core.stateMachine");
require("core.system");
require("core.systemEvent");
require("core.version");
require("core.zip");