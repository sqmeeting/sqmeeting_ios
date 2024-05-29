#import "UIStackView+Extensions.h"

@implementation UIStackView (Extensions)

- (void)addArrangedSubviews:(NSArray <UIView *> *)views {
    for (UIView *item in views) {
        [self addArrangedSubview:item];
    }
}

- (void)removeArrangedSubviews {
    for (UIView *item in self.arrangedSubviews) {
        [self removeArrangedSubview:item];
    }
}

- (void)setCustomSpacing:(CGFloat)spacing afterViews:(NSArray <UIView *> *)arrangedSubviews {
    for (UIView *item in arrangedSubviews) {
        [self setCustomSpacing:spacing afterView:item];
    }
}

@end
