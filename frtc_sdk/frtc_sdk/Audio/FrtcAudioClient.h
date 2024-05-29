#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>
#import "MicphoneCapture.h"
#import "SpeakerRender.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcAudioClientDelegate <NSObject>

- (void)sendAudioDataFrame:(unsigned char *)buffer length:(int)length sampleRate:(int)sampleRate;

- (void)receiveAudioFrame:(void *)buffer length:(unsigned int)length sampleRate:(unsigned int)sampleRate;

@end

@interface FrtcAudioClient : NSObject

+ (FrtcAudioClient *)sharedAudioUnitCapture;

- (OSStatus)removeAudioUnitCoreGraph;

- (OSStatus)enableAudioUnitCoreGraph;

- (OSStatus)disableAudioUnitCoreGraph;

- (void)RestartAudioUnitWithNewFormat:(float)sample_rate;

@property (nonatomic) AudioUnit g_AudioUnit;

@property (nonatomic, strong) MicphoneCapture *micphoneDeviceCapture;

@property (nonatomic, strong) SpeakerRender   *speakerRender;

@property (nonatomic, weak) id<FrtcAudioClientDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
