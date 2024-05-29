#import "UILabel+LineSpacing.h"

@implementation UILabel (LineSpacing)

- (void)setLineSpacing:(CGFloat)lineSpacing {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;

    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    
    self.attributedText = attributedString;
}

@end
