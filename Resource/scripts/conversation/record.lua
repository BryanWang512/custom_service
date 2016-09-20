--录制,播放管理类， 只能播放通过此接口录制的文件
--录制的文件为:原始pcm数据经过speex压缩后的文件
local Record = class();

local s_instance;

--事件常量
Record.EVENT ={
    TRACK_DOWN = 1,--播放完成
    RECORD_DOWN = 2,--录制完成
    RECORD_CANCEL = 3,--取消录制
    RECORD_VOLUME = 5, --声音状态
}

--播放状态
Record.PLAYSTATE ={
    ERROR = -1,--error
    STOPPED = 1,--未播放
    PAUSED = 2,--暂停(暂时没什么用)
    PLAYING = 3,--播放中
}

--获取单例
Record.getInstance = function ()
    if s_instance  == nil then
        s_instance = new(Record);
        EventDispatcher.getInstance():register(KefuEvent.voice, s_instance, s_instance.callback)
    end
    return s_instance;
end

Record.releaseInstance = function ()
    if s_instance then
        EventDispatcher.getInstance():unregister(KefuEvent.voice, s_instance, s_instance.callback)
        delete(s_instance);
        s_instance = nil
    end
end

Record.callback = function (self, event, duration)
    if self.m_callback[event] then
        self.m_callback[event](duration)
    end
end


Record.ctor = function (self)
    if package.preload['kefu_yuyin'] ~= nil then
		self.audio = require "kefu_yuyin";
        if not self.audio then
            error("kefu_yuyin plugin is null!!");
        end
        self.m_listener = {};
        self.audio.audio_create();
    end
end

Record.dtor = function (self)
    self.audio.audio_destroy();
    self.audio = nil;
    self.m_listener = nil;
end

--path是文件的保存路径，绝对路径
Record.startRecord = function (self, filepath)
    self.audio.startRecord(filepath);
end

--结束当前录制任务，文件会保存在filepath
Record.stopRecord = function (self)
    self.audio.stopRecord();
end

--取消当前录制任务，文件不会保存
Record.cancelRecord = function (self)
    self.audio.cancelRecord();
end

--播放filepath下的音频
Record.startTrack = function (self, filepath)
    self.audio.startTrack(filepath);
end

--停止播放
Record.stopTrack = function (self)
    self.audio.stopTrack();
end

--获取播放状态
Record.getTrackState = function (self)
    self.audio.trackState();
end

--获取指定录制文件播放时长
Record.getAudioDuration = function (self,filePath)
    local fileLen = math.floor((System.getFileSize(filePath)/1000) + 0.5)
    return fileLen; 
end

--设置回调函数
Record.setOnEvent = function (self,event,func)
    self.m_callback = self.m_callback or {}
    self.m_callback[event] = func
end



--插件事件回调,duration是时长
function audio_event_callback(event, duration)
    EventDispatcher.getInstance():dispatch(KefuEvent.voice, event, duration)
end

return Record