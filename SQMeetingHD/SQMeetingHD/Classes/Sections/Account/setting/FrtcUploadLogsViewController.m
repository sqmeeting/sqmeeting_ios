#import "FrtcUploadLogsViewController.h"
#import "UIControl+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"
#import "UITextView+FPlaceHolder.h"
#import "UIView+Toast.h"
#import "UIImage+Extensions.h"
#import "FrtcCall.h"
#import "YYModel.h"
#import "NSTimer+Enhancement.h"
#import <sys/utsname.h>
#import "MBProgressHUD+Extensions.h"
#import "FrtcSettingLoginViewController.h"
#import "SettingHDViewController.h"
#import "UINavigationItem+Extensions.h"

#define kBitrate  @"bitrate"
#define kProgress @"progress"

@interface FrtcUploadLogsViewController ()
{
    NSInteger uploadId;
    NSString  *uploadResultStr;
    int  progressStatus;
    NSInteger  bitrateStatus;
    BOOL      fileType;
}

@property (nonatomic, weak) UILabel  *textLable;
@property (nonatomic, weak) UIButton *progressBtn;
@property (nonatomic, weak) UIButton *uploadButton;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *logTimer;
@property (nonatomic, assign) LogUpload logUploadStatus;

@end

@implementation FrtcUploadLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *navView = [[UILabel alloc]init];
    navView.backgroundColor = UIColor.whiteColor;
    navView.text = NSLocalizedString(@"MEETING_LOG_UPLOADBUTTON", nil);
    self.navigationItem.titleView = navView;
    // Do any additional setup after loading the view.
    _logUploadStatus = LogUploading;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startUploadLog];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self cancleTimer];
}

- (void)dealloc {
    [self cancleTimer];
    ISMLog(@"%s",__func__);
}

- (void)leftButtonClicked {
    if (self->_logUploadStatus == LogUploadDone) {
        [self goBackToSettingView];
    }else{
        [self cancelUploadLogs];
    }
}

- (void)configUI {
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
    
    UIImageView *iconImg = [[UIImageView alloc]init];
    iconImg.image = [UIImage imageNamed:@"meeting_upload_log"];
    [bgView addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70);
        make.centerX.equalTo(bgView);
    }];
    
    UILabel *textLable = [[UILabel alloc]init];
    textLable.text = NSLocalizedString(@"MEETING_LOG_UPLOADING", nil);
    textLable.textColor = KTextColor;
    textLable.font = [UIFont boldSystemFontOfSize:16];
    [bgView addSubview:textLable];
    _textLable = textLable;
    [textLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImg.mas_bottom).offset(50);
        make.centerX.equalTo(bgView);
    }];
    
    UIProgressView *progressView = [[UIProgressView alloc]init];
    progressView.progressTintColor = UIColor.greenColor;
    progressView.progress = 0.0;
    [bgView addSubview:progressView];
    _progressView = progressView;
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLable.mas_bottom).offset(35);
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-(KLeftSpacing*2)-20);
        make.height.mas_equalTo(10);
    }];
    
    UIButton *progressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [progressBtn setTitle:@"0%" forState:UIControlStateNormal];
    [progressBtn setTitleColor:KTextColor forState:UIControlStateNormal];
    progressBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _progressBtn = progressBtn;
    [bgView addSubview:progressBtn];
    [progressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(progressView.mas_right).offset(40);
        make.centerY.equalTo(progressView);
    }];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setTitle:NSLocalizedString(@"MEETING_LOG_CANCEL_UPLOAD", nil) forState:UIControlStateNormal];
    [uploadButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:[UIImage imageFromColor:kCellSelecteColor] forState:UIControlStateHighlighted];
    uploadButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [uploadButton addTarget:self action:@selector(didClickuploadButton:) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.layer.masksToBounds = YES;
    uploadButton.layer.cornerRadius  = KCornerRadius;
    uploadButton.layer.borderColor   = KDetailTextColor.CGColor;
    uploadButton.layer.borderWidth   = 0.5;
    [bgView addSubview:uploadButton];
    _uploadButton = uploadButton;
    [uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressView.mas_bottom).offset(60);
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(kButtonHeight);
    }];
}

- (void)startUploadLog {
    
    self->fileType = NO;
    self->progressStatus = 0;
    
    NSDictionary *mateData = @{@"version":CUR_BUILD_VERSION,@"platform":@"ios",@"os":[[UIDevice currentDevice] systemVersion],@"device":[FrtcHelpers getModel],@"issue":self.issue};
    NSString *mateDataStr = [mateData yy_modelToJSONString];
    
    self->uploadId = [[FrtcCall frtcSharedCallClient] frtcStartUploadLogs:mateDataStr fileName:@"" fileCount:0];
    
    @WeakObj(self);
    self.logTimer = [NSTimer plua_scheduledTimerWithTimeInterval:0.5 block:^{
        @StrongObj(self)
        [self handleUploadStatus:self->fileType];
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.logTimer forMode:NSDefaultRunLoopMode];
}

- (void)handleUploadStatus:(BOOL)fileType {
    
    if (fileType) {
        self->uploadResultStr = [[FrtcCall frtcSharedCallClient] frtcGetUploadStatus:(int)uploadId fileType:2];
        NSDictionary *uploadResult = [self jsonToDictionary:self->uploadResultStr];
        self->progressStatus = [uploadResult[kProgress] intValue];
        self->bitrateStatus = [uploadResult[kBitrate] intValue];
        
        if (self->progressStatus == 0 ) {
            self->progressStatus = 99;
            self->_progressView.progress = self->progressStatus/100.00;
            [self->_progressBtn setTitle:[NSString stringWithFormat:@"%d%%",self->progressStatus] forState:UIControlStateNormal];
        }
    }else{
        self->uploadResultStr = [[FrtcCall frtcSharedCallClient] frtcGetUploadStatus:(int)uploadId fileType:0];
        NSDictionary *uploadResult = [self jsonToDictionary:self->uploadResultStr];
        self->progressStatus = [uploadResult[kProgress] intValue];
        self->bitrateStatus = [uploadResult[kBitrate] intValue];
    }
    
    ISMLog(@"progress = %d",self->progressStatus);
    ISMLog(@"bitrate = %td",self->bitrateStatus);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->progressStatus < 0) { //上传失败
            ISMLog(@"上传失败 error error error ~~~~");
            [self cancleTimer];
            self->_logUploadStatus = LogUploadError;
            self->_textLable.text = NSLocalizedString(@"MEETING_LOG_UPLOAD_ERROR", nil);
            [self->_progressBtn setTitle:@"" forState:UIControlStateNormal];
            [self->_progressBtn setImage:[UIImage imageNamed:@"meeting_uploadlog_error"] forState:UIControlStateNormal];
            [self->_uploadButton setTitle:NSLocalizedString(@"MEETING_LOG_UPLOAD_AGAIN", nil) forState:UIControlStateNormal];
        } else if (self->progressStatus == 100) { //上传成功
            if (!fileType) {
                ISMLog(@"开始上传 meta file ````````");
                self->fileType = YES;
                return;
            }
            ISMLog(@"上传成功 yes ok success ！！！");
            [self cancleTimer];
            self->_logUploadStatus = LogUploadDone;
            self->_progressView.progress = 1.0;
            self->_textLable.text = NSLocalizedString(@"MEETING_LOG_UPLOAD_DONE", nil);
            [self->_progressBtn setTitle:@"" forState:UIControlStateNormal];
            [self->_progressBtn setImage:[UIImage imageNamed:@"meeting_uploadlog_done"] forState:UIControlStateNormal];
            [self->_uploadButton setTitle:NSLocalizedString(@"MEETING_LOG_UPLOAD_GOBACK", nil) forState:UIControlStateNormal];
        } else { //正在上传中 ...
            ISMLog(@"上传中 ~~~~ ");
            self->_logUploadStatus = LogUploading;
            self->_progressView.progress = self->progressStatus/100.00;
            NSString *uploadingStr = [NSString stringWithFormat:@"%@,%@ %.2f MB/s",NSLocalizedString(@"MEETING_LOG_UPLOADING", nil),NSLocalizedString(@"MEETING_LOG_UPLOAD_SPEED", nil),[self convertBytesToMB:self->bitrateStatus]];
            self->_textLable.text = uploadingStr;
            [self->_progressBtn setImage:nil forState:UIControlStateNormal];
            [self->_progressBtn setTitle:[NSString stringWithFormat:@"%d%%",self->progressStatus] forState:UIControlStateNormal];
            [self->_uploadButton setTitle:NSLocalizedString(@"MEETING_LOG_CANCEL_UPLOAD", nil) forState:UIControlStateNormal];
        }
    });
}

- (void)cancleTimer {
    if(self.logTimer != nil) {
        [self.logTimer invalidate];
        self.logTimer = nil;
    }
}

- (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceModel;
}

- (CGFloat)convertBytesToMB:(NSUInteger)bytes {
    CGFloat megabytes = (CGFloat)bytes / (1024 * 1024);
    return megabytes;
}

- (NSDictionary *)jsonToDictionary:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (dictionary) {
        
    } else {
        // 转换失败，打印错误信息
        ISMLog(@"Error: %@", error.localizedDescription);
    }
    return dictionary;
}

#pragma mark - action

#pragma mark - action

- (void)didClickuploadButton:(UIButton *)sender {
    switch (_logUploadStatus) {
        case LogUploading:
        {
            [self cancelUploadLogs];
        }
            break;
        case LogUploadDone:
        {
            [self cancleTimer];
            [self goBackToSettingView];
        }
            break;
        case LogUploadError:
        {
            [self cancleTimer];
            [self startUploadLog];
        }
            break;
        default:
            break;
    }
}

- (void)cancelUploadLogs {
    ISMLog(@"end uploadId = %d",(int)uploadId);
    [MBProgressHUD showActivityMessage:@""];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        [[FrtcCall frtcSharedCallClient] frtcCancelUploadLogs:(int)self->uploadId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [self cancleTimer];
            [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_LOG_CANCEL_UPLOADDONE", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void)goBackToSettingView {
    if (isLoginSuccess) {
        [self popToViewController:[FrtcSettingLoginViewController class]];
    }else{
        [self popToViewController:[SettingHDViewController class]];
    }
}

- (void)popToViewController:(Class)toViewController {
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:toViewController]) {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
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
