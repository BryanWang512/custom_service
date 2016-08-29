#ifndef _IOS_AUDIO_TRACK_H
#define _IOS_AUDIO_TRACK_H
#include <stdlib.h>
#include "global.h"
#include "audio_track.h"
#import  <Foundation/Foundation.h>
#import  <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>


#define MIN_SIZE_PER_FRAME (1600) //每帧最小数据长度

class IosAudioTrack :public AudioTrack
{
private:
    AudioStreamBasicDescription audioDescription; ///音频参数
    AudioQueueRef audioQueue; //音频播放队列
    AudioQueueBufferRef audioQueueBuffer; //音频缓存
    static void AudioPlayerAQInputCallback(void* inUserData, AudioQueueRef outQ, AudioQueueBufferRef outQB);
    void reset(int len);
    int bufferSize;
    mutex m_mutex;
    mutex m_state_mutex;
    mutex m_wait_mutex;
    int m_state;
public:
	IosAudioTrack();
	~IosAudioTrack();
    int  getState();
	int  getBufferSize(){ return bufferSize; }
    int  getMinBufferSize(){ return MIN_SIZE_PER_FRAME; }
    void pause(); //暂时不需要
	void play();
    void stop();
    void flush(){};
    void release(){};
	void writeHandle(const char* audioData, int sizeInBytes);
};


#endif