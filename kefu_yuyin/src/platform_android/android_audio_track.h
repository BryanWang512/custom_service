#ifndef _ANDROID_AUDIO_TRACK_H
#define _ANDROID_AUDIO_TRACK_H
#include<stdlib.h>
#include "global.h"
#include "audio_track.h"
#include <jni.h>

class AndroidAudioTrack :public AudioTrack
{
private:
	recursive_mutex m_mutex;		//递归锁
	jclass AudioTrack_j = NULL;		//全局引用
	jobject audioTrack_j = NULL;		//全局引用
	jmethodID constructor_j;
	jmethodID flush_j;
	jmethodID getMinBufferSize_j;
	jmethodID getPlayState_j;
	jmethodID pause_j;
	jmethodID play_j;
	jmethodID release_j;
	jmethodID setStereoVolume_j;
	jmethodID stop_j;
	jmethodID write_j;
	jint minBufferSize_j;
	int bufferSize;
	void writeHandle(const char* audioData, int sizeInBytes);
public:
	AndroidAudioTrack();
	~AndroidAudioTrack();
	int	getState();
	int getBufferSize(){ return bufferSize; }
	void createAudioTrack(int buffSize, int mode);
	void play();
	void pause();//暂时不需要
	void stop();
	void flush();
	void release();
	int	getMinBufferSize();
	int	setStereoVolume(float leftGain, float rightGain);
};

AndroidAudioTrack::AndroidAudioTrack()
{
	lock_guard<recursive_mutex> lock(m_mutex);

	//查找android/media/AudioTrack
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> FindClass");
	jclass AudioTrack_j_Local = getEnv()->FindClass("android/media/AudioTrack");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> FindClass");

	//生成AudioTrack
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> NewGlobalRef AudioTrack_j");
	AudioTrack_j = (jclass)getEnv()->NewGlobalRef(AudioTrack_j_Local);
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> NewGlobalRef AudioTrack_j");
	getEnv()->DeleteLocalRef(AudioTrack_j_Local);

	//获取构造函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID constructor_j");
	constructor_j = getEnv()->GetMethodID(AudioTrack_j, "<init>", "(IIIIII)V");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID constructor_j");

	//获取getMinBufferSize函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> getMinBufferSize getMinBufferSize_j");
	getMinBufferSize_j = getEnv()->GetStaticMethodID(AudioTrack_j, "getMinBufferSize", "(III)I");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> getMinBufferSize getMinBufferSize_j");

	//执行getMinBufferSize函数
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> CallStaticIntMethod getMinBufferSize_j");
	minBufferSize_j = getEnv()->CallStaticIntMethod(
		AudioTrack_j,
		getMinBufferSize_j,
		SAMPLE_RATE_IN_HZ,
		CHANNEL_OUT_MONO,
		ENCODING_PCM_16BIT
		);

	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> minBufferSize_j = %d", minBufferSize_j);
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> minBufferSize_j = NULL");

	//执行创建AudioTrack
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> createAudioTrack");
	//createAudioTrack(minBufferSize_j, MODE_STREAM);

	//获取getPlayState函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID getPlayState_j");
	getPlayState_j = getEnv()->GetMethodID(AudioTrack_j, "getPlayState", "()I");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID getPlayState_j");

	//获取setStereoVolume函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID setStereoVolume_j");
	setStereoVolume_j = getEnv()->GetMethodID(AudioTrack_j, "setStereoVolume", "(FF)I");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID setStereoVolume_j");

	//获取play函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID play_j");
	play_j = getEnv()->GetMethodID(AudioTrack_j, "play", "()V");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID play_j");

	//获取flush函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID flush_j");
	flush_j = getEnv()->GetMethodID(AudioTrack_j, "flush", "()V");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID flush_j");

	//获取write函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID write_j");
	write_j = getEnv()->GetMethodID(AudioTrack_j, "write", "([BII)I");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID write_j");

	//获取pause函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID pause_j");
	pause_j = getEnv()->GetMethodID(AudioTrack_j, "pause", "()V");
	checkJniException(getEnv(), "AnroidAudioTrack::AndroidAudioTrack -> GetMethodID pause_j");

	//获取release函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID release_j");
	release_j = getEnv()->GetMethodID(AudioTrack_j, "release", "()V");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID release_j");

	//获取stop函数ID
	print_log_debug("audio_kefu", "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID stop_j");
	stop_j = getEnv()->GetMethodID(AudioTrack_j, "stop", "()V");
	checkJniException(getEnv(), "AndroidAudioTrack::AndroidAudioTrack -> GetMethodID stop_j");
}

AndroidAudioTrack::~AndroidAudioTrack()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::~AndroidAudioTrack");
	if (getState() != PLAYSTATE_STOPPED){
		print_log_debug("audio_kefu", "AndroidAudioTrack::~AndroidAudioTrack -> getPlayState() != PLAYSTATE_STOPPED");
		stop();
	}
	print_log_debug("audio_kefu", "AndroidAudioTrack::~AndroidAudioTrack -> release");
	release();

	if (AudioTrack_j != NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::~AndroidAudioTrack -> AudioTrack_j != NULL");
		getEnv()->DeleteGlobalRef(AudioTrack_j);
		AudioTrack_j = NULL;
	}

	if (audioTrack_j != NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::~AndroidAudioTrack -> audioTrack_j != NULL");
		getEnv()->DeleteGlobalRef(audioTrack_j);
		audioTrack_j = NULL;
	}
}

void AndroidAudioTrack::createAudioTrack(int buffSize, int mode)
{
	lock_guard<recursive_mutex> lock(m_mutex);

	print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack");
	bufferSize = (buffSize >= minBufferSize_j) ? buffSize : minBufferSize_j;
	print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> minBufferSize_j = %d, bufferSize = %d", minBufferSize_j, bufferSize);

	print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> NewObject audioTrack_j_Local");
	jobject audioTrack_j_Local = getEnv()->NewObject(
		AudioTrack_j,
		constructor_j,
		STREAM_MUSIC,
		SAMPLE_RATE_IN_HZ,
		CHANNEL_OUT_MONO,
		ENCODING_PCM_16BIT,
		bufferSize,
		mode
		);
	checkJniException(getEnv(), "AndroidAudioTrack::createAudioTrack -> NewObject audioTrack_j_Local");

	if (audioTrack_j != NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> audioTrack_j != NULL");
		stop();
		release();
		if (audioTrack_j != NULL){
			print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> getEnv()->DeleteGlobalRef(audioTrack_j)");
			getEnv()->DeleteGlobalRef(audioTrack_j);
			audioTrack_j = NULL;
		}
	}

	print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> NewGlobalRef audioTrack_j");
	audioTrack_j = getEnv()->NewGlobalRef(audioTrack_j_Local);
	checkJniException(getEnv(), "AndroidAudioTrack::createAudioTrack -> NewGlobalRef audioTrack_j");

	print_log_debug("audio_kefu", "AndroidAudioTrack::createAudioTrack -> DeleteLocalRef audioTrack_j");
	getEnv()->DeleteLocalRef(audioTrack_j_Local);
	checkJniException(getEnv(), "AndroidAudioTrack::createAudioTrack -> DeleteLocalRef audioTrack_j");
}


void AndroidAudioTrack::flush()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::flush");
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::flush -> audioTrack_j == NULL");
	}
	else{
		checkJniException(getEnv(), "AndroidAudioTrack::flush -> CallVoidMethod(audioTrack_j, flush_j)");
		getEnv()->CallVoidMethod(audioTrack_j, flush_j);
		checkJniException(getEnv(), "AndroidAudioTrack::flush -> CallVoidMethod(audioTrack_j, flush_j)");
	}
}

int	AndroidAudioTrack::getState()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::getPlayState");
	int state = -1;
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::getPlayState -> audioTrack_j == NULL");
	}
	else{
		state = getEnv()->CallIntMethod(audioTrack_j, getPlayState_j);
		checkJniException(getEnv(), "CallIntMethod getPlayState");
		print_log_debug("audio_kefu", "AndroidAudioTrack::getPlayState -> playState = %d", state);
	}
	return state;
}

void AndroidAudioTrack::pause()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::pause");
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::pause -> audioTrack_j == NULL");
	}
	else{
		getEnv()->CallVoidMethod(audioTrack_j, pause_j);
		checkJniException(getEnv(), "AndroidAudioTrack::pause -> getEnv()->CallVoidMethod(audioTrack_j, pause_j)");
	}
}
void AndroidAudioTrack::play()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::play");
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::play -> audioTrack_j == NULL");
	}
	else{
		getEnv()->CallVoidMethod(audioTrack_j, play_j);
		checkJniException(getEnv(), "AndroidAudioTrack::play -> getEnv()->CallVoidMethod(audioTrack_j, play_j)");
	}
}
void AndroidAudioTrack::release()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::release");
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::release -> audioTrack_j == NULL");
	}
	else{
		getEnv()->CallVoidMethod(audioTrack_j, release_j);
		checkJniException(getEnv(), "AndroidAudioTrack::release -> getEnv()->CallVoidMethod(audioTrack_j, release_j)");
	}
}

void AndroidAudioTrack::stop()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::stop");
	if (audioTrack_j == NULL){
		print_log_debug("audio_kefu", "AndroidAudioTrack::stop -> audioTrack_j == NULL");
	}
	else{
		getEnv()->CallVoidMethod(audioTrack_j, stop_j);
		checkJniException(getEnv(), "AndroidAudioTrack::stop -> getEnv()->CallVoidMethod(audioTrack_j, stop_j)");
	}
}

void printByteArray(jbyteArray buffer)
{
	jsize len = getEnv()->GetArrayLength(buffer);
	jbyte* minut1 = (jbyte *)malloc(len * sizeof(jbyte));
	getEnv()->GetByteArrayRegion(buffer, 0, len, minut1);
	for (int i = 0; i < len; i++){
		print_log_debug("audio_kefu", "buffer[%d] = %d", i, minut1[i]);
	}
	free(minut1);
}

int	AndroidAudioTrack::getMinBufferSize()
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::getMinBufferSize -> minBufferSize_j = %d", minBufferSize_j);
	return minBufferSize_j;
}

int	AndroidAudioTrack::setStereoVolume(float leftGain, float rightGain)
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("recorder", "AndroidAudioTrack::setStereoVolume");
	int flag = -1;
	if (audioTrack_j == NULL){
		print_log_debug("recorder", "AndroidAudioTrack::setStereoVolume -> audioTrack_j == NULL");
	}
	else{
		flag = getEnv()->CallIntMethod(audioTrack_j, setStereoVolume_j, leftGain, rightGain);
		checkJniException(getEnv(), "AndroidAudioTrack::setStereoVolume -> getEnv()->CallIntMethod(audioTrack_j, setStereoVolume_j, leftGain, rightGain) flag");
	}
	return flag;
}

//向AudioTrack写入数据,这里audioData不在这里释放
void AndroidAudioTrack::writeHandle(const char* audioData, int sizeInBytes)
{
	lock_guard<recursive_mutex> lock(m_mutex);
	print_log_debug("audio_kefu", "AndroidAudioTrack::writeHandle");
	createAudioTrack(sizeInBytes, MODE_STATIC);
	setStereoVolume(1.0, 1.0);
	print_log_debug("audio_kefu", "AndroidAudioTrack::writeHandle -> getEnv()->NewByteArray(sizeInBytes)");
	jbyteArray buffer = getEnv()->NewByteArray(sizeInBytes);
	int len = getEnv()->GetArrayLength(buffer);
	print_log_debug("audio_kefu", "AndroidAudioTrack::writeHandle -> buffer len = %d", len);

	print_log_debug("audio_kefu", "getEnv()->SetByteArrayRegion(buffer, 0, sizeInBytes, (jbyte *)audioData)");
	getEnv()->SetByteArrayRegion(buffer, 0, sizeInBytes, (jbyte *)audioData);
	checkJniException(getEnv(), "AndroidAudioTrack::writeHandle -> getEnv()->SetByteArrayRegion(buffer, 0, sizeInBytes, (jbyte *)audioData)");

	print_log_debug("audio_kefu", "getEnv()->CallVoidMethod(audioTrack_j, write_j, buffer, 0, sizeInBytes)");
	int flag = getEnv()->CallIntMethod(audioTrack_j, write_j, buffer, 0, sizeInBytes);
	print_log_debug("audio_kefu", "getEnv()->CallVoidMethod(audioTrack_j, write_j, buffer, 0, sizeInBytes) flag = %d", flag);

	print_log_debug("audio_kefu", "getEnv()->DeleteLocalRef(buffer)");
	getEnv()->DeleteLocalRef(buffer);
	buffer = NULL;
	checkJniException(getEnv(), "getEnv()->DeleteLocalRef(buffer)");
}
#endif