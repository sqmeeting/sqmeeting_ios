#import "FrtcPortraitView.h"

@class FHomeMeetingListModel;
@class FrtcLiveStatusModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrtcShareLiveUrlMaskViewCallBack)(void);

@interface FrtcShareLiveUrlMaskView : FrtcPortraitView

+ (void)showShareLiveView:(FHomeMeetingListModel *)meetingInfo
           liveStatusInfo:(FrtcLiveStatusModel *)liveStatusInfo
        didSelectCallBack:(FrtcShareLiveUrlMaskViewCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
