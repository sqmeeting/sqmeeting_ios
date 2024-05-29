#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UITextField+Extensions.h"
#import "UIAlertController+Extensions.h"

#define KContentViewWidth 250

@implementation UIViewController (Extensions)

- (void)showSheetWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray <NSString *> *)buttonTitles  alerAction:(void (^)(NSInteger index))alerAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kStringIsEmpty(title) ? nil : title
                                                                             message:kStringIsEmpty(message) ? nil : message
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < buttonTitles.count; i++) {
        NSString *btnTitle = buttonTitles[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (alerAction) {
                alerAction(i);
            }
        }];
        
        if ([btnTitle isEqualToString:NSLocalizedString(@"recurrence_cacaleRecurringMeeting", nil)] ||
            [btnTitle isEqualToString:FLocalized(@"meeting_yes", nil)] ||
            [btnTitle isEqualToString:FLocalized(@"meeting_add_removeRecurrence", nil)]) {
            [action setValue:UIColor.redColor forKey:@"_titleTextColor"];
        }
        
        [alertController addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"dialog_cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
    }];
    [cancelAction setValue:KTextColor666666 forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray <NSString *> *)buttonTitles alerAction:(void (^)(NSInteger index))alerAction {
    
    message = [NSString stringWithFormat:@"\n%@",message];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle: UIAlertControllerStyleAlert];
    
    for (NSInteger i = 0; i < buttonTitles.count; i++) {
        NSString *btnTitle = buttonTitles[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (alerAction) {
                alerAction(i);
            }
        }];
        if ([btnTitle isEqualToString:NSLocalizedString(@"dialog_cancel", nil)] ||
            [btnTitle isEqualToString:NSLocalizedString(@"MEETING_REQUESTUNMUTE_OK_CANCLE", nil)] ||
            [btnTitle isEqualToString:NSLocalizedString(@"meeting_thinhAgain", nil)]) {
            [action setValue:KTextColor666666 forKey:@"_titleTextColor"];
        }
        
        if ([btnTitle isEqualToString:NSLocalizedString(@"meeting_stop_record", nil)] ||
            [btnTitle isEqualToString:NSLocalizedString(@"meeting_stop_live", nil)] ||
            [btnTitle isEqualToString:FLocalized(@"meeting_yes", nil)] ||
            [btnTitle isEqualToString:FLocalized(@"meeting_add_removeRecurrence", nil)]) {
            [action setValue:UIColor.redColor forKey:@"_titleTextColor"];
        }
        
        [alertController addAction:action];
    }
    
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KTextColor666666 range:NSMakeRange(0, message.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.f] range:NSMakeRange(0, message.length)];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:true completion:nil];
    }else{
        [self dismissViewControllerAnimated:false completion:nil];
        [self presentViewController:alertController animated:true completion:nil];
    }
}

- (void)showTextFieldAlertWithTitle:(NSString *)title
                     textFieldStyle:(FTextFieldStyle)style
                         alerAction:(void (^)(NSInteger index, NSString * alertString))alerAction {
    [self showTextFieldAlertWithTitle:title textFieldStyle:style placeholder:@"" alerAction:alerAction];
}

- (void)showTextFieldAlertWithTitle:(NSString *)title
                     textFieldStyle:(FTextFieldStyle)style
                        placeholder:(NSString *)placeholder
                         alerAction:(void (^)(NSInteger index, NSString * alertString))alerAction {
    
    NSString *alertactionStr = @"";
    switch (style) {
        case FTextFieldPassword:
            alertactionStr = NSLocalizedString(@"call_join", nil);
            break;
        case FTextFieldRenamed:
            alertactionStr = NSLocalizedString(@"string_ok", nil);
            break;
        default:
            break;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"dialog_cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        alerAction(0,@"");
    }];
    [cancelAction setValue:KTextColor666666 forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:alertactionStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * tf1 = alertController.textFields[0];
        alerAction(1,tf1.text);
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont systemFontOfSize:15.f];
        switch (style) {
            case FTextFieldPassword:
            {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.placeholder = NSLocalizedString(@"ple_meeting_psd", nil);
                textField.secureTextEntry = YES;
            }
                break;
            case FTextFieldRenamed:
            {
                textField.fLengthLimit = 48;
                textField.text = placeholder;
            }
            default:
                break;
        }
    }];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:true completion:nil];
    }else{
        [self dismissViewControllerAnimated:false completion:nil];
        [self presentViewController:alertController animated:true completion:nil];
    }
}

- (void)showRadioViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelTitles:(NSArray <NSString *> *)cancelTitles
                    alerAction:(void (^)(NSInteger index, bool isSelect))alerAction {
    
    __block BOOL select = NO;
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"meeting_live_password_unsel"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"meeting_live_password_sel"] forState:UIControlStateSelected];
    [button setTitle:message forState:UIControlStateNormal];
    [button setTitleColor:KTextColor666666 forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    __block UIButton *copySelectBtn = button;
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        copySelectBtn.selected = !copySelectBtn.selected;
        select = copySelectBtn.isSelected;
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title customView:button viewSize:CGSizeMake(250, 25) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:FLocalized(@"meeting_thinhAgain", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        alerAction(0,0);
    }];
    [action1 setValue:KTextColor666666 forKey:@"_titleTextColor"];
    [alertController addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:FLocalized(@"meeting_yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        alerAction(1,select);
    }];
    [action2 setValue:UIColor.redColor forKey:@"_titleTextColor"];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPasswordAlertViewWithAlerAction:(void (^)(NSInteger index, BOOL isSelect))alerAction {
    
    __block BOOL select = YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"dialog_cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        alerAction(0,0);
    }];
    [cancelAction setValue:KTextColor666666 forKey:@"_titleTextColor"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"FM_VIDEO_START_STREAMING_BUTTON_TITLE", @"Start Live") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        alerAction(1,select);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    UIView *view = [self getContentViewWithBlock:^(BOOL selected) {
        select = !selected;
    }];
    view.frame = CGRectMake(30, 20, 240, 150);
    [alertController.view addSubview:view];
    
    NSLayoutConstraint *heigth = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:230]; // + 90
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:300];
    
    [alertController.view addConstraint:heigth];
    
    [alertController.view addConstraint:width];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


- (UIView *)getContentViewWithBlock:(void(^)(BOOL selected))block {
    
    UIView *contentView = [[UIView alloc]init];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(0, 0, KContentViewWidth, 30);
    titleLabel.text = NSLocalizedString(@"FM_VIDEO_START_STREAMING", @"Start live Stream？");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = KTextColor;
    //titleLabel.backgroundColor = UIColor.redColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    [contentView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.frame = CGRectMake(0, 35, KContentViewWidth, 65);
    messageLabel.text = NSLocalizedString(@"FM_VIDEO_START_STREAMING_MESSAGE", @"It will live meeting audio, video and shared screen, and inform all members.");
    messageLabel.textColor = KTextColor666666;
    messageLabel.numberOfLines = 0;
    //messageLabel.backgroundColor = UIColor.blueColor;
    messageLabel.font = [UIFont systemFontOfSize:14.f];
    [contentView addSubview:messageLabel];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectBtn setImage:[UIImage imageNamed:@"meeting_live_password_sel"] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"meeting_live_password_unsel"] forState:UIControlStateSelected];
    [selectBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    selectBtn.frame = CGRectMake(0, 105, KContentViewWidth, 20);
    [selectBtn setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"FM_VIDEO_STREAMING_PASSWORD_BUTTON_TITLE", @"Password protection")] forState:UIControlStateNormal];
    [selectBtn setTitleColor:KTextColor forState:UIControlStateNormal];
    selectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    __block UIButton *copySelectBtn = selectBtn;
    [selectBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        copySelectBtn.selected = !copySelectBtn.selected;
        block(copySelectBtn.selected);
    }];
    [contentView addSubview:selectBtn];
    
    UILabel *desLabel = [[UILabel alloc]init];
    desLabel.frame = CGRectMake(0, 130, KContentViewWidth, 25);
    desLabel.text = NSLocalizedString(@"FM_VIDEO_STREAMING_PASSWORD_DESCRIPTION", @"It will make your live streaming safer");
    desLabel.textColor = KDetailTextColor;
    desLabel.font = [UIFont systemFontOfSize:12.f];
    [contentView addSubview:desLabel]; //140
    
    return contentView;
}

- (void)performSelectorOnMainThread:(void(^)(void))block {
    if ([[NSThread currentThread] isMainThread]) {
        block();
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)dismissViewControllerWithCount:(NSInteger)count animated:(BOOL)animated {
    
    count--;
    if (count>0 && self.presentingViewController) {
        [self.presentingViewController dismissViewControllerWithCount:count animated:animated];
    }
    else{
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)dismissToViewControllerWithClassName:(NSString *)className animated:(BOOL)animated {
    if (![self.class isKindOfClass:NSClassFromString(className)] && self.presentingViewController) {
        [self.presentingViewController dismissToViewControllerWithClassName:className animated:animated];
    }else{
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

@end
