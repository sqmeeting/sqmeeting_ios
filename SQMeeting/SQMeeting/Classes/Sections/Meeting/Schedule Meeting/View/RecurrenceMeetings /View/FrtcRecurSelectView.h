#import <UIKit/UIKit.h>
#import "FrtcScheduleMeetingModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcRecurSelectViewDelegate <NSObject>

@required

- (void)didRecurSelectResult:(FRecurrenceType)type value:(NSString *)value;

@optional

@end

@interface FrtcRecurSelectView : UIView

- (instancetype)initWithRecurrentMeetingModel:(FRecurrentMeetingResutModel *)editSettingModel tyle:(FRecurrenceType)tyle;

@property (nonatomic, weak) id<FrtcRecurSelectViewDelegate>delegate;
@property (nonatomic, strong) UILabel *heaer_duplicateLabel;

@end

NS_ASSUME_NONNULL_END
