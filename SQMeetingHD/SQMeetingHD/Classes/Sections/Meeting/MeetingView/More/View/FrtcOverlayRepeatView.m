#import "FrtcOverlayRepeatView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"

#define kMinOverlayRepeat 1
#define kMaxOverlayRepeat 999
#define kDefaultOverlayRepeat 3

@interface FrtcOverlayRepeatView () <UITextFieldDelegate>

@property (nonatomic, assign, readwrite) NSInteger repeatNmber;

@property (nonatomic, strong) UIButton *subtractBtn;
@property (nonatomic, strong) UIButton *addBtn;

@end

@implementation FrtcOverlayRepeatView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)setupView {
    
    self.repeatNmber = kDefaultOverlayRepeat;
    self.clipsToBounds = YES;
    self.layer.borderColor = UIColorHex(0xdedede).CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    [self.subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.equalTo(self.mas_height);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.equalTo(self.subtractBtn);
    }];
    
    [self.numberField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.subtractBtn.mas_right);
        make.right.equalTo(self.addBtn.mas_left);
        make.top.bottom.mas_equalTo(0);
    }];
    
}

#pragma mark - action

- (void)setNumbers {
    self.numberField.text = [NSString stringWithFormat:@"%ld",(long)self.repeatNmber];
}

- (void)changeNumber {
    self.repeatNmber = [self.numberField.text intValue];
    if (self.repeatNmber > kMaxOverlayRepeat) {
        self.repeatNmber = kMaxOverlayRepeat;
    }
    if (self.repeatNmber < kMinOverlayRepeat) {
        self.repeatNmber = kMinOverlayRepeat;
    }
    if (self.repeatNmber <= kMinOverlayRepeat) {self.subtractBtn.enabled = NO;};
    if (self.repeatNmber < kMaxOverlayRepeat)  {self.addBtn.enabled = YES;};
    if (self.repeatNmber >= kMaxOverlayRepeat) {self.addBtn.enabled = NO;};
    if (self.repeatNmber > kMinOverlayRepeat)  {self.subtractBtn.enabled = YES;};
    [self setNumbers];
}

#pragma mark - UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self changeNumber];
}

#pragma mark - lazy

- (UIButton *)subtractBtn {
    if (!_subtractBtn) {
        _subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractBtn setImage:[UIImage imageNamed:@"frtc_meeting_subtractNumber"]
                      forState:UIControlStateNormal];
        _subtractBtn.layer.borderColor = UIColorHex(0xdedede).CGColor;
        _subtractBtn.layer.borderWidth = 1;
        @WeakObj(self)
        [_subtractBtn addBlockForControlEvents:UIControlEventTouchUpInside
                                         block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.repeatNmber--;
            [self setNumbers];
            if (self.repeatNmber <= kMinOverlayRepeat) {self.subtractBtn.enabled = NO;};
            if (self.repeatNmber < kMaxOverlayRepeat) { self.addBtn.enabled = YES;};
        }];
        [self addSubview:_subtractBtn];
    }
    return _subtractBtn;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"frtc_meeting_addNumber"]
                 forState:UIControlStateNormal];
        _addBtn.layer.borderColor = UIColorHex(0xdedede).CGColor;
        _addBtn.layer.borderWidth = 1;
        @WeakObj(self)
        [_addBtn addBlockForControlEvents:UIControlEventTouchUpInside
                                    block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.repeatNmber++;
            [self setNumbers];
            if (self.repeatNmber >= kMaxOverlayRepeat) { self.addBtn.enabled = NO;};
            if (self.repeatNmber > kMinOverlayRepeat) {self.subtractBtn.enabled = YES;};
        }];
        [self addSubview:_addBtn];
    }
    return _addBtn;
}

- (UITextField *)numberField {
    if (!_numberField) {
        _numberField = [[UITextField alloc]init];
        _numberField.textAlignment = NSTextAlignmentCenter;
        _numberField.text = [NSString stringWithFormat:@"%d",kDefaultOverlayRepeat];
        _numberField.keyboardType = UIKeyboardTypeNumberPad;
        _numberField.delegate = self;
        @WeakObj(self)
        [_numberField addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self changeNumber];
        }];
        [self addSubview:_numberField];
    }
    return _numberField;
}


@end
