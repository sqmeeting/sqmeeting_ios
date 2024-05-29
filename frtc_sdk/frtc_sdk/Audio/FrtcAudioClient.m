#import "FrtcAudioClient.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioConverter.h>
#import <AVFoundation/AVAudioSession.h>

extern OSStatus MicphoneCaptureCallBack(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData);

extern OSStatus SpeakerRenderCallBack( void *inRefCon, AudioUnitRenderActionFlags     *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData);

// A VP I/O unit's bus 1 connects to input hardware (microphone).
static const AudioUnitElement kInputBus = 1;
// A VP I/O unit's bus 0 connects to output hardware (speaker).
static const AudioUnitElement kOutputBus = 0;

const UInt32 kBytesPerSample = 2;

static FrtcAudioClient *sharedAudioUnitCapture = nil;

@interface FrtcAudioClient ()<MicphoneCaptureDelegate, SpeakerRenderDelegate>

@end

@implementation FrtcAudioClient

+ (FrtcAudioClient *)sharedAudioUnitCapture {
    if (sharedAudioUnitCapture == nil) {
        @synchronized(self) {
            if (sharedAudioUnitCapture == nil) {
                sharedAudioUnitCapture = [[FrtcAudioClient alloc] init];
            }
        }
    }
    
    return sharedAudioUnitCapture;
}

- (id)init {
    if (self = [super init]) {
        [self initAudioUnit];
        [self ConfigureAudioUnit];
        [self setupAudioSession];
    }
    
    return self;
}

- (OSStatus)removeAudioUnitCoreGraph {
    OSStatus status = noErr;
    
    if(!_g_AudioUnit){
        NSLog(@"DeleteAudioUnit : fAudioUnit is null\n");
        return status;
    }
    
    status = AudioOutputUnitStop(_g_AudioUnit);
    
    if(status != noErr) {
        NSLog(@"AudioOutputUnitStop error");
    }
        
    if(AudioUnitUninitialize(_g_AudioUnit) != noErr) {
        NSLog(@"AudioUnitUninitialize error");
    }
    
    if(AudioComponentInstanceDispose (_g_AudioUnit) != noErr) {
        NSLog(@"AudioComponentInstanceDispose error");
    }
        
    _g_AudioUnit = NULL;
    
    return status;
}

- (OSStatus)enableAudioUnitCoreGraph {
    OSStatus status = noErr;

    if(!_g_AudioUnit) {
        return status;
    }
    
    status = AudioOutputUnitStart(_g_AudioUnit);
    
    if(status != noErr) {
        NSLog(@"AudioOutputUnitStart error");
    }
    
    return status;
}

- (OSStatus)disableAudioUnitCoreGraph {
    OSStatus status = noErr;
    
    if(!_g_AudioUnit) {
        return status;
    }
    
    status = AudioOutputUnitStop(_g_AudioUnit);
    
    if(status != noErr) {
        NSLog(@"AudioOutputUnitStop error");
    }
    
    return status;
}

- (OSStatus)initAudioUnit {
    AudioComponent                   component;
    AudioComponentDescription        description;
    OSStatus    err = noErr;

    description.componentType = kAudioUnitType_Output;
    description.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentFlags = 0;
    description.componentFlagsMask = 0;
    component = AudioComponentFindNext(NULL, &description);
    
    if(component) {
        err = AudioComponentInstanceNew(component, &_g_AudioUnit);
        if(err != noErr) {
            NSLog(@"InitAudioUnit::AudioComponentInstanceNew failed!");
            _g_AudioUnit = NULL;
            return err;
        }
    } else {
        NSLog(@"InitAudioUnit::AudioComponentFindNext failed!");
        return err;
    }

    UInt32 enable_input = 1;
    err = AudioUnitSetProperty(_g_AudioUnit, kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input, kInputBus, &enable_input,
                                  sizeof(enable_input));
    if (err != noErr) {
      NSLog(@"Failed to enable input on input scope of input element. "
                   "Error=%ld.",
                  (long)err);
      return false;
    }
    
    // Enable output on the output scope of the output element.
     UInt32 enable_output = 1;
     err = AudioUnitSetProperty(_g_AudioUnit, kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output, kOutputBus,
                                   &enable_output, sizeof(enable_output));
     if (err != noErr) {
       NSLog(@"Failed to enable output on output scope of output element. "
                    "Error=%ld.",
                   (long)err);
       return false;
     }
    
    self.speakerRender = [[SpeakerRender alloc] init];
    self.speakerRender.isAudioMuted = NO;
    self.speakerRender.inputDelegate = self;
    self.speakerRender->speakerAudioUnit = _g_AudioUnit;
    
    AURenderCallbackStruct render_callback;
    render_callback.inputProc = SpeakerRenderCallBack;
    render_callback.inputProcRefCon = (__bridge void*)self.speakerRender;
    
    err = AudioUnitSetProperty(_g_AudioUnit,
                                kAudioUnitProperty_SetRenderCallback,
                                kAudioUnitScope_Input,
                                kOutputBus,
                                &render_callback,
                                sizeof(render_callback));
    if(err != noErr) {
        NSLog(@"failed to set output callback! \n");
        return err;
    }
    
    self.micphoneDeviceCapture = [[MicphoneCapture alloc] init];
    self.micphoneDeviceCapture.delegate = self;
    self.micphoneDeviceCapture->captureAudioUnit = _g_AudioUnit;
   // [self.micphoneDeviceCapture configAudioStreamBasicDescription];
    
    AURenderCallbackStruct input_callback;
    input_callback.inputProc = MicphoneCaptureCallBack;
    input_callback.inputProcRefCon = (__bridge void*)self.micphoneDeviceCapture;
    
    err = AudioUnitSetProperty (_g_AudioUnit,
                                            kAudioOutputUnitProperty_SetInputCallback,
                                            kAudioUnitScope_Output,
                                            kInputBus,
                                            &input_callback,
                                            sizeof(input_callback));
    if(err != noErr)
    {
        NSLog(@"failed to set input callback! \n");
        return err;
    }
    
    return noErr;
}

- (OSStatus)ConfigureAudioUnit {
    OSStatus    err = noErr;
    UInt32    param;
    UInt32 fAudioSamples;

    AudioStreamBasicDescription streamFormat = [self getFormat:48000];
    UInt32 size = sizeof(streamFormat);
    
    AudioStreamBasicDescription streamFormat1 = [self getFormat:44100];
    UInt32 size1 = sizeof(streamFormat1);
    
    err =
        AudioUnitSetProperty(_g_AudioUnit, kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output, kInputBus, &streamFormat1, size1);
    if (err != noErr) {
      NSLog(@"Failed to set format on output scope of input bus. "
                   "Error=%ld.",
                  (long)err);
      return false;
    }
    
    err =
        AudioUnitSetProperty(_g_AudioUnit, kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Input, kOutputBus, &streamFormat, size);
    if (err != noErr) {
      NSLog(@"Failed to set format on input scope of output bus. "
                   "Error=%ld.",
                  (long)err);
      return false;
    }
    
  
    err = AudioUnitInitialize(_g_AudioUnit);
    if(err != noErr)
    {
        NSLog(@"failed to initialize AU\n");
        return err;
    }
    
    fAudioSamples = 124472;
    param = sizeof(UInt32);
    err = AudioUnitSetProperty(_g_AudioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &fAudioSamples, param);
    if(err != noErr)
    {
        NSLog(@"failed to set audio sample size\n");
    }
    
    return noErr;
}

-(BOOL)setupAudioSession {
    OSStatus err = AudioSessionInitialize(NULL, NULL, NULL, NULL);
    if(err != noErr) {
        NSLog(@"failed to init audio session error = %x.maybe this is cause from backgroud to foregroud. we will re-init the AudioSession, but if failed, it doesn't matter\n",err);
    }
    
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    if(err != noErr) {
        NSLog(@"failed to AudioSessionSetProperty AudioCategory. \n");
    }
    
    UInt32 audioMode = kAudioSessionMode_VoiceChat;
    err = AudioSessionSetProperty(kAudioSessionProperty_Mode, sizeof(audioMode), &audioMode);
    if(err != noErr) {
        NSLog(@"failed to AudioSessionSetProperty audioMode. \n");
    }
    
    Float32 preferredBufferSize = .01;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
    if(err != noErr) {
        NSLog(@"couldn't set i/o buffer duration. \n");
    }
    
    
    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
    UInt32 datasize = sizeof(route);
    err = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, datasize, &route);
    
    UInt32 allowBluetoothInput = 1;
    err = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(allowBluetoothInput), &allowBluetoothInput);
    if(err != noErr) {
        NSLog(@"failed to enable bluetooth input. \n");
    }
    
    return YES;
}

- (void)RestartAudioUnitWithNewFormat:(float)sample_rate {
    AudioOutputUnitStop(_g_AudioUnit);
    AudioUnitUninitialize(_g_AudioUnit);
}

- (AudioStreamBasicDescription)getFormat:(float) sample_rate {
  AudioStreamBasicDescription format;
  format.mSampleRate = sample_rate;
  format.mFormatID = kAudioFormatLinearPCM;
  format.mFormatFlags =
      kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
  format.mBytesPerPacket = kBytesPerSample;
  format.mFramesPerPacket = 1;  // uncompressed.
  format.mBytesPerFrame = kBytesPerSample;
  format.mChannelsPerFrame = 1;
  format.mBitsPerChannel = 8 * kBytesPerSample;
    
  return format;
}

#pragma mark - MicphoneCaptureDelegate
//- (void)outputAudioBuffer:(unsigned char *)buffer dataLen:(int)length currentSampleRate:(int)sampleRate;

- (void)outputAudioBuffer:(unsigned char *)buffer dataLen:(int)length currentSampleRate:(int)sampleRate {
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendAudioDataFrame:length:sampleRate:)]) {
        [self.delegate sendAudioDataFrame:buffer length:length sampleRate:sampleRate];
    }
}

#pragma mark - SpeakerRenderDelegate
- (void)receiveAudioFrame:(void *)buffer length:(unsigned int)length sampleRate:(unsigned int)sampleRate {
    if(self.delegate && [self.delegate respondsToSelector:@selector(receiveAudioFrame:length:sampleRate:)]) {
        [self.delegate receiveAudioFrame:buffer length:length sampleRate:sampleRate];
    }
}

@end
