#import "FrtcPortraitView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SendOverlayMessageViewBlock) (void);

@interface FrtcSendOverlayMessageView : FrtcPortraitView

+ (void)showSendOverlayMessageView:(NSString *)meetingNumber
               overlayMessageBlock:(SendOverlayMessageViewBlock)overlayMessageBlock;

- (void)stopOverlayMessage:(NSString *)meetingNumber;

@end

NS_ASSUME_NONNULL_END
