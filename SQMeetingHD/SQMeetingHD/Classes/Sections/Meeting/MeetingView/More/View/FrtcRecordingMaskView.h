#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrtcRecordingMaskViewDismissViewBlock) (void);

@interface FrtcRecordingMaskView : UIView

@property (nonatomic, copy) FrtcRecordingMaskViewDismissViewBlock dismissViewBlock;

@end

NS_ASSUME_NONNULL_END
