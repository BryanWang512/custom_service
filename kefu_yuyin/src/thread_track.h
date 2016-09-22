#ifndef _BYAUDIO_THREAD_TRACK_H
#define _BYAUDIO_THREAD_TRACK_H
#include <stdlib.h>
#include <thread>
#include "config.h"
#include "audio_track.h"
#include "byaudio_timer.h"
#include "_MessageContainer.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
#include "platform_android/android_audio_track.h"
#elif(TARGET_PLATFORM==PLATFORM_IOS)
#include "platform_ios/ios_audio_track.h"
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
#include "platform_win/win_audio_track.h"
#endif

using namespace std;

class TrackThread
{
private:
	thread* _t = NULL; 
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
	AndroidAudioTrack
#elif(TARGET_PLATFORM==PLATFORM_IOS)
	IosAudioTrack
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
	WinAudioTrack
#endif
		* audioTrack = NULL;
	BoyaaTimer playTimer;
public:
	TrackThread();
	~TrackThread();
	void start(string path);
	void pause();
	void play();
	void stop();
	void cancel();
	int getPlayState();
	_MessageContainer* container;
protected:
	void run();
	mutex m_state_mutex;
	mutex m_mutex;
};

TrackThread::TrackThread()
{
	audioTrack = new
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
		AndroidAudioTrack();
#elif(TARGET_PLATFORM==PLATFORM_WIN32)
		WinAudioTrack();
#elif(TARGET_PLATFORM==PLATFORM_IOS)
		IosAudioTrack();
#endif
	container = new _MessageContainer();
}

TrackThread::~TrackThread()
{
	if (audioTrack != NULL){
		audioTrack->stop();
		audioTrack->release();
		delete audioTrack;
		audioTrack = NULL;
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

void TrackThread::pause()
{
	if (audioTrack == NULL)
		return;
	if (audioTrack->getState() == PLAYSTATE_PLAYING)
	{
		audioTrack->pause();
	}
}

void TrackThread::play()
{
	if (audioTrack == NULL)
		return;
	if (audioTrack->getState() == PLAYSTATE_PAUSED)
	{
		audioTrack->play();
	}
}

void TrackThread::start(string path)
{
	if (audioTrack == NULL)
		return;
	kefu_print_log_debug("audio_kefu", "start");
	stop();
	audioTrack->setPath(path);
	kefu_print_log_debug("audio_kefu", "audioTrack->play");
	_t = new thread(&TrackThread::run, this);
}

void TrackThread::stop()
{
	if (audioTrack == NULL)
		return;
	if (audioTrack->getState() != PLAYSTATE_STOPPED)
	{
		audioTrack->pause();
		audioTrack->flush();
		audioTrack->stop();
	}
}

void TrackThread::run()
{
	lock_guard<mutex> locker(m_mutex);
	if (audioTrack == NULL)
		return;
    int dataSize = 0;
	if (TARGET_PLATFORM == PLATFORM_IOS || TARGET_PLATFORM == PLATFORM_WIN32){
        audioTrack->play();
        dataSize = audioTrack->read();
        kefu_print_log_debug("audio_kefu", "TrackThread::run read dataSize: %d", dataSize);
    }else if (TARGET_PLATFORM == PLATFORM_ANDROID){
        dataSize = audioTrack->read();
        kefu_print_log_debug("audio_kefu", "TrackThread::run read dataSize: %d", dataSize);
        audioTrack->play();
    }
    int duration = (dataSize * 8 * 1000) / (SAMPLE_RATE_IN_HZ * 16 * 1); //ms
    //数据量 = （采样频率×采样位数×声道数×时间） / 8
    kefu_print_log_debug("audio_kefu", "TrackThread::run duration: %d", duration);
	_long playTimeCount = 0;
	playTimer.reset();
	while (playTimeCount < duration){
		this_thread::sleep_for(chrono::milliseconds(500));
		playTimeCount = playTimer.elapsed();
		kefu_print_log_debug("audio_kefu", "TrackThread::run playTimeCount: %d", playTimeCount);
	}
	//播放完成
	LuaMessage message;
	message.cmd = EVENT_TRACK_COMPLETED;
	message.duration = duration;
	container->pushLuaMessage(message);
}

int TrackThread::getPlayState()
{
	lock_guard<mutex> lock(m_state_mutex);
	if (audioTrack == NULL)
		return -1;
	return audioTrack->getState();
}
#endif