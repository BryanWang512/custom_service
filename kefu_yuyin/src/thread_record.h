#ifndef _BYAUDIO_THREAD_RECORD_H
#define _BYAUDIO_THREAD_RECORD_H
#include <thread>
#include "Plugin.h"
#include "global.h"
#include "_MessageContainer.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
#include "platform_android/android_audio_record.h"
#elif(TARGET_PLATFORM==PLATFORM_IOS)
#include "platform_ios/ios_audio_record.h"
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
#include "platform_win/win_audio_record.h"
#endif

using namespace std;

class RecordThread
{
private:
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
	AndroidAudioRecord
#elif(TARGET_PLATFORM==PLATFORM_IOS)
	IosAudioRecord
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
	WinAudioRecord
#endif
		*audioRecord = NULL;
protected:
	thread* _t = NULL;
	mutex m_state_mutex;
	mutex m_mutex;
	void run();
public:
	RecordThread();
	~RecordThread();
	void start(string path);
	void stop();
	void cancel();
	int getRecordingState();
	_MessageContainer* container;
};

RecordThread::RecordThread()
{
	audioRecord = new
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
		AndroidAudioRecord();
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
		WinAudioRecord();
#elif(TARGET_PLATFORM==PLATFORM_IOS)
		IosAudioRecord();
#endif
	container = new _MessageContainer();
}

RecordThread::~RecordThread()
{
	if (audioRecord != NULL){
		audioRecord->stop();
		audioRecord->release();
		delete audioRecord;
		audioRecord = NULL;
	}
	if (_t != NULL)
	{
		_t->join();
		delete _t;
		_t = NULL;
	}
	if (container != NULL)
	{
		delete container;
		container = NULL;
	}
}

void RecordThread::start(string path)
{
	stop();
	if (audioRecord == NULL){
		return;
	}
	audioRecord->setPath(path);
	kefu_print_log_debug("audio_kefu", "audioRecord->startRecording");
	_t = new thread(&RecordThread::run, this);
}

void RecordThread::run()
{
	lock_guard<mutex> locker(m_mutex);
	if (audioRecord == NULL)
		return;
	audioRecord->start();
	int dataSize = audioRecord->save(volume_callback);
	kefu_print_log_debug("audio_kefu", "audioRecord->save() dataSize: %d", dataSize);
    //Â¼ÖÆÍê³É
    LuaMessage message;
    if (audioRecord->isCancel) {
        message.cmd = EVENT_RECORD_CANCEL;
		message.duration = 0;
    }else{
        message.cmd = EVENT_RECORD_COMPLETED;
		message.duration = (dataSize * 8 * 1000) / (SAMPLE_RATE_IN_HZ * 16 * 1); //ms
    }
	container->pushLuaMessage(message);
}

void RecordThread::stop()
{
	if (audioRecord != NULL){
		if (audioRecord->getState() != RECORDSTATE_STOPPED){
			audioRecord->stop();
		}
	}
	if (_t != NULL){
		_t->join();
		delete _t;
		_t = NULL;
	}
}

void RecordThread::cancel()
{
	if (audioRecord != NULL){
		if (audioRecord->getState() == RECORDSTATE_RECORDING){
			audioRecord->cancel();
			audioRecord->stop();
		}
	}
	if (_t != NULL){
		_t->join();
		delete _t;
		_t = NULL;
	}
}

int RecordThread::getRecordingState()
{
	lock_guard<mutex> lock(m_state_mutex);
	if (audioRecord == NULL)
		return -1;
	return audioRecord->getState();
}

#endif