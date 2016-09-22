#ifndef _AUDIO_RECORD_H
#define _AUDIO_RECORD_H

#include "global.h"
#include <math.h>
#include <stdlib.h>
#include "math.h"
#include "byaudio_speex_api.h"

class AudioRecord{
public:
	virtual int getState() = 0;;
	virtual void start() = 0;;
	virtual void release() = 0;;
	virtual void stop() = 0;;
	virtual int	readHandle(char **buff) = 0;
	virtual int getBufferSize() = 0;
	int save(_callback);
	void cancel();
	void setPath(string);
	string getPath();
    bool isCancel = false;
	static double calculateVolume(const char* buffer, size_t length);
protected:
	string path;
};

void AudioRecord::setPath(string path)
{
	this->path = path;
}

string AudioRecord::getPath()
{
	return path;
}

double AudioRecord::calculateVolume(const char* buffer, size_t length)
{
	double sumVolume = 0.0;
	double avgVolume = 0.0;
	double volume = 0.0;

	for (int i = 0; i < length; i += 2){
		int v1 = buffer[i] & 0xFF;
		int v2 = buffer[i + 1] & 0xFF;
		int temp = v1 + (v2 << 8);// 小端
		if (temp >= 0x8000) 
			temp = 0xffff - temp;
		sumVolume += abs(temp);
	}
	avgVolume = sumVolume / (length / 2);
	volume = log10(1 + avgVolume) * 20; //保证大于0
	return volume;
}

int AudioRecord::save(_callback callback)
{
	char* temp = NULL;
	char* speexBuff = NULL;

	//录音
	int len = 0;
	int datasize = 0;
	kefu_print_log_debug("audio_kefu", "AudioRecord->path:%s", path.c_str());
	FILE* fp = fopen(path.c_str(), "a+");
	if (fp == NULL){
		kefu_print_log_debug("audio_kefu", "AudioRecord::save failed causeby:fp == NULL ");
	}
	else{
		kefu_print_log_debug("audio_kefu", "AudioRecord::save file create succeed");
		while (((len = readHandle(&temp)) > 0) && !isCancel)
		{
			double volume = calculateVolume(temp, len);
			callback(volume);
			kefu_print_log_debug("audio_kefu", "AudioRecord::volume:%lf", volume);
			datasize += len;
			//speex编码 
			long dataSize = byaudio_speex_encode(temp, &speexBuff, len);
			kefu_print_log_debug("audio_kefu", "AudioRecord::save write size:%d", dataSize);
			//写文件
			fwrite(speexBuff, sizeof(char), dataSize, fp);

			//kefu_print_log_debug("audio_kefu", "AudioRecord::save write size:%d", len);//pcm原数据
			//fwrite(temp, sizeof(char), len, fp); 
			
		}
		fclose(fp);
		fp = NULL;
		if (isCancel)
		{
			remove(path.c_str());
		}
	}
	

	//释放内存
	if (temp != NULL){
		delete[] temp;
		temp = NULL;
	}

	if (speexBuff != NULL){
		delete[] speexBuff;
		speexBuff = NULL;
	}
	return datasize;
}

void AudioRecord::cancel()
{
	isCancel = true;
}

#endif
