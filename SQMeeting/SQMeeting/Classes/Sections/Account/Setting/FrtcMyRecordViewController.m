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
    titleLabel.textColor = KTextColor;
    titleLabel.numberOfLines = 0;
    [whiteBgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(15);
    }];
    
    NSString *server_address = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    NSString *webUrl = [NSString stringWithFormat:@"https://%@",server_address];
    
    UILabel *urlLabel = [[UILabel alloc]init];
    urlLabel.text = webUrl;
    urlLabel.font = [UIFont systemFontOfSize:15];
    urlLabel.textColor = kMainHoverColor;
    [whiteBgView addSubview:urlLabel];
    [urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.centerY.equalTo(urlLabel);
        make.right.mas_equalTo(-KLeftSpacing);
    }];
    
}

@end
