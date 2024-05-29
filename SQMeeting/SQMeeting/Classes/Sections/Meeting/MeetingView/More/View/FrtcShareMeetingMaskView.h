#import "FrtcPortraitView.h"
@class FHomeMeetingListModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^FShareMeetingMaskCallBack)(NSInteger index);

@interface FrtcShareMeetingMaskView : FrtcPortraitView

+ (void)showShareView:(FHomeMeetingListModel *)meetingInfo
    didSelectCallBack:(FShareMeetingMaskCallBack)callBack;

+ (void)disMissView;

@end

NS_ASSUME_NONNULL_END
