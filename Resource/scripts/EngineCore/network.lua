
package.preload[ "network/http" ] = function( ... )
if curl ~= nil then
    return require('network.http_compat')
else
    return require('network.http_old')
end

end
        

package.preload[ "network.http" ] = function( ... )
    return require('network/http')
end
            

package.preload[ "network/http2" ] = function( ... )
require("core.object");
require("core.system");
require("core.constants");
require("core.global");

---
-- 新http库
-- @module network.http2
-- @usage local Http = require('network.http2')
local M = class();
local _pool
local function pool()
    if not _pool then
        _pool = ThreadPool(1, 10)
    end
    return _pool
end

local function http_worker(args)
    local function buffer_writer()
        local result
        return {
            open = function()
                result = {}
            end,
            write = function(buf)
                table.insert(result, buf)
            end,
            close = function()
                local s = table.concat(result)
                result = nil
                return s
            end,
        }
    end

    local function file_writer(filename,mode)
        local fp
        return {
            open = function()
                mode = mode or "wb"
                fp = io.open(filename, mode)
            end,
            write = function(buf)
                fp:write(buf)
            end,
            close = function()
                fp:close()
                fp = nil
            end,
        }
    end

    local function chan_writer(chan_id)
        local ch
        return {
            open = function()
                ch = Chan.get_by_id(chan_id)
            end,
            write = function(buf)
                ch:put(buf)
            end,
            close = function()
                ch:close()
                ch = nil
            end,
        }
    end

    local function urlencode(easy, args)
        if type(args) == 'table' then
            local buf = {}
            for k, v in pairs(args) do
                table.insert(buf, string.format('%s=%s', easy:escape(k), easy:escape(v)))
            end
            return table.concat(buf, '&')
        else
            return easy:escape(tostring(args))
        end
    end

    args = cjson.decode(args)
    local writer
    if args.writer ~= nil then
        if args.writer.type == 'file' then
            writer = file_writer(args.writer.filename, args.writer.mode)
        elseif args.writer.type == 'chan' then
            writer = chan_writer(args.writer.chan_id)
        else
            error('invalid writer argument')
        end
    else
        writer = buffer_writer()
    end
    local abort_var = MVar.get_by_id(args._abort_var_id)

    local easy = curl.easy()



    -- 设置自动跳转
    easy:setopt(curl.OPT_FOLLOWLOCATION,1)
    -- 设置最大跳转次数
    easy:setopt(curl.OPT_MAXREDIRS,10)
    local url = args.url
    if args.query then
        if not string.find(url, '?') then
            url = url .. '?'
        end
        url = url .. urlencode(easy, args.query)
    end
    if args.useragent then
        easy:setopt(curl.OPT_USERAGENT, args.useragent)
    end

    easy:setopt(curl.OPT_NOSIGNAL, 1)
    easy:setopt(curl.OPT_SSL_VERIFYPEER, 0)
    easy:setopt(curl.OPT_SSL_VERIFYHOST, 0)
    if args.connecttimeout then
        easy:setopt_connecttimeout(args.connecttimeout)
    end

    if args.timeout then
        easy:setopt_timeout(args.timeout)
    end

    easy:setopt_url(url)
        :setopt_writefunction(function(buf)
            if abort_var:take(false) then
                return false
            end
            writer.write(buf)
        end)
    local progress_var
    if args.progress_var then
        progress_var = MVar.get_by_id(args.progress_var)
        easy:setopt(curl.OPT_NOPROGRESS, 0)
        easy:setopt_progressfunction(function(total_download, current_download, total_upload, current_upload)
            if abort_var:take(false) then
                return false
            end
            progress_var:modify(cjson.encode{
                total_download, current_download, total_upload, current_upload
            })
        end)
    end
    if args.headers and #args.headers > 0 then
        easy:setopt_httpheader(args.headers)
    end
    local form 
    if args.post ~= nil then
        if type(args.post) == "string" then
            easy:setopt_postfields(args.post)
        else
            form = curl.form()
            for i,v in ipairs(args.post) do
                if type(v) == "table" then
                    if v.type == "file" then
                        form:add_file(v.name or "",
                        v.filepath or "",
                        v.file_type or "text/plain",
                        v.filename,
                        v.headers)
                    elseif v.type == "content" then
                        form:add_content(v.name or "",v.contents or "",
                                v.content_type or nil,v.headers)
                    elseif v.type == "buffer" then
                        form:add_buffer(v.name or "",v.filename ,
                                v.content or "",
                                v.buffer_type ,v.headers)
                    end
                end
            end
            easy:setopt_httppost(form)
        end
    end
    if args.upload ~= nil then
        form = curl.form()
        form:add_file("file",args.upload.filename,"image/png")
        form:add_content("","upload")
        easy:setopt_httppost(form)
    end
    writer.open()
    local ok, msg = pcall(function()
        easy:perform()
    end)
    if progress_var then
        progress_var:close()
    end
    local result = writer.close()
    if ok then
        local rsp = {
            code = easy:getinfo(curl.INFO_RESPONSE_CODE),
            content = result,
            tags = args.tags
        }
        easy:close()
        if form then
            form:free()
        end
        return cjson.encode(rsp)
    else
        easy:close()
        if form then
            form:free()
        end
        return cjson.encode{
            errmsg = msg,
        }
    end
end

---
-- 发起http请求，异步接口，通过回调函数获取结果。
-- @function [parent=#network.http2] request_async
-- @param #table args 参数
-- @param #function callback 接受rsp的回调, 成功时rsp为``{code=#number, content=#string}``，失败时rsp为``{errmsg=#string}``
-- @usage
-- Http = require('network.http2')
-- Http.request_async({
--   url = 'http://www.boyaa.com',  -- required
--   query = {                      -- optional, query_string
--      a = 1,
--   },
--   useragent = '',                -- optional
--   headers = {                    -- optional, http headers,
--      'XX-Header: xxx',
--   },
--   timeout = ,                    -- optional, seconds
--   connecttimeout = ,             -- optional, seconds
--   post = 'a=1&b=2',              -- optional, set post data, and change http method to post.
--   post = {                       -- optional, set upload data
--     {
--         type = "file",
--         name = "file",
--         filepath = "./blurWidget_before.png",
--         file_type = "image/png",
--         -- filename = "xxx.png",
--     },
--     {
--         type = "file",
--         name = "file",
--         filepath = "./log.txt",
--     },
--     {
--         type = "content",
--         name = "",
--         contents = "upload",
--         content_type = ""
--     },
--     {
--         type = "buffer",
--         name = "",
--         filename = "log.txt",
--         contents = "1321313213132",
--         buffer_type = "text/plain"
--     },
--   },
--   writer = {                     -- optional, override writer behaviour.
--      type = 'file',              -- save to file, rsp.content would be empty.
--      filename = '/path/to/file',
--      mode = 'wb',
--   },
--   writer = {                     -- optional, override writer behaviour.
--      type = 'chan',              -- send response content stream through Chan, rsp.content would be empty.
--      chan_id = chan.id,
--   },
--   progress_var = var.id,         -- optional, id of mvar used to receive progress infomation.
-- }, function(rsp)
--   if rsp.errmsg then
--     print_string('failed', rsp.errmsg)
--   else
--     print_string('success', rsp.code, rsp.content)
--   end
-- end)
--
function M.request_async(args, callback)
    local abort_var = MVar.create()
    args._abort_var_id = abort_var.id
    pool():lua_task(http_worker, function(rsp)
        callback(cjson.decode(rsp))
    end, cjson.encode(args))
    return {
        abort = function()
            abort_var:put('abort', false)
        end,
    }
end

---
-- http同步请求，在``tasklet``中执行，详细的参数描述见``request_async``。
-- @function [parent=#network.http2] request
-- @param #table args
-- @return #table rsp 成功时rsp为``{code=#number, content=#string}``，失败时rsp为``{errmsg=#string}``
-- @usage
-- local rsp = Http.request({
--     url = 'http://www.boyaa.com'
-- })
-- if rsp.errmsg then
--     print('request failed', rsp.errmsg)
-- else
--     print('response', rsp.code, rsp.content)
-- end
function M.request(args)
    return coroutine.yield(function(callback)
        M.request_async(args, callback)
    end)
end

return M

end
        

package.preload[ "network.http2" ] = function( ... )
    return require('network/http2')
end
            

package.preload[ "network/http_compat" ] = function( ... )
-- http.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for http functions

--------------------------------------------------------------------------------
-- 用于简单的http请求。
-- **规范请参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)。**
-- @module network.http
-- @return #nil
-- @usage require("network.http")


require("core.object");
require("core.system");
require("core.constants");
require("core.global");
local Http2 = require('network.http2')

--- http请求类型：get
kHttpGet    = 0;
--- http请求类型：post
kHttpPost   = 1;
--- http返回类型(这是唯一可用的类型)
kHttpReserved = 0;

---
--@type Http
Http = class();
Http.s_platform = System.getPlatform();

---
-- 构造方法.
-- 
-- @param self
-- @param #number requestType http请求类型（未使用）。 取值[```kHttpGet```](network.http.html#kHttpGet)、
-- [```kHttpPost```](network.http.html#kHttpPost)。Android、win32平台目前只支持post方式，win10、ios平台均支持Get和Post两种方式。
-- @param #number responseType （未使用）。目前仅能取值[```kHttpReserved```](network.http.html#kHttpReserved)。
-- @param #string url 请求的url。
Http.ctor = function(self, requestType, responseType, url)
    self.m_url = url
    self.m_headers = {}
    self.m_requestType = requestType
    self.m_data = ''
    self.m_eventCallback = {}
end


---  
-- 析构方法.
-- 
-- @param self
Http.dtor = function(self)
    if self.m_response == nil then
        -- not finished, abort
        self:abortRequest()
    end
end


---
-- 设置请求超时时间.  
-- 若多次设置，则取最后一次的值。在@{#Http.execute}前设置才有效 。
-- 
-- @param self
-- @param #number connectTimeout 请求超时时间，单位毫秒。  
-- Android平台：若设置小于1000，则默认为1000；  
-- win32、ios平台：超时时间参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)；  
-- win10平台：默认为10000。
-- @param #number timeout Android、win32、win10平台未使用；ios平台表示[请求过程的最长耗时](https://curl.haxx.se/libcurl/c/CURLOPT_TIMEOUT.html)。
Http.setTimeout = function(self, connectTimeout, timeout)
    self.m_connecttimeout = connectTimeout
    self.m_timeout = timeout
end

---
-- 设置请求消息的User-Agent.
-- 
-- 在@{#Http.execute}前设置才有效。
-- Android未实现；    
-- win32平台：若未调用@{#Http.setAgent}，将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`；  
-- win10平台：已实现，无默认值。  
-- ios平台:若未调用@{#Http.setAgent},将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`。
-- @param self
-- @param #string str 请求消息的userAgent。
Http.setAgent = function(self, str)
    self.m_userAgent = str
end

---
-- 请求消息添加Header.
--   
-- Android平台未实现；  
-- win32平台:首个header为“Accept-Encoding:UTF-8”；用户多次调用@{#Http.addHeader}之后,win32平台上将依次添加header到请求消息中；  
-- win10：用户调用@{#Http.addHeader}之后,平台添加header到请求消息中。每个请求添加多次header时，取最后一次的header；  
-- ios平台：用户多次调用@{#Http.addHeader}之后,平台依次添加header到请求消息中。
-- @param self
-- @param #string str 请求消息的Header。
Http.addHeader = function(self, str)
    table.insert(self.m_headers, str)
end


---
-- 设置请求消息的body.  
-- 
-- 仅支持post请求。
-- Android、win32、win10、ios平台均已实现:请求的消息body默认为空；调用@{#Http.setData}后，更新请求消息的body。
--
-- @param self
-- @param #string str 请求消息的body。
Http.setData = function(self, str)
    self.m_data = str
end

---
-- 发送请求.
--   
-- Android、win32、ios平台请求完成后首先回调[```event_http_response_httpEvent```](network.http.html#event_http_response_httpEvent)方法，然后回调@{#Http.setEvent}方法；  
-- win10平台请求完成后，回调@{#Http.setEvent}方法。
-- 
-- @param self
Http.execute = function(self)
    self.m_req = Http2.request_async({
        url = self.m_url,
        headers = self.m_headers,
        post = self.m_requestType == kHttpPost and self.m_data or nil,
        connecttimeout = self.m_connecttimeout,
        timeout = self.m_timeout,
        useragent = self.m_userAgent,
    }, function(rsp)
        self.m_response = rsp
        if self.m_aborted then
            return
        end
        if not rsp.errmsg and self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj, self)
        end
    end)
end

---
-- 取消请求，在@{#Http.execute}之后执行有效.
-- 注：此方法并没有真正取消请求，而是改变了一个变量的值供各平台调度，以达到真正意义上取消请求的目的。
-- 
-- Android、win32平台未实现；    
-- win10、ios平台已实现:调用各自平台的取消方法来达到取消请求的目的。
--
-- @param self
Http.abortRequest = function(self)
    self.m_aborted = true
    if self.m_req then
        self.m_req:abort()
    end
end

---
-- 请求是否被取消.
-- 
-- Android、win32平台未实现；  
-- win10、ios平台已实现：若已调用过@{#Http.abortRequest}，且平台成功取消请求，则返回true；否则，返回false。
--
-- @param self
-- @return #boolean 若成功取消请求，则返回true；否则，返回false。
Http.isAbort = function(self)
    return self.m_aborted == true
end

---
-- 获得响应的状态码.
-- 
-- Android、win32、win10、ios平台：已实现。返回HTTP状态代码。
--  
-- @param self
-- @return #number 如果请求未完成，返回0；若请求完成，则返回相应的状态码。
Http.getResponseCode = function(self)
    return self.m_response and self.m_response.code or 0
end

---
-- 获得响应的内容.
-- 
-- Android、win32、win10平台:返回全部相应内容。
-- ios平台：返回响应内容（不一定是全部内容）。
--
-- @param self
-- @return #string 响应结果。如果请求未完成，则返回空字符串；否则返回响应结果。
Http.getResponse = function(self)
    return self.m_response and self.m_response.content or ''
end

---
-- 获得错误码.
-- 
-- Android、win32、ios平台，若出现异常返回1；否则返回0。  
-- win10平台：当请求不存在或在请求过程中获取错误码返回-1；未发送请求而去获取错误码，返回0；其他情况返回错误码的整数值。参考[win10平台错误码类型](https://curl.haxx.se/libcurl/c/libcurl-errors.html)。
-- 
-- @param self
-- @return #number 返回错误码。
Http.getError = function(self)
    return self.m_response and self.m_response.errmsg or 0
end

---
-- 设置请求完成后的回调函数.
-- 
-- @param self
-- @param obj 任意类型，当做回调函数func的第一个参数传入。
-- @param #function func 回调函数。
-- 传入参数为:(obj, http),其中obj为任意类型；
-- http即为当前的Http对象。
Http.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

end
        

package.preload[ "network.http_compat" ] = function( ... )
    return require('network/http_compat')
end
            

package.preload[ "network/http_old" ] = function( ... )
-- http.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for http functions

--------------------------------------------------------------------------------
-- 用于简单的http请求。
-- **规范请参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)。**
-- @module network.http
-- @return #nil
-- @usage require("network.http")


require("core.object");
require("core.system");
require("core.constants");
require("core.global");


--- http请求类型：get
kHttpGet    = 0;
--- http请求类型：post
kHttpPost   = 1;
--- http返回类型(这是唯一可用的类型)
kHttpReserved = 0;

---
--@type Http
Http = class();
Http.s_objs = CreateTable("v");
Http.s_platform = System.getPlatform();

if Http.s_platform == kPlatformAndroid then
    require("network.httpRequest");
end


---
-- 构造方法.
-- 
-- @param self
-- @param #number requestType http请求类型（未使用）。 取值[```kHttpGet```](network.http.html#kHttpGet)、
-- [```kHttpPost```](network.http.html#kHttpPost)。Android、win32平台目前只支持post方式，win10、ios平台均支持Get和Post两种方式。
-- @param #number responseType （未使用）。目前仅能取值[```kHttpReserved```](network.http.html#kHttpReserved)。
-- @param #string url 请求的url。
Http.ctor = function(self, requestType, responseType, url)
    self.m_requestID = http_request_create(requestType, responseType, url);
    Http.s_objs[self.m_requestID] = self;
    self.m_eventCallback = { };
end


---  
-- 析构方法.
-- 
-- @param self
Http.dtor = function(self)
    http_request_destroy(self.m_requestID);
    self.m_requestID = nil;
end


---
-- 设置请求超时时间.  
-- 若多次设置，则取最后一次的值。在@{#Http.execute}前设置才有效 。
-- 
-- @param self
-- @param #number connectTimeout 请求超时时间，单位毫秒。  
-- Android平台：若设置小于1000，则默认为1000；  
-- win32、ios平台：超时时间参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)；  
-- win10平台：默认为10000。
-- @param #number timeout Android、win32、win10平台未使用；ios平台表示[请求过程的最长耗时](https://curl.haxx.se/libcurl/c/CURLOPT_TIMEOUT.html)。
Http.setTimeout = function(self, connectTimeout, timeout)
    http_set_timeout(self.m_requestID, connectTimeout, timeout)
end

---
-- 设置请求消息的User-Agent.
-- 
-- 在@{#Http.execute}前设置才有效。
-- Android未实现；    
-- win32平台：若未调用@{#Http.setAgent}，将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`；  
-- win10平台：已实现，无默认值。  
-- ios平台:若未调用@{#Http.setAgent},将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`。
-- @param self
-- @param #string str 请求消息的userAgent。
Http.setAgent = function(self, str)
    http_request_set_agent(self.m_requestID, str);
end

---
-- 请求消息添加Header.
--   
-- Android平台未实现；  
-- win32平台:首个header为“Accept-Encoding:UTF-8”；用户多次调用@{#Http.addHeader}之后,win32平台上将依次添加header到请求消息中；  
-- win10：用户调用@{#Http.addHeader}之后,平台添加header到请求消息中。每个请求添加多次header时，取最后一次的header；  
-- ios平台：用户多次调用@{#Http.addHeader}之后,平台依次添加header到请求消息中。
-- @param self
-- @param #string str 请求消息的Header。
Http.addHeader = function(self, str)
    http_request_add_header(self.m_requestID, str);
end


---
-- 设置请求消息的body.  
-- 
-- 仅支持post请求。
-- Android、win32、win10、ios平台均已实现:请求的消息body默认为空；调用@{#Http.setData}后，更新请求消息的body。
--
-- @param self
-- @param #string str 请求消息的body。
Http.setData = function(self, str)
    http_request_set_data(self.m_requestID, str);
end

---
-- 发送请求.
--   
-- Android、win32、ios平台请求完成后首先回调[```event_http_response_httpEvent```](network.http.html#event_http_response_httpEvent)方法，然后回调@{#Http.setEvent}方法；  
-- win10平台请求完成后，回调@{#Http.setEvent}方法。
-- 
-- @param self
Http.execute = function(self)
    local eventName = "httpEvent";
    http_request_execute(self.m_requestID, eventName);
end

---
-- 取消请求，在@{#Http.execute}之后执行有效.
-- 注：此方法并没有真正取消请求，而是改变了一个变量的值供各平台调度，以达到真正意义上取消请求的目的。
-- 
-- Android、win32平台未实现；    
-- win10、ios平台已实现:调用各自平台的取消方法来达到取消请求的目的。
--
-- @param self
Http.abortRequest = function(self)
    http_request_abort(self.m_requestID);
end

---
-- 请求是否被取消.
-- 
-- Android、win32平台未实现；  
-- win10、ios平台已实现：若已调用过@{#Http.abortRequest}，且平台成功取消请求，则返回true；否则，返回false。
--
-- @param self
-- @return #boolean 若成功取消请求，则返回true；否则，返回false。
Http.isAbort = function(self)
    return(http_request_get_abort(self.m_requestID) == kTrue);
end

---
-- 获得响应的状态码.
-- 
-- Android、win32、win10、ios平台：已实现。返回HTTP状态代码。
--  
-- @param self
-- @return #number 如果请求未完成，返回0；若请求完成，则返回相应的状态码。
Http.getResponseCode = function(self)
    return http_request_get_response_code(self.m_requestID);
end

---
-- 获得响应的内容.
-- 
-- Android、win32、win10平台:返回全部相应内容。
-- ios平台：返回响应内容（不一定是全部内容）。
--
-- @param self
-- @return #string 响应结果。如果请求未完成，则返回空字符串；否则返回响应结果。
Http.getResponse = function(self)
    return http_request_get_response(self.m_requestID);
end

---
-- 获得错误码.
-- 
-- Android、win32、ios平台，若出现异常返回1；否则返回0。  
-- win10平台：当请求不存在或在请求过程中获取错误码返回-1；未发送请求而去获取错误码，返回0；其他情况返回错误码的整数值。参考[win10平台错误码类型](https://curl.haxx.se/libcurl/c/libcurl-errors.html)。
-- 
-- @param self
-- @return #number 返回错误码。
Http.getError = function(self)
    return http_request_get_error(self.m_requestID);
end

---
-- 设置请求完成后的回调函数.
-- 
-- @param self
-- @param obj 任意类型，当做回调函数func的第一个参数传入。
-- @param #function func 回调函数。
-- 传入参数为:(obj, http),其中obj为任意类型；
-- http即为当前的Http对象。
Http.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

---
-- Android、win32、ios平台在请求消息后执行的回调函数，win10平台未执行。
-- **开发者不应主动调用此函数**
-- @param #number  requestID 请求的id。
function event_http_response_httpEvent(requestID)
    requestID = requestID or http_request_get_current_id();
    local http = Http.s_objs[requestID];
    if http and http.m_eventCallback.func then
        http.m_eventCallback.func(http.m_eventCallback.obj, http);
    end
end

end
        

package.preload[ "network.http_old" ] = function( ... )
    return require('network/http_old')
end
            

package.preload[ "network/httpRequest" ] = function( ... )

--------------------------------------------------------------------------------
-- Http类与java(或c#)层通信传递数据的桥梁.
-- 此文件里的方法均只在http.lua内部使用，开发者应使用@{core.http}，而不应直接使用此文件。
--
-- @module network.httpRequest
-- @return #nil 
-- @usage require("network.httpRequest")

kHttpRequestNone=0;
kHttpRequestCreate=1;
kHttpRequestRuning=2;
kHttpRequestFinish=3;

HttpRequestNS = {};
HttpRequestNS.http_request_id=0;
HttpRequestNS.kHttpRequestExecute="http_request_execute";
HttpRequestNS.kHttpResponse="http_response";
HttpRequestNS.kId="id";
HttpRequestNS.kStep="step";
HttpRequestNS.kUrl="url";
HttpRequestNS.kData="data";
HttpRequestNS.kTimeout="timeout";
HttpRequestNS.kEvent="event";
HttpRequestNS.kAbort="abort";
HttpRequestNS.kError="error";
HttpRequestNS.kCode="code";
HttpRequestNS.kRet="ret";
HttpRequestNS.kMethod="method";

HttpRequestNS.allocId = function ()
	HttpRequestNS.http_request_id = HttpRequestNS.http_request_id + 1;
	return HttpRequestNS.http_request_id;
end
HttpRequestNS.getKey = function ( iRequestId )
	local key = string.format("http_request_%d",iRequestId);
	return key;
end

---
-- 创建一个http请求.
--
-- @param #number iTypePost http method
-- @param #number iResponseType 未使用
-- @param #string strUrl 请求网址
-- @return #number iRequestId 此请求的唯一id
function http_request_create( iTypePost, iResponseType, strUrl )
	local iRequestId = HttpRequestNS.allocId();
	local key = HttpRequestNS.getKey(iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestCreate);
	dict_set_int(key,HttpRequestNS.kMethod,iTypePost);
	dict_set_string(key,HttpRequestNS.kUrl,strUrl);
	return iRequestId;
end

---
-- 取消一个http请求.
-- 请求一旦开始就无法取消
--
-- @param #number iRequestId 请求id
function http_request_destroy(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_destroy failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_destroy failed %d, can't destroy while execute ",iRequestId));
		return
	end
	
	dict_delete(key);

end

---
-- 设置请求超时时间.
--
-- @param #number iRequestId 请求id
-- @param #number timeout1 超时时间
-- @param #number timeout2 未使用
function http_set_timeout ( iRequestId, timeout1, timeout2 )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_set_timeout failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_set_timeout failed %d, can't set timeout while execute ",iRequestId));
		return
	end

	dict_set_int(key,HttpRequestNS.kTimeout,timeout1);

end

---
-- 设置请求体.
--
-- @param #number iRequestId 请求id
-- @param #string strValue 请求体.使用key1=value1&key2=value2的格式
function http_request_set_data (iRequestId, strValue )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_set_data failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_set_data failed %d, can't set data while execute ",iRequestId));
		return
	end

	dict_set_string(key,HttpRequestNS.kData,strValue);

end

---
-- 未使用
function http_request_set_agent(iRequestId,strValue)
	FwLog("not support on android platform");
end

---
-- 未使用
function http_request_add_header(iRequestId,strValue)
	FwLog("not support on android platform");
end

---
-- 开始发送请求.
--
-- @param #number iRequestId 请求id
-- @param #string strEventName 事件名. 
-- 如果传nil,则请求完成后会回调lua里的`event_http_response`方法，
-- 如果传abc，则请求完成后会回调lua里的`event_http_response_abc`方法。
function http_request_execute(iRequestId,strEventName )
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestCreate then
		FwLog(string.format("http_request_execute failed %d",iRequestId));
		return
	end
	
	dict_set_int(HttpRequestNS.kHttpRequestExecute,HttpRequestNS.kId,iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestRuning);
	dict_set_string(key,HttpRequestNS.kEvent,strEventName);

	if dict_get_int(key,HttpRequestNS.kMethod, kHttpGet) == kHttpGet then
        call_native("HttpGet");
    else
        call_native("HttpPost");
    end

end

---
-- 取消某个请求.
-- 如果已经开始，则无法取消.
--
-- @param #number iRequestId 请求id
function http_request_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestRuning then
		FwLog(string.format("http_request_abort failed %d",iRequestId));
		return
	end
	dict_set_int(key,HttpRequestNS.kAbort,1);
end

---
-- 获得请求结果.
--
-- @param #number iRequestId 请求id
-- @return #string 请求结果
function http_request_get_response(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response failed %d",iRequestId));
		return "";
	end

	local str = dict_get_string(key,HttpRequestNS.kRet);
	if nil == str then
		return "";
	end
	return str;
end

---
-- 检查某个请求是否被取消.
-- 
-- @param #number iRequestId 请求id
-- @return #number 1表示已取消
function http_request_get_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_abort failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kAbort,0);
	
end

---
-- 获得请求的错误码.
-- 0表示成功，1表示失败
-- 
-- @param #number iRequestId 请求id
-- @return #number 错误码
function http_request_get_error(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_error failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kError,0);

end

---
-- 获得请求返回的状态码 status code.
--
-- @param #number iRequestId 请求id
-- @return #number http status code
function http_request_get_response_code(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response_code failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kCode,0);
end

---
-- 获得当前被回调的请求Id.
--
-- @param #number id 未使用
-- @return #number requestId
function http_request_get_current_id ( id )
	return dict_get_int(HttpRequestNS.kHttpResponse,HttpRequestNS.kId,0);
end

end
        

package.preload[ "network.httpRequest" ] = function( ... )
    return require('network/httpRequest')
end
            

package.preload[ "network/manager" ] = function( ... )
require('core.object')

local MainThreadSocketManager = class()
MainThreadSocketManager.ctor = function(self)
    self._handler = nil
    self._sockets = {}
end

MainThreadSocketManager.started = function(self)
    return self._handler ~= nil
end
MainThreadSocketManager.start = function(self)
    self._uv = require_uv()
    self._handler = require('network.start_uvloop')
end
MainThreadSocketManager.stop = function(self)
    error('not support')
end
MainThreadSocketManager.set_protocol = function(self, name, offset, size, initsize, endianess)
    local socket = self._sockets[name]
    local function create_stream()
        return PacketStream(offset, size, initsize, endianess)
    end
    if socket ~= nil then
        socket.create_stream = create_stream
    else
        self._sockets[name] = {
            create_stream = create_stream
        }
    end
end
MainThreadSocketManager.connect = function(self, name, ip, port, callback)
    assert(self._sockets[name] ~= nil and self._sockets[name].sock == nil, 'socket already exists.')
    local socket = self._uv.new_tcp()
    socket:connect(ip, port, function(err)
        if err then
            socket:close()
            self._sockets[name].sock = nil
            callback(err)
        else
            self._sockets[name].sock = socket
            callback()
        end
    end)
end
MainThreadSocketManager.close = function(self, name, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    socket.sock:close(callback)
    self._sockets[name] = nil
end
MainThreadSocketManager.read_start = function(self, name, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    local stream = socket.create_stream()
    socket.sock:read_start(function(err, chunk)
        if err or not chunk then
            if err then
                print_string('read error:' .. err)
            else
                print_string('connection closed')
            end
            -- closed by remote.
            socket.sock:close()
            self._sockets[name] = nil
            callback()
            return
        end
        for _, packet in ipairs{stream:feed(chunk)} do
            callback(packet)
        end
    end)
end
MainThreadSocketManager.write = function(self, name, buffer, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    socket.sock:write(buffer, function(err)
        if err then
            print_string('write error:' .. err)
            socket.sock:close()
            self._sockets[name] = nil
        end
        callback(err)
    end)
end

local MultiThreadSocketManager = class(MainThreadSocketManager)
MultiThreadSocketManager.start = function(self)
    if not self._started then
        self:_start()
        self._started = true
        function event_close()
            self:stop()
        end

    end
end
MultiThreadSocketManager._start = function(self)
    self.m_request_chan = Chan.create()
    self.m_response_chan = Chan.create()
    local async_id_mvar = MVar.create()
    ThreadPool.instance():lua_task(function(request_chan_id, response_chan_id, async_id_mvar_id)
        local sockets = {}
        local request_chan = Chan.get_by_id(request_chan_id)
        local response_chan = Chan.get_by_id(response_chan_id)
        local async_id_mvar = MVar.get_by_id(async_id_mvar_id)
        local uv = require_uv()
        local function handle_request(type, name, ...)
            if type == 'stop' then
                uv.stop()
            elseif type == 'set_protocol' then
                local socket = sockets[name]
                local args = {...}
                local create_stream = function()
                    return PacketStream(unpack(args))
                end
                if socket ~= nil then
                    socket.create_stream = create_stream
                else
                    sockets[name] = {
                        create_stream = create_stream
                    }
                end
            elseif type == 'connect' then
                assert(sockets[name], 'socket ' .. name .. ' has no protocol')
                assert(sockets[name].sock == nil, 'socket ' .. name .. ' already exists.')
                local sock = uv.new_tcp()
                local ip, port = ...
                sock:connect(ip, port, function(status)
                    if not status then
                        -- success
                        sockets[name].sock = sock
                    else
                        sock:close()
                    end
                    response_chan:put(name, 'connect', status)
                end)
            elseif type == 'close' then
                local socket = sockets[name]
                if socket.sock then
                    socket.sock:close()
                    socket.sock = nil
                end
            elseif type == 'read_start' then
                local socket = sockets[name]
                assert(socket and socket.sock, 'socket ' .. name .. ' not opened')
                local stream = socket.create_stream()
                socket.sock:read_start(function(err, chunk)
                    if err or not chunk then
                        if err then
                        end
                        -- closed
                        socket.sock:close()
                        socket.sock = nil
                        response_chan:put(name, 'read', nil)
                        return
                    end
                    for _, packet in ipairs{stream:feed(chunk)} do
                        response_chan:put(name, 'read', packet)
                    end
                end)
            elseif type == 'write' then
                local socket = sockets[name]
                assert(socket and socket.sock, 'socket ' .. name .. ' not opened')
                local data, callback = ...
                if socket and socket.sock then
                    socket.sock:write(data, function(err)
                        if err then
                            socket.sock:close()
                            socket.sock = nil
                        end
                        response_chan:put(name, callback, err)
                    end)
                end
            end
        end
        local async_id = UVAsync.create(function()
            while true do
                local req = {request_chan:take(false)}
                if not req or not req[1] then
                    break
                end
                -- handle requests
                local err, msg = pcall(handle_request, unpack(req))
                if err then
                    print_string('handle request error:' .. msg)
                end
            end
        end)
        async_id_mvar:put(async_id)
        uv.run()
    end, nil, self.m_request_chan.id, self.m_response_chan.id, async_id_mvar.id)

    -- block waiting for async.
    self.m_async_id = async_id_mvar:take()
end

MultiThreadSocketManager.send_request = function(self, ...)
    self.m_request_chan:put(...)
    UVAsync.send(self.m_async_id)
end

MultiThreadSocketManager.set_protocol = function(self, name, offset, size, initsize, endianess)
    self:send_request('set_protocol', name, offset, size, initsize, endianess)
end

MultiThreadSocketManager.stop = function(self)
    if self._started then
        self:send_request('stop')
    end
end
MultiThreadSocketManager.started = function(self)
    return self._started
end
MultiThreadSocketManager.connect = function(self, name, ip, port, callback)
    assert(self._sockets[name] == nil, 'socket already exists.');
    -- notify
    self._sockets[name] = {
        write_callback_id = 0,
        connect = callback,
        close = nil,
        read = nil,
    }

    self:send_request('connect', name, ip, port)
    self:_ensure_scheduler()
end
MultiThreadSocketManager.close = function(self, name, callback)
    self._sockets[name] = nil
    self:send_request('close', name)
end
MultiThreadSocketManager._ensure_scheduler = function(self)
    if not self._scheduler then
        self._scheduler = Clock.instance():schedule(function()
            -- check response
            while true do
                local name, callback, arg = self.m_response_chan:take(false)
                if not name then
                    break
                end
                local callback = self._sockets[name][callback]
                if (callback == 'read' and not arg) or (callback == 'write' and arg) then
                    self._sockets[name] = nil
                elseif callback ~= 'read' then
                    self._sockets[name][callback] = nil
                end
                if callback == nil then
                    print_string('callback is nil ' .. callback)
                end
                callback(arg)
            end
        end)
    end
end

MultiThreadSocketManager.read_start = function(self, name, callback)
    assert(self._sockets[name].read == nil, 'duplicate read request')
    self._sockets[name].read = callback
    self:send_request('read_start', name)
end

MultiThreadSocketManager.write = function(self, name, buffer, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    socket.write_callback_id = socket.write_callback_id + 1
    socket[socket.write_callback_id] = callback
    self:send_request('write', name, buffer, socket.write_callback_id)
end

return {
    singleThread = new(MainThreadSocketManager),
    multiThread = new(MultiThreadSocketManager),
}

end
        

package.preload[ "network.manager" ] = function( ... )
    return require('network/manager')
end
            

package.preload[ "network/protobuf" ] = function( ... )
local c = require('protobuf.c')

local setmetatable = setmetatable
local type = type
local table = table
local assert = assert
local pairs = pairs
local ipairs = ipairs
local string = string
local print = print
local io = io
local tinsert = table.insert
local rawget = rawget

module "protobuf"

local _pattern_cache = {}

-- skynet clear
local P = c._env_new()
local GC = c._gc(P)

function lasterror()
	return c._last_error(P)
end

local decode_type_cache = {}
local _R_meta = {}

function _R_meta:__index(key)
	local v = decode_type_cache[self._CType][key](self, key)
	self[key] = v
	return v
end

local _reader = {}

function _reader:int(key)
	return c._rmessage_integer(self._CObj , key , 0)
end

function _reader:real(key)
	return c._rmessage_real(self._CObj , key , 0)
end

function _reader:string(key)
	return c._rmessage_string(self._CObj , key , 0)
end

function _reader:bool(key)
	return c._rmessage_integer(self._CObj , key , 0) ~= 0
end

function _reader:message(key, message_type)
	local rmessage = c._rmessage_message(self._CObj , key , 0)
	if rmessage then
		local v = {
			_CObj = rmessage,
			_CType = message_type,
			_Parent = self,
		}
		return setmetatable( v , _R_meta )
	end
end

function _reader:int32(key)
	return c._rmessage_int32(self._CObj , key , 0)
end

function _reader:int64(key)
	return c._rmessage_int64(self._CObj , key , 0)
end

function _reader:int52(key)
	return c._rmessage_int52(self._CObj , key , 0)
end

function _reader:uint52(key)
	return c._rmessage_uint52(self._CObj , key , 0)
end

function _reader:int_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_integer(cobj , key , i))
	end
	return ret
end

function _reader:real_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_real(cobj , key , i))
	end
	return ret
end

function _reader:string_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_string(cobj , key , i))
	end
	return ret
end

function _reader:bool_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_integer(cobj , key , i) ~= 0)
	end
	return ret
end

function _reader:message_repeated(key, message_type)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		local m = {
			_CObj = c._rmessage_message(cobj , key , i),
			_CType = message_type,
			_Parent = self,
		}
		tinsert(ret, setmetatable( m , _R_meta ))
	end
	return ret
end

function _reader:int32_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_int32(cobj , key , i))
	end
	return ret
end

function _reader:int64_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_int64(cobj , key , i))
	end
	return ret
end

function _reader:int52_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_int52(cobj , key , i))
	end
	return ret
end

function _reader:uint52_repeated(key)
	local cobj = self._CObj
	local n = c._rmessage_size(cobj , key)
	local ret = {}
	for i=0,n-1 do
		tinsert(ret,  c._rmessage_uint52(cobj , key , i))
	end
	return ret
end

_reader[1] = function(msg) return _reader.int end
_reader[2] = function(msg) return _reader.real end
_reader[3] = function(msg) return _reader.bool end
_reader[4] = function(msg) return _reader.string end
_reader[5] = function(msg) return _reader.string end
_reader[6] = function(msg)
	local message = _reader.message
	return	function(self,key)
			return message(self, key, msg)
		end
end
_reader[7] = function(msg) return _reader.int64 end
_reader[8] = function(msg) return _reader.int32 end
_reader[9] = _reader[5]
_reader[10] = function(msg) return _reader.int52 end
_reader[11] = function(msg) return _reader.uint52 end

_reader[128+1] = function(msg) return _reader.int_repeated end
_reader[128+2] = function(msg) return _reader.real_repeated end
_reader[128+3] = function(msg) return _reader.bool_repeated end
_reader[128+4] = function(msg) return _reader.string_repeated end
_reader[128+5] = function(msg) return _reader.string_repeated end
_reader[128+6] = function(msg)
	local message = _reader.message_repeated
	return	function(self,key)
			return message(self, key, msg)
		end
end
_reader[128+7] = function(msg) return _reader.int64_repeated end
_reader[128+8] = function(msg) return _reader.int32_repeated end
_reader[128+9] = _reader[128+5]
_reader[128+10] = function(msg) return _reader.int52_repeated end
_reader[128+11] = function(msg) return _reader.uint52_repeated end

local _decode_type_meta = {}

function _decode_type_meta:__index(key)
	local t, msg = c._env_type(P, self._CType, key)
	local func = assert(_reader[t],key)(msg)
	self[key] = func
	return func
end

setmetatable(decode_type_cache , {
	__index = function(self, key)
		local v = setmetatable({ _CType = key } , _decode_type_meta)
		self[key] = v
		return v
	end
})

local function decode_message( message , buffer, length)
	local rmessage = c._rmessage_new(P, message, buffer, length)
	if rmessage then
		local self = {
			_CObj = rmessage,
			_CType = message,
		}
		c._add_rmessage(GC,rmessage)
		return setmetatable( self , _R_meta )
	end
end

----------- encode ----------------

local encode_type_cache = {}

local function encode_message(CObj, message_type, t)
	local type = encode_type_cache[message_type]
	for k,v in pairs(t) do
		local func = type[k]
		func(CObj, k , v)
	end
end

local _writer = {
	int = c._wmessage_integer,
	real = c._wmessage_real,
	enum = c._wmessage_string,
	string = c._wmessage_string,
	int64 = c._wmessage_int64,
	int32 = c._wmessage_int32,
	int52 = c._wmessage_int52,
	uint52 = c._wmessage_uint52,
}

function _writer:bool(k,v)
	c._wmessage_integer(self, k, v and 1 or 0)
end

function _writer:message(k, v , message_type)
	local submessage = c._wmessage_message(self, k)
	encode_message(submessage, message_type, v)
end

function _writer:int_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_integer(self,k,v)
	end
end

function _writer:real_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_real(self,k,v)
	end
end

function _writer:bool_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_integer(self, k, v and 1 or 0)
	end
end

function _writer:string_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_string(self,k,v)
	end
end

function _writer:message_repeated(k,v, message_type)
	for _,v in ipairs(v) do
		local submessage = c._wmessage_message(self, k)
		encode_message(submessage, message_type, v)
	end
end

function _writer:int32_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_int32(self,k,v)
	end
end

function _writer:int64_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_int64(self,k,v)
	end
end

function _writer:int52_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_int52(self,k,v)
	end
end

function _writer:uint52_repeated(k,v)
	for _,v in ipairs(v) do
		c._wmessage_uint52(self,k,v)
	end
end

_writer[1] = function(msg) return _writer.int end
_writer[2] = function(msg) return _writer.real end
_writer[3] = function(msg) return _writer.bool end
_writer[4] = function(msg) return _writer.string end
_writer[5] = function(msg) return _writer.string end
_writer[6] = function(msg)
	local message = _writer.message
	return	function(self,key , v)
			return message(self, key, v, msg)
		end
end
_writer[7] = function(msg) return _writer.int64 end
_writer[8] = function(msg) return _writer.int32 end
_writer[9] = _writer[5]
_writer[10] = function(msg) return _writer.int52 end
_writer[11] = function(msg) return _writer.uint52 end

_writer[128+1] = function(msg) return _writer.int_repeated end
_writer[128+2] = function(msg) return _writer.real_repeated end
_writer[128+3] = function(msg) return _writer.bool_repeated end
_writer[128+4] = function(msg) return _writer.string_repeated end
_writer[128+5] = function(msg) return _writer.string_repeated end
_writer[128+6] = function(msg)
	local message = _writer.message_repeated
	return	function(self,key, v)
			return message(self, key, v, msg)
		end
end
_writer[128+7] = function(msg) return _writer.int64_repeated end
_writer[128+8] = function(msg) return _writer.int32_repeated end
_writer[128+9] = _writer[128+5]
_writer[128+10] = function(msg) return _writer.int52_repeated end
_writer[128+11] = function(msg) return _writer.uint52_repeated end

local _encode_type_meta = {}

function _encode_type_meta:__index(key)
	local t, msg = c._env_type(P, self._CType, key)
	local func = assert(_writer[t],key)(msg)
	self[key] = func
	return func
end

setmetatable(encode_type_cache , {
	__index = function(self, key)
		local v = setmetatable({ _CType = key } , _encode_type_meta)
		self[key] = v
		return v
	end
})

function encode( message, t , func , ...)
	local encoder = c._wmessage_new(P, message)
	assert(encoder ,  message)
	encode_message(encoder, message, t)
	if func then
		local buffer, len = c._wmessage_buffer(encoder)
		local ret = func(buffer, len, ...)
		c._wmessage_delete(encoder)
		return ret
	else
		local s = c._wmessage_buffer_string(encoder)
		c._wmessage_delete(encoder)
		return s
	end
end

--------- unpack ----------

local _pattern_type = {
	[1] = {"%d","i"},
	[2] = {"%F","r"},
	[3] = {"%d","b"},
	[4] = {"%d","i"},
	[5] = {"%s","s"},
	[6] = {"%s","m"},
	[7] = {"%D","x"},
	[8] = {"%d","p"},
	[10] =  {"%D","d"},
	[11] =  {"%D","u"},
	[128+1] = {"%a","I"},
	[128+2] = {"%a","R"},
	[128+3] = {"%a","B"},
	[128+4] = {"%a","I"},
	[128+5] = {"%a","S"},
	[128+6] = {"%a","M"},
	[128+7] = {"%a","X"},
	[128+8] = {"%a","P"},
	[128+10] = {"%a", "D" },
	[128+11] = {"%a", "U" },
}

_pattern_type[9] = _pattern_type[5]
_pattern_type[128+9] = _pattern_type[128+5]


local function _pattern_create(pattern)
	local iter = string.gmatch(pattern,"[^ ]+")
	local message = iter()
	local cpat = {}
	local lua = {}
	for v in iter do
		local tidx = c._env_type(P, message, v)
		local t = _pattern_type[tidx]
		assert(t,tidx)
		tinsert(cpat,v .. " " .. t[1])
		tinsert(lua,t[2])
	end
	local cobj = c._pattern_new(P, message , "@" .. table.concat(cpat," "))
	if cobj == nil then
		return
	end
	c._add_pattern(GC, cobj)
	local pat = {
		CObj = cobj,
		format = table.concat(lua),
		size = 0
	}
	pat.size = c._pattern_size(pat.format)

	return pat
end

setmetatable(_pattern_cache, {
	__index = function(t, key)
		local v = _pattern_create(key)
		t[key] = v
		return v
	end
})

function unpack(pattern, buffer, length)
	local pat = _pattern_cache[pattern]
	return c._pattern_unpack(pat.CObj , pat.format, pat.size, buffer, length)
end

function pack(pattern, ...)
	local pat = _pattern_cache[pattern]
	return c._pattern_pack(pat.CObj, pat.format, pat.size , ...)
end

function check(typename , field)
	if field == nil then
		return c._env_type(P,typename)
	else
		return c._env_type(P,typename,field) ~=0
	end
end

--------------

local default_cache = {}

-- todo : clear default_cache, v._CObj

local function default_table(typename)
	local v = default_cache[typename]
	if v then
		return v
	end

	v = { __index = assert(decode_message(typename , "")) }

	default_cache[typename]  = v
	return v
end

local decode_message_mt = {}

local function decode_message_cb(typename, buffer)
	return setmetatable ( { typename, buffer } , decode_message_mt)
end

function decode(typename, buffer, length)
	local ret = {}
	local ok = c._decode(P, decode_message_cb , ret , typename, buffer, length)
	if ok then
		return setmetatable(ret , default_table(typename))
	else
		return false , c._last_error(P)
	end
end

local function expand(tbl)
	local typename = rawget(tbl , 1)
	local buffer = rawget(tbl , 2)
	tbl[1] , tbl[2] = nil , nil
	assert(c._decode(P, decode_message_cb , tbl , typename, buffer), typename)
	setmetatable(tbl , default_table(typename))
end

function decode_message_mt.__index(tbl, key)
	expand(tbl)
	return tbl[key]
end

function decode_message_mt.__pairs(tbl)
	expand(tbl)
	return pairs(tbl)
end

local function set_default(typename, tbl)
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			local t, msg = c._env_type(P, typename, k)
			if t == 6 then
				set_default(msg, v)
			elseif t == 128+6 then
				for _,v in ipairs(v) do
					set_default(msg, v)
				end
			end
		end
	end
	return setmetatable(tbl , default_table(typename))
end

function register( buffer)
	c._env_register(P, buffer)
end

function register_file(filename)
	local f = assert(io.open(filename , "rb"))
	local buffer = f:read "*a"
	c._env_register(P, buffer)
	f:close()
end

function enum_id(enum_type, enum_name)
	return c._env_enum_id(P, enum_type, enum_name)
end

function extract(tbl)
    local typename = rawget(tbl , 1)
    local buffer = rawget(tbl , 2)
    if type(typename) == "string" and type(buffer) == "string" then
        if check(typename) then
            expand(tbl)
        end
    end

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            extract(v)
        end
    end
end

default=set_default

end
        

package.preload[ "network.protobuf" ] = function( ... )
    return require('network/protobuf')
end
            

package.preload[ "network/protocols" ] = function( ... )
require('core.object')

local function encrypt_buffer(buffer)
    if #buffer ~= 1 then
        buffer = table.concat(buffer)
    else
        buffer = buffer[1]
    end
    return PacketStream.encrypt_buffer(buffer, 0)
end

local Packet = class()

Packet.ctor = function(self, headformat, index_of_size, endian)
    self.headformat = endian .. headformat
    self.headsize = struct.size(self.headformat)
    self.index_of_size = index_of_size
    self.endian = endian
    self.buffer = {}
    self.headvalue = {}
end

Packet.readBegin = function(endian, packet)
    error('not implementated')
    -- return position, {cmd=, subcmd=,}
end

Packet.writeBegin = function(self, ...)
    self.headvalue = {...}
end

Packet.preWrite = function(self)
    -- update body size
    local len = 0
    for _, buf in ipairs(self.buffer) do
        len = len + #buf
    end
    self.headvalue[self.index_of_size] = len
end

Packet.writeEnd = function(self)
    self:preWrite()
    local head = struct.pack(self.headformat, unpack(self.headvalue))
    local buf = self.buffer
    self.buffer = {}
    table.insert(buf, 1, head)
    return table.concat(buf)
end

Packet.write = function(self, buf)
    table.insert(self.buffer, buf)
end

local Packet_BY9 = class(Packet, false)
Packet_BY9.headformat = 'HBBBBHB'
Packet_BY9.ctor = function(self, endian)
    super(self, Packet_BY9.headformat, 1, endian)
end
Packet_BY9.readBegin = function(endian, packet)
    packet.position = struct.size(Packet_BY9.headformat)+1
    packet.data = PacketStream.decrypt_buffer(packet.data, packet.position-1)
    packet.head = {
        size = struct.unpack(endian .. 'H', packet.data, 1),
        cmd = struct.unpack(endian .. 'H', packet.data, 7),
    }
end
Packet_BY9.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, subver, cmd, 0)
end
Packet_BY9.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- encrypt
    local buffer, check = encrypt_buffer(self.buffer)
    self.headvalue[7] = check
    self.buffer = {buffer}
end

local Packet_BY7 = class(Packet, false)
Packet_BY7.headformat = 'HBBBH'
Packet_BY7.ctor = function(endian)
    super(Packet_BY7.headformat, 1, endian)
end
Packet_BY7.writeBegin = function(self, cmd, ver)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, cmd)
end
Packet_BY7.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- encrypt
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
end
Packet_BY7.readBegin = function(endian, buffer)
    packet.position = struct.size(Packet_BY9.headformat)+1
    packet.data = decrypt_buffer(packet.data, packet.position-1)
    packet.head = {
        size = struct.unpack(endian .. 'H', buffer, 1),
        cmd = struct.unpack(endian .. 'H', buffer, 6),
    }
end

local Packet_BY14 = class(Packet, false)
Packet_BY14.headformat = 'HBBBBHBHHB'
Packet_BY14.ctor = function(endian)
    super(Packet_BY14.headformat, 1, endian)
end
Packet_BY14.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, subver, cmd, 0, subCmd, 0, dev)
end
Packet_BY14.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- set sequeuce
    self.headvalue[9] = 0
    local buffer, check = encrypt_buffer(self.buffer)
    self.headvalue[7] = check
    self.buffer = {buffer}
end

local Packet_TEXAS = class(Packet, false)
Packet_TEXAS.headformat = 'BBHBBHBI4'
Packet_TEXAS.ctor = function(endian)
    super(Packet_TEXAS.headformat, 6, endian)
end
Packet_TEXAS.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, string.byte('I'), string.byte('C'), cmd, ver, subver, 0, 0, 0)
end
Packet_TEXAS.preWrite = function(self)
    Packet.preWrite(self)
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[7] = check
    --self.headvalue[8] = sequence
end

local Packet_VOICE = class(Packet, false)
Packet_VOICE.headformat = 'BBHBBI4BI4'
Packet_VOICE.ctor = function(endian)
    super(Packet_VOICE.headformat, 6, endian)
end
Packet_VOICE.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, string.byte('I'), string.byte('C'), cmd, ver, subver, 0, 0, 0)
end
Packet_VOICE.preWrite = function(self)
    Packet.preWrite(self)
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[7] = check
    --self.headvalue[8] = sequence
end

local Packet_QE = class(Packet, false)
Packet_QE.headformat = 'I4BBBBI4HB'
Packet_QE.ctor = function(endian)
    super(Packet_QE.headformat, 1, endian)
end
Packet_QE.writeBegin = function(self, ver, cmd, gameId)
    Packet.writeBegin(self, 0, string.byte('Q'), string.byte('E'), ver, 0, cmd, gameId, 0)
end
Packet_QE.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 4
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[8] = check
end

local Packet_IPOKER = class(Packet, false)
Packet_IPOKER.headformat = 'BBHHH'
Packet_IPOKER.ctor = function(endian)
    super(Packet_IPOKER.headformat, 5, endian)
end
Packet_IPOKER.writeBegin = function(self, cmd, ver)
    Packet.writeBegin(self, string.byte('E'), string.byte('S'), cmd, ver, 0)
end

return {
    IPOKER = Packet_IPOKER,
    TEXAS = Packet_TEXAS,
    BY9 = Packet_BY9,
    BY7 = Packet_BY7,
    BY14 = Packet_BY14,
    QE = Packet_QE,
    VOICE = Packet_VOICE,
}

end
        

package.preload[ "network.protocols" ] = function( ... )
    return require('network/protocols')
end
            

package.preload[ "network/socket" ] = function( ... )
if require_uv ~= nil then
    require('network.socket_compat')
else
    require('network.socket_old')
end

end
        

package.preload[ "network.socket" ] = function( ... )
    return require('network/socket')
end
            

package.preload[ "network/socket2" ] = function( ... )
require('network.start_uvloop')

---
-- socket库
-- @module network.socket2
-- @usage local socket = require('network.socket2')
-- @usage
-- -- 自动重连示例：
-- function auto_reconnect(ip, port, handler)
--     local tasklet = require('tasklet')
--     local socket = require('network.socket2')
--     print('connecting')
--     socket.connect_async(ip, port, function(sock, err)
--         if not sock then
--             print('connected failed, retry in 500ms.', err)
--             Clock.instance():schedule_once(function()
--                 auto_reconnect(ip, port, handler)
--             end, 0.5)
--             return
--         end
--         print('connect success')
--         sock:set_on_closed(function(reason)
--             print('client on closed', reason)
--             auto_reconnect(ip, port, handler)
--         end)
--         tasklet.spawn(handler, sock)
--     end)
-- end
--
-- @usage
-- -- client 示例：
-- auto_reconnect('127.0.0.1', 8000, function(sock)
--     -- send test request every second.
--     tasklet.spawn(function()
--         while true do
--             tasklet.sleep(1)
--             local buf = struct.pack('>I4c4', 8, 'test')
--             assert(sock:write(buf))
--             print('client write', #buf)
--         end
--     end)
--     -- keep receiving packets.
--     while true do
--         local header = assert(sock:read(4))
--         local len = struct.unpack('>I4', header)
--         print('client recv', assert(sock:read(len-4)))
--     end
-- end)
--
-- @usage
-- -- echo server 示例
-- socket.spawn_server('127.0.0.1', 8000, function(sock)
--     print('server new connection')
--     sock:set_on_closed(function(reason)
--         print('server on closed', reason)
--     end)
--     while true do
--         assert(sock:write(assert(sock:read(0))))
--     end
-- end)

local M = {}
local uv = require_uv()

---
-- socket对象，不能直接构造，通过 connect connect_async 等方法获得。
-- @type socket
function M.socket(sock)
    local wait_size = 0         -- current read wait
    local _callback             -- current read callback, one shot.
    local bufs = {}             -- current pending buffers
    local size = 0              -- size of current pending buffers
    local status = 'normal'     -- status of socket: normal | closing | closed
    local closed_reason = nil   -- if status is closing or closed, close reason.
    local on_closed             -- callback to listen on_closed event.
    local function do_callback(...)
        -- auto remove callback when called.
        local cb = _callback
        _callback = nil
        cb(...)
    end
    local function check()
        -- try to call current read callback.
        if not _callback then
            return
        end
        if status ~= 'normal' then
            do_callback(nil, 'socket closed')
            return
        end
        if size == 0 then
            return
        end
        if wait_size == 0 then
            -- return whatever we got.
            local result = table.concat(bufs)
            bufs = {}
            size = 0
            do_callback(result)
        elseif size >= wait_size then
            local buf = table.concat(bufs)
            local result = string.sub(buf, 1, wait_size)
            bufs = {}
            local left = string.sub(buf, wait_size+1)
            size = #left
            if size > 0 then
                table.insert(bufs, left)
            end
            do_callback(result)
        end
    end
    local function feed(chunk)
        table.insert(bufs, chunk)
        size = size + #chunk
        check()
    end
    local function on_error(err, callback)
        -- could be read error, write error, user close
        status = 'closing'
        closed_reason = err
        sock:close(function()
            sock = nil
            status = 'closed'
            check()
            if callback then
                callback(err)
            end
            if on_closed then
                on_closed(closed_reason)
            end
        end)
    end

    -- auto start reading.
    sock:read_start(function(err, chunk)
        if err or not chunk then
            on_error(err or 'remote closed')
            return
        end
        feed(chunk)
    end)

    return {
        ---
        -- 异步读，传入回调获取结果，读够size长度才回调，size为0表示任意大于0的长度。
        --
        -- 回调函数的参数：成功为``buffer``，失败为 ``nil, err_string`` 。
        -- @function [parent=#socket] read_async
        -- @param #socket self
        -- @param #number size
        -- @param #function cb
        read_async = function(self, size, cb)
            assert(cb, 'callback can not be nil')
            wait_size = size
            _callback = cb
            check()
        end,
        ---
        -- 同步读，在``tasklet``中调用，读够size长度才返回，size为0表示任意大于0的长度，默认值为0。
        -- @function [parent=#socket] read
        -- @param #socket self
        -- @return #string 成功返回``buffer``，失败返回 ``nil, err_string``
        read = function(self, size)
            return coroutine.yield(function(callback)
                self:read_async(size, callback)
            end)
        end,
        ---
        -- 异步写，可通过回调等待结束。
        -- @function [parent=#socket] write_async
        -- @param #socket self
        -- @param #string buffer 写入的内容
        -- @param #function cb 接受结果的回调，可选，参数：成功为``nil``，失败为``err_string``。
        write_async = function(self, buffer, cb)
            assert(cb, 'callback can not be nil')
            if status ~= 'normal' then
                cb(nil, 'socket closed')
                return
            end
            sock:write(buffer, function(err)
                if err then
                    on_error(err)
                end
                if cb then
                    if err then
                        cb(nil, err)
                    else
                        cb(true)
                    end
                end
            end)
        end,
        ---
        -- 同步写，在``tasklet``中调用。写成功返回 ``nil`` ，写失败返回 ``err_string``
        -- @function [parent=#socket] write
        -- @param #socket self
        -- @param #string buffer
        write = function(self, buffer)
            return coroutine.yield(function(callback)
                self:write_async(buffer, callback)
            end)
        end,
        ---
        -- 异步关闭，通过回调等待关闭结束。
        -- @function [parent=#socket] close_async
        -- @param #socket self
        -- @param #function cb
        close_async = function(self, cb)
            assert(status == 'normal', 'socket is ' .. status)
            on_error('user close', cb)
        end,
        ---
        -- 同步关闭，在``tasklet``中使用。
        -- @param #socket self
        -- @function [parent=#socket] close
        close = function(self)
            return coroutine.yield(function(callback)
                self:close_async(callback)
            end)
        end,
        ---
        -- 获取当前状态，``normal|closing|closed`` 。
        -- @function [parent=#socket] status
        -- @param #socket self
        -- @return #string 
        status = function(self)
            return status
        end,
        ---
        -- 设置监听关闭事件的回调.
        -- @function [parent=#socket] set_on_closed 接受字符串参数 ``close_reason``
        -- @param #socket self
        -- @param #function cb
        -- @usage
        -- local sock = socket.connect('127.0.0.1', 8000)
        -- sock:set_on_closed(function(reason)
        --     print('closed', reason)
        --     -- start reconnect.
        -- end)
        set_on_closed = function(self, cb)
            on_closed = cb
        end,
    }
end

---
-- 异步连接，通过回调获取结果，成功返回``socket``对象，失败返回 ``nil, err_string`` 。
-- @function [parent=#network.socket2] connect_async
-- @param #string ip
-- @param #string port
-- @param #string cb
-- @usage
-- socket.connect_async('127.0.0.1', 8000, function(sock, err)
--     assert(sock, err)
-- end)
function M.connect_async(ip, port, cb)
    local sock = uv.new_tcp()
    sock:connect(ip, port, function(err)
        if err then
            cb(nil, err)
        else
            cb(M.socket(sock))
        end
    end)
end

---
-- 同步连接，在``tasklet``中使用，成功返回``socket``对象，失败返回 ``nil, err_string`` 。
-- @function [parent=#network.socket2] connect
-- @param #string ip ip
-- @param #number port 端口
-- @return #socket 成功：socket示例，失败：``nil, err_string``
-- @usage
-- tasklet.spawn(function()
--     local sock = assert(socket.connect('127.0.0.1', 8000))
--     local len = struct.unpack('>I4', sock:read(4))
--     print('recv body', sock:read(len))
-- end)
function M.connect(ip, port)
    return coroutine.yield(function(callback)
        M.connect_async(ip, port, callback)
    end)
end

---
-- 创建服务器。
-- @function [parent=#network.socket2] spawn_server
-- @param #string host ip
-- @param #number port 端口
-- @param #function on_connection 处理单个连接的回调，运行为``tasklet``。
-- @usage
-- socket.spawn_server('127.0.0.1', 8000, function(sock)
--    sock:write(sock:read())
-- end)
function M.spawn_server(host, port, on_connection)
    local tasklet = require('tasklet')
    local uv = require_uv()
    local server = uv.new_tcp()
    server:bind(host, port)
    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        tasklet.spawn(on_connection, M.socket(client))
    end)
end

return M

end
        

package.preload[ "network.socket2" ] = function( ... )
    return require('network/socket2')
end
            

package.preload[ "network/socket_compat" ] = function( ... )
require("core.object");
local Packets = require('network.protocols')
local manager = require('network.manager').singleThread
manager:start()

--- socket连接成功
kSocketConnected        = 1;
--- socket连接失败
kSocketConnectFailed    = 4;
--- socket关闭成功
kSocketUserClose        = 5;
--- socket收到数据包
kSocketRecvPacket       = 9;

Socket = class();

Socket.s_sockets = {};
Socket.ctor = function(self,sockName,sockHeader,netEndian, gameId, deviceType, ver, subVer)
    if Socket.s_sockets[sockName] then
        error("Already have a " .. sockName .. " socket");
        return
    end
    self.m_name = sockName
    self.m_socketType = sockName; 
    Socket.s_sockets[sockName] = self;

    self:setProtocol(sockHeader, netEndian)
    self.m_packet_id = 0
    self.m_packets = {}

    self.m_gameId = gameId
    self.m_deviceType = deviceType
    self.m_ver = ver
    self.m_subVer = subVer
end

Socket.setProtocol = function(self, protocol, netEndian)
    self.m_endian = netEndian and '>' or '<'
    self.m_protocol = protocol
    -- for stream reader, { offset, size, initsize }.
    local size_field = {
        TEXAS = {6, 2, struct.size(Packets.TEXAS.headformat)},
        VOICE = {6, 2, struct.size(Packets.VOICE.headformat)},
        BY9 = {0, 2, 2},
        BY14 = {0, 2, 2},
        QE = {0, 4, 4},
        BY7 = {0, 2, 2},
        IPOKER = {6, 2, struct.size(Packets.IPOKER.headformat)},
    }
    local args = size_field[protocol]
    table.insert(args, self.m_endian)
    table.insert(args, 1, self.m_name)
    manager:set_protocol(unpack(args))
end

Socket.setConnTimeout = function (self,timeOut)
end

Socket.setEvent = function(self,obj,func)
    self.m_cbObj = obj;
    self.m_cbFunc = func;
end

Socket.onSocketEvent = function(self,eventType, param)
    if self.m_cbFunc then
        self.m_cbFunc(self.m_cbObj,eventType, param);
    end
end

Socket.open = function(self, ip, port)
    manager:connect(self.m_name, ip, port, function(status)
        if not status then
            -- success
            self:onSocketEvent(kSocketConnected)
            manager:read_start(self.m_name, function(packet)
                if packet == nil then
                    -- connection lost
                    self:onSocketEvent(kSocketUserClose)
                    return
                end
                local packetId = self:_addPacket(packet)
                self:onSocketEvent(kSocketRecvPacket, packetId)
            end)
        else
            self:onSocketEvent(kSocketConnectFailed, status)
        end
    end)
end

Socket._addPacket = function(self, packet)
    self.m_packet_id = self.m_packet_id + 1
    self.m_packets[self.m_packet_id] = {
        data = packet,
        position = 1
    }
    return self.m_packet_id
end

Socket.close = function(self, callback)
    manager:close(self.m_name, callback)
end
Socket.readBegin = function(self, packetId)
    local packet = self.m_packets[packetId]
    Packets[self.m_protocol].readBegin(self.m_endian, packet)
    return packet.head.cmd
end
Socket.readEnd = function(self, packetId)
    self.m_packets[packetId] = nil
end

Socket.readInt = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 4 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'I4', packet.data, packet.position)
    return n
end

Socket.writeBegin = function(self, ...)
    local packet = new(Packets[self.m_protocol], self.m_endian)
    packet:writeBegin(...)

    self.m_packet_id = self.m_packet_id + 1
    self.m_packets[self.m_packet_id] = packet
    return self.m_packet_id
end

Socket.writeBegin2 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeBegin3 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeBegin4 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeInt = function(self, packetId, n)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'I4', n))
end

Socket.writeEnd = function(self, packetId)
    local packet = self.m_packets[packetId]
    local buffer = packet:writeEnd()
    manager:write(self.m_name, buffer, function(err)
        if err then
            self:onSocketEvent(kSocketUserClose)
        end
    end)
    self.m_packets[packetId] = nil
end

Socket.readBinary = function(self, packetId)
    local n1 = self:readInt(packetId, 0)
    local len = self:readInt(packetId, 0)
    local str
    str, packet.position = struct.unpack('c' .. tostring(len), packet.data, packet.position)
    if n1 == 0 then
        return str
    else
        return gzip_decompress(str)
    end
end

Socket.writeBinary = function(self, packetId, string, compress)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack('I4', compress))
    self:writeString(packetId, compress and gzip_compress(string) or string)
end

Socket.readString = function(self, packetId)
    local packet = self.m_packets[packetId]
    local len = self:readInt(packetId, 0)
    local str
    str, packet.position = struct.unpack('c' .. tostring(len-1), packet.data, packet.position)
    assert(string.sub(packet.data, packet.position, packet.position) == '\0', 'not zero terminated.')
    packet.position = packet.position + 1
    return str
end

Socket.writeString = function(self, packetId, str)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'I4s', #str + 1, str))
end

Socket.readByte = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 1 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'B', packet.data, packet.position)
    return n
end

Socket.writeByte = function(self, packetId, b)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'B', b))
end

Socket.readShort = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 2 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'H', packet.data, packet.position)
    return n
end

Socket.writeShort = function(self, packetId, b)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'H', b))
end

Socket.writeBuffer = function(self, buffer)
    manager:write(self.m_name, buffer, function(err)
        if err then
            self:onSocketEvent(kSocketUserClose)
        end
    end)
end

end
        

package.preload[ "network.socket_compat" ] = function( ... )
    return require('network/socket_compat')
end
            

package.preload[ "network/socket_old" ] = function( ... )

--------------------------------------------------------------------------------
-- socket，用于和游戏服务器通信.
-- 只支持博雅游戏的各种协议，数据加密与解密已经内置在引擎中。
-- 
-- @module network.socket
-- @return #nil 
-- @usage     require("network.socket")
--     local PROTOCOL_TYPE_QE="QE"                           -- 注：具体协议应与server确定
--     -- 创建一个socket，socketName为"DOUDIZHU",此名称唯一
--     -- socketHeader为PROTOCOL_TYPE_QE，netEndian网络字节序设为1， gameId为10010
--     -- deviceType为192，ver主版本号为20.5，subVer子版本号为0.08
--     local socket = new(Socket,"DOUDIZHU",PROTOCOL_TYPE_QE,1, 10010, 192, 20.5, 0.08)
--     -- 设置10s内连接有效
--     socket:setConnTimeout(10*1000) 
--     -- 服务器的地址为192.168.1.1 端口号为80   
--     socket:open("192.168.1.1",80) 
--      
--     -- socket成功连接后，可以发送数据。
--     -- cmd的值此处为1，应与server确认。由于ver，subVer，deviceType已经在构造函数中设置，所以这里传nil；也可以传其他值覆盖。
--     -- 返回packetId,收到消息、设置回调会用到
--     local packetId=socket:writeBegin (1, nil, nil, nil)   --先写入包头
--     socket:writeString(packetId,"发送的内容")              -- 写入数据
--     socket:writeEnd(packetId)                             -- 数据写入完成，可以发送了 
--   
--     -- 设置回调函数。设置事件kSocketRecvPacket，那么每次收到消息时即触发。
--     socket:setEvent(packetId,function(kSocketRecvPacket,packetId)
--          socket:readString(packetId)                        -- 读取消息。 调用readString或readInt等，应与server确认。
--     end
--     )
--     
--     -- 关闭连接
--     socket:close()

-- socket.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2015-12-15 by DengXuanYing
-- Description: provide basic wrapper for socket functions


require("core.object");

--- socket连接成功
kSocketConnected        = 1;
--- socket连接失败
kSocketConnectFailed    = 4;
--- socket关闭成功
kSocketUserClose        = 5;
--- socket收到数据包
kSocketRecvPacket       = 9;

---
--
-- @type Socket
Socket = class();

---
-- 保存所有的socket实例.
Socket.s_sockets = {};

---
-- 构造函数.
--
-- @param self
-- @param #string sockName socket名字，同名的socket只能同时存在一个。
-- @param #number sockHeader 包头类型，请联系游戏server来确定。
-- @param #number netEndian 网络字节序， 目前固定传1。 
-- @param #number gameId 游戏的id，此值是游戏server确定的。
-- @param #number deviceType 设备类型，此值是游戏server确定的。
-- @param #number ver 协议版本号，此值是游戏server确定的。
-- @param #number subVer 协议子版本号，此值是游戏server确定的。
Socket.ctor = function(self,sockName,sockHeader,netEndian, gameId, deviceType, ver, subVer)

  if Socket.s_sockets[sockName] then
    error("Already have a " .. sockName .. " socket");
    return
  end

  self.m_socketType = sockName; 
  Socket.s_sockets[sockName] = self;
  self:setProtocol ( sockHeader, netEndian ); 

  self.m_gameId = gameId;
  self.m_deviceType = deviceType;
  self.m_ver = ver;
  self.m_subVer = subVer;
  
end

---
-- 析构函数.
--
-- @param self
Socket.dtor = function(self)
  Socket.s_sockets[self.m_socketType] = nil;
end


---
-- 设置协议类型.
-- 此方法仅在构造方法内调用。
--
-- @param self
-- @param #number sockHeader 包头类型，请联系游戏server来确定。
-- @param #number netEndian 网络字节序，目前固定传1。 
Socket.setProtocol = function ( self,sockHeader,netEndian )
  socket_set_protocol ( self.m_socketType, sockHeader, netEndian );
end

---
-- 设置连接超时时间.
--
-- @param self
-- @param #number timeOut 超时时间(毫秒)。
Socket.setConnTimeout = function ( self,timeOut )
  socket_set_conn_timeout ( self.m_socketType, timeOut );
end

---
-- 设置QE协议的扩展包头长度.
--
-- @param self
-- @param #number sizeExt 扩展包头大小，单位为字节。
Socket.setHeaderExtSize = function ( self,sizeExt )
  socket_set_header_extend ( self.m_socketType, sizeExt );
end

---
-- 该接口已废除.
--
Socket.setReconnectParam = function(self, reconnectTimes, interval)
  --return Socket.callFunc(self,"reconnect",reconnectTimes,interval);
end

---
-- 设置事件回调函数.
-- 
-- @param self
-- @param obj 任意类型，回调时传回。
-- @param #function func 回调函数，传入参数为：(obj, eventType, param)。
-- eventType: 事件类型。  
-- 取值[```kSocketConnected```](network.socket.html#kSocketConnected)(连接成功)，
-- [```kSocketConnectFailed```](network.socket.html#kSocketConnectFailed)(连接失败)，
-- [```kSocketUserClose```](network.socket.html#kSocketUserClose)(关闭连接)，
-- [```kSocketRecvPacket```](network.socket.html#kSocketRecvPacket)(收到数据包)。  
-- param: 辅助参数，任意类型。当eventType取值kSocketRecvPacket时，param应传数据包的id。
Socket.setEvent = function(self,obj,func)
  self.m_cbObj = obj;
  self.m_cbFunc = func;
end

---
-- 用于接收事件回调.
-- **开发者不应主动调用此函数。**
--
-- @param self
-- @param #number eventType 事件类型。
-- @param #number param 额外参数。
Socket.onSocketEvent = function(self,eventType, param)
  if self.m_cbFunc then
    self.m_cbFunc(self.m_cbObj,eventType, param);
  end
end

--- 
-- 该函数已经废除.
Socket.reconnect = function(self,num,interval)
  
end

---
-- 开始连接socket.
-- 成功仅表示开始连接，并不代表已经连上。
--
-- @param self
-- @param #string ip 连接ip。
-- @param #number port 端口号。
-- @return #number 返回0表示连接成功，-1表示连接失败。
Socket.open = function(self, ip, port)
  return socket_open(self.m_socketType,ip,port);
end

---
-- 关闭socket.
-- 关闭是异步的，关闭完成后会收到kSocketUserClose事件。
--
-- @param self
-- @param #number param 保留，目前未使用。
Socket.close = function(self, param)
  return socket_close(self.m_socketType,param or -1);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @param #number subVer 协议子版本号。
-- @param #number deviceType 设备类型。
-- @return #number 该数据包的packetId。
Socket.writeBegin = function(self, cmd, ver, subVer, deviceType)
  return socket_write_begin(self.m_socketType,cmd,
    ver or self.m_ver,
    subVer or self.m_subVer,
    deviceType or self.m_deviceType);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number subCmd 子命令号。
-- @param #number ver 协议版本号。
-- @param #number subVer 协议子版本号。
-- @param #number deviceType 设备类型。
-- @return #number 该数据包的packetId。
Socket.writeBegin2 = function(self, cmd, subCmd, ver, subVer, deviceType)
  return socket_write_begin2(self.m_socketType,cmd,subCmd,
    ver or self.m_ver,
    subVer or self.m_subVer,
    deviceType or self.m_deviceType);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @param #number gameId 游戏类型id。
-- @return #number 该数据包的packetId。
Socket.writeBegin3 = function(self, cmd, ver, gameId)
  return socket_write_begin3(self.m_socketType,
      ver or self.m_ver,
      cmd,
      gameId or self.m_gameId);
end

---
-- 生成一个数据包，并写入包头信息.
--
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @return #number 该数据包的packetId。
Socket.writeBegin4 = function(self,cmd,ver)
  return socket_write_begin4(self.m_socketType,ver or self.m_ver,cmd);
end

---
-- 写入一个byte.
-- 向指定的数据包末尾位置写入一个byte数据。
--
-- @param self
-- @param #number packetId 数据包id, 由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的byte数据。
Socket.writeByte = function(self, packetId, value)
  return socket_write_byte(packetId,value);
end

---
-- 写入一个short.
-- 向指定的数据包末尾位置写入一个short数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的short数据。
Socket.writeShort = function(self, packetId, value)
  return socket_write_short(packetId,value);
end

---
-- 写入一个int.
-- 向指定的数据包末尾位置写入一个int数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的int数据。
Socket.writeInt = function(self, packetId, value)
  return socket_write_int(packetId,value);
end


---
-- 写入一个int64.
-- 向指定的数据包末尾位置写入一个int64数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的int64数据。
Socket.writeInt64 = function(self,packetId,value)
  return socket_write_int64(packetId,value);
end

---
-- 写入一个string.
-- 向指定的数据包末尾位置写入一个字符串数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #string value 写入的字符串数据。
Socket.writeString = function(self, packetId, value)
  return socket_write_string(packetId,value);
end

---
-- 直接发送字符串.
-- 创建一个包，向包里写入一个字符串，覆盖包的全部内容（包括包头），然后发送该包。
--
-- @param self
-- @param #string value 要发送的字符串，最大32k。
Socket.writeBuffer = function(self,value)
  return socket_write_buffer(self.m_socketType,value);
end

---
-- 数据包内容写入完成.
-- 调用该函数后代表数据包已经完成，并开始发送数据包给服务器。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
Socket.writeEnd = function(self, packetId)
  return socket_write_end(packetId);
end

---
-- 开始读取一个数据包.
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readBegin = function(self, packetId)
  return socket_read_begin(packetId);
end

---
-- 读取子命令号.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @return #number subCmd 返回子命令号。
Socket.readSubCmd = function(self, packetId)
  return socket_read_sub_cmd(packetId);
end

---
-- 读取一个byte.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个byte数据。
Socket.readByte = function(self, packetId, defaultValue)
  return socket_read_byte(packetId,defaultValue);
end


---
-- 读取一个short.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个short数据。
Socket.readShort = function(self, packetId, defaultValue)
  return socket_read_short(packetId,defaultValue);
end


---
-- 读取一个int.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个int数据。
Socket.readInt = function(self, packetId, defaultValue)
  return socket_read_int(packetId,defaultValue);
end

---
-- 读取一个int64.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个int64数据。
Socket.readInt64 = function(self, packetId, defaultValue)
  return socket_read_int64(packetId,defaultValue);
end

---
-- 读取一个string.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @return #string 读到的string。
Socket.readString = function(self,packetId)
  return socket_read_string(packetId);
end


---
-- 读取结束后调用此方法释放数据包所占内存.
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readEnd = function(self, packetId)
  return socket_read_end(packetId);
end

Socket.writeBinary = function(self, packetId, string, compress)
  return socket_write_string_compress(packetId, string, compress)
end

Socket.readBinary = function(self, packetId)
  return socket_read_string_compress(packetId)
end

---
-- 用于接收c++的socket事件通知.
-- **开发者不应直接调用此方法。**
--
-- @param #string sockName socket的名称。
-- @param #number eventType 事件类型，取值：[```kSocketConnected```](network.socket.html#kSocketConnected)(连接成功)，
-- [```kSocketConnectFailed```](network.socket.html#kSocketConnectFailed)(连接失败)，
-- [```kSocketUserClose```](network.socket.html#kSocketUserClose)(关闭连接)，
-- [```kSocketRecvPacket```](network.socket.html#kSocketRecvPacket)(收到数据包)。
-- @param #number param1 eventType为kSocketRecvPacket时是packetId。
-- @param #number param2 eventType为kSocketRecvPacket时是接收包队列里数据包的数量。
function event_socket(sockName, eventType, param1, param2)
  if Socket.s_sockets[sockName] then
    Socket.s_sockets[sockName]:onSocketEvent(eventType, param1);
  end
end

end
        

package.preload[ "network.socket_old" ] = function( ... )
    return require('network/socket_old')
end
            

package.preload[ "network/start_uvloop" ] = function( ... )
local uv = require_uv()
-- start event loop
return Clock.instance():schedule(function()
    uv.run('nowait')
end)

end
        

package.preload[ "network.start_uvloop" ] = function( ... )
    return require('network/start_uvloop')
end
            

package.preload[ "network/version" ] = function( ... )

--返回版本号
return '3.1(d8b60d968339803e72d7f4f2a59c18beaa4b3404)'

end
        

package.preload[ "network.version" ] = function( ... )
    return require('network/version')
end
            
require("network.http");
require("network.http2");
require("network.socket");
require("network.version");

