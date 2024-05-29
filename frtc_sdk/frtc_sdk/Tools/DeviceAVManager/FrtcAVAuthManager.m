#import "FrtcAVAuthManager.h"
#import <AVFoundation/AVFoundation.h>
#import "FrtcAlertController.h"

@implementation FrtcAVAuthManager

+ (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones]||
            [[output portType] isEqualToString:AVAudioSessionPortBluetoothLE] ||
            [[output portType] isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [[output portType] isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isInReceiverMode {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        if ([output.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark --AVAuthorizationStatus
+ (void)getAVAuthorization:(NSString *)mediaType withMeidaDescription:(NSString *)description rootView:(UIViewController *)rootView {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus ==AVAuthorizationStatusRestricted) {
    } else if(authStatus == AVAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            FrtcAlertController *alertController = [FrtcAlertController alertControllerWithTitle:@""
                                                                                   message:description
                                                                            preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Setting", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
                }
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
            [alertController addAction:cancel];
            [alertController addAction:action1];
            [rootView presentViewController:alertController animated:YES completion:nil];
        });
    } else if(authStatus == AVAuthorizationStatusAuthorized) {
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(granted) {
            } else {
            }
            
        }];
    } else {
    }
}

+ (void)setAudioSessionPortOverride:(BOOL)isSpeaker {
    if(isSpeaker) {
        NSError *error;
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [audioSession setActive:YES error:nil];
    } else {
        NSError *error;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }
}

+ (void)setAudioSessionCategoryOptions {
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    if ([self isInReceiverMode]) {
        options = AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:options error:nil];
}

@end
