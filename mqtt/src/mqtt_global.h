#ifndef _GLOBAL_H
#define _GLOBAL_H
#include "stdio.h"
#include "stdarg.h"
#include "Plugin.h"
#include "config.h"
#include "MQTTAsync.h"
#include "BYJsonUtil.h"
#include <mutex>
#include <chrono>	

using namespace std;

static const char* MQTT_MESSAGE_ARRIVED = "mqtt_message_arrived";

static void delivery_completed(void *context, MQTTAsync_token dt);
static int message_arrived(void *context, char *topicName, int topicLen, MQTTAsync_message *message);
static void conn_lost(void *context, char *cause);

static void onConnectFailure(void* context, MQTTAsync_failureData* response);
static void onConnect(void* context, MQTTAsync_successData* response);
static void onSubscribe(void* context, MQTTAsync_successData* response);
static void onSubscribeFailure(void* context, MQTTAsync_failureData* response);
static void onDisconnect(void* context, MQTTAsync_successData* response);
static void onDisconnectFailure(void* context, MQTTAsync_failureData* response);
static void onPublish(void* context, MQTTAsync_successData* response);
static void onPublishFailure(void* context, MQTTAsync_failureData* response);

static const int MQTT_CONNECT_SUCCESS = 1;
static const int MQTT_CONNECT_FAILURE = 2;
static const int MQTT_SUBSCRIBE_SUCCESS = 3;
static const int MQTT_SUBSCRIBE_FAILURE = 4;
static const int MQTT_SEND_MSG_SUCCESS = 5;
static const int MQTT_SEND_MSG_FAILURE = 6;
static const int MQTT_CONNECT_LOST = 7;
static const int MQTT_DELIVERY_COMPLETED = 8;
static const int MQTT_DISCONNECT_SUCCESS = 9;
static const int MQTT_DISCONNECT_FAILURE = 10;
static const char* MQTT_EVENT_CALLBACK = "mqtt_event_callback";


static EngineInterface* g_EngineInterface = 0;

static const bool __DEBUG = true;
static const char* TAG = "mqtt";
void print_log_debug(const char* tag, const char *fmt, ...);

const int K_FAILED = 0;
const int K_SUCCESS = 1;

const int EVENT_CONNECT_RESULT = 1;
const int EVENT_CONNECTION_LOST = 2;
const int EVENT_CONNECTION_TOKEN = 3;

static lua_State* GetLuaState();

static const int BUFFER_SIZE = 1024 * 10;

bool str_ends_with(string src, string suffix)
{
	int srcLen = src.length();
	int sufLen = suffix.length();
	int start = srcLen - sufLen;
	if (start < 0)
		return false;
	return (src.substr(start, sufLen) == suffix);
}

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

_long currentTimeMillis()
{
	chrono::time_point<chrono::system_clock, chrono::milliseconds> tp = chrono::time_point_cast<chrono::milliseconds>(chrono::system_clock::now());
	auto tmp = chrono::duration_cast<chrono::milliseconds>(tp.time_since_epoch());
	_long timestamp = tmp.count();
	print_log_debug(TAG, "currentTimeMillis : %I64d", timestamp);
	return timestamp;
}

void printBuffer(const char* buffer, int size)
{
	for (int i = 0; i < size; i++){
		print_log_debug(TAG, "buffer[%d] = %d", i, buffer[i]);
	}
}

#endif
