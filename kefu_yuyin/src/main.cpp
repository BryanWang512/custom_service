#include "config.h"
#include "Plugin.h"

/*��ͬOS������*/
#include "stdio.h"
#include "stdarg.h"
#include <string>
#include <time.h>

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
extern "C" {
#endif
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#if (TARGET_PLATFORM==PLATFORM_ANDROID)
}
#endif
#include "_lua_bind.h"
#include "global.h"
#include "thread_record.h"
#include "thread_track.h"
using namespace std;

static RecordThread* recordThread = NULL;
static TrackThread* trackThread = NULL;
static void handleLuaMessage();

static luaL_Reg lualibs[] =
{
	{ "kefu_yuyin", audio_register_funcs},
	{ NULL, NULL }
};

static void audioDestory()
{
	if (recordThread != NULL){
		kefu_print_log_debug("audio_kefu", "destory recordThread");
		recordThread->stop();
		delete recordThread;
		recordThread = NULL;
	}
	if (trackThread != NULL){
		kefu_print_log_debug("audio_kefu", "destory trackThread");
		trackThread->stop();
		delete trackThread;
		trackThread = NULL;
	}
	byaudio_speex_destroy();
}

static void audioCreate(lua_State* L)
{
	kefu_print_log_debug("audio_kefu", "start create audio");
	audioDestory();
	//create track thread
	trackThread = new TrackThread();
	//create recorde thread
	recordThread = new RecordThread();
	byaudio_speex_create();
}

/*ȫ�ֻ�ȡLuaState�Ľӿ�*/
static lua_State* __GetLuaState()
{
	if (0 == g_EngineInterface) return 0;
	return (lua_State*)g_EngineInterface->GetLuaState();
}

/*ע��lua��*/
static void registLuaLib(lua_State* L)
{
	luaL_Reg* libs = lualibs;
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	for (; libs->func; libs++){
		lua_pushcfunction(L, libs->func);
		lua_setfield(L, -2, libs->name);
	}
	lua_pop(L, 2);
}


/*---------------------------------------------------------------
*ÿ��LuaState����������������(���������ڼ�,LuaState���ܻ��ؽ�,����lua����֮��)
*/
static void LuaInit(void* param1, void* param2)
{
	lua_State* L = __GetLuaState();
	registLuaLib(L);
}


static void ViewInit(void* param1, void* param2)
{
	g_EngineInterface = (EngineInterface*)param1;
}


/*ÿ֡����*/
static void OnUpdate(long time)
{
	handleLuaMessage();
}


/*֪ͨ�ر�,�˴�������������Լ���һЩ����*/
static void OnClose()
{
	audioDestory();
	g_EngineInterface = NULL;
}

static int MainProc(EPluginMsgType eMsgType, void* param1, void* param2)
{
	long* time;
	switch (eMsgType)
	{
	case EViewOnReady:
		ViewInit(param1, param2);
		break;
	case ELuaOnReady:
		LuaInit(param1, param2);
		break;
	case EFrameUpdate:
		time = (long*)param1;
		OnUpdate(*time);
		break;
	case EOnExit:
		OnClose();
		break;
	default:
		break;
	}

	return 0;
}

extern "C"
{
#if (TARGET_PLATFORM==PLATFORM_WIN32)
	__declspec(dllexport) int plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
	int plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif

#if (TARGET_PLATFORM==PLATFORM_IOS)
	int kefu_yuyin_plugin_proc(EPluginMsgType eMsgType, void* param1, void* param2)
	{
		return MainProc(eMsgType, param1, param2);
	}
#endif
}

/*--------------------------lua call C/C++ func------------------------------------*/
/** ����*/
int audio_create(lua_State* L)
{
	audioCreate(L);
	return 0;
}

/** ����*/
int audio_destroy(lua_State* L)
{
	audioDestory();
	return 0;
}

/** ��ʼ¼��*/
int audio_record_start(lua_State* L)
{
	if (recordThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_record_start failed causeby:recordThread == NULL ");
	}
	else{
		string path = luaL_checkstring(L, 1);
		kefu_print_log_debug("audio_kefu", "audio_record_start path:%s", path.c_str());
		recordThread->start(path);
	}
	return 0;
}


/** ֹͣ¼��*/
int audio_record_stop(lua_State* L)
{
	if (recordThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_record_stop failed causeby:recordThread == NULL ");
	}
	else{
		recordThread->stop();
	}

	return 0;
}

int audio_record_cancel(lua_State* L)
{
	if (recordThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_record_stop failed causeby:recordThread == NULL ");
	}
	else{
		recordThread->cancel();
	}
	return 0;
}

int audio_track_start(lua_State* L)
{
	if (trackThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_track_start failed causeby:trackThread == NULL ");
	}
	else{
		string path = luaL_checkstring(L, 1);
		kefu_print_log_debug("audio_kefu", "audio_track_start,path:%s", path.c_str());
		trackThread->start(path);
	}
	return 0;
}

int audio_track_stop(lua_State*L)
{
	if (trackThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_track_stop failed causeby:trackThread == NULL ");
	}
	else{
		trackThread->stop();
	}
	return 0;
}


int audio_track_state(lua_State*L)
{
	if (trackThread == NULL){
		kefu_print_log_debug("audio_kefu", "call audio_track_state failed causeby:trackThread == NULL ");
		lua_pushnumber(L, -1);
	}
	else{
		int state = trackThread->getPlayState();
		lua_pushnumber(L, state);
	}
	return 1;
}

int audio_clear(lua_State*L)
{
	return 1;
}

int audio_cur_memory(lua_State*L)
{
	return 1;
}

/*�ص�lua*/
static void audio_event_callback(int cmd, int duration)
{
	lua_State* L = __GetLuaState();
	if (L == NULL){
		kefu_print_log_debug("recorder", "call recorder_event_callback failed causeby:lua_State* == NULL");
		return;
	}
	lua_getglobal(L, "audio_event_callback");
	lua_pushnumber(L, cmd);
	lua_pushnumber(L, duration);
	lua_pcall(L, 2, 0, 0);
}

static void handleAudioTrack()
{
	if (trackThread != NULL && !trackThread->container->is_lua_message_queue_empty())
	{
		LuaMessage item = trackThread->container->popLuaMessage();
		audio_event_callback(item.cmd, item.duration);
	}
}

static void handleAudioRecord()
{
	if (recordThread != NULL && !recordThread->container->is_lua_message_queue_empty())
	{
		LuaMessage item = recordThread->container->popLuaMessage();
		audio_event_callback(item.cmd, item.duration);
	}
}

static void handleLuaMessage()
{
	handleAudioRecord();
	handleAudioTrack();
}

static void volume_callback(double volume)
{
	if (recordThread != NULL)
	{
		LuaMessage message;
		message.cmd = EVENT_RECORD_VOLUME;
		message.duration = volume; //db
		recordThread->container->pushLuaMessage(message);
	}
}
