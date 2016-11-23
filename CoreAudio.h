//
//  CoreAudio.h
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/22/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>

typedef struct {
    AudioStreamBasicDescription asbd;
    Float32 *data;
    UInt32 numberOfFrames;
    UInt32 sampleNumber;
    Float32 *frequencyData;
} SoundBuffer, *SoundBufferPtr;


@class AudioDevice;
@protocol AudioDeviceDelegate <NSObject>
@optional
- (void)coreAudioController:(SPTCoreAudioController *)controller didReceivedFrecuenciesData:(float *)frecuencies;
@end

@interface AudioDevice : SPTCoreAudioController
@property (nonatomic, unsafe_unretained) id<AudioDeviceDelegate> audioDelegate;
@end
