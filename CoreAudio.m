//
//  CoreAudio.m
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/22/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#import "CoreAudio.h"

@implementation CoreAudio
@synthesize fft_delegate;

- (BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError *__autoreleasing *)error {
    
    [super connectOutputBus:sourceOutputBusNumber ofNode:sourceNode toInputBus:destinationInputBusNumber ofNode:destinationNode inGraph:graph error:error];
    

    AUGraphAddRenderNotify(graph, test, (__bridge void * _Nullable)(fft_delegate));
    
    return true;
}

static OSStatus test (void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    int bufferLog2 = round(log2(inNumberFrames));
    float fftNormFactor = 1.0/( 2 * inNumberFrames);
    
    FFTSetup fftSetup = vDSP_create_fftsetup(bufferLog2, kFFTRadix2);
    
    int numberOfFramesOver2 = inNumberFrames / 2;
    float outReal[numberOfFramesOver2];
    float outImaginary[numberOfFramesOver2];
    
    COMPLEX_SPLIT output = { .realp = outReal, .imagp = outImaginary };
    
    //Put all of the even numbered elements into outReal and odd numbered into outImaginary
    vDSP_ctoz((COMPLEX *)ioData->mBuffers->mData, 2, &output, 1, numberOfFramesOver2);
    
    //Perform the FFT via Accelerate
    //Use FFT forward for standard PCM audio
    vDSP_fft_zrip(fftSetup, &output, 1, bufferLog2, FFT_FORWARD);
    
    //Scale the FFT data
    vDSP_vsmul(output.realp, 1, &fftNormFactor, output.realp, 1, numberOfFramesOver2);
    vDSP_vsmul(output.imagp, 1, &fftNormFactor, output.imagp, 1, numberOfFramesOver2);
    
    
    //Take the absolute value of the output to get in range of 0 to 1
    
    id<CoreAudioDelegate> delegate = (__bridge id<CoreAudioDelegate>)inRefCon;
    
    Float32 frecuency[256];
    
    vDSP_zvabs(&output, 1, frecuency, 1, numberOfFramesOver2);
    
    [delegate frecuencies:frecuency];
    
    vDSP_destroy_fftsetup(fftSetup);
    
    return noErr;
}

@end
