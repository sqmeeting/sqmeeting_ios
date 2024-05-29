#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FMeetingReminderInfo)(NSString *info);

@interface FrtcMeetingReminderView : UIView

@property (nonatomic, strong) NSArray <NSDictionary *> *notificationList;

- (void)show;
- (void)disMiss;

@end

NS_ASSUME_NONNULL_END
