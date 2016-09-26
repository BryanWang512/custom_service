require(string.format('%smqttModule/boyaaConversation', KefuRootPath))
local HTTP2 = require("network.http2")
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))

--接收协议后的回调函数
local receviceCallback = require("conversation/protocalFunc")
local loginTaskClock = nil

netWorkControl = {}

netWorkControl.init = function ()

	if netWorkControl.MQTT then
		delete(netWorkControl.MQTT)
		netWorkControl.MQTT = nil
	end

	netWorkControl.initClock = Clock.instance():schedule_once(function()
		netWorkControl.MQTT = new(BoyaaConversation, mqtt_client_config, mqtt_client_info);
		EventDispatcher.getInstance():register(KefuEvent.mqttReceive, netWorkControl, netWorkControl.receiveProtocal)
		netWorkControl.sendProtocol("connect") 
			          
	end, 0.4)


end

netWorkControl.generateClientInfo = function (avatarUri)
	if netWorkControl.MQTT then
		return netWorkControl.MQTT:generateClientInfo(avatarUri)
	end

	return "" 
end



netWorkControl.sendProtocol = function (proName, ...)
	if netWorkControl.MQTT and netWorkControl.MQTT[proName] then
		netWorkControl.MQTT[proName](netWorkControl.MQTT, ...)
	end
end


netWorkControl.receiveProtocal = function (self, proName, ...)
	print_string("================receiveProtocal name:",proName)

	if proName == "end" then
		proName = "xend"
	end

	if receviceCallback[proName] then
		receviceCallback[proName](...)
	end
end

--不断发Login协议
netWorkControl.schedulePollLoginTask = function ()
	if not loginTaskClock then
		loginTaskClock = Clock.instance():schedule(function()
             netWorkControl.sendProtocol("login")   
        end, DELAY_POLL_LOGIN)
	else
		loginTaskClock.paused = false
	end
end


--取消循环login操作
netWorkControl.cancelPollLoginTask = function ()
	if loginTaskClock then
		loginTaskClock.paused = true
	end
end


netWorkControl.downLoadFile = function (url, filePath, callback)
	
	local data = UserData.getStatusData() or {}

	local args = {
      	url = url, 
	    headers = {

	    },

	    query = {                      -- optional, query_string
	        fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
	        session_id = data.sessionId,
	    },
	    timeout = 10,                    -- optional, seconds
	    connecttimeout = 10,             -- optional, seconds
	      writer = {                     -- optional, override writer behaviour.
		     type = 'file',                  -- save to file, rsp.content would be empty.
		     filename = filePath,
		     mode = 'wb',
		},
	}

	HTTP2.request_async(args,
	    function(rsp)
	    	--print("LoadHistoryMsg:"..rsp.content)
	    	if rsp.errmsg then
	    		print_string("DownLoadFile Fail:"..rsp.errmsg)
	    	elseif rsp.code == 200 and callback then
		     	callback()
		    end
	    end
    )
end


netWorkControl.upLoadFile = function (fullPath, callback,fileType)
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
                file_type = fileType,
            },                      
	    },
	}

	HTTP2.request_async(args,
	    function(rsp)
	    	if callback then
	    		callback(rsp)
	    	end
	    end
    )
end


--从网络拉取历史消息
netWorkControl.loadHistoryMsgFromNetwork = function (seqId, callback)
	local args = {
      	url = HTTP_NETWORK_HISTORY_MESSAGE_URI,
      	headers = {},
      	query = {
      		gid = mqtt_client_config.gameId,
      		site_id = mqtt_client_config.siteId,
      		client_id = mqtt_client_config.stationId,
      		seq_id = seqId,					--当前显示的最早的消息的seqId
      		limit = NETWORK_MESSAGE_LIMIT,
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
      
	}

	HTTP2.request_async(args,
	    function(rsp)
	      	if rsp.errmsg then
	      		Log.d("LoadHistoryMsg", "Fail:"..rsp.errmsg)
	    	elseif rsp.code == 200 and callback then
	    		Log.d("LoadHistoryMsg", "success: "..rsp.content)		    	
		    end

	     	callback(rsp)
	    end
    )
    
end

--获取用户留言,盗号，举报历史记录
netWorkControl.obtainUserTabHistroy = function (start, limit, url, callback)
	local args = {
      	url = url,
      	headers = {},
      	query = {
      		gid = mqtt_client_config.gameId,
      		site_id = mqtt_client_config.siteId,
      		client_id = mqtt_client_config.stationId,
      		start = start,					
      		limit = limit,
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
      
	}

	HTTP2.request_async(args,
	    function(rsp)
	      	if rsp.errmsg then
	    		Log.v("obtainUserAdviceHistroy","Fail:" ,rsp.errmsg);
	    	elseif rsp.code == 200 and callback then
	    		Log.v("obtainUserTabHistroy",":" ,rsp.content);
		     	callback(rsp.content)
		    	
		    end
	    end
    )

end




netWorkControl.postString = function (url, content, callback)

	local args = {
      	url = url,
      	headers = {
      		'Content-Type:application/json',
      		'Accept:application/json',
      		'charset:utf-8'
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
	    post = content,
	}

	HTTP2.request_async(args,
	    function(rsp)
	    	callback(rsp);
	     --  	if rsp.errmsg then
	    	-- 	Log.v("postString","提交失败:" ,rsp.errmsg);
	    	-- elseif rsp.code == 200 and callback then
	    	-- 	Log.v("postString","提交结果:" ,rsp.content);
		    --  	callback(rsp.content);
		    -- end
	    end
    )

end


netWorkControl.destroy = function (time)
	EventDispatcher.getInstance():unregister(KefuEvent.mqttReceive, netWorkControl, netWorkControl.receiveProtocal)

	if netWorkControl.initClock then
		netWorkControl.initClock:cancel()
		netWorkControl.initClock = nil
	end



	if netWorkControl.MQTT then
		delete(netWorkControl.MQTT)
		netWorkControl.MQTT = nil
	end	            

end

return netWorkControl