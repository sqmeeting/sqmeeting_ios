#import "FrtcScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FrtcCall.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "FrtcUserDefault.h"
#import "FrtcMakeCallClient.h"
#import "FrtcUserModel.h"
#import "UIView+Toast.h"
#import "UIViewController+Extensions.h"
#import <CommonCrypto/CommonCryptor.h>
#import "FrtcScanQRManager.h"
#import "NSData+AES.h"
#import "FrtcManagement.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcManager.h"

#define TOP  (KScreenHeight-220)/2
#define LEFT (KScreenWidth-220)/2

#define kScanRect CGRectMake(LEFT, TOP, 0, 0)

@interface FrtcScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int num;
    BOOL upOrdown;
    CAShapeLayer *cropLayer;
    BOOL pssswordCancle;
}

@property (strong, nonatomic)AVCaptureSession * session;

@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) UIButton *albumButton;

@end

@implementation FrtcScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.hidden = YES;
    pssswordCancle = NO;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"nav_Wback_icon"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
    self.view.backgroundColor = UIColorHex(0x000);
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.view hideAllToasts];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self stop];
}

-(void)configUI {
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] init];
    _line.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:_line];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(TOP - 100);
    }];
    
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-200);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.centerLabel.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(60);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [self.albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lightButton.mas_centerY);
        make.right.mas_equalTo(-60);
        make.size.equalTo(self.lightButton);
    }];
    [self addScannerLineAnimation];
}

-(void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addScannerLineAnimation {
    [_line.layer removeAllAnimations];
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    lineAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, KScreenWidth - 150, 1)];
    lineAnimation.duration = 4;
    lineAnimation.repeatCount = HUGE;
    [_line.layer addAnimation:lineAnimation forKey:@"ScannerLineAnmationKey"];
    _line.layer.speed = 1.5;
}

- (void)setupCamera {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"string_tips", nil) message:NSLocalizedString(@"device_noCamera", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"psd_confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    @WeakObj(self);
    [FrtcScanQRManager f_checkCameraAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            @StrongObj(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _setupScanner];
            });
        }
    }];
}

- (void)_setupScanner {
    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    CGFloat top    = 0.1;
    CGFloat left   = 0.1;
    CGFloat width  = 0.8;
    CGFloat height = 0.8;
    
    [metadataOutput setRectOfInterest:CGRectMake(top,left, height, width)];
    
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
    }
    
    [metadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    AVCaptureVideoPreviewLayer *preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
}

- (void)stop {
    if (self.session) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session stopRunning];
        });
        self.session = nil;
    }
}

- (void)turnOnLight:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [FrtcScanQRManager f_FlashlightOn:sender.selected];
}

- (void)goAlbum:(UIButton *)sender {
    @WeakObj(self);
    [FrtcScanQRManager f_checkAlbumAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            @StrongObj(self)
            [self imagePicker];
        }
    }];
}

- (void)imagePicker {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
}

#pragma mark -- <UIImagePickerControllerDelegate>--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak __typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf makeScanQRCodeCall:info];
    }];
}

- (void)makeScanQRCodeCall:(NSDictionary<NSString *,id> *)info {
    
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        return;
    }
    
    UIImage *qrImage = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:qrImage.CGImage]];
    
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *stringValue = feature.messageString;
        [self dealScanQRResult:stringValue];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        return;
    }
    NSString *stringValue;
    
    if ([metadataObjects count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session stopRunning];
        });
        [self.timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        [self dealScanQRResult:stringValue];
    } else {
        return;
    }
}

- (void)dealScanQRResult:(NSString *)stringValue {
    NSArray *array = [stringValue componentsSeparatedByString:@"://"];
    
    if(array.count == 0) {
        [self alertWrongView];
        return;
    }
    
    NSString *tempAddreess = @"";
    
    if ([array[0] isEqualToString:@"frtc_meetingurl"]) {
        tempAddreess = array[1];
        [self dealTempAddreess:tempAddreess];
        
    }else if ([array[0] isEqualToString:@"https"]) { //[array[0] hasPrefix:@"http"]
        NSURL *stringUrl = [NSURL URLWithString:stringValue];
        NSString *urlHost = stringUrl.host;
        NSString *urlPort = [stringUrl.port stringValue];
        
        NSString *meetingUrl = @"";
        if (kStringIsEmpty(urlPort)) {
            meetingUrl = urlHost;
        }else{
            meetingUrl = [NSString stringWithFormat:@"%@:%@",urlHost,urlPort];
        }
        NSString *meetingToken = stringUrl.path.pathComponents.lastObject;
        @WeakObj(self)
        [[FrtcManagement sharedManagement] queryUrlMeetingInfo:meetingUrl
                                                  meetingToken:meetingToken
                                             completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
            @StrongObj(self);
            NSString *link = meetingInfo[@"meeting_link"];
            [self dealTempAddreess:link];
        } failure:^(NSError * _Nonnull error) {
            @StrongObj(self);
            [self.navigationController.view makeToast:NSLocalizedString(@"wrong_qr", nil)];
        }];
    }else {
        [self alertWrongView];
    }
}

- (void)dealTempAddreess:(NSString *)tempAddreess {
    
    if (kStringIsEmpty(tempAddreess)) {return;}
    NSArray *tempValues = [self tempServerAddressIsEqulCurrentAddress:tempAddreess];
    if (tempValues.count < 2) {return;}
    BOOL isSame = [tempValues[0] boolValue];
    NSString *tempServerAddress = tempValues[1];
    
    if (isSame) {
        [self scanQRJoinMeetingWithCallUrl:tempAddreess];
    }else{
        if (isLoginSuccess) {
            FrtcManager.guestUser = YES;
            FrtcManager.serverAddress = tempServerAddress;
            [self scanQRJoinMeetingWithCallUrl:tempAddreess];
        }else{
            [self showAlertWithTitle:[NSString stringWithFormat:@"%@\n\"%@\"\n%@",NSLocalizedString(@"change_default_service_address_title1", nil),tempServerAddress,NSLocalizedString(@"change_default_service_address_title2", nil)] message:NSLocalizedString(@"change_default_service_address_message", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) {
                if (index == 1) {
                    [[FrtcUserDefault sharedUserDefault] setObject:tempServerAddress forKey:SERVER_ADDRESS];
                    [[FrtcManagement sharedManagement] setFRTCSDKConfig:FRTCSDK_SERVER_ADDRESS withSDKConfigValue:tempServerAddress];
                    [MBProgressHUD showMessage:NSLocalizedString(@"change_default_service_address_save", nil)];
                }
                FrtcManager.guestUser = !index;
                FrtcManager.serverAddress = tempServerAddress;
                [self scanQRJoinMeetingWithCallUrl:tempAddreess];
            }];
        }
    }
}

- (NSArray *)tempServerAddressIsEqulCurrentAddress:(NSString *)callUrl {
    NSData *afterDecodeData = [[NSData alloc]initWithBase64EncodedString:callUrl options:0];
    NSData *afterDesData = [afterDecodeData AES256DecryptWithKey:kEncryptionKey];
    NSString *cipherString = [[NSString alloc]initWithData:afterDesData encoding: NSUTF8StringEncoding];
    if(kStringIsEmpty(cipherString)) { return @[@NO,@""]; }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:afterDesData options:NSJSONReadingMutableLeaves error:nil];
    NSString *tempServerAddress = [jsonDict[@"server_address"] lowercaseString];
    NSString *currentAddress = [[[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS] lowercaseString];
    BOOL isSame = [tempServerAddress isEqualToString:currentAddress];
    return @[[NSNumber numberWithBool:isSame],tempServerAddress];
}

- (void)alertWrongView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"wrong_qr", nil) preferredStyle:UIAlertControllerStyleAlert ];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:action1];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scanQRJoinMeetingWithCallUrl:(NSString *)callUrl {
    
    if ([FrtcHelpers f_isInMieeting]) {
        return;
    }
    
    NSString *userName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].real_name : [FrtcLocalInforDefault getMeetingDisPlayName];
    if(userName == nil || [userName isEqualToString:@""]) {
        userName = [UIDevice currentDevice].name;
    }
    
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FRTCSDKCallParam param;
        param.muteCamera = YES;
        param.muteMicrophone = YES;
        param.clientName = userName;
        param.audioCall = NO;
        param.callUrl = callUrl;
        
        if (isLoginSuccess) {
            param.userToken = [FrtcUserModel fetchUserInfo].user_token;
        }
        
        @WeakObj(self)
        __weak typeof(self) weakSelf = self;
        [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:param withCallSuccessBlock:^{
            @StrongObj(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->pssswordCancle = NO;
                self.navigationItem.leftBarButtonItem.enabled = YES;
                [self.navigationController.view hideToastActivity];
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        } withCallFailureBlock:^(FRTCMeetingStatusReason reason, NSString * _Nonnull errMsg) {
            @StrongObj(self)
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view hideToastActivity];
                self.navigationItem.leftBarButtonItem.enabled = YES;
                //                if (kStringIsEmpty(errMsg)) {
                //                    if (![[[FrtcMakeCallClient sharedSDKContext] valueForKey:@"reconnect"] boolValue] && !self->pssswordCancle) {
                //                        self->pssswordCancle = NO;
                //                        [self.navigationController popViewControllerAnimated:YES];
                //                    }
            });
        } withInputPassCodeCallBack:^{
            @StrongObj(self)
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.navigationController.view hideToastActivity];
            [self showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
                @StrongObj(self)
                if (index == 1) {
                    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                    self.navigationItem.leftBarButtonItem.enabled = NO;
                    [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                    [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
                }
                if (index == 0) {
                    self->pssswordCancle = YES;
                    self.navigationItem.leftBarButtonItem.enabled = YES;
                    [[FrtcCall frtcSharedCallClient] frtcHangupCall];
                    if (self.session) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [self.session startRunning];
                        });
                    }
                }
            }];
            
        }];
    });
}

#pragma mark lazy load
- (UILabel *)centerLabel {
    if(!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.numberOfLines = 1.0;
        _centerLabel.text = NSLocalizedString(@"aim_scan", nil);
        _centerLabel.textColor = [UIColor whiteColor];
        _centerLabel.font = [UIFont systemFontOfSize:20.0];
        [self.view addSubview:_centerLabel];
    }
    
    return _centerLabel;
}

- (UIButton *)lightButton {
    if(!_lightButton) {
        _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lightButton setBackgroundImage:[UIImage imageNamed:@"icon_flashlight"]
                                forState:UIControlStateNormal];
        [_lightButton setBackgroundImage:[UIImage imageNamed:@"icon_flashlight_on"] forState:UIControlStateSelected];
        [_lightButton addTarget:self action:@selector(turnOnLight:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_lightButton];
    }
    
    return _lightButton;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setImage:[UIImage imageNamed:@"icon_image"]forState:UIControlStateNormal];
        [_albumButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_albumButton addTarget:self action:@selector(goAlbum:)forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_albumButton];
    }
    return _albumButton;
}
@end
