#ifndef _BYJSON_UTIL_H
#define _BYJSON_UTIL_H
#include "json.h"
#include <string>
using namespace std;

bool string_to_json(string jsonStr, Json::Value& root)
{
	Json::Reader reader;
	return reader.parse(jsonStr, root);
}

string json_to_string(Json::Value& root)
{
	Json::FastWriter writer;
	return writer.write(root);
}

#endif
