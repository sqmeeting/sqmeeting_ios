#import "MicphoneCapture.h"
#include <mach/mach_time.h>

#define SAMPLE_48K_10MS_SIZE 960
#define MIN_FRAMES 10
#define RESAMPLE_BUFFER_SIZE (sizeof(short) * 512 * 100)
#define ERROR 1

#define min(a, b) (((a) < (b)) ? (a) : (b))

static OSStatus ConverterInputDataProc(AudioConverterRef inAudioConverter,
                                       UInt32 *ioNumberDataPackets,
                                       AudioBufferList *ioData,
                                       AudioStreamPacketDescription **outDataPacketDesc,
                                       void *inUserData
                                       )
{
    OSStatus err = noErr;
    MicphoneCapture *SELF = (__bridge MicphoneCapture *)inUserData;
    AudioStreamBasicDescription *sASBD = &SELF->sourceASBD;
    
    UInt32 minPackets   = min(*ioNumberDataPackets, SELF->audioSourceBuffer->ReadingLength() / sASBD->mBytesPerPacket);
    UInt32 ioBytes      = minPackets * sASBD->mBytesPerPacket;
    
    if (ioBytes > RESAMPLE_BUFFER_SIZE) 
    {
        ioBytes = RESAMPLE_BUFFER_SIZE;
    }
    
    ioBytes = SELF->audioSourceBuffer->ReadingData(SELF->audioSourceConvertBuffer, ioBytes);
    
    ioData->mBuffers[0].mData           = SELF->audioSourceConvertBuffer;
    ioData->mBuffers[0].mDataByteSize   = ioBytes;
    
    *ioNumberDataPackets = ioBytes / sASBD->mBytesPerPacket;
    
    return err;
}

OSStatus MicphoneCaptureCallBack(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData)
{
    OSStatus err = noErr;
    
    static unsigned char audioInputBuffer[SAMPLE_48K_10MS_SIZE * 4 * 4] = {0};
    int audioInputBufferLength = 0;
         
    if(inNumberFrames > 4096)
    {
        return err;
    }
         
    MicphoneCapture *SELF = (__bridge MicphoneCapture*)inRefCon;
    SELF->audioSourceBufferList->mBuffers[0].mDataByteSize = inNumberFrames * sizeof(short);
         
    err = AudioUnitRender(SELF->captureAudioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, SELF->audioSourceBufferList);
    
    if (err != noErr)
    {
        return err;
    }
   
    SELF->audioSourceBuffer->WritingData(
                                          (unsigned char *)SELF->audioSourceBufferList->mBuffers[0].mData,
                                          SELF->audioSourceBufferList->mBuffers[0].mDataByteSize
                                         );
         
    unsigned int frames = SELF->audioSourceBuffer->ReadingLength() / sizeof(short);
         
    if (frames > MIN_FRAMES)
    {
        UInt32 audioFrames = (frames - MIN_FRAMES) * 48000.0 / 44100.0;
        UInt32 audioBytes  = min(RESAMPLE_BUFFER_SIZE, audioFrames * sizeof(short));
             
        UInt32 audioPackets = audioBytes / sizeof(short);
        inNumberFrames = audioPackets;
        SELF->audioConvertedSendingBufferList->mBuffers[0].mDataByteSize = inNumberFrames * sizeof(short);
             
        OSStatus err = AudioConverterFillComplexBuffer(
                                                       SELF->audioSampleConverter,
                                                       ConverterInputDataProc,
                                                       (__bridge void*)SELF,
                                                       (UInt32*)&inNumberFrames,
                                                       SELF->audioConvertedSendingBufferList,
                                                       NULL
                                                       );

        if(err)
        {
            return err;
        }
             
        AudioBuffer *audioBuffer = &SELF->audioConvertedSendingBufferList->mBuffers[0];
        memcpy(audioInputBuffer, audioBuffer->mData, audioBuffer->mDataByteSize);
        audioInputBufferLength = audioBuffer->mDataByteSize;
    }
    else
    {
        return noErr;
    }
         
    SELF->audioDataBuffer->WritingData(audioInputBuffer, audioInputBufferLength);
     
    int ringBufferLength = SELF->audioDataBuffer->ReadingLength();
     
    if(ringBufferLength < SAMPLE_48K_10MS_SIZE * sizeof(short))
    {
        return ERROR;
    }
         
    int readingBufferLength = 0;
        
    while(SELF->audioDataBuffer->ReadingLength() >= SAMPLE_48K_10MS_SIZE * sizeof(short))
    {
        static unsigned char sendAudioDataBuffer[1920] = {0};
        
        readingBufferLength = SELF->audioDataBuffer->ReadingData(sendAudioDataBuffer, SAMPLE_48K_10MS_SIZE * sizeof(short));
                
        if(readingBufferLength < SAMPLE_48K_10MS_SIZE * sizeof(short))
        {
            return ERROR;
        }
        
        int dataLength = SAMPLE_48K_10MS_SIZE * sizeof(short);
        
        [SELF outputAudioBuffer:sendAudioDataBuffer dataLen:dataLength];
    }

    return err;
}

@interface MicphoneCapture()

@end

@implementation MicphoneCapture

- (id)init {
    self = [super init];
    if(self) {
        audioSourceBufferList   = [self allocateAudioBufferListWihtChannels:1 size: 124472 * sizeof(short)];
        audioSourceBuffer       = new RingBuffer(44100 * 10 * sizeof(short));
        audioDataBuffer         = new RingBuffer(48000);
        
        audioConvertedSendingBufferList = [self allocateAudioBufferListWihtChannels:1 size:RESAMPLE_BUFFER_SIZE];
        
        if(audioConvertedSendingBufferList == NULL) {
            return NULL;
        }
        
        audioSourceConvertBuffer = (unsigned char *)malloc(RESAMPLE_BUFFER_SIZE);
        
        [self initSampleRateConvert];
    }
    
    return self;
}

- (void)initSampleRateConvert {
    if(audioSampleConverter) {
        AudioConverterDispose(audioSampleConverter);
    }
    
    audioSampleConverter = 0;
    
    convertedASBD   = [self generalASBD:48000];
    sourceASBD      = [self generalASBD:44100];
                
    OSStatus err = AudioConverterNew(&sourceASBD, &convertedASBD, &audioSampleConverter);
    if(err)
        NSLog(@"InitSampleRateConvert::AudioConverterNew() failed! ");
        
    UInt32 quality = kAudioConverterQuality_Medium;
  
    UInt32 primeMethod = kConverterPrimeMethod_None;
    err = AudioConverterSetProperty(audioSampleConverter,
                                        kAudioConverterSampleRateConverterQuality,
                                        sizeof(UInt32),
                                        &quality);
    if(err)
        NSLog(@"InitSampleRateConvert:: AudioConverterSetProperty(kAudioConverterSampleRateConverterQuality) failed!");
    
    err = AudioConverterSetProperty(audioSampleConverter,
                                        kAudioConverterPrimeMethod,
                                        sizeof(UInt32),
                                        &primeMethod);
    if(err)
        NSLog(@"InitSampleRateConvert:: AudioConverterSetProperty(kAudioConverterPrimeMethod) failed!");
}

- (AudioStreamBasicDescription)generalASBD:(Float64)sampleRate {
    AudioStreamBasicDescription asbd;
    
    asbd.mFormatID          = kAudioFormatLinearPCM;
    asbd.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    asbd.mSampleRate        = sampleRate;
    asbd.mChannelsPerFrame  = 1;
    asbd.mBitsPerChannel    = 16;
    asbd.mBytesPerFrame     = 16/8;
    asbd.mFramesPerPacket   = 1;
    asbd.mBytesPerPacket    = asbd.mBytesPerFrame;
    
    return asbd;
}

- (void)destroyAudioBufferList:(AudioBufferList *)list {
    UInt32 i;
     
    if(list) {
        for(i = 0; i < list->mNumberBuffers; i++) {
            if(list->mBuffers[i].mData) {
                free(list->mBuffers[i].mData);
            }
        }
        
        free(list);
    }
}
 
- (AudioBufferList *)allocateAudioBufferListWihtChannels:(UInt32)numChannels size:(UInt32)size {
    AudioBufferList*            list;
    UInt32                        i;
     
    list = (AudioBufferList*)malloc(sizeof(AudioBufferList) + numChannels * sizeof(AudioBuffer));
    
    if(list == NULL) {
        return NULL;
    }
     
    list->mNumberBuffers = numChannels;
    
    for(i = 0; i < numChannels; ++i) {
        list->mBuffers[i].mNumberChannels = 1;
        list->mBuffers[i].mDataByteSize = size;
        list->mBuffers[i].mData = malloc(size);
        
        if(list->mBuffers[i].mData == NULL) {
            [self destroyAudioBufferList:list];
            return NULL;
        }
        
    }
    
    return list;
}

- (void)outputAudioBuffer:(unsigned char *)buffer dataLen:(int)length {
    if(self.delegate && [self.delegate respondsToSelector:@selector(outputAudioBuffer:dataLen:currentSampleRate:)]) {
        [self.delegate outputAudioBuffer:buffer dataLen:length currentSampleRate:48000];
    }
}



@end
