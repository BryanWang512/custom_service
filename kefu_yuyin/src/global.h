#ifndef _GLOBAL_H
#define _GLOBAL_H
#include "stdio.h"
#include "stdarg.h"
#include "Plugin.h"
#include "config.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
extern "C" {
#endif
#include "lua.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
}
#endif
#include <mutex>
#include <string>
using namespace std;

typedef void(*_callback)(double);

static EngineInterface* g_EngineInterface = 0;
static const bool __DEBUG = true;
static void volume_callback(double);

void print_log_debug(const char* tag, const char *fmt, ...);

#define AUDIO_SOURCE_VOICE_COMMUNICATION (7)
#define AUDIO_SOURCE_MIC (1)
#define SAMPLE_RATE_IN_HZ (8000)
//android音频参数
#define CHANNEL_IN_MONO (16) //16是单声道
#define ENCODING_PCM_16BIT (2) //2 -> 16比特率
#define CHANNEL_OUT_MONO (4)
//ios音频参数
#define ENCODING_PCM_16BIT_IOS (16) // 16比特率
#define NUM_OF_CHANNEL_IOS (1) //声道数 1
//录音状态
#define RECORDSTATE_RECORDING (3)
#define RECORDSTATE_STOPPED (0)

//回放状态
#define PLAYSTATE_STOPPED (1)
#define PLAYSTATE_PAUSED (2)
#define PLAYSTATE_PLAYING (3)

#define STREAM_MUSIC (3)

#define MODE_STATIC (0)
#define MODE_STREAM (1)

const static int EVENT_TRACK_COMPLETED = 1;
const static int EVENT_RECORD_COMPLETED = 2;
const static int EVENT_RECORD_CANCEL = 3;
const static int EVENT_DURATION = 4;
const static int EVENT_RECORD_VOLUME = 5;

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
#include <jni.h>
extern "C"
{

	JNIEnv* getEnv();

	typedef struct _JniMethodInfo
	{
		JNIEnv*	    env;
		jclass      classID;
		jmethodID   methodID;
	} JniMethodInfo;

	bool checkJniException(JNIEnv *env, const char* str){
		if (env->ExceptionCheck()){
			env->ExceptionDescribe();
			print_log_debug("ERROR", "jni error from %s", 0 == str ? "" : str);
			env->ExceptionClear();
			return true;
		}
		return false;
	}

}


#endif

static mutex m_print_mutex;
void print_log_debug(const char* tag, const char *fmt, ...)
{
	if (!__DEBUG)
	{
		return;
	}
	lock_guard<mutex>locker(m_print_mutex);
	if ((0 == tag || '\0' == tag[0]) || (0 == fmt || '\0' == fmt[0])){
		return;
	}

	va_list args;
	va_start(args, fmt);

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
	__android_log_vprint(ANDROID_LOG_DEBUG, tag, fmt, args);
#endif

#if (TARGET_PLATFORM==PLATFORM_WIN32)

	int len;
	len = _vscprintf(fmt, args) + 1;
	char* buffer = new char[len];
	vsprintf_s(buffer, len, fmt, args);

	std::string str = buffer;
	delete[] buffer;
	if (0 != g_EngineInterface){
		g_EngineInterface->Log(tag, str.c_str());
	}

#endif

#if (TARGET_PLATFORM==PLATFORM_IOS)
	if (0 != g_EngineInterface){
		g_EngineInterface->Log(tag, fmt, args);
	}

#endif
	va_end(args);

}


#endif
