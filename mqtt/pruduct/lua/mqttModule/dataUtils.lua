DataUtils = class();

TABLE_BOYAA_IM_CONFIGS = "configs_im_boyaa_table";

-- tab name
TAG_SERVICE_FID = "service_fid_tag";
-- complain history
COMPLAIN_HISTORY = "complain_history";
COMMENT_HISTORY = "comment_history";
INFORM_HISTORY = "inform_history";
RECORD_CONNECT_CALLBACK = "record_connect_callback";
--[[
/**
* 格式如下：{"inform":{"completed" :[11,12],"clicked":[13,14]}}
* 解释如下：inform表示是举报相关的消息
* 		 completed:表示已处理的消息
*       clicked：表示新点击查看的消息
*       
*  此用于menu记录消息是否点击查看
*/
--]]
RECORD_INFORM_CLIEKED_MESSAGE = "msg_inform_clicked_num";
RECORD_COMMENT_CLICKED_MESSAGE = "msg_comment_clicked_num";
RECORD_COMPLAIN_CLICKED_MESSAGE = "msg_complain_clicked_num";
--[[
/**
* 记录举报申诉留言三个界面因一场情况退出时用户已填的相关信息
*/
--]]
MENU_COMPLAIN_TMP_HISTORY = "tmp_complain_history";
MENU_COMMENT_TMP_HISTORY = "tmp_comment_history";
MENU_INFORM_TMP_HISTORY = "tmp_inform_history";

DataUtils.getInstance = function()
	if not DataUtils.s_instance then 
		DataUtils.s_instance = new(DataUtils);
	end
	return DataUtils.s_instance;
end

function DataUtils:ctor()
    self.dict = new(Dict, TABLE_BOYAA_IM_CONFIGS);
    self.dict:load();
end

function DataUtils:dtor()
    self.dict:save();
    delete(self.dict);
    self.dict = nil;
end


function DataUtils:save()
    self.dict:save();
end

--[[
/**
* 记录临时举报用户填入内容
* @param activity
* @param nums
*/
--]]
function DataUtils:saveInformTmpHistory(history)
    self.dict:setString(MENU_INFORM_TMP_HISTORY, history);
    self:save();
end
	
function DataUtils:saveCommentTmpHistory(history)
    self.dict:setString(MENU_COMMENT_TMP_HISTORY, history);
    self:save();
end
	
function DataUtils:saveComplainTmpHistory(history)
    self.dict:setString(MENU_COMPLAIN_TMP_HISTORY, history);
    self:save();
end
	
function DataUtils:getInformTmpHistory()
    return self.dict:getString(MENU_INFORM_TMP_HISTORY);
end

function DataUtils:getCommentTmpHistory()
    return self.dict:getString(MENU_COMMENT_TMP_HISTORY);
end

function DataUtils:getComplainTmpHistory()
    return self.dict:getString(MENU_COMPLAIN_TMP_HISTORY);
end
	
function DataUtils:saveInformMessageClickedNums(nums)
    self.dict:setString(RECORD_INFORM_CLIEKED_MESSAGE, nums);
    self:save();
end
	
function DataUtils:saveCommentMessageClickedNums(nums)
    self.dict:setString(RECORD_COMMENT_CLICKED_MESSAGE, nums);
    self:save();
end

function DataUtils:saveComplainMessageClickedNums(nums)
    self.dict:setString(RECORD_COMPLAIN_CLICKED_MESSAGE, nums);
    self:save();
end

function DataUtils:getInformMessageClickedNums()
    return self.dict:getString(RECORD_INFORM_CLIEKED_MESSAGE);
end

function DataUtils:getCommentMessageClickedNums()
    return self.dict:getString(RECORD_COMMENT_CLICKED_MESSAGE);
end

function DataUtils:getComplainMessageClickedNums()
    return self.dict:getString(RECORD_COMPLAIN_CLICKED_MESSAGE);
end


function DataUtils:saveCurrentServiceFid(sfid)
    self.dict:setString(TAG_SERVICE_FID, sfid);
    self:save();
end

function DataUtils:getCurrentServiceFid()
    return self.dict:getString(TAG_SERVICE_FID);
end

function DataUtils:removeCurentServiceFid()
	self:saveCurrentServiceFid("");
end

function DataUtils:saveComplainHistoryCount(count)
    self.dict:setInt(COMPLAIN_HISTORY, count);
    self:save();
end

function DataUtils:getComplainHistoryCount()
    return self.dict:getInt(COMPLAIN_HISTORY, 0);
end

function DataUtils:cleanComplainHistoryCount()
    self:saveComplainHistoryCount(0);
end

function DataUtils:saveInformHistoryCount(count)
    self.dict:setInt(INFORM_HISTORY, count);
    self:save();
end

function DataUtils:getInformHistoryCount()
    return self.dict:getInt(INFORM_HISTORY, 0);
end

function DataUtils:saveCommentHistoryCount(count)
	self.dict:setInt(COMMENT_HISTORY, count);
    self:save();
end

function DataUtils:getCommentHistoryCount()
    return self.dict:getInt(COMMENT_HISTORY, 0);
end
--[[
/**
* 
* @param context
* @param md5
*            : 用本地file生成md5值
* @param uri
*            : 上传文件服务器之后，服务器下载的下载download uri
* @return
*/
--]]
function DataUtils:getAvatarUri(md5)
    return self.dict:getString(md5);
end
--[[
/**
* 做优化处理，比如该图片以上传过之后，就不用上传了
* 
* @param context
* @param md5
* @param uri
*/
--]]
function DataUtils:saveAvatarUri(md5, uri)
    self.dict:setString(md5, uri);
    self:save();
end
	
function DataUtils:setConnectCallbackStatus(isCallback)
    self.dict:setBoolean(RECORD_CONNECT_CALLBACK, isCallback);
    self:save();
end
	
function DataUtils:obtainConnectCallbackStatus()
    return self.dict:getBoolean(RECORD_CONNECT_CALLBACK, false);
end