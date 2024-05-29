#import "FrtcMoreCustomButton.h"

@implementation FrtcMoreCustomButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat titleWidth = self.titleLabel.frame.size.width;
    CGFloat titleHeight = self.titleLabel.frame.size.height;

    CGFloat totalHeight = imageHeight + titleHeight;
    self.imageEdgeInsets = UIEdgeInsetsMake(-totalHeight/2, 0, 0, -titleWidth);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, -totalHeight/2, 0);
}

@end

