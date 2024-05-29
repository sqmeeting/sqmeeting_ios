#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DatePickerHeaderBlock) (BOOL index); //0 cancel

@interface FrtcScheduleDatePickerHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) DatePickerHeaderBlock dateHeaderViewBlock;

@end

NS_ASSUME_NONNULL_END
