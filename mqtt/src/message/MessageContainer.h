#ifndef _MESSAGE_CONTAINER_H
#define _MESSAGE_CONTAINER_H

#include <mutex>
#include <string>
#include <queue>
#include "Message.h"
using namespace std;

enum LUA_MESSAGE_TYPE
{
	LOGIN_RESPONSE = 1,
	SHIFT_SESSION = 2,
	END_SESSION = 3,
	CHATREADY_RESPONSE = 4,
	CHAT_MESSAGE = 5,
	CHATOFF_MESSAGE = 6,
	LOGOUT_MESSAGE = 7,
	MQTT_EVENT = 8,
	DEFAULT = 0,
};

class MessageContainer {
private:
    std::mutex m_login_mutex;
	std::mutex m_shift_mutex;
	std::mutex m_end_mutex;
	std::mutex m_chatready_mutex;
	std::mutex m_chat_mutex;
	std::mutex m_chatoff_mutex;
	std::mutex m_logout_mutex;
	std::mutex m_event_mutex;
	std::mutex m_lua_mutex;
	queue<LUA_LoginResponse> login_response_queue;
	queue<LUA_ShiftSession> shift_session_queue;
	queue<LUA_EndSession> end_session_queue;
	queue<LUA_ChatReadyResponse> chatready_response_queue;
	queue<LUA_ChatMessage> chat_message_queue;
	queue<LUA_ChatMessage> chatoff_message_queue;
	queue<LUA_LogoutMessage> logout_message_queue;
	queue<MqttEvent> mqtt_event_queue;
	queue<LUA_MESSAGE_TYPE> lua_message_queue;
	void pushLuaMessage(LUA_MESSAGE_TYPE item);
public:
	void pushLoginResponse(LUA_LoginResponse item);
	LUA_LoginResponse popLoginResponse();
	void pushShiftSession(LUA_ShiftSession item);
	LUA_ShiftSession popShiftSession();
	void pushEndSession(LUA_EndSession item);
	LUA_EndSession popEndSession();
	void pushChatReadyResponse(LUA_ChatReadyResponse item);
	LUA_ChatReadyResponse popChatReadyResponse();
	void pushChatMessage(LUA_ChatMessage item);
	LUA_ChatMessage popChatMessage();
	void pushChatOffMessage(LUA_ChatMessage item);
	LUA_ChatMessage popChatOffMessage();
	void pushLogoutMessage(LUA_LogoutMessage item);
	LUA_LogoutMessage popLogoutMessage();
	void pushMqttEvent(MqttEvent item);
	MqttEvent popMqttEvent();
	LUA_MESSAGE_TYPE popLuaMessage();
	void clearAll();
    MessageContainer(){};
	~MessageContainer();

	bool is_login_response_queue_empty()
	{
		return login_response_queue.empty();
	}
	bool is_shift_session_queue_empty()
	{
		return shift_session_queue.empty();
	}
	bool is_end_session_queue_empty()
	{
		return end_session_queue.empty();
	}
	bool is_chatready_response_queue_empty()
	{
		return chatready_response_queue.empty();
	}
	bool is_chat_message_queue_empty()
	{
		return chat_message_queue.empty();
	}
	bool is_chatoff_message_queue_empty()
	{
		return chatoff_message_queue.empty();
	}
	bool is_logout_message_queue_empty()
	{
		return logout_message_queue.empty();
	}
	bool is_mqtt_event_queue_empty()
	{
		return mqtt_event_queue.empty();
	}
	bool is_lua_message_queue_empty()
	{
		return lua_message_queue.empty();
	}
};

MessageContainer::~MessageContainer()
{
	clearAll();
}

void MessageContainer::pushLoginResponse(LUA_LoginResponse item)
{
	lock_guard<mutex> locker(m_login_mutex);
	login_response_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::LOGIN_RESPONSE);
}

LUA_LoginResponse MessageContainer::popLoginResponse()
{
	lock_guard<mutex> locker(m_login_mutex);
	LUA_LoginResponse item;
	if (!login_response_queue.empty())
	{
		item = login_response_queue.front();
		login_response_queue.pop();
	}
	return item;
}

void MessageContainer::pushShiftSession(LUA_ShiftSession item)
{
	lock_guard<mutex> locker(m_shift_mutex);
	shift_session_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::SHIFT_SESSION);
}

LUA_ShiftSession MessageContainer::popShiftSession()
{
	lock_guard<mutex> locker(m_shift_mutex);
	LUA_ShiftSession item;
	if (!shift_session_queue.empty())
	{
		item = shift_session_queue.front();
		shift_session_queue.pop();
	}
	return item;
}

void MessageContainer::pushEndSession(LUA_EndSession item)
{
	lock_guard<mutex> locker(m_end_mutex);
	end_session_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::END_SESSION);
}

LUA_EndSession MessageContainer::popEndSession()
{
	lock_guard<mutex> locker(m_end_mutex);
	LUA_EndSession item;
	if (!end_session_queue.empty())
	{
		item = end_session_queue.front();
		end_session_queue.pop();
	}
	return item;
}

void MessageContainer::pushChatReadyResponse(LUA_ChatReadyResponse item)
{
	lock_guard<mutex> locker(m_chatready_mutex);
	chatready_response_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::CHATREADY_RESPONSE);
}

LUA_ChatReadyResponse MessageContainer::popChatReadyResponse()
{
	lock_guard<mutex> locker(m_chatready_mutex);
	LUA_ChatReadyResponse item;
	if (!chatready_response_queue.empty())
	{
		item = chatready_response_queue.front();
		chatready_response_queue.pop();
	}
	return item;
}

void MessageContainer::pushChatMessage(LUA_ChatMessage item)
{
	lock_guard<mutex> locker(m_chat_mutex);
	chat_message_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::CHAT_MESSAGE);
}

LUA_ChatMessage MessageContainer::popChatMessage()
{
	lock_guard<mutex> locker(m_chat_mutex);
	LUA_ChatMessage item;
	if (!chat_message_queue.empty())
	{
		item = chat_message_queue.front();
		chat_message_queue.pop();
	}
	return item;
}

void MessageContainer::pushChatOffMessage(LUA_ChatMessage item)
{
	lock_guard<mutex> locker(m_chatoff_mutex);
	chatoff_message_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::CHATOFF_MESSAGE);
}

LUA_ChatMessage MessageContainer::popChatOffMessage()
{
	lock_guard<mutex> locker(m_chatoff_mutex);
	LUA_ChatMessage item;
	if (!chatoff_message_queue.empty())
	{
		item = chatoff_message_queue.front();
		chatoff_message_queue.pop();
	}
	return item;
}

void MessageContainer::pushLogoutMessage(LUA_LogoutMessage item)
{
	lock_guard<mutex> locker(m_logout_mutex);
	logout_message_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::LOGOUT_MESSAGE);
}

LUA_LogoutMessage MessageContainer::popLogoutMessage()
{
	lock_guard<mutex> locker(m_logout_mutex);
	LUA_LogoutMessage item;
	if (!logout_message_queue.empty())
	{
		item = logout_message_queue.front();
		logout_message_queue.pop();
	}
	return item;
}

void MessageContainer::pushMqttEvent(MqttEvent item)
{
	lock_guard<mutex> locker(m_event_mutex);
	mqtt_event_queue.push(item);
	pushLuaMessage(LUA_MESSAGE_TYPE::MQTT_EVENT);
}

MqttEvent MessageContainer::popMqttEvent()
{
	lock_guard<mutex> locker(m_event_mutex);
	MqttEvent item;
	if (!mqtt_event_queue.empty())
	{
		item = mqtt_event_queue.front();
		mqtt_event_queue.pop();
	}
	return item;
}

void MessageContainer::pushLuaMessage(LUA_MESSAGE_TYPE item)
{
	lock_guard<mutex> locker(m_lua_mutex);
	lua_message_queue.push(item);
}

LUA_MESSAGE_TYPE MessageContainer::popLuaMessage()
{
	lock_guard<mutex> locker(m_lua_mutex);
	LUA_MESSAGE_TYPE item = DEFAULT;
	if (!lua_message_queue.empty())
	{
		item = lua_message_queue.front();
		lua_message_queue.pop();
	}
	return item;
}

void MessageContainer::clearAll()
{
    m_lua_mutex.lock();
	while (lua_message_queue.size() > 0)
	{
		lua_message_queue.pop();
	}
    m_lua_mutex.unlock();
	m_login_mutex.lock();
	while (login_response_queue.size() > 0)
	{
		login_response_queue.pop();
	}
    m_login_mutex.unlock();
	m_shift_mutex.lock();
	while (shift_session_queue.size() > 0)
	{
		shift_session_queue.pop();
	}
    m_shift_mutex.unlock();
    m_end_mutex.lock();
	while (end_session_queue.size() > 0)
	{
		end_session_queue.pop();
	}
    m_end_mutex.unlock();
    m_chatready_mutex.lock();
	while (chatready_response_queue.size() > 0)
	{
		chatready_response_queue.pop();
	}
    m_chatready_mutex.unlock();
    m_chat_mutex.lock();
	while (chat_message_queue.size() > 0)
	{
		chat_message_queue.pop();
	}
    m_chat_mutex.unlock();
    m_chatoff_mutex.lock();
	while (chatoff_message_queue.size() > 0)
	{
		chatoff_message_queue.pop();
	}
    m_chatoff_mutex.unlock();
    m_logout_mutex.lock();
	while (logout_message_queue.size() > 0)
	{
		logout_message_queue.pop();
	}
    m_logout_mutex.unlock();
    m_event_mutex.lock();
	while (mqtt_event_queue.size() > 0)
	{
		mqtt_event_queue.pop();
	}
    m_event_mutex.unlock();
}

#endif