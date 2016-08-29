#ifndef _IOS_AUDIO_RECORD_H
#define _IOS_AUDIO_RECORD_H
#include <stdlib.h>
#include "global.h"
#include "audio_record.h"
#include <AudioToolbox/AudioToolbox.h>
#include <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>
#include <condition_variable>
//#include "ios_audio_track.h"

const int kBufferByteSize = 1024;
const int kNumberAudioQueueBuffers = 1;
const float kBufferDurationSeconds = 0.1f;

class IosAudioRecord:public AudioRecord
{
private:
    AudioQueueRef				m_audioQueue;
    AudioQueueBufferRef			m_audioBuffers[kNumberAudioQueueBuffers];
    AudioStreamBasicDescription	m_recordFormat;
    NSMutableArray *            m_recordQueue;
    int                         m_buffSize;
    void add(NSData* data);
    NSData* getDataAndremove();
    bool isWrited;
    static void inputBufferHandler(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc);
    mutex m_mutex;
    mutex m_state_mutex;
    mutex m_wait_mutex;
    condition_variable_any m_condition_wait;
    int m_state;
    
    void setupAudioFormat();
    void setRecordingState(int);
    bool isRecording();
public:
	IosAudioRecord();
	~IosAudioRecord();
    int  getState();
	void start();
    void release(){};
	void stop();
	int readHandle(char** audioData);
    int getBufferSize();
};


#endif