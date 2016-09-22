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
	virtual int	getState() = 0;//播放状态
	virtual int getBufferSize() = 0;
	virtual void pause() = 0; //微信，暂时不需要暂停
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

//先读取数据，在播放
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
		fseek(fp, 0, SEEK_END); //定位到文件末 
		int len = (int)ftell(fp); //文件长度
		char* buffer = new char[len];
		fseek(fp, 0, SEEK_SET); //定位到文件开头 
		int readSize = (int)fread(buffer, sizeof(char), len, fp);
		kefu_print_log_debug("audio_kefu", "AudioRecord::play -> fread, len =%d", readSize);
		fclose(fp);
		fp = NULL;
		
		//speex解码
		int dataSize = (int)byaudio_speex_decode(buffer, &audioData, len);
		kefu_print_log_debug("audio_kefu", "AudioRecord::play -> speex_decode, len =%d", dataSize);
		writeHandle(audioData, dataSize);
		delete[] buffer;
		buffer = NULL;
		//writeHandle((const char*)buffer, readSize);//pcm原数据
		return dataSize;
	}
	
}

#endif
