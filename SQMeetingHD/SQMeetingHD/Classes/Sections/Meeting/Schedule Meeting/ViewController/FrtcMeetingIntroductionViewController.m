#import "FrtcMeetingIntroductionViewController.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"

@interface FrtcMeetingIntroductionViewController () <UITextViewDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;

@end
                             
@implementation FrtcMeetingIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"添加会议介绍";
    @WeakObj(self);
    [self.navigationItem initWithRightButtonTitle:NSLocalizedString(@"string_done", nil)  back:^{
        @StrongObj(self)
        if ([self.delegate respondsToSelector:@selector(didEditIntroductionWithResult:)]) {
            [self.delegate didEditIntroductionWithResult:self.textView.text];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    if (!kStringIsEmpty(_introduction) && ![_introduction isEqualToString:@"输入会议介绍"]) {
        self.textView.text = _introduction;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configUI {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(330);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(KLeftSpacing);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(15);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(230);
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 100)
    {
        textView.text = [textView.text substringToIndex:100];
    }
}

#pragma mark - lazy

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
        _titleLabel.text = @"会议介绍";
        [self.bgView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.layer.borderColor = KLineColor.CGColor;
        _textView.layer.borderWidth = 1;
        _textView.layer.cornerRadius = 4;
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:16.f];
        
        UILabel*placeHolderLabel = [[UILabel alloc]init];
        placeHolderLabel.text=@"输入会议介绍";
        placeHolderLabel.numberOfLines=0;
        placeHolderLabel.font= [UIFont systemFontOfSize:14.f];
        placeHolderLabel.textColor= [UIColor lightGrayColor];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        [self.bgView addSubview:_textView];
    }
    return _textView;
}

@end
