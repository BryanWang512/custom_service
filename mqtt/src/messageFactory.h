#ifndef _MESSAGE_FACTORY_H
#define _MESSAGE_FACTORY_H
#include "boyim.pb.h"
#include <string>
#include <vector>
using namespace boyim_proto;
using namespace std;

//logoutMessage
void fill_logout_message(Header* header, LogoutMessage* message, char* buffer,int end_type, size_t* size)
{
	message->set_allocated_header(header);
	message->set_clock(currentTimeMillis());
	message->set_end_type(end_type);
	*size = message->ByteSize();
	bool ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);
}

//loginRequest
void fill_login_request(Header* header, LoginRequest* message, const string& from_id, const string& dest_id, const string& pre_id, char* buffer, size_t* size)
{
	message->set_allocated_header(header);
	if (!from_id.empty())
	{
		message->set_from_service_fid(from_id);
	}
	if (!dest_id.empty())
	{
		message->set_dest_service_fid(dest_id);
	}
	if (!pre_id.empty())
	{
		message->set_preferred_service_fid(pre_id);
	}
	*size = message->ByteSize();
	bool ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);
}

//chatReady
void fill_chat_ready_request(Header* header, ChatReadyRequest* message, const string& clientInfo, const string& sessionId, char* buffer, size_t* size)
{
	message->set_allocated_header(header);
	message->set_client_info(clientInfo);
	message->set_session_id(sessionId);
	*size = message->ByteSize();
	int ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);
}

//chatMessage
void fill_chat_message(Header* header, ChatMessage* message, const string& msg, const string& sessionId, const string& type, char* buffer, size_t* size)
{
	message->set_allocated_header(header);
	message->set_session_id(sessionId);
	message->set_seq_id(currentTimeMillis());
	message->set_type(type);
	message->set_msg(msg);
	*size = message->ByteSize();
	int ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);
}

//ChatMessageAck
void fill_chat_message_ack(Header* header, ChatMessageAck* message, _long seq_id, const string& sessionId, char* buffer, size_t* size)
{
	message->set_allocated_header(header);
	message->set_session_id(sessionId);
	message->add_seq_ids(seq_id);
	*size = message->ByteSize();
	int ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);

}

//ChatMessageAcks
void fill_chat_messages_ack(Header* header, ChatMessageAck* message, vector<_long> seq_ids, const string& sessionId, char* buffer, size_t* size)
{
	message->set_allocated_header(header);
	message->set_session_id(sessionId);
	for (auto i = seq_ids.begin(); i != seq_ids.end(); ++i)
	{
		message->add_seq_ids(*i);
	}
	*size = message->ByteSize();
	int ret = message->SerializeToArray(buffer, *size);
	mqtt_print_log_debug(TAG, "SerializeToArray result: %d.", ret);

}

#endif
