//
//  byaudio_speex.h
//  BoyaaAudio
//
//  Created by xiaolingxi on 12-7-11.
//  Copyright (c) 2012年 Boyaa. All rights reserved.
//

#ifndef BoyaaAudio_byaudio_speex_h
#define BoyaaAudio_byaudio_speex_h

#ifdef __cplusplus
extern "C" {
#endif

#include "speex/speex.h"
#include "speex/speex_bits.h"
#include "speex/speex_preprocess.h"

#define BUFFER_SIZE (1024 * 1024)
#define FRAME_SIZE 160
#define BIT_BUFFER_SIZE 200
#define SAMPLE_PER_SECOND 8000.0f
    
#define NOISE_SUPRESS_DB -25
    
#define VOICE_VOLUME_LIMIT 8000
    
#define VAD_PROB_START      80
#define VAD_PROB_CONTINUE   65
    
#define DEFAULT_FRAME_BYTES 20
    
typedef enum _speex_error
{
    NO_ERROR = 0,
    INVALID_PARAMETER,
    ENCODER_ALLOC_FAILED,
    DECODER_ALLOC_FAILED,
    ENCODER_CTL_FAILED,
    DECODER_CTL_FAILED,
    INSUFFICEIENT_MEMORY
}SPEEX_ERROR;

/**
 *	@brief	SpeeX codec context
 */
typedef struct _speex_context
{
	int     isInited;                   /**< is this instance had been initialized */
	void*   encodeState;                /**< the Encode State of SpeeX */
	void*   decodeState;                /**< the Decode State of SpeeX */
SpeexPreprocessState*   preprocState;   /**< the Preprocess State of SpeeX */
	long    dataSize;                   /**< how many data has been encoded/decoded to buffer */
	int     overflow;                   /**< is buffer overflowed, 0 - false */
	long    bufferCapacity;             /**< buffer capacity */
	char*   buffer;                     /**< the pointer to buffer */
}SpeexContext;


/**
 *	@brief	Create a speex codec instance
 *
 *	@param 	buffer      the buffer to store the encoded data
 *	@param 	bufferSize 	the buffer capacity
 *	@param 	quality 	voice encode quality, check the speex document please
 *	@param 	vbr         shall we enable variable bit rate encoding
 *	@param 	enhancement shall we enable enhancement
 *	@param 	denoise 	shall we enable noise suppression
 *
 *	@return	SpeeX codec context
 */
SpeexContext* speex_context_create(char* buffer, long bufferSize, int quality, int vbr, int enhancement, int denoise);

    
/**
 *	@brief	Destroy a SpeeX codec instance and free the memory 
 *
 *	@param 	context 	the SpeeX codec instance to destroy
 */
void speex_context_destroy(SpeexContext* context);

    
/**
 *	@brief	Clear a SpeeX codec instance's buffer and status
 *
 *	@param 	context 	the SpeeX codec instance to clear
 */
void speex_context_clear(SpeexContext* context);

    
/**
 *	@brief	Encode data with SpeeX codec
 *
 *	@param 	context 	the speex codec instance to work with
 *	@param 	data        raw pcm data
 *	@param 	length      the data size
 *
 *	@return             the size of the encoded data
 */
long speex_context_encode(SpeexContext* context, char* data, long length);

    
/**
 *	@brief	Decode data with SpeeX codec
 *
 *	@param 	context 	the speex codec instance to work with
 *	@param 	data        encoded voice data
 *	@param 	length      the data size
 *
 *	@return             the size of the data after decoded
 */
long speex_context_decode(SpeexContext* context, char* data, long length);

    
/**
 *	@brief	Context validation
 *
 *	@param 	context 	the speex codec instance to verify with
 *
 *	@return             integer indicate whether the context is a valid speex codec instance
 *                      1       - valid
 *                      other   - invalid
 */
int speex_context_validation(SpeexContext* context);

    
#ifdef __cplusplus
}
#endif

#endif
