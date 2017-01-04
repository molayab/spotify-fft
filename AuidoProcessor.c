
//
//  AuidoProcessor.c
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/23/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#include "AuidoProcessor.h"

// FFT Processor, procces the waweform of the streaming and return each frecuencies values.
OSStatus fft_processor(void *inRefCon, UInt32 frames, AudioBufferList *ioData) {
    size_t buffer_data_size = (size_t)ioData->mBuffers[0].mDataByteSize;
    void * buffer = malloc(buffer_data_size);
    
    float factor = 1.0 / (2 * frames);
    
    fft_audio_processor_t * context = (fft_audio_processor_t *)inRefCon;
    
    vDSP_Length len = log2(frames);
    int n = frames / 2;
    
    FFTSetup fft = vDSP_create_fftsetup(len, FFT_RADIX2);
    
    // Se genera y llena la memoria otorgada para la funcion Hamm.
    float * window = (float *) malloc(sizeof(float) * frames);
    vDSP_hamm_window(window, frames, 0);
    
    vDSP_vmul(ioData->mBuffers[0].mData, 1, window, 1, buffer, 1, frames);
    
    // Se define el buffer de complejos
    COMPLEX_SPLIT C;
    C.realp = (float *)malloc(n * sizeof(float));
    C.imagp = (float *)malloc(n * sizeof(float));
    
    // Empaquetar los frames
    vDSP_ctoz((COMPLEX *)buffer, 2, &C, 1, n);
    
    // Se ejecuta el FFT, los resultados se almacenan en A.
    vDSP_fft_zrip(fft, &C, 1, len, FFT_FORWARD);
    
    
    //vDSP_vsmul(C.realp, 1, &factor, C.realp, 1, n);
    //vDSP_vsmul(C.imagp, 1, &factor, C.imagp, 1, n);
    
    // Covertir COMPLEX_SPLIT (C) en las magnitudes.
    float amplitude[frames];

    
    vDSP_zvmags(&C, 1, amplitude, 1, n);
    

    
    context->data = (float *)malloc(sizeof(float) * frames);
    context->frames = (size_t)frames;
    
    memcpy(context->data, amplitude, frames);
    
    vDSP_destroy_fftsetup(fft);
    
    free(buffer);
    free(window);
    free(C.realp);
    free(C.imagp);
    
    return noErr;
}

void fft_destroy_processor(fft_audio_processor_t * processor) {
    free(processor->data);
}
