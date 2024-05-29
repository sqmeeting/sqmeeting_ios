#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UIButtonLayoutType) {
    UIButtonLayoutImageLeft,
    UIButtonLayoutImageRight,
    UIButtonLayoutImageTop,
    UIButtonLayoutImageBottom,
};

@interface UIButton (Extensions)

- (void)setImageLayout:(UIButtonLayoutType)type space:(CGFloat)space;

@property (assign, nonatomic) BOOL isSizeToFit;

@end

NS_ASSUME_NONNULL_END
