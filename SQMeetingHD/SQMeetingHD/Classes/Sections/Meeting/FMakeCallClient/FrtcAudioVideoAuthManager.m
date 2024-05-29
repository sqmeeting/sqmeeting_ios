#import "FrtcAudioVideoAuthManager.h"
#import <AVFoundation/AVFoundation.h>
#import "FrtcTimer.h"

static FAudioLevelBlock audioLevelBlock = nil;

@interface FrtcAudioVideoAuthManager () <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSString *levelTimer;

@end

@implementation FrtcAudioVideoAuthManager

+ (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones]||[[output portType] isEqualToString:AVAudioSessionPortBluetoothLE] || [[output portType] isEqualToString:AVAudioSessionPortBluetoothHFP] || [[output portType] isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            return YES;
        }
    }
    return NO;
}

- (void)f_stopAudioTimer {
    [FrtcTimer canelTimer:self.levelTimer];
    self.audioRecorder = nil;
}

- (void)f_audioSizeChange:(FAudioLevelBlock)block {
    
    audioLevelBlock = block;
        
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:44100], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
    
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (self.audioRecorder) {
        self.audioRecorder.delegate = self;
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder record];
        [self.audioRecorder setMeteringEnabled:YES];
        
        @WeakObj(self)
        self.levelTimer = [FrtcTimer timerTask:^{
            @StrongObj(self)
            [self levelTimerCallback];
        } start:0 interval:0.01 repeats:YES async:YES];
        
    }
}

- (void)levelTimerCallback{
    [self.audioRecorder updateMeters];
    
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    int lastVolume = 0;
    if (lowPassResults <= 0.067) {
        lastVolume = 1;
    }else if (lowPassResults <= 0.134) {
        lastVolume = 2;
    }else if (lowPassResults <= 0.2) {
        lastVolume = 3;
    }else if (lowPassResults <= 0.267) {
        lastVolume = 4;
    }else if (lowPassResults <= 0.33) {
        lastVolume = 5;
    }else if (lowPassResults <= 0.4) {
        lastVolume = 6;
    }else if (lowPassResults <= 0.52) {
        lastVolume = 7;
    }else if (lowPassResults <= 0.64) {
        lastVolume = 8;
    }else if (lowPassResults <= 0.76) {
        lastVolume = 9;
    }else if (lowPassResults <= 0.88) {
        lastVolume = 10;
    }else{
        lastVolume = 11;
    }
    //ISMLog(@"lastVolume = %d",lastVolume);
    if (audioLevelBlock) {
        audioLevelBlock(lastVolume);
    }
}

@end
