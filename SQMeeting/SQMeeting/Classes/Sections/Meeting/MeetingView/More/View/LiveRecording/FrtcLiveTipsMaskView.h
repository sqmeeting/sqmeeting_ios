#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FLiveTipsStatusLive,
    FLiveTipsStatusRecording,
} FLiveTipsStatus;

@interface FrtcLiveTipsMaskView : UIView

- (void)setTipsStatus:(FLiveTipsStatus)tipsStatus;

@end

NS_ASSUME_NONNULL_END
