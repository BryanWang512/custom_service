
function event_load ( width, height )

    require("EngineCore/config")
	
    System.setStencilState(true);
    
    -- System.setClearBackgroundEnable(true);
    require("clientInfo");
    require("mqttModule/boyaaConversation");

    local mqtt
    local text
	createBtn = new(Button, "ui/button.png");
	createBtn:addToRoot();
	createBtn:setPos(100, 100);
    text = new(Text, "create", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    createBtn:addChild(text);
	createBtn:setOnClick(nil, function()
		mqtt = new(BoyaaConversation, mqtt_client_config, mqtt_client_info);
	end)
	
	
	startBtn = new(Button, "ui/button.png");
	startBtn:addToRoot();
	startBtn:setPos(300, 100);
    text = new(Text, "connect", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    startBtn:addChild(text);
	startBtn:setOnClick(nil, function()
		mqtt:connect();
	end)
	
	 stopBtn = new(Button, "ui/button.png");
	stopBtn:addToRoot();
	stopBtn:setPos(500, 100);
    text = new(Text, "subscribe", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    stopBtn:addChild(text);
	stopBtn:setOnClick(nil, function()
		mqtt:subscribe();
	end)
	
	desBtn = new(Button, "ui/button.png");
	desBtn:addToRoot();
	desBtn:setPos(700, 100);
    text = new(Text, "login", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    desBtn:addChild(text);
	desBtn:setOnClick(nil, function()
		mqtt:login();
	end)
	
	trackBtn = new(Button, "ui/button.png");
	trackBtn:addToRoot();
	trackBtn:setPos(100, 250);
    text = new(Text, "chatReady", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    trackBtn:addChild(text);
	trackBtn:setOnClick(nil, function()
		mqtt:sendChatReadyMsg(mqtt:generateClientInfo(""));
	end)
	
	trackStopBtn = new(Button, "ui/button.png");
	trackStopBtn:addToRoot();
	trackStopBtn:setPos(300, 250);
    text = new(Text, "chatMsg", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    trackStopBtn:addChild(text);
	trackStopBtn:setOnClick(nil, function()
        mqtt:sendChatMsg(mqtt:generateClientInfo(""), MessageType_Map.TXT);
	end)

   
    btn1 = new(Button, "ui/button.png");
	btn1:addToRoot();
	btn1:setPos(500, 250);
    text = new(Text, "logout", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn1:addChild(text);
	btn1:setOnClick(nil, function()
		mqtt:logout(LogoutEndType_Map.USER); --”√ªß
	end)

    btn = new(Button, "ui/button.png");
	btn:addToRoot();
	btn:setPos(700, 250);
    text = new(Text, "disconnect", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn:addChild(text);
	btn:setOnClick(nil, function()
		mqtt:disconnect();
	end)

     btn2 = new(Button, "ui/button.png");
	btn2:addToRoot();
	btn2:setPos(100, 400);
    text = new(Text, "isConnected", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn2:addChild(text);
	btn2:setOnClick(nil, function()
		local ret = mqtt:isConnected();
        print_string("isConnected :" .. tostring(ret));
	end)

     btn3 = new(Button, "ui/button.png");
	btn3:addToRoot();
	btn3:setPos(300, 400);
    text = new(Text, "destory", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn3:addChild(text);
	btn3:setOnClick(nil, function()
		mqtt:destroyMqtt();
	end)
	
    btn4 = new(Button, "ui/button.png");
	btn4:addToRoot();
	btn4:setPos(500, 400);
    text = new(Text, "test", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn4:addChild(text);
	btn4:setOnClick(nil, function()
		require("htmlParser");
        local str = HtmlParser.parser("xxxx convert to &amp;B ID:xxxx &quot; send email &quot;");
        print_string(str);
	end)

    require("sqliteModule/messageDao");
     btn5 = new(Button, "ui/button.png");
	btn5:addToRoot();
	btn5:setPos(100, 550);
    text = new(Text, "createSqlite", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn5:addChild(text);
	btn5:setOnClick(nil, function()
        local db = System.getStorageUserPath() .. "boyaa_kefu11.db"
        sqls = new(MessageDao, db);
	end)

     btn6 = new(Button, "ui/button.png");
	btn6:addToRoot();
	btn6:setPos(300, 550);
    text = new(Text, "insert", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn6:addChild(text);
	btn6:setOnClick(nil, function()
        local message = new(Message, Message.TestData);
        for i = 1, 20 do
            local rowid = sqls:insert(message);
            local id = sqls:getIdByRowid(rowid);
            print_string("id:" .. id);
        end 
	end)

     btn7 = new(Button, "ui/button.png");
	btn7:addToRoot();
	btn7:setPos(500, 550);
    text = new(Text, "count", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn7:addChild(text);
	btn7:setOnClick(nil, function()
        local count = sqls:count();
        print_string("count:" .. count);
	end)

     btn8 = new(Button, "ui/button.png");
	btn8:addToRoot();
	btn8:setPos(700, 550);
    text = new(Text, "update", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn8:addChild(text);
	btn8:setOnClick(nil, function()
        local messages = sqls:queryRaw(0, 2);
        local message = messages[2];
        message:setFrom("what the fuck!!!!!!!!!!");
        sqls:update(message);
	end)

      btn9 = new(Button, "ui/button.png");
	btn9:addToRoot();
	btn9:setPos(900, 550);
    text = new(Text, "delete", 0, 0, kAlignCenter, "", 18, 255, 255, 255);
    btn9:addChild(text);
	btn9:setOnClick(nil, function()
        local messages = sqls:queryRaw(0, 2);
        local message = messages[1];
        sqls:delete(message);
	end)

end


function event_error_param()

end


