//
//  AuidoProcessor.h
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/23/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#ifndef AuidoProcessor_h
#define AuidoProcessor_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Accelerate/Accelerate.h>
#include <CoreAudio/CoreAudioTypes.h>

typedef struct fft_audio_processor_t {
    float * data;
    size_t frames;
} fft_audio_processor_t;

OSStatus fft_processor(void *, UInt32, AudioBufferList *);
void fft_destroy_processor(fft_audio_processor_t *);

#endif /* AuidoProcessor_h */
