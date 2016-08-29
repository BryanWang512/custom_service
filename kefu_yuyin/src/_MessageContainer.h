#ifndef _MESSAGE_CONTAINER_H
#define _MESSAGE_CONTAINER_H

#include <mutex>
#include <string>
#include <queue>
using namespace std;
class LuaMessage
{
public:
	int cmd;
	int duration; //ms
};


class _MessageContainer {
private:
	mutex m_mutex;
	queue<LuaMessage> lua_message_queue;
public:
	void pushLuaMessage(LuaMessage item);
	LuaMessage popLuaMessage();
	void clearAll();
	~_MessageContainer();
	bool is_lua_message_queue_empty()
	{
		return lua_message_queue.empty();
	}
};

_MessageContainer::~_MessageContainer()
{
	clearAll();
}

void _MessageContainer::pushLuaMessage(LuaMessage item)
{
	lock_guard<mutex> locker(m_mutex);
	lua_message_queue.push(item);
}

LuaMessage _MessageContainer::popLuaMessage()
{
	lock_guard<mutex> locker(m_mutex);
	LuaMessage item;
	if (!lua_message_queue.empty())
	{
		item = lua_message_queue.front();
		lua_message_queue.pop();
	}
	return item;
}

void _MessageContainer::clearAll()
{
	lock_guard<mutex> locker(m_mutex);
	while (lua_message_queue.size() > 0)
	{
		lua_message_queue.pop();
	}
}

#endif