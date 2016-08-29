//
//  byaudio_wave_header.c
//  BoyaaAudio
//
//  Created by xiaolingxi on 12-7-11.
//  Copyright (c) 2012年 Boyaa. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "byaudio_wave_header.h"

void wave_header_setup(WaveHeader* header, long pcmSize)
{
    if (header == NULL) {
        return;
    }
    
    header->riffTag[0] = 'R';
    header->riffTag[1] = 'I';
    header->riffTag[2] = 'F';
    header->riffTag[3] = 'F';
    
    header->waveTag[0] = 'W';
    header->waveTag[1] = 'A';
    header->waveTag[2] = 'V';
    header->waveTag[3] = 'E';
    
    header->fmtTag[0] = 'f';
    header->fmtTag[1] = 'm';
    header->fmtTag[2] = 't';
    header->fmtTag[3] = ' ';
    
    header->subChunk1Size = 16;
    header->audioFormat = 1;
    header->channels = 1;
    header->samplesPerSec = 8000;
    header->bytesPerSec = 16000;
    header->blockAlign = 2;
    header->bitsPerSample = 16;
    
    header->dataTag[0] = 'd';
    header->dataTag[1] = 'a';
    header->dataTag[2] = 't';
    header->dataTag[3] = 'a';
    
    header->subChunk2Size = (uint32_t)pcmSize;
    
    header->chunkSize = 4 + (8 + header->subChunk1Size) + (8 + header->subChunk2Size);
}