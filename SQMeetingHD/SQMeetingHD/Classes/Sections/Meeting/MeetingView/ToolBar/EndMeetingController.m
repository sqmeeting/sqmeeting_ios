#import "EndMeetingController.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import "FrtcCall.h"
#import "UIButton+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIViewController+Extensions.h"

@interface EndMeetingController ()

@property (nonatomic, strong) UIButton *leaveButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *hangUpButton;

@end

@implementation EndMeetingController

- (CGFloat)getScreenLandscapeWidth {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width > size.height ? size.width : size.height;
}

- (CGFloat)getScreenLandscapeHeight {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.height > size.width ? size.width : size.height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    [self configView];
    
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)configView {
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = 20;
    [self.view addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    if (self.isMeetingOperator) {
        [stackView addArrangedSubviews:@[self.leaveButton,self.hangUpButton,self.cancelButton]];
        self.leaveButton.backgroundColor = KTextColor;
        [stackView setCustomSpacing:40 afterView:self.hangUpButton];
        [self.hangUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(320, 50));
        }];
    }else{
        [stackView addArrangedSubviews:@[self.leaveButton,self.cancelButton]];
        self.leaveButton.backgroundColor = UIColorHex(0xe32726);
        [stackView setCustomSpacing:40 afterView:self.leaveButton];
    }
    
    [self.leaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(320, 50));
    }];
}

#pragma mark -- private function
- (void)cancelButton:(UIButton*)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- private function
- (void)onClickHangUp:(UIButton*)sender {
    self.view.backgroundColor = [UIColor clearColor];
    [self.hangUpButton removeFromSuperview];
    [self.leaveButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self showAlertWithTitle:NSLocalizedString(@"meeting_stop_title", nil) message:NSLocalizedString(@"meeting_stop_message", nil) buttonTitles:@[NSLocalizedString(@"call_cancel", nil),NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
        if (index == 1) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(endMeetingClicked:)]) {
                [self.delegate endMeetingClicked:YES];
            }
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark -- lazy load

- (UIButton *)hangUpButton {
    if(!_hangUpButton) {
        _hangUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangUpButton setTitle:NSLocalizedString(@"meeting_dismiss", nil) forState:UIControlStateNormal];
        [_hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hangUpButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        _hangUpButton.layer.cornerRadius = KCornerRadius;
        _hangUpButton.backgroundColor = UIColorHex(0xe32726);
        [_hangUpButton addTarget:self action:@selector(onClickHangUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _hangUpButton;
}

- (UIButton *)leaveButton {
    if(!_leaveButton) {
        @WeakObj(self);
        _leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leaveButton setTitle:NSLocalizedString(@"meeting_leave", nil) forState:UIControlStateNormal];
        [_leaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _leaveButton.backgroundColor = KTextColor;
        _leaveButton.layer.cornerRadius = KCornerRadius;
        _leaveButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [_leaveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if(self.delegate && [self.delegate respondsToSelector:@selector(endMeetingClicked:)]) {
                [self.delegate endMeetingClicked:NO];
            }
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
    
    return _leaveButton;
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"meeting_cancle"] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];;
        [_cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setImageLayout:UIButtonLayoutImageTop space:8];
        _cancelButton.isSizeToFit = true;
    }
    
    return _cancelButton;
}

@end










