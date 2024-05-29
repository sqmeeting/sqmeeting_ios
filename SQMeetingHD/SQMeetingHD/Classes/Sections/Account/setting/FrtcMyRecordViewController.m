#import "FrtcMyRecordViewController.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "MBProgressHUD+Extensions.h"

@interface FrtcMyRecordViewController ()

@end

@implementation FrtcMyRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title =  NSLocalizedString(@"FM_VIDEO_MY_RECORDING", nil);
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configUI {

    UIView *whiteBgView = [[UIView alloc]init];
    whiteBgView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:whiteBgView];
    [whiteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.right.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = NSLocalizedString(@"SHENQI_WEBPORTAL_TOVIEW", nil);
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = KTextColor;
    [whiteBgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(15);
    }];
    
    NSString *server_address = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    NSString *webUrl = [NSString stringWithFormat:@"https://%@",server_address];
    
    UIButton *urlBtn = [[UIButton alloc]init];
    [urlBtn setTitle:webUrl forState:UIControlStateNormal];
    urlBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [urlBtn setTitleColor:kMainHoverColor forState:UIControlStateNormal];
    [urlBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webUrl]
                                           options:@{}
                                 completionHandler:^(BOOL success) { }];
    }];
    [whiteBgView addSubview:urlBtn];
    [urlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_left);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-15);
    }];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyBtn setImage:[UIImage imageNamed:@"meeting_copyinfo"] forState:UIControlStateNormal];
    [copyBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = webUrl;
        [MBProgressHUD showMessage:NSLocalizedString(@"share_plate", nil)];
    }];
    [whiteBgView addSubview:copyBtn];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(urlBtn);
        make.right.mas_equalTo(-KLeftSpacing);
    }];
}

@end
