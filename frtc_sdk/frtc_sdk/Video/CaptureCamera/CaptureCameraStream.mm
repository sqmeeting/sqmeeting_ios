#import "CaptureCameraStream.h"
#import "ObjectInterface.h"
#import "FrtcUIMacro.h"
#import <UIKit/UIKit.h>
#include "video_transfer.h"

@interface CaptureCameraStream ()

//@property (nonatomic, strong) dispatch_queue_t         videoQueue;
@property (nonatomic, strong) AVCaptureDevice          *captureVideoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput     *captureVideoDeviceDataInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDeviceDataOutput;
@property (nonatomic, strong) AVCaptureSession         *captureSession;

@property (nonatomic, assign) uint8_t *buffer;
@property (nonatomic, assign) size_t bufferSize;
@property (nonatomic, assign) uint8_t *mirrorBuffer;

@end

@implementation CaptureCameraStream

+ (CaptureCameraStream *)SingletonInstance {
    static CaptureCameraStream *sharedInstance = nil;
    static dispatch_once_t once_taken = 0;
    dispatch_once(&once_taken, ^{
        sharedInstance = [[CaptureCameraStream alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mediaID = @"VPL_PREVIEW";
        self.captureSession = nil;
        self.captureVideoDeviceDataInput = nil;
        self.captureVideoDeviceDataOutput = nil;
        self.captureVideoDevice = nil;
        self.captureDevicePostion = AVCaptureDevicePositionFront;
        if (ISIPAD) {
            self.bufferSize = kMaxVidePixels;
        }else{
            self.bufferSize = (1280 * 720 * 3 / 2);
        }
        self.buffer = (uint8_t *)malloc(self.bufferSize);
        self.mirrorBuffer = (uint8_t *)malloc(self.bufferSize);
    }
    return self;
}

- (void)dealloc {
    if (self.buffer) {
        free(self.buffer);
    }
    if (self.mirrorBuffer) {
        free(self.mirrorBuffer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (AVCaptureDevice *)captureDeviceByCameraPostion:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                                                                                            mediaType:AVMediaTypeVideo
                                                                                                                             position:AVCaptureDevicePositionUnspecified];
    NSArray *captureDevices = [captureDeviceDiscoverySession devices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)configCaptureConnectionOrientation:(AVCaptureVideoOrientation)orientation {
    AVCaptureConnection *videoOutConn = [self.captureVideoDeviceDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoOutConn setVideoOrientation:orientation];
}

- (BOOL)configVideoSession {
    self.startingVideoCapture = YES;
    NSError *error = nil;
    self.captureVideoDevice = [self captureDeviceByCameraPostion:self.captureDevicePostion];
    self.captureVideoDeviceDataInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureVideoDevice error:&error];
    if (self.captureVideoDeviceDataInput == nil) {
        return NO;
    }

    self.captureVideoDeviceDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    [self.captureVideoDeviceDataOutput setVideoSettings:videoSettings];

    dispatch_queue_t sampleBufferCallbackQueue = dispatch_queue_create("com.frtc.sdk", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_set_target_queue(sampleBufferCallbackQueue, priority);
    [self.captureVideoDeviceDataOutput setSampleBufferDelegate:self queue:sampleBufferCallbackQueue];

    //self.videoQueue = dispatch_queue_create("frtc.videoQueue", NULL);
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    [self.captureSession addOutput:self.captureVideoDeviceDataOutput];
    [self.captureSession addInput:self.captureVideoDeviceDataInput];

    AVCaptureConnection *videoCaptureConnection = [self.captureVideoDeviceDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([videoCaptureConnection isVideoOrientationSupported]) {
        [videoCaptureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }

    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeObserver:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self configCaptureOrientation];
    });

    if (self.captureDevicePostion == AVCaptureDevicePositionFront) {
        videoCaptureConnection.videoMirrored = YES;
    }
    
    int32_t frameRate = 24;
    self.captureVideoDevice.activeVideoMinFrameDuration = CMTimeMake(1, frameRate);
    [self.captureSession commitConfiguration];

    //dispatch_async(self.videoQueue, ^{
    [self.captureSession startRunning];
    //});

    NSString *model = [UIDevice currentDevice].model;
    NSString *cameraCapbility;
    if ([model isEqualToString:@"iPad"] && [self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        cameraCapbility = @"1080p30";
        [self updateResolutionPreset:RESOLUTION_PRESET_SUPER_HIGH frameRates:frameRate];
    } else {
        cameraCapbility = @"720p30";
        [self updateResolutionPreset:RESOLUTION_PRESET_HIGH frameRates:frameRate];
    }

    if ([model isEqualToString:@"iPad"]) {
        [[ObjectInterface sharedObjectInterface] setCameraCapabilityObject:[cameraCapbility UTF8String]];
    }

    return YES;
}

- (void)removeVideoSession {
    if (self.captureSession.isRunning) {
        //dispatch_async(self.videoQueue, ^{
        [self.captureSession stopRunning];
        //});
    }
    [self.captureVideoDeviceDataOutput setSampleBufferDelegate:nil queue:NULL];
    [self.captureSession removeInput:self.captureVideoDeviceDataInput];
    [self.captureSession removeOutput:self.captureVideoDeviceDataOutput];
    self.captureSession = nil;
    self.captureVideoDeviceDataInput = nil;
    self.captureVideoDeviceDataOutput = nil;
    self.captureVideoDevice = nil;
}

- (void)captureSessionStartRunning {
    if (self.captureVideoDevice == nil) {
        if (![self configVideoSession]) {
            return;
        }
    } else {
        //dispatch_async(self.videoQueue, ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
        //});
    }
}

- (void)captureSessionStopRunning {
    if ([self.captureSession isRunning]) {
        //dispatch_async(self.videoQueue, ^{
        [self.captureSession stopRunning];
        //});
    }
}

- (BOOL)updateResolutionPreset:(RESOLUTION_PRESET)resolutionPreset frameRates:(int32_t)frameRate {
    if (!self.captureVideoDevice) {
        return NO;
    }
    if ([self.captureVideoDevice supportsAVCaptureSessionPreset:[self.captureSession sessionPreset]]) {
        if (resolutionPreset == RESOLUTION_PRESET_SUPER_HIGH) {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
        } else if (resolutionPreset == RESOLUTION_PRESET_HIGH) {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
        } else if (resolutionPreset == RESOLUTION_PRESET_MEDIUM) {
            [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        } else if (resolutionPreset == RESOLUTION_PRESET_LOW) {
            [self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
        }
    }
    if ([self.captureVideoDevice lockForConfiguration:NULL]) {
        [self.captureVideoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, frameRate)];
        [self.captureVideoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, frameRate)];
    }
    return YES;
}

- (void)resetDefaultVideoDevicePostion {
    if (self) {
        self.captureDevicePostion = AVCaptureDevicePositionFront;
    }
}

- (BOOL)selectVideoDeviceByPostion {
    if (self.captureDevicePostion == AVCaptureDevicePositionBack) {
        self.captureDevicePostion = AVCaptureDevicePositionFront;
    } else {
        self.captureDevicePostion = AVCaptureDevicePositionBack;
    }

    [self removeVideoSession];
    if ([self configVideoSession]) {
        [self captureSessionStartRunning];
    }
    return YES;
}

- (BOOL)stopVideoCameraCapture {
    BOOL flag = NO;
    do {
        if (nil == self.captureSession) {
            break;
        }
        if (nil == self.captureVideoDeviceDataInput) {
            break;
        }
        if (nil == self.captureVideoDeviceDataOutput) {
            break;
        }
        flag = YES;
    } while (0);
    
    if (!flag) {
        return NO;
    }
    [self.captureVideoDeviceDataOutput setSampleBufferDelegate:nil queue:NULL];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [strongSelf stopSession];
        });
    });
    return YES;
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        //dispatch_async(self.videoQueue, ^{
        [self.captureSession stopRunning];
        //});
    }
    if (self.captureVideoDeviceDataOutput != nil) {
        [self.captureSession removeOutput:self.captureVideoDeviceDataOutput];
        self.captureVideoDeviceDataOutput = nil;
    }
    if (self.captureVideoDeviceDataInput != nil) {
        [self.captureSession removeInput:self.captureVideoDeviceDataInput];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CaptureCameraStream <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        size_t y_bytes_per_row = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        size_t uv_bytes_per_row = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
        uint8_t *base_address_of_plane = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        int width = (int)CVPixelBufferGetWidth(imageBuffer);
        int height = (int)CVPixelBufferGetHeight(imageBuffer);
        
        uint8_t *uv_offset_buffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
        
        if (width * height * 3 / 2 > self.bufferSize) {
            self.bufferSize = width * height * 3 / 2;
            self.buffer = (uint8_t *)realloc(self.buffer, self.bufferSize);
            self.mirrorBuffer = (uint8_t *)realloc(self.mirrorBuffer, self.bufferSize);
        }
        
        nv12_to_i420(base_address_of_plane, y_bytes_per_row, uv_offset_buffer, uv_bytes_per_row, width, height, self.buffer);
        
        if (self.captureDevicePostion == AVCaptureDevicePositionFront) {
            i420_mirror(self.buffer, self.mirrorBuffer, width, height);
            
            if (self.mediaID) {
                if ([self.delegate respondsToSelector:@selector(outputVideoBuffer:mirrorBuffer:length:width:height:type:mediaID:)]) {
                    [self.delegate outputVideoBuffer:self.buffer mirrorBuffer:self.mirrorBuffer length:width * height * 3 / 2 width:width height:height type:RTC::kI420 mediaID:self.mediaID];
                }
            }
        } else {
            if (self.mediaID) {
                if ([self.delegate respondsToSelector:@selector(outputVideoBuffer:mirrorBuffer:length:width:height:type:mediaID:)]) {
                    [self.delegate outputVideoBuffer:self.buffer mirrorBuffer:self.buffer length:width * height * 3 / 2 width:width height:height type:RTC::kI420 mediaID:self.mediaID];
                }
            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
}


- (void)deviceOrientationDidChangeObserver:(NSNotification *)notification {
    [self configCaptureOrientation];
}

- (void)configCaptureOrientation {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            [self configCaptureConnectionOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self configCaptureConnectionOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

@end

