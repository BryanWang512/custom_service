local UI = require('byui/basic');
local AutoLayout = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))
require(string.format('%scommon/nativeEvent', KefuRootPath))
local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))


local currency
currency = class('currency', nil, {
	__init__ = function (self,root)
		if not root then return end;
		self.m_root = root;
		self.m_imgPath = "";
		self:createImg();
		self:createPicture();
	end,

	createImg = function(self)
		self.m_img = Widget();
		local wh = 105
		self.m_img:add_rules({
			AutoLayout.width:eq(wh),
			AutoLayout.height:eq(AutoLayout.parent('height')),
			AutoLayout.top:eq(0);
			AutoLayout.left:eq(70);
		})

		self.m_img_btn = UI.Button{
			text = "",
			radius = 0,
			border = 0,
			image = 
			{
				normal = TextureUnit(TextureCache.instance():get(KefuResMap.currencyPickNormal)),
				down   = TextureUnit(TextureCache.instance():get(KefuResMap.currencyPickDown)),
			},
		}
		self.m_img_btn:add_rules({
			AutoLayout.width:eq(wh),
			AutoLayout.height:eq(wh),
			AutoLayout.top:eq(26),
		})

		self.m_img_btn.on_click = function()
			EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent);
			self.m_imgPath = Clock.now() .. "_img.jpg"
			local savePath = string.format("%s%s",System.getStorageImagePath(),self.m_imgPath);
			local tab = {};
		    tab.savePath = savePath;
		    local json_data = json.encode(tab);
		    NativeEvent.getInstance():RequestGallery(json_data);
		end

		self.m_img_tx = Label();
		self.m_img_tx.layout_size = Point(wh, 0)
		self.m_img_tx.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4)/4
		self.m_img_tx.align_h = ALIGN.CENTER%4

		-- self.m_img_tx:add_rules{
		-- 	AutoLayout.top:eq(32+wh),
		-- 	AutoLayout.left:eq(15),
		-- }

		local data = {}
	    table.insert(data, {
	        text = "上传图片",                       -- 文本
	        color = Color(160,160,160,255),                -- 文字颜色
	        bg = Color(220,220,220,0),                 -- 背景色
	        size = 23,                           -- 字号
	        weight=1,                            -- 字体粗细

	    })
	    self.m_img_tx:set_data(data)
        
    	

    	self.m_img_tx.x = 0
    	self.m_img_tx.y = 150


        self.m_img:add(self.m_img_btn);
        self.m_img:add(self.m_img_tx);
        self.m_root:add(self.m_img);
        
	end,

	onNativeEvent = function(self,param,status, jsonTable)
		EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent);
		Log.v("currency" ,"self.onNativeEvent===================param:"..param);
		Log.v("currency" ,"self.onNativeEvent===================status:"..(status and 1 or 0));
		local fullPath = jsonTable.savePath;
		Log.v("currency" ,"self.onNativeEvent fullPath:" .. fullPath);

    	local data = UserData.getStatusData() or {}
    	local seqId = tostring(tonumber(os.time())*1000)
    	local message = ChatMessage(seqId, MessageType_Map.IMG, self.m_imgPath, data.sessionId or 1, 1)
    	--上传图片消息
    	SessionControl.dealwithSendMsg(message, fullPath)
	end,

	createPicture = function(self)
		local wh = 105

		self.m_picture = Widget();

		self.m_picture:add_rules({
			AutoLayout.width:eq(wh),
			AutoLayout.height:eq(AutoLayout.parent('height')),
			AutoLayout.top:eq(0);
			AutoLayout.left:eq(70+60+wh);
		})

		self.m_picture_btn = UI.Button{
			text = "",
			radius = 0,
			border = 0,
			image = 
			{
				normal = TextureUnit(TextureCache.instance():get(KefuResMap.currencyPictureNormal)),
				down   = TextureUnit(TextureCache.instance():get(KefuResMap.currencyPictureDown)),
			},
		}

		self.m_picture_btn:add_rules({
			AutoLayout.width:eq(wh),
			AutoLayout.height:eq(wh),
			AutoLayout.top:eq(26),
		})

		self.m_picture_btn.on_click = function()
			self.m_imgPath = Clock.now() .. "_img.jpg"
			local savePath = string.format("%s%s",System.getStorageImagePath(),self.m_imgPath);
			local tab = {};
		    tab.savePath = savePath;
		    local json_data = json.encode(tab);
		    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent);
		    NativeEvent.getInstance():RequestCapture(json_data);
		end

		self.m_picture_tx = Label();
		self.m_picture_tx.layout_size = Point(wh, 0)
		self.m_picture_tx.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4)/4
		self.m_picture_tx.align_h = ALIGN.CENTER%4
		local data = {}
	    table.insert(data, {
	        text = "拍摄",                       -- 文本
	        color = Color(160,160,160,255),                -- 文字颜色
	        bg = Color(220,220,220,0),                 -- 背景色
	        size = 23,                           -- 字号
	        weight=1,                            -- 字体粗细

	    })
	    self.m_picture_tx:set_data(data)

        
    	self.m_picture_tx.x = 0
    	self.m_picture_tx.y = 150

        self.m_picture:add(self.m_picture_btn);
        self.m_picture:add(self.m_picture_tx);
        self.m_root:add(self.m_picture);
	end,

})


return currency