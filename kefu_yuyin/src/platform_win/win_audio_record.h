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
	HWAVEIN hWaveIn;  //�����豸
	WAVEFORMATEX waveform; //�ɼ���Ƶ�ĸ�ʽ���ṹ��
	BYTE *pBuffer1;//�ɼ���Ƶʱ�����ݻ���
	WAVEHDR wHdr1; //�ɼ���Ƶʱ�������ݻ���Ľṹ��
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
	waveform.wFormatTag = WAVE_FORMAT_PCM;//������ʽΪPCM
	waveform.nSamplesPerSec = SAMPLE_RATE_IN_HZ;//�����ʣ�8000��/��
	waveform.wBitsPerSample = 16;//�������أ�16bits/��
	waveform.nChannels = 1;//������������2����
	waveform.nAvgBytesPerSec = 16000;//ÿ��������ʣ�����ÿ���ܲɼ������ֽڵ�����
	waveform.nBlockAlign = 2;//һ����Ĵ�С������bit���ֽ�������������
	waveform.cbSize = 0;//һ��Ϊ0

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
		//ʹ��waveInOpen����������Ƶ�ɼ�
		waveInOpen(&hWaveIn, WAVE_MAPPER, &waveform, 0L, 0L, CALLBACK_NULL);
		buffSize = getBufferSize();
		pBuffer1 = new BYTE[getBufferSize()];
		wHdr1.lpData = (LPSTR)pBuffer1;
		wHdr1.dwBufferLength = buffSize;
		wHdr1.dwBytesRecorded = 0;
		wHdr1.dwUser = 0;
		wHdr1.dwLoops = 1;
		waveInPrepareHeader(hWaveIn, &wHdr1, sizeof(WAVEHDR));//׼��һ���������ݿ�ͷ����¼��
		waveInAddBuffer(hWaveIn, &wHdr1, sizeof (WAVEHDR));//ָ���������ݿ�Ϊ¼�����뻺��
		waveInStart(hWaveIn);//��ʼ¼��
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