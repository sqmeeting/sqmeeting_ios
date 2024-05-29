#import "FCallViewController.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "FUserDefault.h"
#import "MBProgressHUD.h"
#import "FRtcsdk.h"
#import "ServerConfigDlg.h"
#import "TalkingToolBarView.h"
#import "MediaControlView.h"
#import "TopLayoutBarView.h"
#import "TopBarView.h"
#import "EndMeetingController.h"
#import "WZLBadgeImport.h"
#import "RostListViewController.h"
#import "StaticsViewController.h"
#import "FStaticsModel.h"
#import "OverlayMessageModel.h"
#import "TopOverLayMessageView.h"
#import "FMeetingPasscodeController.h"
#import "FMakeCallClient.h"

#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

#define SCREEN_SCALE [UIScreen mainScreen].scale
#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define LAND_SCAPE_WIDTH  (SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT)
#define LAND_SCAPE_HEIGHT  (SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_WIDTH : SCREEN_HEIGHT)

#define WEAK_NETWORK_VIDEO_LOSS_THRESHOLD_1  3
#define WEAK_NETWORK_VIDEO_LOSS_THRESHOLD_2  8
#define WEAK_NETWORK_AUDIO_LOSS_THRESHOLD_1  15
#define WEAK_NETWORK_AUDIO_LOSS_THRESHOLD_2  30

#define SIGNAL_INTENSITY_LOW  0
#define SIGNAL_INTENSITY_MEDIAN  1
#define SIGNAL_INTENSITY_HIGH  2

@interface FCallViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, getter=isCameraOn) BOOL cameraOn;

@property (nonatomic, getter=isMicrophoneOn) BOOL microphoneOn;

@property (nonatomic, getter=isRememberNameOn) BOOL rememberNameOn;


@end

@implementation FCallViewController

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    NSLog(@"The view safeAreaInsets is %f, %f, %f, %f", self.view.safeAreaInsets.top, self.view.safeAreaInsets.left, self.view.safeAreaInsets.bottom, self.view.safeAreaInsets.right);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backGroundView setImage:[UIImage imageNamed:@"bg-image"]];
    //self.navigationController.tabBarItem.title = @"Video Call";
    NSLog(@"The width is %f", self.view.frame.size.width);
    NSLog(@"The height is %f", self.view.frame.size.height);
    if(self.audioCall) {
        self.title = NSLocalizedString(@"audio_call", nil);
    } else {
        self.title = NSLocalizedString(@"video_call", nil);
    }
    
    
    [self configView];
    [self configSwithchOnStatus];
    
    NSString *nameStatus = [[FUserDefault sharedUserDefault] objectForKey:NAME_SATTUS];
    
    if ([nameStatus isEqualToString:@"true"])  {
        _displayNameTextField.text = [[FUserDefault sharedUserDefault] objectForKey:DISPLAY_NAME];
    }
    
    _conferenceNumberTextField.text = [[FUserDefault sharedUserDefault] objectForKey:CONFERENCE_NUMBER];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.backGroundView addGestureRecognizer:tapGesture];
    
    // Do any additional setup after loading the view.
}

- (void)configSwithchOnStatus {
    NSString *microphoneStatus = [[FUserDefault sharedUserDefault] objectForKey:MICROPHONE_STATUS];
    NSLog(@"configSwithchOnStatus microphoneStatus = %@", microphoneStatus);
    if(microphoneStatus == nil || [microphoneStatus isEqualToString:@""]) {
        _microphoneSwitch.on = NO;
    } else if([microphoneStatus isEqualToString:@"true"]) {
        _microphoneSwitch.on = YES;
    } else {
        _microphoneSwitch.on = NO;
    }
    
    NSString *cameraStatus = [[FUserDefault sharedUserDefault] objectForKey:CAMERA_STATUS];
    NSLog(@"configSwithchOnStatus cameraStatus = %@", cameraStatus);
    if(cameraStatus == nil || [cameraStatus isEqualToString:@""]) {
        _cameraSwitch.on = NO;
    } else if([cameraStatus isEqualToString:@"true"]) {
        _cameraSwitch.on = YES;
    } else {
        _cameraSwitch.on = NO;
    }
    
    NSString *nameStatus = [[FUserDefault sharedUserDefault] objectForKey:NAME_SATTUS];
    NSLog(@"configSwithchOnStatus nameStatus = %@", nameStatus);
    if([nameStatus isEqualToString:@"false"]) {
        _rememberSwitch.on = NO;
    } else {
        _rememberSwitch.on = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
   
    NSString *signStatus = [[FUserDefault sharedUserDefault] objectForKey:SIGN_STATUS];
    if ([signStatus isEqualToString:@"true"]) {
        _displayNameLabel.hidden = YES;
        _displayNameTextField.hidden = YES;
        _nameNotificationLabel.hidden = YES;
        _rememberNameLabel.hidden = YES;
        _rememberSwitch.hidden = YES;
        _line1.hidden = YES;
        [_callButton mas_updateConstraints:^(MASConstraintMaker *maker) {
            maker.top.mas_equalTo(_numberNotificationLabel.mas_bottom).offset(10);
        }];
        [_microphoneLabel mas_updateConstraints:^(MASConstraintMaker *maker) {
            maker.top.mas_equalTo(_line0.mas_bottom).offset(20);
        }];
    } else {
        _displayNameLabel.hidden = NO;
        _displayNameTextField.hidden = NO;
        _nameNotificationLabel.hidden = NO;
        _rememberNameLabel.hidden = NO;
        _rememberSwitch.hidden = NO;
        _line1.hidden = NO;
        [_callButton mas_updateConstraints:^(MASConstraintMaker *maker) {
            maker.top.mas_equalTo(_nameNotificationLabel.mas_bottom).offset(10);
        }];
        [_microphoneLabel mas_updateConstraints:^(MASConstraintMaker *maker) {
            maker.top.mas_equalTo(_line1.mas_bottom).offset(20);
        }];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    
    NSString *conferenceAlias = _conferenceNumberTextField.text;
    NSString *conferenceName = _displayNameTextField.text;
 
    if (conferenceAlias != nil) {
           [[FUserDefault sharedUserDefault] setObject:conferenceAlias forKey:CONFERENCE_NUMBER];
    }
    
    if(_rememberSwitch.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:NAME_SATTUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:NAME_SATTUS];
    }
    
    if ((conferenceName != nil) && (_rememberSwitch.isOn))  {
        [[FUserDefault sharedUserDefault] setObject:conferenceName forKey:DISPLAY_NAME];
    }
    
    if(_microphoneSwitch.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:MICROPHONE_STATUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:MICROPHONE_STATUS];
    }
    
    if(self.isAudioCall) {
        return;
    }
    
    if(_cameraSwitch.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:CAMERA_STATUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:CAMERA_STATUS];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    NSLog(@"FCallViewController dealloc");
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    NSArray *subViews = [self.backGroundView subviews];
    
    if ([subViews count] == 0) {
        return;
    }
    
    UIView *subView = nil;
    for (subView  in subViews) {
        if([subView isKindOfClass:[UITextField class]]) {
            if ([subView isFirstResponder]) {
                [subView resignFirstResponder];
            }
        }
    }
}

-(void)configView {
    [self.conferenceNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(110);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.conferenceNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.conferenceNumberLabel.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(36);
    }];
    
    [self.numberNotificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.conferenceNumberTextField.mas_bottom).mas_offset(2);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(16);
    }];
    
    [self.displayNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.numberNotificationLabel.mas_bottom).mas_offset(2);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.displayNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.displayNameLabel.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(36);
    }];
    
    [self.nameNotificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.displayNameTextField.mas_bottom).mas_offset(2);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(16);
    }];
    
    [self.callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.nameNotificationLabel.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(40);
    }];
    
    [self.line0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.callButton.mas_bottom).mas_offset(22);
        make.height.mas_equalTo(10);
    }];
    
    [self.rememberNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.line0.mas_bottom).mas_offset(20);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.rememberSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.rememberNameLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.rememberNameLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(1);
    }];
    
    [self.microphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.line1.mas_bottom).mas_offset(20);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.microphoneSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.microphoneLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.microphoneLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(1);
    }];
    
    if(self.isAudioCall) {
        [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(self.microphoneLabel.mas_bottom).mas_offset(20);
            make.height.mas_equalTo(1);
        }];
    } else {
        [self.cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(self.line2.mas_bottom).mas_offset(20);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        
        [self.cameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(self.cameraLabel.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(40);
            make.height.mas_greaterThanOrEqualTo(24);
        }];
        
        [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(self.cameraLabel.mas_bottom).mas_offset(20);
            make.height.mas_equalTo(1);
        }];
    }
    
}

#pragma mark -- private function
- (void)didClickCallButton:(UIButton*)sender {
    NSLog(@"didClickCallButton");
    
    [self.view endEditing:YES];
    
    NSString *conferenceAlias = _conferenceNumberTextField.text;
    NSString *conferenceName = _displayNameTextField.text;
    NSString *conferenceServer = [[FUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    
    NSString *conferenceCallRate = [[FUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    //end add
    
    if(conferenceName != nil) {
        [[FUserDefault sharedUserDefault] setObject:conferenceName forKey:DISPLAY_NAME];
    }
    
    if(conferenceAlias != nil) {
        [[FUserDefault sharedUserDefault] setObject:conferenceAlias forKey:CONFERENCE_NUMBER];
    }
    
    NSString *signStatus = [[FUserDefault sharedUserDefault] objectForKey:SIGN_STATUS];

    bool bReturn = false;

    if([signStatus isEqualToString:@"true"]) {
//        conferenceName = [[FUserDefault sharedUserDefault] objectForKey:SIGN_NAME];
        conferenceName = [[[FUserDefault sharedUserDefault] objectForKey:ACCOUNT_LASTNAME] stringByAppendingString:[[FUserDefault sharedUserDefault] objectForKey:ACCOUNT_FIRSTNAME]];
    }
    
    if (self.conferenceNumberTextField.text.length == 0) {
        _numberNotificationLabel.text = NSLocalizedString(@"meeting_id_error", nil);
        bReturn = true;
    }
    
    if ((self.displayNameTextField.text.length == 0)&&([signStatus isEqualToString:@"false"])){
        _nameNotificationLabel.text = NSLocalizedString(@"meeting_name_error", nil);;
        bReturn = true;
    }
    
    if(bReturn) {
        return;
    }
    
    if(conferenceServer.length == 0){
        NSLog(@"conferenceServer is empty");
        dispatch_async(dispatch_get_main_queue(), ^{
            ServerConfigDlg *vc = [ServerConfigDlg new];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:vc animated:YES completion:nil];
            
        });
        return;
    }
    
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hub];
    [hub show:YES];
    
    __weak __typeof(self)weakSelf = self;
    NSLog(@"numberCallRate = %d",numberCallRate);
    
    CallParam callParam;
    callParam.conferenceNumber = conferenceAlias;
    callParam.clientName = conferenceName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera = !self.cameraSwitch.isOn;
    callParam.muteMicrophone = !self.microphoneSwitch.isOn;
    callParam.audioCall = self.audioCall;
    
    [[FMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hub hide:YES];
            [hub removeFromSuperview];
        });
        } withCallFailureBlock:^(FRSDKCallResult reason){
            dispatch_async(dispatch_get_main_queue(), ^{
                [hub hide:YES];
                [hub removeFromSuperview];
            });

            __strong __typeof(weakSelf)strongSelf = weakSelf;

            NSString *failureReason;
            if(reason == FR_CALL_SERVERERROR) {
                failureReason = NSLocalizedString(@"server_unreachable", nil);
            } else if(reason == FR_CALL_LOCKED) {
                failureReason = NSLocalizedString(@"meeting_locked", nil);
            } else if(reason == FR_CALL_MEETINGNOTEXIST) {
                failureReason = NSLocalizedString(@"meeting_not_exist", nil);
            } else if(reason == FR_CALL_SUCCESS) {
                failureReason = NSLocalizedString(@"call_ended", nil);
                return;
            }
       
            dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:failureReason preferredStyle:UIAlertControllerStyleAlert ];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:action1];
                [strongSelf presentViewController:alertController animated:YES completion:nil];
            });
            
    }];
}

- (void)dismissKeyBoard:(UIView *)view {
    NSArray *subViews = [view subviews];
    
    if ([subViews count] == 0) {
        return;
    }
    
    UIView *subView = nil;
    for (subView  in subViews) {
        if ([subView isFirstResponder]) {
            [subView resignFirstResponder];
            break;
        }
        [self dismissKeyBoard:subView];
    }
    return;
}

- (void)rememberChanged:(UISwitch *)sender {
    if(sender.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:NAME_SATTUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:NAME_SATTUS];
    }
}

- (void)microphoneChanged:(UISwitch *)sender {
    if(sender.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:MICROPHONE_STATUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:MICROPHONE_STATUS];
    }
}

- (void)cameraChanged:(UISwitch *)sender {
    if(sender.isOn) {
        [[FUserDefault sharedUserDefault] setObject:@"true" forKey:CAMERA_STATUS];
    } else {
        [[FUserDefault sharedUserDefault] setObject:@"false" forKey:CAMERA_STATUS];
    }
}


#pragma mark -- lazy load

- (UIImageView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _backGroundView.userInteractionEnabled = YES;
        [self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UILabel *)conferenceNumberLabel {
    if(!_conferenceNumberLabel) {
        _conferenceNumberLabel = [[UILabel alloc] init];
        _conferenceNumberLabel.textAlignment = NSTextAlignmentLeft;
        _conferenceNumberLabel.numberOfLines = 1.0;
        _conferenceNumberLabel.text = NSLocalizedString(@"meeting_id", nil);
        _conferenceNumberLabel.textColor = [UIColor blackColor];
        _conferenceNumberLabel.font = [UIFont systemFontOfSize:14.0];
        [self.backGroundView addSubview:_conferenceNumberLabel];
    }
    
    return _conferenceNumberLabel;
}

- (UITextField *)conferenceNumberTextField {
    if(!_conferenceNumberTextField) {
        _conferenceNumberTextField = [[UITextField alloc] init];
        _conferenceNumberTextField.delegate = self;
        _conferenceNumberTextField.backgroundColor =  KColorRGB(239,241,245,1.0);
        _conferenceNumberTextField.textAlignment = NSTextAlignmentLeft;
        _conferenceNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
        _conferenceNumberTextField.textColor = [UIColor blackColor];
        _conferenceNumberTextField.font = [UIFont systemFontOfSize:13.0];
        [_conferenceNumberTextField addTarget:self action:@selector(editNumberBegin:)
                 forControlEvents:UIControlEventEditingDidBegin];
        [self.backGroundView addSubview:_conferenceNumberTextField];
    }
    return _conferenceNumberTextField;
}

- (void) editNumberBegin:(UITextField*) sender {
    NSLog(@"editNumberBegin");
    self.numberNotificationLabel.text = @"";
    
}

- (void) editNameBegin:(UITextField*) sender {
    NSLog(@"editNameBegin");
    self.nameNotificationLabel.text = @"";
    
}

- (UILabel *)displayNameLabel {
    if(!_displayNameLabel) {
        _displayNameLabel = [[UILabel alloc] init];
        _displayNameLabel.textAlignment = NSTextAlignmentLeft;
        _displayNameLabel.numberOfLines = 1.0;
        _displayNameLabel.text = NSLocalizedString(@"display_name", nil);
        _displayNameLabel.textColor = [UIColor blackColor];
        _displayNameLabel.font = [UIFont systemFontOfSize:14.0];
        [self.backGroundView addSubview:_displayNameLabel];
    }
    
    return _displayNameLabel;
}

- (UITextField *)displayNameTextField {
    if(!_displayNameTextField) {
        _displayNameTextField = [[UITextField alloc] init];
        _displayNameTextField.delegate = self;
        _displayNameTextField.backgroundColor =  KColorRGB(239,241,245,1.0);
        _displayNameTextField.textAlignment = NSTextAlignmentLeft;
        _displayNameTextField.textColor = [UIColor blackColor];
        _displayNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _displayNameTextField.text = @"iPhone";
        [[FUserDefault sharedUserDefault] setObject:_displayNameTextField.text  forKey:DISPLAY_NAME];
        _displayNameTextField.font = [UIFont systemFontOfSize:13.0];
        [_displayNameTextField addTarget:self action:@selector(editNameBegin:)
                 forControlEvents:UIControlEventEditingDidBegin];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_displayNameTextField];
        
        [self.backGroundView addSubview:_displayNameTextField];
    }
    return _displayNameTextField;
}

//limit the name length
#pragma mark - UITextFieldDelegate
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    if (toBeString.length > 20) {
        textField.text = [toBeString substringToIndex:20];
    }
}

- (UILabel *)nameNotificationLabel {
    if(!_nameNotificationLabel) {
        _nameNotificationLabel = [[UILabel alloc] init];
        _nameNotificationLabel.textAlignment = NSTextAlignmentLeft;
        _nameNotificationLabel.textColor = KColorRGB(235,60,0,1.0);
        _nameNotificationLabel.text = @"";
        _nameNotificationLabel.font = [UIFont systemFontOfSize:13.0];
        [self.backGroundView addSubview:_nameNotificationLabel];
    }
    
    return _nameNotificationLabel;
}

- (UILabel *)numberNotificationLabel {
    if(!_numberNotificationLabel) {
        _numberNotificationLabel = [[UILabel alloc] init];
        _numberNotificationLabel.textAlignment = NSTextAlignmentLeft;
        _numberNotificationLabel.textColor = KColorRGB(235,60,0,1.0);
        _numberNotificationLabel.text = @"";
        _numberNotificationLabel.font = [UIFont systemFontOfSize:13.0];
        [self.backGroundView addSubview:_numberNotificationLabel];
    }
    
    return _numberNotificationLabel;
}

- (UILabel *)line0 {
    if(!_line0) {
        _line0 = [[UILabel alloc] init];
        _line0.backgroundColor = KColorRGB(239,241,245,1.0);
        [self.backGroundView addSubview:_line0];
    }
    
    return _line0;
}

- (UILabel *)rememberNameLabel {
    if(!_rememberNameLabel) {
        _rememberNameLabel = [[UILabel alloc] init];
        _rememberNameLabel.textAlignment = NSTextAlignmentLeft;
        _rememberNameLabel.numberOfLines = 1.0;
        _rememberNameLabel.text = NSLocalizedString(@"remember_name", nil);
        _rememberNameLabel.textColor = [UIColor blackColor];
        _rememberNameLabel.font = [UIFont systemFontOfSize:14.0];
        [self.backGroundView addSubview:_rememberNameLabel];
    }
    
    return _rememberNameLabel;
}

- (UISwitch *)rememberSwitch {
    if(!_rememberSwitch) {
        _rememberSwitch = [[UISwitch alloc] init];
        _rememberSwitch.on = YES;
        [_rememberSwitch addTarget:self action:@selector(rememberChanged:) forControlEvents:(UIControlEventValueChanged)];
        _rememberSwitch.onTintColor = KColorRGB(0,135,218,1.0);
        [self.backGroundView addSubview:_rememberSwitch];
    }
    
    return _rememberSwitch;
}

- (UILabel *)line1 {
    if(!_line1) {
        _line1 = [[UILabel alloc] init];
        _line1.backgroundColor = KColorRGB(239,241,245,1.0);
        [self.backGroundView addSubview:_line1];
    }
    
    return _line1;
}

- (UILabel *)microphoneLabel {
    if(!_microphoneLabel) {
        _microphoneLabel = [[UILabel alloc] init];
        _microphoneLabel.textAlignment = NSTextAlignmentLeft;
        _microphoneLabel.numberOfLines = 1.0;
        _microphoneLabel.text = NSLocalizedString(@"phone_microphone", nil);
        _microphoneLabel.textColor = [UIColor blackColor];
        _microphoneLabel.font = [UIFont systemFontOfSize:14.0];
        [self.backGroundView addSubview:_microphoneLabel];
    }
    
    return _microphoneLabel;
}

- (UISwitch *)microphoneSwitch {
    if(!_microphoneSwitch) {
        _microphoneSwitch = [[UISwitch alloc] init];
        _microphoneSwitch.on = NO;
        [_microphoneSwitch addTarget:self action:@selector(microphoneChanged:) forControlEvents:(UIControlEventValueChanged)];
        _microphoneSwitch.onTintColor = KColorRGB(0,135,218,1.0);
        [self.backGroundView addSubview:_microphoneSwitch];
    }
    
    return _microphoneSwitch;
}

- (UILabel *)line2 {
    if(!_line2) {
        _line2 = [[UILabel alloc] init];
        _line2.backgroundColor = KColorRGB(239,241,245,1.0);
        [self.backGroundView addSubview:_line2];
    }
    
    return _line2;
}

- (UILabel *)cameraLabel {
    if(!_cameraLabel) {
        _cameraLabel = [[UILabel alloc] init];
        _cameraLabel.textAlignment = NSTextAlignmentLeft;
        _cameraLabel.numberOfLines = 1.0;
        _cameraLabel.text = NSLocalizedString(@"phone_camera", nil);
        _cameraLabel.textColor = [UIColor blackColor];
        _cameraLabel.font = [UIFont systemFontOfSize:14.0];
        _cameraLabel.hidden = self.isAudioCall;
        [self.backGroundView addSubview:_cameraLabel];
    }
    
    return _cameraLabel;
}

- (UISwitch *)cameraSwitch {
    if(!_cameraSwitch) {
        _cameraSwitch = [[UISwitch alloc] init];
        _cameraSwitch.on = NO;
        _cameraSwitch.onTintColor = KColorRGB(0,135,218,1.0);
         [_cameraSwitch addTarget:self action:@selector(cameraChanged:) forControlEvents:(UIControlEventValueChanged)];
        _cameraSwitch.hidden = self.isAudioCall;
        [self.backGroundView addSubview:_cameraSwitch];
    }
    
    return _cameraSwitch;
}

- (UILabel *)line3 {
    if(!_line3) {
        _line3 = [[UILabel alloc] init];
        _line3.backgroundColor = KColorRGB(239,241,245,1.0);
        [self.backGroundView addSubview:_line3];
    }

    return _line3;
}

- (UIButton *)callButton {
    if(!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callButton setTitle:NSLocalizedString(@"call_join", nil) forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _callButton.backgroundColor = KColorRGB(18,95,123,1.0);
        //_callButton.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        _callButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_callButton addTarget:self action:@selector(didClickCallButton:) forControlEvents:UIControlEventTouchUpInside];
        // _callButton.titleLabel.numberOfLines = 1;
        _callButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _callButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.backGroundView addSubview:_callButton];
    }
    
    return _callButton;
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
