#ifndef _ANDROID_AUDIO_RECORD_H
#define _ANDROID_AUDIO_RECORD_H
#include<stdlib.h>
#include <math.h>
#include "audio_record.h"
#include "global.h"

class AndroidAudioRecord :public AudioRecord
{
private:
	jclass AudioRecord_j = NULL;		//全局引用
	jobject audioRecord_j = NULL;		//全局引用
	jmethodID constructor_j;
	jmethodID getMinBuffSize_j;
	jmethodID getRecordingState_j;
	jmethodID startRecording_j;
	jmethodID read_j;
	jmethodID release_j;
	jmethodID stop_j;
	jint minBuffSize_j;
public:
	AndroidAudioRecord();
	~AndroidAudioRecord();
	int getState();
	void stop();
	void release();
	void start();
	int getBufferSize();
	int readHandle(char** audioData);
};

AndroidAudioRecord::AndroidAudioRecord() 
{
	jclass AudioRecord_j_Local = getEnv()->FindClass("android/media/AudioRecord");
	checkJniException(getEnv(), "FindClass android/media/AudioRecord");

	AudioRecord_j = (jclass)getEnv()->NewGlobalRef(AudioRecord_j_Local);
	checkJniException(getEnv(), "NewGlobalRef AudioRecord_j");

	getEnv()->DeleteLocalRef(AudioRecord_j_Local);

	constructor_j = getEnv()->GetMethodID(AudioRecord_j, "<init>", "(IIIII)V");
	checkJniException(getEnv(), "GetMethodID constructor");

	getMinBuffSize_j = getEnv()->GetStaticMethodID(AudioRecord_j, "getMinBufferSize", "(III)I");
	checkJniException(getEnv(), "GetStaticMethodID getMinBuffSize");


	minBuffSize_j = getEnv()->CallStaticIntMethod(
		AudioRecord_j,
		getMinBuffSize_j,
		SAMPLE_RATE_IN_HZ,
		CHANNEL_IN_MONO,
		ENCODING_PCM_16BIT
		);
	print_log_debug("audio_kefu", "AndroidAudioRecord::readHandle -> minBuffSize_j = %d", minBuffSize_j);
	checkJniException(getEnv(), "CallStaticIntMethod getMinBuffSize");


	jobject audioRecord_j_Local = getEnv()->NewObject(
		AudioRecord_j,
		constructor_j,
		AUDIO_SOURCE_VOICE_COMMUNICATION,
		SAMPLE_RATE_IN_HZ,
		CHANNEL_IN_MONO,
		ENCODING_PCM_16BIT,
		minBuffSize_j
		);

	checkJniException(getEnv(), "NewObject audioRecord");
	audioRecord_j = getEnv()->NewGlobalRef(audioRecord_j_Local);
	checkJniException(getEnv(), "NewGlobalRef audioRecord_j");
	getEnv()->DeleteLocalRef(audioRecord_j_Local);

	startRecording_j = getEnv()->GetMethodID(AudioRecord_j, "startRecording", "()V");
	checkJniException(getEnv(), "GetMethodID startRecording");

	getRecordingState_j = getEnv()->GetMethodID(AudioRecord_j, "getRecordingState", "()I");
	checkJniException(getEnv(), "GetMethodID startRecording");

	read_j = getEnv()->GetMethodID(AudioRecord_j, "read", "([BII)I");
	checkJniException(getEnv(), "GetMethodID read");

	release_j = getEnv()->GetMethodID(AudioRecord_j, "release", "()V");
	checkJniException(getEnv(), "GetMethodID release");

	stop_j = getEnv()->GetMethodID(AudioRecord_j, "stop", "()V");
	checkJniException(getEnv(), "GetMethodID stop");
}

AndroidAudioRecord::~AndroidAudioRecord()
{
	if (getState() != RECORDSTATE_STOPPED){
		stop();
	}
	release();
	getEnv()->DeleteGlobalRef(AudioRecord_j);
	getEnv()->DeleteGlobalRef(audioRecord_j);
}


int AndroidAudioRecord::getState()
{	
	int state = -1;
	print_log_debug("audio_kefu", "AndroidAudioRecord::getRecordingState");
	if (audioRecord_j != NULL){
		state = getEnv()->CallIntMethod(audioRecord_j, getRecordingState_j);
		checkJniException(getEnv(), "CallIntMethod getRecordingState");
	}
	else{
		print_log_debug("audio_kefu", "AndroidAudioRecord::getRecordingState audioRecord_j == NULL");
	}
	return state;
}


void AndroidAudioRecord::start()
{
	getEnv()->CallVoidMethod(audioRecord_j, startRecording_j);
	checkJniException(getEnv(), "CallVoidMethod startRecording");
}

int AndroidAudioRecord::readHandle(char** audioData)
{
	print_log_debug("audio_kefu", "AndroidAudioRecord::readHandle");
	jint blockSize = minBuffSize_j;
	jbyteArray read_buff = getEnv()->NewByteArray(blockSize);
	if (audioRecord_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioRecord::readHandle -> audioRecord_j == NULL");
	}
	if (read_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioRecord::readHandle -> read_j == NULL");
	}
	jint readLen = getEnv()->CallIntMethod(audioRecord_j, read_j, read_buff, 0, blockSize);
	print_log_debug("audio_kefu", "AndroidAudioRecord::readHandle -> readLen = %d", readLen);
	if (*audioData != NULL){
		delete[] * audioData;
		*audioData = NULL;
	}
	jbyte* audio_bytes = new jbyte[blockSize]();
	if (readLen > 0){
		getEnv()->GetByteArrayRegion(read_buff, 0, readLen, audio_bytes);
	}
	*audioData = (char*)audio_bytes;
	getEnv()->DeleteLocalRef(read_buff);
	 
	return readLen;
}

void AndroidAudioRecord::release()
{
	getEnv()->CallVoidMethod(audioRecord_j, release_j);
	checkJniException(getEnv(), "CallVoidMethod release");
}

void AndroidAudioRecord::stop()
{
	getEnv()->CallVoidMethod(audioRecord_j, stop_j);
	checkJniException(getEnv(), "CallVoidMethod stop");
}

int AndroidAudioRecord::getBufferSize()
{
	return minBuffSize_j;
}

#endif
