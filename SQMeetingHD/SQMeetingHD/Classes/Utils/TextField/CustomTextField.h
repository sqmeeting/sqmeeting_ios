#import <UIKit/UIKit.h>

@class CustomTextField;
@protocol CustomTextFieldDeleteDelegate <NSObject>

- (void)customTextFieldDeleteBackward:(CustomTextField *)textField;

@end

@interface CustomTextField : UITextField

@property (nonatomic,weak)id <CustomTextFieldDeleteDelegate>custom_delegate;

@end
