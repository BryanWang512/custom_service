require ("sqliteModule/message");
MessageDao = class();

MessageDao.ctor = function (self, filename)
    if sqlite3 then
        self:open(filename);
        self:createTable();
    else
        error("no sqlite3 lib!!!");
    end
end

MessageDao.dtor = function (self)
    self:close();
end

--boyaa_kefu.db
MessageDao.open = function (self, filename)
    self.db = sqlite3.open(filename);
end

MessageDao.close = function (self)
    if self.db and self.db:isopen() then
        self.db:close();
        self.db = nil;
    end
end

--表名 MESSAGE
MessageDao.createTable = function (self)
    local sql = "CREATE TABLE " .. Message.TABLE .. "(" .. --
            Message.ID .. " INTEGER PRIMARY KEY," .. -- 0: id
            Message.TEXT_MESSAGE_BODY .. " TEXT," .. -- 1: textMessageBody
            Message.TYPE .." INTEGER NOT NULL," .. -- 2: type
            Message.DIRECT .." INTEGER NOT NULL," .. -- 3: direct
            Message.STATUS .." INTEGER NOT NULL," .. -- 4: status
            Message.MSG_TIME .." INTEGER NOT NULL," .. -- 5: msgTime
            Message.VOICE_LENGTH .." INTEGER," .. -- 6: voiceLength
            Message.URI .." TEXT," .. -- 7: uri
            Message.FROM .." TEXT NOT NULL," .. -- 8: from
            Message.TO .." TEXT NOT NULL);" -- 9: to
    print_string("createTable sql:" .. sql);
    local ret = self.db:exec(sql);
    print_string("createTable result : " .. ret);
    return ret;
end

MessageDao.dropTable = function (self)
    local sql = "DROP TABLE IF EXISTS " .. Message.TABLE;
    print_string("dropTable sql:" .. sql);
    local ret = self.db:exec(sql);
    print_string("dropTable result : " .. ret);
    return ret;
end

--插入一条message
MessageDao.insert = function (self, message)
    if not typeof(message, Message) then
        print_string("insert error message");
        return;
    end
    local id = message:getId() or "NULL";
    --字符串需要加上 ''
    local sql = "INSERT INTO " .. Message.TABLE  ..  " VALUES("
    .. id ..", '"
    .. message:getTextMessageBody() .."', "
    .. message:getType() ..", "
    .. message:getDirect() ..", "
    .. message:getStatus() ..", "
    .. message:getMsgTime() ..", "
    .. message:getVoiceLength() ..", '"
    .. message:getUri() .."', '"
    .. message:getFrom() .."', '"
    .. message:getTo() .. "')";
    print_string("insert sql:" .. sql);
    local ret = self.db:exec(sql);
    local rowId = self.db:last_insert_rowid();
    print_string("insert result : " .. ret);
    return rowId;
end

--删除一条message
MessageDao.delete = function (self, message)
    if not typeof(message, Message) then
        print_string("delete error message");
        return;
    end
    local sql = "DELETE FROM " .. Message.TABLE .. " WHERE " .. Message.ID .." = " .. message:getId();
    print_string("delete sql:" .. sql);
    local ret = self.db:exec(sql);
    print_string("delete result : " .. ret);
    return ret;
end

--更新这条message，message是MessageDao.queryRaw 查询返回的，主键不能改
MessageDao.update = function (self, message)
     if not typeof(message, Message) then
        print_string("update error message");
        return;
    end
    local sql = "UPDATE " .. Message.TABLE .. " SET " .. 
    Message.TEXT_MESSAGE_BODY .. " = '" .. message:getTextMessageBody() .."', " ..
    Message.TYPE .. " = " .. message:getType() ..", " ..
    Message.DIRECT .. " = " .. message:getDirect() ..", " ..
    Message.STATUS .. " = " .. message:getStatus() ..", " ..
    Message.MSG_TIME .. " = " .. message:getMsgTime() ..", " ..
    Message.VOICE_LENGTH .. " = " .. message:getVoiceLength() ..", " ..
    Message.URI .. " = '" .. message:getUri() .."', " ..
    Message.FROM .. " = '" .. message:getFrom() .."', " ..
    Message.TO .. " = '" .. message:getTo() ..
    "' WHERE " .. Message.ID .. " = " .. message:getId();
    print_string("update sql:" .. sql);
    local ret = self.db:exec(sql);
    print_string("update result : " .. ret);
    return ret;
end

--从 start开始 查询 limit条，返回一个message的集合
MessageDao.queryRaw = function (self, start, limit)
    local sql = "SELECT * FROM " .. Message.TABLE .. " LIMIT " .. start .. ", " .. limit;
    print_string("query sql:" .. sql);
    local messages = {}
    for row in self.db:nrows(sql) do 
        local message = new(Message, row);
        table.insert(messages, message);
    end
    return messages;
end

--查询数量
MessageDao.count = function (self)
    local sql = "SELECT COUNT(*) FROM " .. Message.TABLE;
    print_string("query sql:" .. sql);
    local count = 0;
    for row in self.db:rows(sql) do 
        count = row[1];
    end
    return count;
end

--通过rowid获取这条数据的"_id"
MessageDao.getIdByRowid = function (self, rowid)
    local sql = "SELECT " .. Message.ID .. " FROM " .. Message.TABLE .. " WHERE ROWID = " .. rowid;
    print_string("query sql:" .. sql);
    local _id = 0;
    for row in self.db:rows(sql) do 
        _id = row[1];
    end
    return _id;
end





