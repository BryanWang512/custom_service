//
//  byaudio_wave_header.h
//  BoyaaAudio
//
//  Created by xiaolingxi on 12-7-11.
//  Copyright (c) 2012年 Boyaa. All rights reserved.
//

#ifndef BoyaaAudio_byaudio_wave_header_h
#define BoyaaAudio_byaudio_wave_header_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include <stdint.h>
    
typedef struct _wav_header
{
    char        riffTag[4];     // RIFF header
    uint32_t    chunkSize;      // RIFF chunk size
    char        waveTag[4];     // WAVE header
    char        fmtTag[4];      // FMT  header
    uint32_t    subChunk1Size;  // Size of the fmt chunk
    
    uint16_t    audioFormat;    // Audio format
                                // 001 - PCM
                                // 006 - mulaw
                                // 007 - alaw
                                // 257 - IBM Mu-Law
                                // 258 - IBM A-Law
                                // 259 - ADPCM
    
    uint16_t    channels;       // Number of channels
                                // 1 - mono
                                // 2 - stereo
    
    uint32_t    samplesPerSec;  // Sampling Frequency in Hz
    uint32_t    bytesPerSec;    // bytes per second
    
    uint16_t    blockAlign;     // 2 = 16 bit mono
                                // 4 = 16 bit stereo
    
    uint16_t    bitsPerSample;  // Number of bits per sample
    char        dataTag[4];     // DATA header
    uint32_t    subChunk2Size;  // sampled data length
}WaveHeader;

/**
 *	@brief	setup a wave file header to default
 *
 *	@param 	header      the header to reset for
 *	@param 	pcmSize 	pcm data size
 */
void wave_header_setup(WaveHeader* header, long pcmSize);


#ifdef __cplusplus
}
#endif

#endif
