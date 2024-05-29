#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>

NS_ASSUME_NONNULL_BEGIN

extern OSStatus SpeakerRenderCallBack( void *inRefCon, AudioUnitRenderActionFlags     *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData);

@protocol SpeakerRenderDelegate <NSObject>

- (void)receiveAudioFrame:(void* )buffer length:(unsigned int )length sampleRate:(unsigned int )sampleRate;

@end

@interface SpeakerRender : NSObject {
@public
    AudioStreamBasicDescription stream48KBasicDescription;
    AudioStreamBasicDescription stream441KBasicDescription;
    AudioConverterRef audioStreamBasicConverter;
    
    AudioUnit speakerAudioUnit;
}

@property (nonatomic, weak) id<SpeakerRenderDelegate> inputDelegate;
@property (nonatomic) BOOL isAudioMuted;
 
- (void)receiveAudioFrame:(void* )buffer length:(unsigned int )length sampleRate:(unsigned int )sampleRate;

@end

NS_ASSUME_NONNULL_END
