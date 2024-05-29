#import <UIKit/UIKit.h>
@class FHomeMeetingListModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^FShareMeetingMaskCallBack)(NSInteger index);

@interface FrtcShareMeetingMaskView : UIView

+ (void)showShareView:(FHomeMeetingListModel *)meetingInfo
    didSelectCallBack:(FShareMeetingMaskCallBack)callBack;

+ (void)disMissView;

@end

NS_ASSUME_NONNULL_END
