#import "UIView+Add.h"

@implementation UIView (Add)

- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
    if (self.bounds.size.width == 0) { return; }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(value, value)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}


@end
