#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ObjectInterface.h"

typedef NS_ENUM(NSInteger,  RESOLUTION_PRESET) {
    RESOLUTION_PRESET_SUPER_HIGH,
    RESOLUTION_PRESET_HIGH,
    RESOLUTION_PRESET_MEDIUM,
    RESOLUTION_PRESET_LOW
};

@protocol CaptureCameraStreamDelegate <NSObject>

- (void)outputVideoBuffer:(void *)buffer mirrorBuffer:(void *)buffer_mirror length:(int)length width:(int)width height:(int)height type:(RTC::VideoColorFormat)type mediaID:(NSString *)mediaID;

@end

@interface CaptureCameraStream :NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, copy) NSString *mediaID;

@property (nonatomic, assign, getter=isStartingVideoCapture) BOOL startingVideoCapture;

@property (nonatomic, weak) id <CaptureCameraStreamDelegate>  delegate;

@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePostion;

+ (CaptureCameraStream *)SingletonInstance;

- (BOOL)configVideoSession;

- (void)removeVideoSession;

- (BOOL)selectVideoDeviceByPostion;

- (void)resetDefaultVideoDevicePostion;

- (BOOL)stopVideoCameraCapture;

- (void)configCaptureConnectionOrientation:(AVCaptureVideoOrientation)orient;

- (void)captureSessionStartRunning;

- (void)captureSessionStopRunning;

@end
