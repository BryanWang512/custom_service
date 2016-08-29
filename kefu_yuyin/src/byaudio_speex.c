//
//  byaudio_speex.c
//  BoyaaAudio
//
//  Created by xiaolingxi on 12-7-11.
//  Copyright (c) 2012年 Boyaa. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "byaudio_speex.h"

SpeexContext* speex_context_create(char* buffer, long bufferSize, int quality, int vbr, int enhancement, int denoise)
{   
    int ret = 0;
    SpeexContext * instance = NULL;
    instance = (SpeexContext *)malloc(sizeof(SpeexContext));
    
    // Initialize resourcez n sh*t yo
    do {
        if (instance == NULL)
            break;
    
        instance->isInited = 0;
        instance->encodeState = NULL;
        instance->decodeState = NULL;
        instance->preprocState = NULL;
        instance->dataSize = 0;
        instance->overflow = 0;
        instance->bufferCapacity = bufferSize;
        instance->buffer = buffer;
        
        // check buffer
        if (instance->bufferCapacity <= 0 || instance->buffer == NULL)
            break;
        
        // init codecs
        instance->encodeState = speex_encoder_init(&speex_nb_mode);
        instance->decodeState = speex_decoder_init(&speex_nb_mode);
        
        instance->preprocState = speex_preprocess_state_init(FRAME_SIZE, SAMPLE_PER_SECOND);
        
        // check codecs
        if (instance->encodeState == NULL || instance->decodeState == NULL || instance->preprocState == NULL)
            break;
        
        // set up codecs
        int noiseDB = NOISE_SUPRESS_DB;
        
        ret  = speex_encoder_ctl(instance->encodeState, SPEEX_SET_QUALITY, &quality);                               // 设置语言质量
        ret |= speex_encoder_ctl(instance->encodeState, SPEEX_SET_VBR, &vbr);                                       // 设置VBR
        ret |= speex_decoder_ctl(instance->decodeState, SPEEX_SET_ENH, &enhancement);                               // 设置解码器增强
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_DENOISE, &denoise);                 // 设置预处理器降噪
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_NOISE_SUPPRESS, &noiseDB);          // 设置预处理器降噪域分贝
        
        /* 自动增益控制在Fixed Float 模式下不可用
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_AGC, &agc);
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_AGC_LEVEL, &volume);
         */
        
        /* 静音检测目前不可用
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_VAD, &vad);                         // 设置预处理器静音检测
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_PROB_START, &vadProbStart);         // 设置预处理器由静音模式转入语音模式的概率
        ret |= speex_preprocess_ctl(instance->preprocState, SPEEX_PREPROCESS_SET_PROB_CONTINUE, &vadProbContinue);   // 设置预处理器保持语音模式的概率
        */
        
        if (ret != 0)
            break;

        // Init success
        instance->isInited = 1;
        return instance;
    } while(0);
    
    // Init failure
    speex_context_destroy(instance);
    return NULL;
}

void speex_context_destroy(SpeexContext* context)
{
    if (context == NULL)
        return;
    
    if (context->encodeState != NULL)
    {
        speex_encoder_destroy(context->encodeState);
        context->encodeState = NULL;
    }
    
    if (context->decodeState != NULL)
    {
        speex_decoder_destroy(context->decodeState);
        context->decodeState = NULL;
    }
    
    if (context->preprocState != NULL) {
        speex_preprocess_state_destroy(context->preprocState);
        context->preprocState = NULL;
    }

    context->buffer = NULL;
    
    context->bufferCapacity = 0;
    context->overflow = 0;
    context->isInited = 0;
    
    free(context);
    context = NULL;
}

void speex_context_clear(SpeexContext* context)
{
    if (context == NULL)
        return;
    
    if (context->buffer != NULL)
        memset(context->buffer, 0, context->dataSize);

    context->dataSize = 0;
    context->overflow = 0;
}

long speex_context_encode(SpeexContext* context, char* data, long length)
{
    long    encodedBytes = 0;
    char    cbits[BIT_BUFFER_SIZE];
    short   in[FRAME_SIZE];
    float   input[FRAME_SIZE];
    int     nbBytes = 0;
    int     i = 0;
    int     vbr = 0;
    
    int     increasement = 0;
    
    int     bufferPointer = 0;
    int     bytesToCopy = 0;

    // Holds bits so they can be read and written to by the SpeeX routines
    SpeexBits bits;
    
    if (context == NULL || context->isInited == 0 || context->buffer == NULL || data == NULL || length <= 0)
        return 0;
    
    // check if VBR is enabled
    speex_encoder_ctl(context->encodeState, SPEEX_GET_VBR, &vbr);
    
    speex_bits_init(&bits);
    
    while (bufferPointer < length)
    {
        bytesToCopy = FRAME_SIZE * sizeof(short);
        if (bytesToCopy + bufferPointer >= length)
        {
            bytesToCopy = (int)(length - bufferPointer);
        }
        
        memcpy(in, data + bufferPointer, bytesToCopy);
        
        bufferPointer += bytesToCopy;
        
        // Pre process the stream
        speex_preprocess_run(context->preprocState, in);            
        
        // Copy the 16 bits values to float so speex can work on them        
        for (i = 0; i < bytesToCopy/sizeof(short); i++) {
            input[i] = in[i];
        }
        
        // Flush all the bits in the struct so we can encode a new frame
        speex_bits_reset(&bits);
        
        // Encode the frame
        speex_encode(context->encodeState, input, &bits);
        
        // Copy the bits to an array of char that can be written
        nbBytes = speex_bits_write(&bits, cbits, BIT_BUFFER_SIZE);
        
        increasement = nbBytes + (vbr == 0 ? 0 : sizeof(int32_t));
        
        if ((context->dataSize + increasement) >= context->bufferCapacity)
        {
            // Buffer overflow
            context->overflow = 1;
            return encodedBytes;
        }
        
        if (vbr != 0)
        {
            memcpy(context->buffer + context->dataSize, &nbBytes, sizeof(int32_t));
            context->dataSize += sizeof(int32_t);
            encodedBytes += sizeof(int32_t);
        }
        
        memcpy(context->buffer + context->dataSize, cbits, nbBytes);
        context->dataSize += nbBytes;
        encodedBytes += nbBytes;
    }
    
    speex_bits_destroy(&bits);
    
    return encodedBytes;
}

long speex_context_decode(SpeexContext* context, char* data, long length)
{
    long decodedBytes = 0;
    
    char    cbits[BIT_BUFFER_SIZE];
    float   output[FRAME_SIZE];
    short   out[FRAME_SIZE];
    int     nbBytes = 0;
    long    bufferPointer = 0;
    int     i = 0;
    
    int     vbr = 0;
    
    SpeexBits bits;
    
    if (context == NULL || context->isInited == 0 || context->buffer == NULL || data == NULL || length <= 0)
        return 0;
    
    // if vbr
    //speex_decoder_ctl(context->decodeState, SPEEX_GET_VBR, &vbr);
    
    speex_bits_init(&bits);
    
    while (bufferPointer < length)
    {
        if (vbr != 0)
        {
            memcpy(&nbBytes, data + bufferPointer, sizeof(int32_t));
            bufferPointer += sizeof(int32_t);
        }
        else
        {
            // default frame size is 20 bytes
            nbBytes = DEFAULT_FRAME_BYTES;
        }
        
        if (nbBytes >= length)
        {
            // Error
            return decodedBytes;
        }
        
        memcpy(cbits, data + bufferPointer, nbBytes);
        bufferPointer += sizeof(char) * nbBytes;
        
        speex_bits_read_from(&bits, cbits, nbBytes);
        
        speex_decode(context->decodeState, &bits, output);
        
        for (i = 0; i < FRAME_SIZE; i++)
            out[i] = output[i];
        
        if (context->dataSize + sizeof(short) * FRAME_SIZE >= context->bufferCapacity)
        {
            // Buffer overflow
            context->overflow = 1;
            return decodedBytes;
        }
        
        memcpy(context->buffer + context->dataSize, out, sizeof(short) * FRAME_SIZE);
        context->dataSize += sizeof(short) * FRAME_SIZE;
        decodedBytes += sizeof(short) * FRAME_SIZE;
    }
    
    speex_bits_destroy(&bits);
    
    return decodedBytes;
}

// For the sake of stability
int speex_context_validation(SpeexContext* context)
{
    if (context == NULL) {
        return 0;
    }
    
    if (context->encodeState == NULL || context->decodeState == NULL || context->preprocState == NULL) {
        return 0;
    }
    
    if (context->buffer == NULL && context->bufferCapacity != 0) {
        return 0;
    }
    
    if (context->overflow != 0 && context->overflow != 1) {
        return 0;
    }
    
    if (context->dataSize > context->bufferCapacity) {
        return 0;
    }
    
    return 1;
}
