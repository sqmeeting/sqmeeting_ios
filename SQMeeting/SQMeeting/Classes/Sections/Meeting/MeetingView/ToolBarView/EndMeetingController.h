#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EndMeetingControllerDelegate <NSObject>

- (void)endMeetingClicked:(BOOL)stop;

@end

@interface EndMeetingController : UIViewController

@property (nonatomic, weak) id<EndMeetingControllerDelegate> delegate;

@property (nonatomic, assign, getter=isMeetingOperator) BOOL meetingOperator;

@end

NS_ASSUME_NONNULL_END

