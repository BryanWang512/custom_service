#ifndef _WIN_AUDIO_TRACK_H
#define _WIN_AUDIO_TRACK_H
#include <stdio.h>
#include <stdlib.h>
#include "global.h"
#include "audio_track.h"

#if (TARGET_PLATFORM==PLATFORM_WIN32)
#include <Windows.h>

#define WIN_TRACK_PLAYING (0L)
#define WIN_TRACK_STOPED  (1L)
#pragma comment(lib, "winmm.lib")
class WinAudioTrack:public AudioTrack
{
private:
	int             cnt;
	HWAVEOUT        hwo;
	WAVEHDR         wh1;
	WAVEFORMATEX    wfx;
	int state;
	BOOL			isDone;
public:
	mutex			m_win_mutex;
	mutex		    m_wait_mutex;
	static void CALLBACK WaveCallback(HWAVEOUT hWave, UINT uMsg, DWORD dwInstance, DWORD dw1, DWORD dw2);
public:
	WinAudioTrack();
	~WinAudioTrack();
	int	getMinBufferSize(){ return 0; }
	int	getState();
	int	setStereoVolume(float leftGain, float rightGain){ return 0; }
	int getBufferSize(){ return 0; }
	void createAudioTrack(int buffSize, int mode){}
	void pause(){}
	void play();
	void stop();
	void flush(){}
	void release();
	void setDone(BOOL isDone);
	BOOL getDone();
	BOOL isPlaying();
	void writeHandle(const char* audioData, int sizeInBytes);
};

void CALLBACK WinAudioTrack::WaveCallback(HWAVEOUT hWave, UINT uMsg, DWORD dwInstance, DWORD dw1, DWORD dw2)//�ص�����
{
	WAVEHDR * wh1 = NULL;
	switch (uMsg)
	{
		case WOM_DONE://�ϴλ��沥�����,�������¼�
			wh1 = (WAVEHDR *)dw1;
			if (wh1 != NULL){
				wh1->dwUser = WIN_TRACK_STOPED;
			}
			break;
	}
}

WinAudioTrack::WinAudioTrack()
{
	wfx.wFormatTag = WAVE_FORMAT_PCM;//���ò��������ĸ�ʽ
	wfx.nChannels = 1;//������Ƶ�ļ���ͨ������
	wfx.nSamplesPerSec = 8000;//����ÿ���������źͼ�¼ʱ������Ƶ��
	wfx.nAvgBytesPerSec = 16000;//���������ƽ�����ݴ�����,��λbyte/s�����ֵ���ڴ��������С�Ǻ����õ�
	wfx.nBlockAlign = 2;//���ֽ�Ϊ��λ���ÿ����
	wfx.wBitsPerSample = 16;
	wfx.cbSize = 0;//������Ϣ�Ĵ�С
	state = PLAYSTATE_STOPPED;
	setDone(false);
}

WinAudioTrack::~WinAudioTrack()
{
	lock_guard<mutex> locker(m_wait_mutex);
}

void WinAudioTrack::play()
{
	lock_guard<mutex> locker(m_win_mutex);
	state = PLAYSTATE_PLAYING;
}

void WinAudioTrack::stop()
{
	lock_guard<mutex> locker(m_win_mutex);
	state = PLAYSTATE_STOPPED;
}

void WinAudioTrack::release()
{
}

void WinAudioTrack::setDone(BOOL isDone)
{
	lock_guard<mutex> locker(m_win_mutex);
	this->isDone = isDone;
}

BOOL WinAudioTrack::getDone()
{
	lock_guard<mutex> locker(m_win_mutex);
	return isDone;
}

int WinAudioTrack::getState()
{
	lock_guard<mutex> locker(m_win_mutex);
	return state;
}

int WinAudioTrack::isPlaying()
{
	lock_guard<mutex> locker(m_win_mutex);
	return (state == PLAYSTATE_PLAYING);
}

void WinAudioTrack::writeHandle(const char* audioData, int sizeInBytes)
{
	lock_guard<mutex> locker(m_wait_mutex);
	BoyaaTimer timer;
	timer.reset();
	print_log_debug("recorder", "win32 writeHandle begin");
	if (getState() == PLAYSTATE_PLAYING){
		waveOutOpen(&hwo, WAVE_MAPPER, &wfx, 0L, 0L, CALLBACK_NULL);//��һ�������Ĳ�����Ƶ���װ���������������ţ���ʽΪ�ص�������ʽ������ǶԻ�����򣬿��Խ������������Ϊ(DWORD)this����������Demo��������
		wh1.dwLoops = 0L;//������һ
		char* tmp = new char[sizeInBytes];
		wh1.lpData = tmp;
		wh1.dwBufferLength = sizeInBytes;
		memcpy(wh1.lpData, audioData, sizeInBytes);
		wh1.dwFlags = 0L;
		waveOutPrepareHeader(hwo, &wh1, sizeof(WAVEHDR));//׼��һ���������ݿ����ڲ���
		waveOutWrite(hwo, &wh1, sizeof(WAVEHDR));//����Ƶý���в��ŵڶ�������ָ�������ݣ�Ҳ�൱�ڿ���һ������������˼

		BOOL isDone = false;
		do
		{
			isDone = (wh1.dwFlags & WHDR_DONE) == WHDR_DONE;
			Sleep(1);
		} while (!isDone && isPlaying());
		
		if (!isDone){
			waveOutReset(hwo);
		}
		waveOutUnprepareHeader(hwo, &wh1, sizeof(WAVEHDR));//��������

		if (tmp != NULL){
			delete[]tmp;
			tmp = NULL;
		}

		setDone(true);
		waveOutClose(hwo);
	}
	print_log_debug("recorder", "win32 writeHandle end speed:%dms", timer.elapsed());
	return;
}
#endif
#endif