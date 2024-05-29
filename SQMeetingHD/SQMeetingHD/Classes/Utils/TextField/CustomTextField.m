#import "CustomTextField.h"

@implementation CustomTextField

- (void)deleteBackward
{
    if ([self.text length] == 0) {
        if ([self.custom_delegate respondsToSelector:@selector(customTextFieldDeleteBackward:)]) {
            [self.custom_delegate customTextFieldDeleteBackward:self];
        }
    }
    [super deleteBackward];
}

@end
