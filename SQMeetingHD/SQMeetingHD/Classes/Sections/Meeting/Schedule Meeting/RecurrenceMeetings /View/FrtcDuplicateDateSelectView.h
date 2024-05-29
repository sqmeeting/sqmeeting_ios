#import <UIKit/UIKit.h>
#import "FrtcScheduleMeetingModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kDuplicateDateWidth ((kIPAD_WIDTH - 18*7) / 7)

typedef enum : NSUInteger {
    FDuplicateNone,
    FDuplicateWeek,
    FDuplicateMonth,
} FDuplicateType;


@protocol FrtcDuplicateDateSelectViewDelegate <NSObject>

@optional

@required

- (void)didDuplicateDateSelectResult:(NSArray <NSString *> *)resultList type:(FDuplicateType)type;

@end

@interface FrtcDuplicateDateSelectView : UIView

@property (nonatomic, weak) id<FrtcDuplicateDateSelectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                duplicateType:(FDuplicateType)duplicateType
                        model:(FRecurrentMeetingResutModel *)editSettingModel
                  defaultDate:(NSString *)defaultDate; //默认时间不可修改不可取消

@end

NS_ASSUME_NONNULL_END
