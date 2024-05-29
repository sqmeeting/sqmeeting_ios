#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import "ContentCaptureAdaper.h"
NS_ASSUME_NONNULL_BEGIN

@interface ScreenContentCaptureIOS : NSObject<ContentCapture>

@property (nonatomic, weak) id<ContentCaptureOutputBufferDelegate> delegate;
@property (nonatomic) NSString *mediaID;

- (instancetype) init;
@end

NS_ASSUME_NONNULL_END
