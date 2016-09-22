#ifndef _WIN_AUDIO_RECORD_H
#define _WIN_AUDIO_RECORD_H
#include <stdio.h>
#include <stdlib.h>
#include "global.h"
#include "byaudio_timer.h"
#include "audio_record.h"

#if (TARGET_PLATFORM==PLATFORM_WIN32)
#include <Windows.h> 

#pragma comment(lib, "winmm.lib")
class WinAudioRecord:public AudioRecord
{
private:
	HWAVEIN hWaveIn;  //输入设备
	WAVEFORMATEX waveform; //采集音频的格式，结构体
	BYTE *pBuffer1;//采集音频时的数据缓存
	WAVEHDR wHdr1; //采集音频时包含数据缓存的结构体
	int state;
	mutex m_wait_mutex;
	mutex m_state_mutex;
public:
	WinAudioRecord();
	~WinAudioRecord();
	int getState();
	void start();
	int getBufferSize();
	void release();
	void stop();
	int readHandle(char** audioData);
};

WinAudioRecord::WinAudioRecord()
{
	waveform.wFormatTag = WAVE_FORMAT_PCM;//声音格式为PCM
	waveform.nSamplesPerSec = SAMPLE_RATE_IN_HZ;//采样率，8000次/秒
	waveform.wBitsPerSample = 16;//采样比特，16bits/次
	waveform.nChannels = 1;//采样声道数，2声道
	waveform.nAvgBytesPerSec = 16000;//每秒的数据率，就是每秒能采集多少字节的数据
	waveform.nBlockAlign = 2;//一个块的大小，采样bit的字节数乘以声道数
	waveform.cbSize = 0;//一般为0

	state = RECORDSTATE_STOPPED;
}

WinAudioRecord::~WinAudioRecord()
{
	lock_guard<mutex> locker(m_wait_mutex);
	kefu_print_log_debug("recorder", "~WinAudioRecord");
}

int WinAudioRecord::getState()
{
	lock_guard<mutex> locker(m_state_mutex);
	return state;
}

int WinAudioRecord::getBufferSize()
{
	return 1024 * 10;
}

void WinAudioRecord::start()
{
	lock_guard<mutex> locker(m_state_mutex);
	kefu_print_log_debug("kefu_yuyin", "WinAudioRecord::startRecording");
	state = RECORDSTATE_RECORDING;
	kefu_print_log_debug("kefu_yuyin", "WinAudioRecord::startRecording return");
}

void WinAudioRecord::release()
{
	kefu_print_log_debug("kefu_yuyin", "WinAudioRecord::release");
}

void WinAudioRecord::stop()
{
	lock_guard<mutex> locker(m_state_mutex);
	state = RECORDSTATE_STOPPED;
	kefu_print_log_debug("kefu_yuyin", "WinAudioRecord::stop>>>>>>>>>>>>>>>>>>>>>");
}

int WinAudioRecord::readHandle(char** audioData)
{
	lock_guard<mutex> locker(m_wait_mutex);
	DWORD buffSize = 0;
		
	if (*audioData != NULL){
		delete[] * audioData;
		*audioData = NULL;
	}

	BoyaaTimer timer;
	timer.reset();
	kefu_print_log_debug("kefu_yuyin", "win32 readHandle begin");
	if (getState() == RECORDSTATE_RECORDING)
	{
		//使用waveInOpen函数开启音频采集
		waveInOpen(&hWaveIn, WAVE_MAPPER, &waveform, 0L, 0L, CALLBACK_NULL);
		buffSize = getBufferSize();
		pBuffer1 = new BYTE[getBufferSize()];
		wHdr1.lpData = (LPSTR)pBuffer1;
		wHdr1.dwBufferLength = buffSize;
		wHdr1.dwBytesRecorded = 0;
		wHdr1.dwUser = 0;
		wHdr1.dwLoops = 1;
		waveInPrepareHeader(hWaveIn, &wHdr1, sizeof(WAVEHDR));//准备一个波形数据块头用于录音
		waveInAddBuffer(hWaveIn, &wHdr1, sizeof (WAVEHDR));//指定波形数据块为录音输入缓存
		waveInStart(hWaveIn);//开始录音
		BOOL isDone = false;
		do
		{
			isDone = (wHdr1.dwFlags & WHDR_DONE) == WHDR_DONE;
			Sleep(1);
		} while (!isDone && getState() == RECORDSTATE_RECORDING);

		if (!isDone){
			waveInReset(hWaveIn);
		}


		if (wHdr1.dwBytesRecorded > 0){
			char* tmp = new char[buffSize]();
			memcpy(tmp, pBuffer1, wHdr1.dwBytesRecorded);
			*audioData = tmp;
		}
		else{
			buffSize = 0;
		}

		waveInUnprepareHeader(hWaveIn, &wHdr1, sizeof(WAVEHDR));
		if (pBuffer1 != NULL){
			delete[] pBuffer1;
			pBuffer1 = NULL;
		}
		waveInClose(hWaveIn);
	}
	kefu_print_log_debug("kefu_yuyin", "win32 readHandle end speed:%dms", timer.elapsed());
	return buffSize;
}
#endif

#endif