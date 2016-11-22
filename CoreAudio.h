//
//  CoreAudio.h
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/22/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <Accelerate/Accelerate.h>

typedef struct {
    AudioStreamBasicDescription asbd;
    Float32 *data;
    UInt32 numberOfFrames;
    UInt32 sampleNumber;
    Float32 *frequencyData;
} SoundBuffer, *SoundBufferPtr;

@protocol CoreAudioDelegate <NSObject>
- (void)frecuencies:(Float32 *)frecuencies;
@end

@interface CoreAudio : SPTCoreAudioController
@property (nonatomic, strong) id<CoreAudioDelegate> fft_delegate;
@end
