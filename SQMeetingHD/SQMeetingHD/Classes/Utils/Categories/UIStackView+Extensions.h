#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIStackView (Extensions)

- (void)addArrangedSubviews:(NSArray <UIView *> *)views;

- (void)removeArrangedSubviews;

- (void)setCustomSpacing:(CGFloat)spacing afterViews:(NSArray <UIView *> *)arrangedSubviews;

@end

NS_ASSUME_NONNULL_END
