#import <UIKit/UIKit.h>
#import "FrtcLiveTipsMaskView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrtcLiveItemMaskViewStopBlock) (void);
typedef void(^FrtcLiveItemMaskViewShareBlock) (void);


@interface FrtcLiveItemMaskView : UIView

@property (nonatomic, copy) FrtcLiveItemMaskViewStopBlock stopBlock;
@property (nonatomic, copy) FrtcLiveItemMaskViewShareBlock shareBlock;

- (void)setTipsStatus:(FLiveTipsStatus)tipsStatus;

@end

NS_ASSUME_NONNULL_END
