#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FrtcRtcsdkExtention.h"
#import "ObjectInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ContentCaptureOutputBufferDelegate <NSObject>

- (void)outputContentBuffer:(void * _Nonnull)buffer length:(int)length width:(int)width height:(int)height type:(RTC::VideoColorFormat)type mediaID:(NSString *)mediaID roration:(int )roration;

@end

@protocol ContentCapture<NSObject>

- (BOOL)startContentSharing;

- (void)stopContentSharing;

- (void)setBufOutputDelegate:(id<ContentCaptureOutputBufferDelegate> _Nullable)  delegate;

- (void)setMediaID:(NSString *)mediaID;

- (NSString *)getMediaID;

- (void)onContentBufferReady:(void*_Nonnull) buffer width:(size_t) width height:(size_t)height pixFormmat:(OSType)pixFormmat roration:(size_t )roration;

@end

@interface ContentCaptureAdaper:NSObject

@property (nonatomic, strong) ScreenCaptureCallBack screenCaptureCB;
 
+(ContentCaptureAdaper *)SingletonInstance;

- (instancetype)init;

- (void)setMediaID:(NSString *)mediaID;

- (NSString *)getMediaID;

- (void)setDelegate:(id<ContentCaptureOutputBufferDelegate>) delegate;

- (BOOL)startContentSharing;

- (void)stopContentSharing;

- (void)onContentBufferReady:(void*_Nonnull)buffer width:(size_t)width height:(size_t)height pixFormmat:(OSType)pixFormmat roration:(size_t )roration;

@end

NS_ASSUME_NONNULL_END
