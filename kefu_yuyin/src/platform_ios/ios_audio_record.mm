#include "ios_audio_record.h"

IosAudioRecord::IosAudioRecord()
{
    
    m_recordQueue = [[NSMutableArray alloc] init];
    setRecordingState(RECORDSTATE_STOPPED);
}

IosAudioRecord::~IosAudioRecord()
{

    lock_guard<mutex> lock(m_wait_mutex);
    if (m_recordQueue != NULL){
        m_recordQueue = NULL;
    }
}

void IosAudioRecord::setupAudioFormat()
{
    
    memset(&m_recordFormat, 0, sizeof(m_recordFormat));
    
    m_recordFormat.mSampleRate         = SAMPLE_PER_SECOND;
    m_recordFormat.mFormatID           = kAudioFormatLinearPCM;
    m_recordFormat.mFormatFlags        = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    m_recordFormat.mChannelsPerFrame   = 1; // mono
    m_recordFormat.mBitsPerChannel     = 16;
    m_recordFormat.mFramesPerPacket    = 1;
    m_recordFormat.mBytesPerPacket     = 2;
    m_recordFormat.mBytesPerFrame      = 2;
    m_recordFormat.mReserved           = 0;
}


void IosAudioRecord::inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
                                        UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    IosAudioRecord *recorder = (IosAudioRecord *)inUserData;
    if (inNumPackets > 0 && recorder->getState() == RECORDSTATE_RECORDING){
        int pcmSize = inBuffer->mAudioDataByteSize;
        char *pcmData = new char[pcmSize];
        memcpy(pcmData, (char *)inBuffer->mAudioData, pcmSize);
        
        NSData *data = [[NSData alloc] initWithBytes:pcmData length:pcmSize];
        recorder->add(data);
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

void IosAudioRecord::add(NSData* data)
{
    lock_guard<mutex> lock(m_mutex);
    if(data != NULL){
        [m_recordQueue addObject:data];
        m_condition_wait.notify_all();
    }
}


NSData* IosAudioRecord::getDataAndremove()
{
    lock_guard<mutex> lock(m_mutex);
    NSData* audioData = nil;
    if (m_recordQueue.count > 0) {
        // 获取队头数据
        audioData = [m_recordQueue objectAtIndex:0];
        [m_recordQueue removeObjectAtIndex:0];
    }
    return audioData;
}

int IosAudioRecord::getState()
{
    lock_guard<mutex> lock(m_state_mutex);
    return m_state;
}

bool IosAudioRecord::isRecording()
{
    lock_guard<mutex> lock(m_state_mutex);
    return (m_state == RECORDSTATE_RECORDING);
}

void IosAudioRecord::setRecordingState(int state)
{
    lock_guard<mutex> lock(m_state_mutex);
    m_state = state;
}

void IosAudioRecord::start()
{
    if(isRecording()){
        stop();
    }
    
    NSError *error = nil;
    //设置audio session的category
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];//注意，这里选的是AVAudioSessionCategoryPlayAndRecord参数，如果只需要录音，就选择Record就可以了，如果需要录音和播放，则选择PlayAndRecord，这个很重要
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }
    setupAudioFormat();
    
    // 设置回调函数
    AudioQueueNewInput(&m_recordFormat, inputBufferHandler, this, NULL, NULL, 0, &m_audioQueue);
    
    
    m_buffSize = m_recordFormat.mBitsPerChannel * m_recordFormat.mChannelsPerFrame * m_recordFormat.mSampleRate * kBufferDurationSeconds / 8;
    // 创建缓冲器
    for (int i = 0; i < kNumberAudioQueueBuffers; ++i){
        AudioQueueAllocateBuffer(m_audioQueue, m_buffSize, &m_audioBuffers[i]);
        AudioQueueEnqueueBuffer(m_audioQueue, m_audioBuffers[i], 0, NULL);
    }
    
    // 开始录音
    AudioQueueStart(m_audioQueue, NULL);
    setRecordingState(RECORDSTATE_RECORDING);
    m_condition_wait.notify_all();
}

void IosAudioRecord::stop()
{
    if(getState() == RECORDSTATE_RECORDING){
        AudioQueueFlush(m_audioQueue);
        AudioQueueStop(m_audioQueue, true);
        AudioQueueDispose(m_audioQueue, true);
    }
    setRecordingState(RECORDSTATE_STOPPED);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    OSStatus propertySetError = 0;
    UInt32 allowMixing = false;
    propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing);
    
    UInt32 shouldDuck = (UInt32)NO;
    propertySetError |= AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(UInt32), &shouldDuck);
    
    [[AVAudioSession sharedInstance] setActive:YES withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
    m_condition_wait.notify_all();
}

int IosAudioRecord::readHandle(char** audioData)
{
    lock_guard<mutex> lock(m_wait_mutex);
    int len  = 0;
    if (*audioData != NULL){
        delete[] *audioData;
        *audioData = NULL;
    }
    
    
    while(isRecording())
    {
        NSData * data = getDataAndremove();
        if(data == NULL){
            m_condition_wait.wait(m_wait_mutex);
        }
        else{
            len = (int)data.length;
            if(len > 0){
                *audioData = new char[m_buffSize]();
                memcpy(*audioData, (char*)data.bytes, len);
            }
            data = nil;
        }
        if(len > 0){
            break;
        }
    }
    return len;
}

int IosAudioRecord::getBufferSize()
{
    return m_buffSize;
}
