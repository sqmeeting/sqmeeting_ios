#import "SpeakerRender.h"

OSStatus  SpeakerRenderCallBack(
                               void                        *inRefCon,
                               AudioUnitRenderActionFlags  *ioActionFlags,
                               const AudioTimeStamp        *inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList             *ioData)
{
    SpeakerRender *SELF = (__bridge SpeakerRender*)inRefCon;
    
    memset(ioData->mBuffers[0].mData, 0, inNumberFrames*2);
    
    if(!SELF.isAudioMuted) {
        if(inNumberFrames % 512 != 0)
        {
            [SELF receiveAudioFrame:ioData->mBuffers[0].mData length:inNumberFrames*2 sampleRate:48000];
        }
        else
        {
            for(int i = 0; i < inNumberFrames*2/1024; i++)
            {
                [SELF receiveAudioFrame:(unsigned char *)(ioData->mBuffers[0].mData)+ i*1024 length:1024 sampleRate:48000];
            }
        }
    }
    
    return noErr;
}

@implementation SpeakerRender

- (id)init {
    self = [super init];
    if(self) {
        [self captureRateConvert];
    }
    
    return self;
}

- (void)captureRateConvert {
    memset((void *)&stream48KBasicDescription, 0, sizeof(AudioStreamBasicDescription));

    stream48KBasicDescription.mFormatID          = kAudioFormatLinearPCM;
    stream48KBasicDescription.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    stream48KBasicDescription.mSampleRate        = 48000;
    stream48KBasicDescription.mChannelsPerFrame  = 1;
    stream48KBasicDescription.mBitsPerChannel    = 16;
    stream48KBasicDescription.mBytesPerFrame     = 16/8;
    stream48KBasicDescription.mFramesPerPacket   = 1;
    stream48KBasicDescription.mBytesPerPacket    = stream48KBasicDescription.mBytesPerFrame;
    
    memset((void *)&stream441KBasicDescription, 0, sizeof(AudioStreamBasicDescription));
    
    self->stream441KBasicDescription.mFormatID          = kAudioFormatLinearPCM;
    stream441KBasicDescription.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    stream441KBasicDescription.mSampleRate        = 44100;
    stream441KBasicDescription.mChannelsPerFrame  = 1;
    stream441KBasicDescription.mBitsPerChannel    = sizeof(short)*8;
    stream441KBasicDescription.mBytesPerFrame     = sizeof(short);
    stream441KBasicDescription.mFramesPerPacket   = 1;
    stream441KBasicDescription.mBytesPerPacket    = stream441KBasicDescription.mBytesPerFrame;
    
    OSStatus status = AudioConverterNew(&stream48KBasicDescription, &stream441KBasicDescription, &audioStreamBasicConverter);
    
    if(status) {
        NSLog(@"HW2AEConverter error! ");
    }
    
    UInt32 quality = kAudioConverterQuality_Medium;
    UInt32 primeMethod = kConverterPrimeMethod_None;
    
    status = AudioConverterSetProperty(audioStreamBasicConverter,
                                       kAudioConverterSampleRateConverterQuality,
                                       sizeof(UInt32),
                                       &quality);
    if(status) {
        NSLog(@"AudioConverterSetProperty error!");
    }
    
    status = AudioConverterSetProperty(audioStreamBasicConverter,
                                       kAudioConverterPrimeMethod,
                                       sizeof(UInt32),
                                       &primeMethod);
    if(status)
        NSLog(@"AudioConverterSetProperty error");
}

- (void)receiveAudioFrame:(void* )buffer length:(unsigned int )length sampleRate:(unsigned int)sampleRate {
    if(self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(receiveAudioFrame:length:sampleRate:)]) {
        [self.inputDelegate receiveAudioFrame:buffer length:length sampleRate:sampleRate];
    }
}

@end
