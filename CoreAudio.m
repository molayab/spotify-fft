//
//  CoreAudio.m
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/22/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#import "CoreAudio.h"
#import "AuidoProcessor.h"

@implementation AudioDevice

- (BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError *__autoreleasing *)error {
    
    [super connectOutputBus:sourceOutputBusNumber ofNode:sourceNode toInputBus:destinationInputBusNumber ofNode:destinationNode inGraph:graph error:error];
    
    AUGraphAddRenderNotify(graph, perform, (__bridge void * _Nullable)(self));
    
    return true;
}

static OSStatus perform(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    AudioDevice * instance = (__bridge AudioDevice *)inRefCon;
    
    fft_audio_processor_t processor;
    processor.frames = 0;
    
    OSStatus ret = fft_processor(&processor, inNumberFrames, ioData);
    
    if (processor.frames > 0) {
        float amplitudes[processor.frames];
        
        memcpy(amplitudes, processor.data, processor.frames);
        
        if ([instance.audioDelegate respondsToSelector:@selector(coreAudioController:didReceivedFrecuenciesData:)]) {
            [instance.audioDelegate coreAudioController:instance didReceivedFrecuenciesData:amplitudes];
            
        }
        
        fft_destroy_processor(&processor);
    }
    
    
    return ret;
}

//static OSStatus test (void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
//    
//    int bufferLog2 = round(log2(inNumberFrames));
//    float fftNormFactor = 1.0/( 2 * inNumberFrames);
//    
//    FFTSetup fftSetup = vDSP_create_fftsetup(bufferLog2, kFFTRadix5);
//    
//    int numberOfFramesOver2 = inNumberFrames / 2;
//    float outReal[numberOfFramesOver2];
//    float outImaginary[numberOfFramesOver2];
//    
//    COMPLEX_SPLIT output = { .realp = outReal, .imagp = outImaginary };
//    
//    //Put all of the even numbered elements into outReal and odd numbered into outImaginary
//    vDSP_ctoz((COMPLEX *)ioData->mBuffers[0].mData, 2, &output, 1, numberOfFramesOver2);
//    
//    //Perform the FFT via Accelerate
//    //Use FFT forward for standard PCM audio
//    vDSP_fft_zrip(fftSetup, &output, 1, bufferLog2, FFT_FORWARD);
//    
//    //Scale the FFT data
//    //vDSP_vsmul(output.realp, 1, &fftNormFactor, output.realp, 1, numberOfFramesOver2);
//    //vDSP_vsmul(output.imagp, 1, &fftNormFactor, output.imagp, 1, numberOfFramesOver2);
//    
//    
//    //Take the absolute value of the output to get in range of 0 to 1
//    
//    id<CoreAudioDelegate> delegate = (__bridge id<CoreAudioDelegate>)inRefCon;
//    
//    Float32 frecuency[numberOfFramesOver2];
//    
//    //vDSP_zvabs(&output, 1, frecuency, 1, 16);
//    vDSP_zvmags(&output, 1, frecuency, 1, numberOfFramesOver2);
//    vDSP_hann_window(frecuency, numberOfFramesOver2, vDSP_HANN_NORM);
//    
//    [delegate frecuencies:frecuency];
//    
//    vDSP_destroy_fftsetup(fftSetup);
//    
//    return noErr;
//}

@end
