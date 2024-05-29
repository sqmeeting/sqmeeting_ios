#import "FrtcManager.h"
#import "FrtcCall.h"
#import "FrtcMakeCallClient.h"
#import "FrtcUserDefault.h"
#import "FrtcUserModel.h"
#import "UIViewController+Extensions.h"
#import "UIView+Toast.h"
#import "NSData+AES.h"
#import "FrtcManagement.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcScheduleListPresenter.h"

@implementation FrtcManager

+ (void)setInMeeting:(BOOL)inMeeting {
    [[NSUserDefaults standardUserDefaults] setBool:inMeeting forKey:@"FrtcInMeeting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isInMeeting {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"FrtcInMeeting"];
}

+ (void)setGuestUser:(BOOL)guestUser {
    [[NSUserDefaults standardUserDefaults] setBool:guestUser forKey:@"FrtcGuestUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isGuestUser {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"FrtcGuestUser"];
}

+ (void)setServerAddress:(NSString *)serverAddress {
    [[NSUserDefaults standardUserDefaults] setObject:serverAddress forKey:@"FrtcServerAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)serverAddress {
    return  [[NSUserDefaults standardUserDefaults] objectForKey:@"FrtcServerAddress"];
}


+ (void)handleOpenURL:(NSURL *)url {
    
    if ([url.scheme isEqualToString:@"frtcmeeting"]) {
        NSString *meetingUrl = url.absoluteString;
        NSArray *array = [meetingUrl componentsSeparatedByString:@"://"];
        if (array.count > 1) {
            
            UIViewController *currentVC = [FrtcHelpers getCurrentVC];
            if (FrtcManager.isInMeeting) {
                return;
            }
            
            NSString *tempAddreess = array[1];
            if (kStringIsEmpty(tempAddreess)) {return;}
            
            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:tempAddreess options:0];
            NSString *decodedString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
            if (kStringIsEmpty(decodedString)) {
                NSArray *tempValues = [FrtcManager tempServerAddressIsEqulCurrentAddress:tempAddreess];
                if (tempValues.count < 2) {return;}
                BOOL isSame = [tempValues[0] boolValue];
                NSString *tempServerAddress = tempValues[1];
                [self configJoinWebMeetingWithIsSame:isSame
                                             callUrl:tempAddreess
                                      viewController:currentVC
                                   tempServerAddress:tempServerAddress];
            }else{
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:base64Data options:NSJSONReadingMutableLeaves error:nil];
                if ([jsonDict.allKeys containsObject:@"operation"]) {
                    NSString *operation = jsonDict[@"operation"];
                    if ([operation isEqualToString:@"meeting_save"]) {
                        NSString *meeting_url = jsonDict[@"meeting_url"];
                        managerMeetingUrl(meeting_url);
                    }
                }else{
                    NSString *tempServerAddress = [jsonDict[@"server_address"] lowercaseString];
                    NSString *tempUsername = [jsonDict[@"username"] lowercaseString];
                    NSString *currentAddress = [[[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS] lowercaseString];
                    BOOL isSame = [tempServerAddress isEqualToString:currentAddress];
                    
                    [self configJoinWebMeetingWithIsSame:isSame
                                                 callUrl:tempAddreess
                                          viewController:currentVC
                                       tempServerAddress:tempServerAddress
                                            tempUsername:tempUsername];
                }
            }
        }
    }
}

+ (NSArray *)tempServerAddressIsEqulCurrentAddress:(NSString *)callUrl {
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


+ (void)configJoinWebMeetingWithIsSame:(BOOL)isSame
                               callUrl:(NSString *)tempAddreess
                        viewController:(UIViewController *)currentVC
                     tempServerAddress:(NSString *)tempServerAddress {
    [self configJoinWebMeetingWithIsSame:isSame
                                 callUrl:tempAddreess
                          viewController:currentVC
                       tempServerAddress:tempServerAddress
                            tempUsername:@""];
}

+ (void)configJoinWebMeetingWithIsSame:(BOOL)isSame
                               callUrl:(NSString *)tempAddreess
                        viewController:(UIViewController *)currentVC
                     tempServerAddress:(NSString *)tempServerAddress
                          tempUsername:(NSString *)tempUsername {
    if (isSame) {
        [self joinMeetingWithController:currentVC callUrl:tempAddreess tempUsername:tempUsername];
    }else{
        if (isLoginSuccess) {
            FrtcManager.guestUser = YES;
            FrtcManager.serverAddress = tempServerAddress;
            [self joinMeetingWithController:currentVC callUrl:tempAddreess tempUsername:tempUsername];
        }else{
            @WeakObj(self)
            [self showAlertView:currentVC tempServerAddress:tempServerAddress block:^{
                @StrongObj(self)
                [self joinMeetingWithController:currentVC callUrl:tempAddreess tempUsername:tempUsername];
            }];
        }
    }
}

+ (void)showAlertView:(UIViewController *)currentVC
    tempServerAddress:(NSString *)tempServerAddress
                block:(void(^)(void))block {
    [currentVC showAlertWithTitle:[NSString stringWithFormat:@"%@\n\"%@\"\n%@",NSLocalizedString(@"change_default_service_address_title1", nil),tempServerAddress,NSLocalizedString(@"change_default_service_address_title2", nil)] message:NSLocalizedString(@"change_default_service_address_message", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) {
        if (index == 1) {
            [[FrtcUserDefault sharedUserDefault] setObject:tempServerAddress forKey:SERVER_ADDRESS];
            [[FrtcManagement sharedManagement] setFRTCSDKConfig:FRTCSDK_SERVER_ADDRESS withSDKConfigValue:tempServerAddress];
            [MBProgressHUD showMessage:NSLocalizedString(@"change_default_service_address_save", nil)];
        }
        FrtcManager.guestUser = !index;
        FrtcManager.serverAddress = tempServerAddress;
        block();
    }];
}

void managerMeetingUrl(NSString *meetingUrl) {
    if (!kStringIsEmpty(meetingUrl)) { //调用加入会议接口
        if (!isLoginSuccess) {
            showAlertTitle(FLocalized(@"meeting_url_nologin", nil));
            return;
        }
        NSURL *url = [NSURL URLWithString:meetingUrl];
        NSString *lastPath_meetingId = [url.lastPathComponent stringByDeletingPathExtension];
        NSString *serviceAddress = [NSString stringWithFormat:@"%@:%@", url.host, url.port];
        NSString *currentAddress = [[[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS] lowercaseString];
        if ([serviceAddress isEqualToString:currentAddress]) {
            f_addMeetingIntoHomeMeetingList(lastPath_meetingId);
        }else{
            showAlertTitle(FLocalized(@"meeting_url_sameaddress", nil));
        }
    }
}

void showAlertTitle(NSString *title) {
    UIViewController *currentVC = [FrtcHelpers getCurrentVC];
    [currentVC showAlertWithTitle:title message:@"" buttonTitles:@[FLocalized(@"string_ok", nil)] alerAction:^(NSInteger index) {
            
    }];
}

+ (void)joinMeetingWithController:(UIViewController *)currentVC
                          callUrl:(NSString *)callUrl {
    [self joinMeetingWithController:currentVC callUrl:callUrl];
}

+ (void)joinMeetingWithController:(UIViewController *)currentVC
                          callUrl:(NSString *)callUrl
                     tempUsername:(NSString *)tempUsername{
    
    NSString *userName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].real_name : [FrtcLocalInforDefault getMeetingDisPlayName];
    
    if(userName == nil || [userName isEqualToString:@""]) {
        userName = [UIDevice currentDevice].name;
    }
    
    if (!kStringIsEmpty(tempUsername)) {
        userName = tempUsername;
    }
    
    [currentVC.navigationController.view makeToastActivity:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        FRTCSDKCallParam param;
        param.muteCamera = YES;
        param.muteMicrophone = YES;
        param.clientName = userName;
        param.audioCall = NO;
        param.callUrl = callUrl;
        if (isLoginSuccess) {
            param.userToken = [FrtcUserModel fetchUserInfo].user_token;
        }
        
        [[FrtcMakeCallClient sharedSDKContext] makeCall:currentVC withCallParam:param withCallSuccessBlock:^{
            [currentVC.navigationController.view hideToastActivity];
        } withCallFailureBlock:^(FRTCMeetingStatusReason reason, NSString * _Nonnull errMsg) {
            if (kStringIsEmpty(errMsg)) { return; }
            [currentVC.navigationController.view hideToastActivity];
        } withInputPassCodeCallBack:^{
            [currentVC.navigationController.view hideToastActivity];
            [currentVC showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
                if (index == 1) {
                    [currentVC.navigationController.view makeToastActivity:CSToastPositionCenter];
                    [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                    [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
                }
                if (index == 0) {
                    [[FrtcCall frtcSharedCallClient] frtcHangupCall];
                }
            }];
            
        }];
    });
}

@end
