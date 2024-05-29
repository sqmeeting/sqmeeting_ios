#import "FrtcFeedbackViewController.h"
#import "UIControl+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"
#import "UITextView+FPlaceHolder.h"
#import "UIView+Toast.h"
#import "UIImage+Extensions.h"
#import "FrtcUploadLogsViewController.h"

@interface FrtcFeedbackViewController () <UITextViewDelegate>

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UIButton *callButton;

@end

@implementation FrtcFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
    //self.title = NSLocalizedString(@"MEETING_LOG_TITLE", nil);
    UILabel *navView = [[UILabel alloc]init];
    navView.backgroundColor = UIColor.whiteColor;
    navView.text = NSLocalizedString(@"MEETING_LOG_TITLE", nil);
    self.navigationItem.titleView = navView;
    
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
}

- (void)configUI {

    UIView *topView = [[UIView alloc]init];
    topView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(200);
    }];
    
    UIImageView *iconImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meeting_guest_feedback"]];
    [topView addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(35);
        make.centerX.equalTo(topView);
    }];
    
    UILabel *textLable = [[UILabel alloc]init];
    textLable.numberOfLines = 0;
    textLable.text = NSLocalizedString(@"MEETING_LOG_CONTENT", nil);
    textLable.font = [UIFont systemFontOfSize:14];
    textLable.textColor = KTextColor666666;
    [topView addSubview:textLable];
    [textLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImg.mas_bottom).offset(20);
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
    }];
    
    UITextView *textView = [[UITextView alloc]init];
    textView.delegate = self;
    textView.placeHoldString = NSLocalizedString(@"MEETING_LOG_TEXTVIEW_DEFIAULT", nil);
    textView.placeHoldColor = KDetailTextColor;
    textView.placeHoldFont = [UIFont systemFontOfSize:14];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = KTextColor;
    textView.delegate = self;
    textView.scrollEnabled = NO;
    textView.backgroundColor = [UIColor whiteColor];
    textView.contentInset = UIEdgeInsetsMake(8, KLeftSpacing12, 8, KLeftSpacing12);
    [self.contentView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(150);
    }];
    _textView = textView;
    
    UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [callButton setTitle:NSLocalizedString(@"MEETING_LOG_UPLOADBUTTON", nil) forState:UIControlStateNormal];
    [callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
    [callButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
    callButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [callButton addTarget:self action:@selector(didClickCallButton:) forControlEvents:UIControlEventTouchUpInside];
    callButton.layer.masksToBounds = YES;
    callButton.layer.cornerRadius = KCornerRadius;
    [self.contentView addSubview:callButton];
    [callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_bottom).offset(10);
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(kButtonHeight);
    }];
    _callButton = callButton;
}

#pragma mark - textField delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length == 0) {
        return YES;
    }
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger length = newText.length;
    NSInteger maxLength = 100;
    if (length > maxLength) {
        //[self.view makeToast:@"最多100个字"];
        return NO;
    }
    return YES;
}

#pragma mark - action
- (void)didClickCallButton:(UIButton *)sender {
    if (kStringIsEmpty(_textView.text)) {
        [self.view makeToast:NSLocalizedString(@"MEETING_LOG_PLEASE_ISSUE", nil)];
        return;
    }
    FrtcUploadLogsViewController *uploadLogsVC = [[FrtcUploadLogsViewController alloc]init];
    uploadLogsVC.issue = _textView.text;
    [self.navigationController pushViewController:uploadLogsVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
