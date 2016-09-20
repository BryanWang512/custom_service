-- NativeEvent.lua
-- 本地事件方法

NativeEvent = class();
NativeEvent.s_luaCallNavite = "OnLuaCall";
NativeEvent.s_luaCallEvent = "LuaCallEvent";
NativeEvent.s_platform = System.getPlatform();

kLuacallEvent="event_call"; -- 原生语言调用lua 入口方法
kcallEvent = "LuaEventCall"; -- 获得 指令值的key
kCallResult="CallResult"; --结果标示  0 -- 成功， 1--失败,2 -- ...
kResultPostfix="_result"; --返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key
kparmPostfix="_parm"; --参数后缀 

NativeEvent.getInstance = function()
	if not NativeEvent.s_instance then 
		NativeEvent.s_instance = new(NativeEvent);
	end
	return NativeEvent.s_instance;
end

NativeEvent.onEventCall = function()
	EventDispatcher.getInstance():dispatch(Event.Call,NativeEvent.getInstance():getNativeCallResult());
end


---
-- 收到native层(android/win32/ios等)的调用，并派发相应的消息.
-- 在native层使用`call_native("event_call")`会调用到这个方法。
function event_call()
	NativeEvent.onEventCall();
end


---
-- 收到win32上的键盘按键事件，并派发此消息。
--
-- @param #number key 键盘码。
function event_win_keydown(key)
	NativeEvent.onWinKeyDown(key);
end


NativeEvent.onWinKeyDown = function(key)
	if key == 81 then
		event_backpressed();
	else
		EventDispatcher.getInstance():dispatch(Event.KeyDown,key);
	end
end

-- 解析 call_native 返回值
NativeEvent.getNativeCallResult = function(self)
	local callParam = dict_get_string(kcallEvent,kcallEvent);
	local callResult = dict_get_int(callParam, kCallResult,-1);

    if callResult == 1 then -- 获取数值失败
        return callParam , false;
    end
    local result = dict_get_string(callParam , callParam .. kResultPostfix);
    dict_delete(callParam);
    local json_data = {};
    if result and type(result) == "string" and result == "onWindowFocusChanged" then
    	json_data.onWindowFocusChanged = "onWindowFocusChanged";
    else
	    json_data = cjson.decode(result);
	end
    Log.d("NativeEvent.getNativeCallResult callParam = "..callParam.." =========");
    --返回错误json格式.
    if json_data then
        return callParam ,true, json_data;
    else
        return callParam , true;
    end
end

--/////////////////////////////// android //////////////////////////////////

if NativeEvent.s_platform == kPlatformAndroid or NativeEvent.s_platform == kPlatformIOS then
	-- 公共call_native 方法
	NativeEvent.callNativeEvent = function(self , keyParm , data)
		if data then
			dict_set_string(keyParm,keyParm..kparmPostfix,data);
		end
		print_string("NativeEvent.RequestGallery=============01")
		dict_set_string(NativeEvent.s_luaCallEvent,NativeEvent.s_luaCallEvent,keyParm);
		call_native(NativeEvent.s_luaCallNavite);
	end

	
	--请求图库
	NativeEvent.RequestGallery = function(self,data)
		self:callNativeEvent("RequestGallery",data);
	end

	--拍照
	NativeEvent.RequestCapture = function(self,data)
		self:callNativeEvent("RequestCapture",data);
	end

end

--///////////////////////////////// Win32 ////////////////////////////////

if NativeEvent.s_platform ~= kPlatformAndroid and NativeEvent.s_platform ~= kPlatformIOS  then

	NativeEvent.callNativeEvent = function(self , keyParm , data)
		if data then
			dict_set_string(keyParm,keyParm..kparmPostfix,data);
		end
		dict_set_string(NativeEvent.s_luaCallEvent,NativeEvent.s_luaCallEvent,keyParm);
		call_native(NativeEvent.s_luaCallNavite);
	end

	--请求图库
	NativeEvent.RequestGallery = function(self,data)

	end

	--拍照
	NativeEvent.RequestCapture = function(self)
	end

end

