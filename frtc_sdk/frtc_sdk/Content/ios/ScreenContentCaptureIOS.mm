#import "ScreenContentCaptureIOS.h"

@interface ScreenContentCaptureIOS () {
    bool _isSharing;
}

@property (nonatomic, strong) RPSystemBroadcastPickerView* broadPickerView;
@property (nonatomic, weak)  UIView* parentView;
@end

@implementation ScreenContentCaptureIOS

- (instancetype)init {
    self = [super init];
    _isSharing = false;
    
    return  self;

}

- (void)onContentBufferReady:(void*_Nonnull) buffer width:(size_t) width height:(size_t)height pixFormmat:(OSType)pixFormmat roration:(size_t)roration{
    if ([self.delegate respondsToSelector:@selector(outputContentBuffer:length:width:height:type:mediaID:roration:)]) {
        if(pixFormmat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            [self.delegate outputContentBuffer:buffer length:(int)(width * height * 3 / 2) width:(int)width height:(int)height type:RTC::kI420 mediaID:self.mediaID roration:(int)roration];
        }
    }
}

- (BOOL)startContentSharing {
    return true;
}

- (void)stopContentSharing {
}

- (void)setBufOutputDelegate: (id<ContentCaptureOutputBufferDelegate> _Nullable)  delegate {
    _delegate = delegate;
}

- (void)setMediaID:(NSString *)mediaID {
    _mediaID = mediaID;
}

- (NSString *)getMediaID {
    return self.mediaID;
}


@end
