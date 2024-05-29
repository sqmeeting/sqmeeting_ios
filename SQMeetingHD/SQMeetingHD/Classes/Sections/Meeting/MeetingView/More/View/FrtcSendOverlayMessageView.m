#import "FrtcSendOverlayMessageView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcScheduleDatePickerHeaderView.h"
#import "UIView+Extensions.h"
#import "FrtcOverlayRepeatView.h"
#import "FrtcOverlayPositionView.h"
#import "RosterPresenter.h"
#import "UIView+Toast.h"
#import "MBProgressHUD+Extensions.h"

#define KPositionViewHeight  100
#define KRepeatViewHeight    40
#define kOverlayMessageSpacing 14

static FrtcSendOverlayMessageView *sendOverlayMessageView = nil;
static SendOverlayMessageViewBlock sendOverlayMessageBlock = nil;

@interface FrtcSendOverlayMessageView () <UIGestureRecognizerDelegate,RosterViewProtocol>

@property (nonatomic, copy) NSString *meetingNumber;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FrtcScheduleDatePickerHeaderView *headerView;
@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *enableScrollLabel;
@property (nonatomic, strong) UILabel *repeatLabel;
@property (nonatomic, strong) UILabel *positionLabel;

@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UISwitch *scrollSwitch;
@property (nonatomic, strong) FrtcOverlayRepeatView *repeatView;
@property (nonatomic, strong) FrtcOverlayPositionView *positionView;
@property (nonatomic, strong) RosterPresenter *presenter;

@end

@implementation FrtcSendOverlayMessageView

+ (void)showSendOverlayMessageView:(NSString *)meetingNumber overlayMessageBlock:(SendOverlayMessageViewBlock)overlayMessageBlock {
    sendOverlayMessageView = [[FrtcSendOverlayMessageView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    sendOverlayMessageBlock = overlayMessageBlock;
    sendOverlayMessageView.meetingNumber = meetingNumber;
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    [window addSubview:sendOverlayMessageView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(LAND_SCAPE_WIDTH/2);
            make.centerX.equalTo(self);
        }];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(90);
            make.top.equalTo(self.headerView.mas_bottom).offset(KLeftSpacing);
        }];
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_top);
            make.left.equalTo(self.contentLabel.mas_right).offset(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.bottom.mas_equalTo(-KLeftSpacing);
        }];
        
        [self.stackView addArrangedSubviews:@[self.contentTextView,self.scrollSwitch,self.repeatView,self.positionView]];
        
        [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
        }];
        
        [self.repeatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(KRepeatViewHeight);
        }];
        
        [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(KPositionViewHeight);
        }];
        
        [self.enableScrollLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.contentLabel);
            make.centerY.equalTo(self.scrollSwitch);
        }];
        
        [self.repeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.contentLabel);
            make.centerY.equalTo(self.repeatView);
        }];
        
        [self.positionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.contentLabel);
            make.centerY.equalTo(self.positionView);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.contentView setCornerRadius:12 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
            //[self show];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrameNotification:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
}

- (void)stopOverlayMessage:(NSString *)meetingNumber {
    [self.presenter stopTextOverlayWithMeetingNumber:meetingNumber];
}

#pragma mark - Notification

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight   = CGRectGetHeight(rect);
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (self.contentTextView.isFirstResponder) {
        
        CGFloat maxYSwitchHeight = self.scrollSwitch.on ? (self.repeatView.bounds.size.height + kOverlayMessageSpacing) : 0;
        CGFloat textViewSpacing = keyboardHeight - KLeftSpacing - KPositionViewHeight -
                                  kOverlayMessageSpacing - self.scrollSwitch.bounds.size.height - maxYSwitchHeight ;
        
        [self.stackView setCustomSpacing:textViewSpacing afterView:self.contentTextView];
        [self.stackView setCustomSpacing:8 afterView:self.repeatView];
    }
    
    if (self.repeatView.numberField.isFirstResponder) {
        [self.stackView setCustomSpacing:keyboardHeight - KPositionViewHeight - KLeftSpacing afterView:self.repeatView];
    }
    
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo   = [notification userInfo];
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self.stackView setCustomSpacing:kOverlayMessageSpacing afterView:self.contentTextView];
    [self.stackView setCustomSpacing:kOverlayMessageSpacing afterView:self.repeatView];
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - action

- (void)show{
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)disMiss{
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(LAND_SCAPE_HEIGHT);
    }];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        sendOverlayMessageView = nil;
        sendOverlayMessageBlock = nil;
    }];
}

- (void)removeRepeatView:(BOOL)isHide {
    [UIView animateWithDuration:0.25 animations:^{
        self.repeatView.alpha =
        self.repeatLabel.alpha = !isHide;
        self.repeatView.hidden =
        self.repeatLabel.hidden = isHide;
    }];
}

- (void)startOverlay {
    NSString *textViewContent = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (kStringIsEmpty(textViewContent)) {
        [self makeToast:NSLocalizedString(@"meeting_overlay_noempty", nil)]; return;
    }
    [self disMiss];
    [self.presenter startTextOverlayWithMeetingNumber:self.meetingNumber
                                              content:self.contentTextView.text
                                               repeat:[NSNumber numberWithInteger:self.repeatView.repeatNmber]
                                             position:[NSNumber numberWithInteger:self.positionView.positionNmber]
                                        enable_scroll:[NSNumber numberWithBool:self.scrollSwitch.on]];
}

#pragma mark - RosterViewProtocol

- (void)startTextOverlayResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_overlay_start", nil)];
    }
}

- (void)stopTextOverlayResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_overlay_stop", nil)];
    }
}

#pragma mark - lazy

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = UIColorHex(0xf8f9fa);
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (FrtcScheduleDatePickerHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[FrtcScheduleDatePickerHeaderView alloc]init];
        _headerView.backgroundColor = UIColor.whiteColor;
        @WeakObj(self);
        _headerView.dateHeaderViewBlock = ^(BOOL index) {
            @StrongObj(self)
            if (index) {
                if (sendOverlayMessageBlock) {
                    sendOverlayMessageBlock();
                }
                [self startOverlay];
            }else{
                [self disMiss];
            }
        };
        _headerView.titleLabel.text = NSLocalizedString(@"meeting_heaer_start_overlay", nil);
        [self.contentView addSubview:_headerView];
    }
    return _headerView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [self getLableWith:NSLocalizedString(@"meeting_overlay_message", nil)];
        //_contentLabel.backgroundColor = UIColor.redColor;
        _contentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)enableScrollLabel {
    if (!_enableScrollLabel) {
        _enableScrollLabel = [self getLableWith:NSLocalizedString(@"meeting_overlay_rolling", nil)];
        _enableScrollLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_enableScrollLabel];
    }
    return _enableScrollLabel;
}

- (UILabel *)repeatLabel {
    if (!_repeatLabel) {
        _repeatLabel = [self getLableWith:NSLocalizedString(@"meeting_overlay_repetitions", nil)];
        _repeatLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_repeatLabel];
    }
    return _repeatLabel;
}

- (UILabel *)positionLabel {
    if (!_positionLabel) {
        _positionLabel = [self getLableWith:NSLocalizedString(@"meeting_overlay_postion", nil)];
        _positionLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_positionLabel];
    }
    return _positionLabel;
}

- (UILabel *)getLableWith:(NSString *)title {
    UILabel *lable = [[UILabel alloc]init];
    lable.textAlignment = NSTextAlignmentRight;
    lable.text = title;
    lable.textColor = KTextColor;
    lable.font = [UIFont systemFontOfSize:16];
    //lable.backgroundColor = UIColor.brownColor;
    return lable;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc]init];
        _contentTextView.font = [UIFont systemFontOfSize:16];
        _contentTextView.text = NSLocalizedString(@"meeting_overlay_welcome", nil);
        _contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _contentTextView;
}

- (UISwitch *)scrollSwitch {
    if (!_scrollSwitch) {
        _scrollSwitch = [[UISwitch alloc]init];
        _scrollSwitch.on = YES;
        _scrollSwitch.onTintColor = kMainColor;
        @WeakObj(self)
        [_scrollSwitch addBlockForControlEvents:UIControlEventValueChanged
                                          block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self removeRepeatView:!self.scrollSwitch.on];
        }];
    }
    return _scrollSwitch;
}

- (FrtcOverlayRepeatView *)repeatView {
    if (!_repeatView) {
        _repeatView = [[FrtcOverlayRepeatView alloc]init];
    }
    return _repeatView;
}

- (FrtcOverlayPositionView *)positionView {
    if (!_positionView) {
        _positionView = [[FrtcOverlayPositionView alloc]init];
        _positionView.backgroundColor = self.contentView.backgroundColor;
    }
    return _positionView;
}

- (RosterPresenter *)presenter {
    if (!_presenter) {
        _presenter = [RosterPresenter new];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc]init];
        _stackView.spacing = kOverlayMessageSpacing;
        _stackView.axis = UILayoutConstraintAxisVertical;
        [self.contentView addSubview:_stackView];
    }
    return _stackView;
}

@end

