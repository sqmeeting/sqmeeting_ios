#import "FrtcSignLoginPresenter.h"
#import "FrtcManagement.h"
#import "MBProgressHUD+Extensions.h"
#import "YYModel.h"
#import "HDUserInfoModel.h"
#import "FrtcUserModel.h"
#import "FrtcHDErrorInfo.h"
#import "FrtcUserDefault.h"
#import "FrtcUserErrorInfo.h"
#import "FrtcMeetingReminderDataManager.h"

@interface FrtcSignLoginPresenter ()

@property (nonatomic, weak) id view;

@end


@implementation FrtcSignLoginPresenter

- (void)bindView:(id<FrtcSignLoginProtocol>)view {
    _view = view;
}

- (void)requestLoginWithName:(NSString *)name password:(NSString *)password {
    [MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] loginWithUserName:name
                                            withPassword:password
                                            loginSuccess:^(NSDictionary * _Nonnull userInfo) {
        HDUserInfoModel *userModel = [HDUserInfoModel yy_modelWithDictionary:userInfo];
        BOOL isSave = [FrtcUserModel saveUserInfo:userModel];
        if (isSave) {
        }
        // Save login status
        [[FrtcUserDefault sharedUserDefault] setBool:YES forKey:LOGIN_STATUS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [self.view loadLoginSuccess:userModel errMsg:nil isLock:NO];
        });
    } loginFailure:^(NSError * _Nonnull error) {
        NSString *errorMsg = @"";
        NSDictionary *erroInfo = error.userInfo;
        NSData *data = [erroInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
        NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        FrtcUserErrorInfo *errorModel = [FrtcUserErrorInfo yy_modelWithJSON:errorString];
        if (errorModel.isLock) {
            [self.view loadLoginSuccess:nil errMsg:nil isLock:YES];
            return;
        }else{
            errorMsg = errorModel.errorMessage;
        }
        
        if (kStringIsEmpty(errorMsg)) {
            errorMsg = [FrtcHDErrorInfo getErrorWithCode:error.code];
        }
        [MBProgressHUD hideHUD];
        [self.view loadLoginSuccess:nil errMsg:errorMsg isLock:NO];
    }];
}

- (void)requestLogOut {
    NSString *userToken = [FrtcUserModel fetchUserInfo].user_token;
    if (kStringIsEmpty(userToken)) {return;}
    [MBProgressHUD showActivityMessage:@""];
    [self clearUserInformation];
    [[FrtcMeetingReminderDataManager sharedInstance] removeMeetingInfoFromLocalNotifications:@""];;
    [[FrtcManagement sharedManagement] setFRTCSDKConfig:FRTCSDK_SERVER_LOGOUT withSDKConfigValue:@""];
    [[FrtcManagement sharedManagement] logoutWithUserToken:userToken logoutSuccess:^(NSDictionary * _Nonnull userInfo) {
    } logoutFailure:^(NSError * _Nonnull error) {
    }];
}

- (void)clearUserInformation {
    [MBProgressHUD hideHUD];
    [[FrtcUserDefault sharedUserDefault] setBool:NO forKey:LOGIN_STATUS];
    [FrtcUserModel deleteUserInfo];
    if (self.view) {
        [self.view responseLogOutResultWithSuccess:YES errMsg:nil];
    }
}

+ (void)refreshUserToken {
    NSString *userToken = [FrtcUserModel fetchUserInfo].user_token;
    if (isLoginSuccess && !kStringIsEmpty(userToken)) {
        [[FrtcManagement sharedManagement] getLoginUserInfomation:userToken getInfoSuccess:^(NSDictionary * _Nonnull userInfo) {
            HDUserInfoModel *userModel = [HDUserInfoModel yy_modelWithDictionary:userInfo];
            BOOL isSave = [FrtcUserModel saveUserInfo:userModel];
            if (isSave) {
            }
        } getInfoFailure:^(NSError * _Nonnull error) {
            if (error.code == NSURLErrorBadServerResponse && [error.localizedDescription containsString:@"(401)"]) {
                FrtcSignLoginPresenter *loginPresenter = [FrtcSignLoginPresenter new];
                [loginPresenter requestLogOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTokenFailureNotification object:nil];
            }
        }];
    }
}


@end
