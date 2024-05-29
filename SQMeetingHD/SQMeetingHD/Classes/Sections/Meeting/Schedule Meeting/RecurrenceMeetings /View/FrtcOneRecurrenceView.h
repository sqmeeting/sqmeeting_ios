#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcOneRecurrenceView : UIView

- (instancetype)initWithFrame:(CGRect)frame isRight:(BOOL)isRight;
@property (nonatomic, copy) void(^didOneRecurrenceViewBlock)(void);
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

NS_ASSUME_NONNULL_END
