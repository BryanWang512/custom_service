#include "ios_audio_track.h"

IosAudioTrack::IosAudioTrack()
{
    ///设置音频参数
    audioDescription.mSampleRate = 8000; //采样率
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioDescription.mChannelsPerFrame = 1; ///单声道
    audioDescription.mFramesPerPacket = 1; //每一个packet一侦数据
    audioDescription.mBitsPerChannel = 16; //每个采样点16bit量化
    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel / 8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame;
}

IosAudioTrack::~IosAudioTrack()
{
    stop();
    
}

int IosAudioTrack::getState()
{
    lock_guard<mutex> locker(m_state_mutex);
    return m_state;
}

void IosAudioTrack::reset(int len)
{
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue, true);
        AudioQueueReset(audioQueue);
        AudioQueueDispose(audioQueue, true);
    }
    
   
    audioQueue = nil;
    audioQueueBuffer = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // session.outputDataSources
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    // use the louder speaker
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    

    
    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (void*)this, nil, nil, 0, &audioQueue); //使用player的内部线程播放
    //初始化音频缓冲区
    int result = AudioQueueAllocateBuffer(audioQueue, len, &audioQueueBuffer); ///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的
    NSLog(@"IosAudioTrack:: result = %d", result);
    NSLog(@"IosAudioTrack:: reset");
    
    bufferSize = len;
    AudioQueueStart(audioQueue, NULL);
}


void IosAudioTrack::AudioPlayerAQInputCallback(void* inUserData, AudioQueueRef outQ, AudioQueueBufferRef outQB)
{
    IosAudioTrack* player = (IosAudioTrack*)inUserData;
}

void IosAudioTrack::play()
{
    lock_guard<mutex> locker(m_state_mutex);
    m_state = PLAYSTATE_PLAYING;
}

void IosAudioTrack::pause()
{
    lock_guard<mutex> locker(m_state_mutex);
    m_state = PLAYSTATE_PAUSED;
}

void IosAudioTrack::stop()
{
    lock_guard<mutex> locker(m_state_mutex);
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue, true);
        AudioQueueReset(audioQueue);
        AudioQueueDispose(audioQueue, true);
    }
    
    audioQueue = nil;
    m_state = PLAYSTATE_STOPPED;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    OSStatus propertySetError = 0;
    UInt32 allowMixing = false;
    propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing);
    
    UInt32 shouldDuck = (UInt32)NO;
    propertySetError |= AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(UInt32), &shouldDuck);
    
    [[AVAudioSession sharedInstance] setActive:YES withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
}

void IosAudioTrack::writeHandle(const char* audioData, int sizeInBytes)
{
    if(getState() == PLAYSTATE_PLAYING){
        if(audioData != NULL && sizeInBytes > 0){
            reset(sizeInBytes);
            audioQueueBuffer->mAudioDataByteSize = sizeInBytes;
            char* mAudioData = (char*)audioQueueBuffer->mAudioData;
            memcpy(mAudioData, audioData, sizeInBytes);
            AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, 0, NULL);
        }
    }
}