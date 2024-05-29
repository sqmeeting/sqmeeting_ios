#import "NSObject+AlertView.h"
#import "FrtcCAlertView.h"

@implementation NSObject (AlertView)

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                   buttons:(NSArray *)buttons
                 doneBlock:(void(^)(void))doneBlock {
    
    FrtcCAlertView *alertView = [[FrtcCAlertView alloc]init];
    [alertView showAlertWithTitle:title
                     withSubtitle:message
                  withCustomImage:nil
              withDoneButtonTitle:NSLocalizedString(@"string_ok", nil)
                       andButtons:buttons];
    alertView.doneBlock = ^{
        doneBlock();
    };
}

- (void)showTextFieldWithTitle:(NSString *)title
                   placeholder:(NSString *)placeholder
                       buttons:(NSArray *)buttons
                textFieldBlock:(void(^)(NSString *text))textBlock
                     doneBlock:(void(^)(void))doneBlock {
    
    FrtcCAlertView *alertView = [[FrtcCAlertView alloc]init];
    [alertView showAlertWithTitle:title
                     withSubtitle:nil
                  withCustomImage:nil
              withDoneButtonTitle:NSLocalizedString(@"string_ok", nil)
                       andButtons:buttons];
    [alertView addTextFieldWithText:placeholder
                 andTextReturnBlock:^(NSString *text) {
        textBlock(text);
    }];
    alertView.doneBlock = ^{
        doneBlock();
    };
}

@end
