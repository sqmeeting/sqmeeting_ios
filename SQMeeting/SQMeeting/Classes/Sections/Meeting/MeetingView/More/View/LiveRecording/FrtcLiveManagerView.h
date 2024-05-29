#import <UIKit/UIKit.h>
#import "FrtcLiveItemMaskView.h"

@class FrtcLiveTipsMaskView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrtcLiveManagerViewShareCallBack)(void);

@interface FrtcLiveManagerView : UIView

@property (nonatomic, strong) FrtcLiveItemMaskView *liveView;
@property (nonatomic, strong) FrtcLiveItemMaskView *recordView;
@property (nonatomic, copy)   FrtcLiveManagerViewShareCallBack sharLiveUrlBlock;

@property (nonatomic, strong) NSString *meetingNumber;

@end

NS_ASSUME_NONNULL_END
