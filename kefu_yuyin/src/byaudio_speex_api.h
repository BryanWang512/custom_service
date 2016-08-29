#ifndef _BYAUDIO_SPEEX_API_H
#define _BYAUDIO_SPEEX_API_H


#include <string.h>
#include <mutex>
#include "speex/speex.h"
#include "byaudio_speex.h"
#include "byaudio_wave_header.h"
using namespace std;

static int codec_open = 0;
static int dec_frame_size;
static int enc_frame_size;

static SpeexBits ebits, dbits;
void *enc_state;
void *dec_state;
static SpeexContext* sc;
static mutex mbyaudio_speex_mutex;

void _byaudio_speex_create()
{
	char* buffer = NULL;
	buffer = (char*) malloc(512 * 1024);
	sc = speex_context_create(buffer, 512 * 1024, 4, 0, 1, 1);
}

void _byaudio_speex_encode(char* data, int length)
{
	char* src = NULL;
	src = (char*) malloc(length);
	memcpy(src, data, length);
	speex_context_encode(sc, src, length);
	free(src);
}

long _byaudio_speex_getcontent(char** bytes)
{
	char* dst = sc->buffer;
	long dataSize = sc->dataSize;
	if (*bytes != NULL){
		free(*bytes);
		*bytes = NULL;
	}
	*bytes = (char*)malloc(dataSize);
	memcpy(*bytes, dst, dataSize);
	return dataSize;
}

long _byaudio_speex_decode(char* data, char** bytes, int length) {
	char* src = NULL;
	src = (char*) malloc(length);
	memcpy(src, data, length);

	speex_context_decode(sc, src, length);
	char* dst = sc->buffer;
	long dataSize = sc->dataSize;
	if (*bytes != NULL){
		free(*bytes);
		*bytes = NULL;
	}
	*bytes = (char*)malloc(dataSize);
	memcpy(*bytes, dst, dataSize);
	free(src);
	return dataSize;
}

long _byaudio_speex_header(char** bytes, char* buffer, long dataSize)
{
	WaveHeader header;
	wave_header_setup(&header, dataSize);
	long tempSize = sizeof(WaveHeader) + dataSize;
	char* tempBuffer = (char *) malloc(sizeof(char) * tempSize);
	memcpy(tempBuffer, &header, sizeof(WaveHeader));
	memcpy(tempBuffer + sizeof(WaveHeader), buffer, dataSize);
	if (*bytes != NULL){
		free(*bytes);
		*bytes = NULL;
	}
	*bytes = (char*)malloc(tempSize);
	memcpy(*bytes, tempBuffer, tempSize);
	free(tempBuffer);
	return tempSize;
}

void _byaudio_speex_clear() {
	speex_context_clear(sc);
}

void _byaduio_speex_destroy(){
    if(sc != NULL){
        char* buff = sc->buffer;
        if(buff != NULL){
            free(buff);
        }
        speex_context_destroy(sc);
    }
    sc = NULL;
}

void byaudio_speex_create()
{
    lock_guard<mutex> locker(mbyaudio_speex_mutex);
    _byaudio_speex_create();
}

void byaudio_speex_destroy()
{
    lock_guard<mutex> locker(mbyaudio_speex_mutex);
    _byaduio_speex_destroy();
}


long byaudio_speex_encode(char* input, char** output, int len)
{
	lock_guard<mutex> locker(mbyaudio_speex_mutex);
    _byaudio_speex_encode(input, len);
	long dataSize = _byaudio_speex_getcontent(output);
    _byaudio_speex_clear();
    return dataSize;
}

long byaudio_speex_decode(char* input, char** output, int len)
{
	lock_guard<mutex> locker(mbyaudio_speex_mutex);
    long dataSize = _byaudio_speex_decode(input, output, len);
    _byaudio_speex_clear();
	return dataSize;
}
#endif