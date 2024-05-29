#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>
#include "ring_buffer.h"

NS_ASSUME_NONNULL_BEGIN

extern OSStatus MicphoneCaptureCallBack(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData);

@protocol MicphoneCaptureDelegate <NSObject>

- (void)outputAudioBuffer:(unsigned char *)buffer dataLen:(int)length currentSampleRate:(int)sampleRate;

@end

@interface MicphoneCapture : NSObject {
@public
    AudioBufferList *audioSourceBufferList;
    AudioBufferList *audioConvertedSendingBufferList;
    
    RingBuffer *audioSourceBuffer;
    RingBuffer *audioDataBuffer;
    unsigned char *audioSourceConvertBuffer;
    
    AudioUnit captureAudioUnit;
    
    AudioStreamBasicDescription convertedASBD;
    AudioStreamBasicDescription sourceASBD;
    AudioConverterRef audioSampleConverter;
}

@property (nonatomic, weak) id<MicphoneCaptureDelegate> delegate;

- (void)outputAudioBuffer:(unsigned char *)buffer dataLen:(int)length;

@end

NS_ASSUME_NONNULL_END
