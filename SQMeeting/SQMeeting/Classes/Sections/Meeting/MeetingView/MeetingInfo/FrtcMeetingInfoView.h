#import <UIKit/UIKit.h>
@class FrtcMeetingInfoLeftView,FrtcMeetingNetWorkView;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingInfoView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FrtcMeetingInfoLeftView *infoLeftView;
@property (nonatomic, strong) FrtcMeetingNetWorkView *staticsView;

@end

NS_ASSUME_NONNULL_END
