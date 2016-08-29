#ifndef _LUA_BIND_H
#define _LUA_BIND_H

int audio_create(lua_State* L);
int audio_destroy(lua_State* L);

int audio_record_start(lua_State* L);
int audio_record_stop(lua_State* L);
int audio_record_cancel(lua_State*L);

int audio_track_start(lua_State* L);
int audio_track_stop(lua_State*L);
int audio_clear(lua_State*L);

int audio_track_state(lua_State*L);
int audio_clear(lua_State*L);
int audio_cur_memory(lua_State*L);

static const struct luaL_Reg func[] = {
	//Ԥ���������
	{ "audio_create", audio_create },
	{ "audio_destroy", audio_destroy },

	//¼��
	{ "startRecord", audio_record_start },
	{ "stopRecord", audio_record_stop },
	{ "cancelRecord", audio_record_cancel },
	//����
	{ "startTrack", audio_track_start },
	{ "stopTrack", audio_track_stop },
	{ "clear", audio_clear },

	{ "trackState", audio_track_state },

	{ "curMemory", audio_cur_memory },
	{ NULL, NULL }
};

static int audio_register_funcs(lua_State* L)
{
	// ����һ���µ�Ԫ��
	luaL_register(L, "kefu_yuyin", func);
	return 1;
}

#endif