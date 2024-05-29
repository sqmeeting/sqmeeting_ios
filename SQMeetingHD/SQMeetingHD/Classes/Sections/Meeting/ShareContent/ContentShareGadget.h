#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ContentShareGadget : NSObject

+(instancetype) sharedInstance;

- (void)startScreenSharing:(BOOL)isSharing;

- (void)startRecordScreenSharing:(BOOL)isSharing;

- (void)startSendContentStream;

@end

NS_ASSUME_NONNULL_END
