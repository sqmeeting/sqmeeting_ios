#import "FrtcAccountPresenter.h"
#import <FrtcManagement.h>
#import "FrtcUserModel.h"
#import "MBProgressHUD+Extensions.h"

@interface FrtcAccountPresenter ()

@property (nonatomic, weak) id accountView;

@end

@implementation FrtcAccountPresenter

- (void)bindAccountView:(id<FrtcAccountProtocol>)view{
    _accountView = view;
}

- (void)modiyUserPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {
    
    [MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] modifyUserPasswordWithUserToken:[FrtcUserModel fetchUserInfo].user_token oldPassword:oldPassword newPassword:newPassword modifyCompletionHandler:^(FRTCSDKModifyPasswordResult result) {
        if (result == FRTCSDK_MODIFY_PASSWORD_SUCCESS) {
            [self.accountView responseChangeUserPasswordWithSuccess:YES];
        }else{
            [self.accountView responseChangeUserPasswordWithSuccess:NO];
        }
    }];;
}

@end
