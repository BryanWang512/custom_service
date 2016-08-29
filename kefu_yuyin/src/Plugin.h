#ifndef _BOYAA_PLUGIN_H_
#define _BOYAA_PLUGIN_H_

#include <memory>

typedef enum EPluginMsgType
{
	EViewOnReady = 10,
	ELuaOnReady = 11,
	EFrameUpdate = 12,
	EOnPause = 15,
	EOnResume = 16,
	EOnExit = 30,
} EPluginMsgType;

extern "C"
{
	typedef int(*PluginProc)(EPluginMsgType, void*, void*);
	void addPlugin(PluginProc proc);
}

class EngineInterface
{
public:
	virtual void* GetLuaState() = 0;
	virtual void LuaError() = 0;
	virtual void Log(const char* tag, const char* str) = 0;
	virtual void Log(const char* tag, const char* format, va_list vlist) = 0;

	virtual ~EngineInterface() {};
};

#endif // _BOYAA_PLUGIN_H_
