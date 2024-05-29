#import "FrtcScanQRManager.h"
#import <Photos/PHPhotoLibrary.h>
#import "UIViewController+Extensions.h"
#import <AVFoundation/AVFoundation.h>

@implementation FrtcScanQRManager

+ (void)f_checkCameraAuthorizationStatusWithGrand:(void(^)(BOOL granted))permissionGranted {
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (videoAuthStatus) {
        case AVAuthorizationStatusAuthorized:
        {
            permissionGranted(YES);
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                permissionGranted(granted);
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            [[FrtcHelpers getCurrentVC] showAlertWithTitle:@"" message:NSLocalizedString(@"CameraUsageDescription", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
                }
            }];
            permissionGranted(NO);
        }
            break;
        default:
            break;
    }
}


+ (void)f_checkAlbumAuthorizationStatusWithGrand:(void(^)(BOOL granted))permissionGranted {
    
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthStatus) {
        case PHAuthorizationStatusAuthorized:
        {
            permissionGranted(YES);
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                permissionGranted(status == PHAuthorizationStatusAuthorized);
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            [[FrtcHelpers getCurrentVC] showAlertWithTitle:@"" message:NSLocalizedString(@"PhotoLibraryUsageDescription", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
                }
            }];
            permissionGranted(NO);
        }
            break;
        default:
            break;
    }
}

+ (void)f_FlashlightOn:(BOOL)on {
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch] && [captureDevice hasFlash]) {
        [captureDevice lockForConfiguration:nil];
        if (on) {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
        }else
        {
            [captureDevice setTorchMode:AVCaptureTorchModeOff];
        }
        [captureDevice unlockForConfiguration];
    }
    
}


@end
