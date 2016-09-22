#ifndef _AUDIO_TRACK_H
#define _AUDIO_TRACK_H
#include "global.h"
#include <math.h>
#include <stdlib.h>
#include "byaudio_speex_api.h"
#include <string.h>

using namespace std;
class AudioTrack{
public:
	virtual int	getState() = 0;//����״̬
	virtual int getBufferSize() = 0;
	virtual void pause() = 0; //΢�ţ���ʱ����Ҫ��ͣ
	virtual void stop() = 0;
	virtual void flush() = 0;
	virtual void release() = 0;
	virtual void play() = 0;
	virtual int	getMinBufferSize() = 0;
	virtual void writeHandle(const char* audioData, int sizeInBytes) = 0;
	int read();
	void setPath(string path);
protected:
	string path;
};

void AudioTrack::setPath(string path)
{
	this->path = path;
}

//�ȶ�ȡ���ݣ��ڲ���
int AudioTrack::read()
{
	kefu_print_log_debug("audio_kefu", "AudioRecord::play->path:%s", path.c_str());
	FILE* fp = fopen(path.c_str(), "r");
	if (fp == NULL){
		kefu_print_log_debug("audio_kefu", "AudioRecord::play failed causeby:fp == NULL ");
		return 0;
	}
	else{
		char* audioData = NULL;
		kefu_print_log_debug("audio_kefu", "AudioRecord::play file open succeed");
		fseek(fp, 0, SEEK_END); //��λ���ļ�ĩ 
		int len = (int)ftell(fp); //�ļ�����
		char* buffer = new char[len];
		fseek(fp, 0, SEEK_SET); //��λ���ļ���ͷ 
		int readSize = (int)fread(buffer, sizeof(char), len, fp);
		kefu_print_log_debug("audio_kefu", "AudioRecord::play -> fread, len =%d", readSize);
		fclose(fp);
		fp = NULL;
		
		//speex����
		int dataSize = (int)byaudio_speex_decode(buffer, &audioData, len);
		kefu_print_log_debug("audio_kefu", "AudioRecord::play -> speex_decode, len =%d", dataSize);
		writeHandle(audioData, dataSize);
		delete[] buffer;
		buffer = NULL;
		//writeHandle((const char*)buffer, readSize);//pcmԭ����
		return dataSize;
	}
	
}

#endif
