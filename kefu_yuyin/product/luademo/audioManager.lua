--录制,播放管理类， 只能播放通过此接口录制的文件
--录制的文件为:原始pcm数据经过speex压缩后的文件
AudioManager = class();

local s_instance;

--获取单例
AudioManager.getInstance = function ()
    if s_instance  == nil then
        s_instance = new(AudioManager);
    end
    return s_instance;
end

AudioManager.releaseInstance = function ()
    if s_instance then
        delete(s_instance);
    end
end

AudioManager.ctor = function (self)
    if package.preload['kefu_yuyin'] ~= nil then
		self.audio = require "kefu_yuyin";
        if not self.audio then
            error("kefu_yuyin plugin is null!!");
        end
        self.audio.create();
    end
end

AudioManager.dtor = function (self)
    self.audio.destroy();
    self.audio = nil;
end

--path是文件的保存路径，绝对路径
AudioManager.startRecord = function (self, filepath)
    self.audio.startRecord(filepath);
end

--结束当前录制任务，文件会保存在filepath
AudioManager.stopRecord = function (self)
    self.audio.stopRecord();
end

--取消当前录制任务，文件不会保存
AudioManager.cancelRecord = function (self)
    self.audio.cancelRecord();
end

--播放filepath下的音频
AudioManager.startTrack = function (self, filepath)
    self.audio.startTrack(filepath);
end

--停止播放
AudioManager.stopTrack = function (self)
    self.audio.stopTrack();
end

--获取播放状态
AudioManager.getTrackState = function (self)
    self.audio.trackState();
end


--事件常量
AudioManager.EVENT_TRACK_COMPLETED = 1; --播放完成
AudioManager.EVENT_RECORD_COMPLETED = 2; --录制完成
AudioManager.EVENT_RECORD_CANCEL = 3; --取消录制
--播放状态
AudioManager.PLAYSTATE_ERROR = -1; --error
AudioManager.PLAYSTATE_STOPPED = 1; --未播放
AudioManager.PLAYSTATE_PAUSED = 2; --暂停(暂时没什么用)
AudioManager.PLAYSTATE_PLAYING = 3; --播放中


--插件事件回调,duration是时长
function audio_event_callback(cmd, duration)
	if cmd == AudioManager.EVENT_TRACK_COMPLETED then
        
	end
	if cmd == AudioManager.EVENT_RECORD_COMPLETED then
		
	end
	if cmd == AudioManager.EVENT_RECORD_CALCEL then
		
	end
end