#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (FPlaceHolder)

@property (copy, nonatomic) NSString *placeHoldString;
@property (strong, nonatomic) UIColor *placeHoldColor;
@property (strong, nonatomic) UIFont *placeHoldFont;

@end

NS_ASSUME_NONNULL_END
