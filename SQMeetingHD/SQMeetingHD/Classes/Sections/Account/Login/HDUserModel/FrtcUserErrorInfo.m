#import "FrtcUserErrorInfo.h"

@implementation FrtcUserErrorInfo

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.errorMessage = @"";
    NSString *errorCode = self.errorCode;
    if ([errorCode isEqualToString:kLoginErrorCode00]) {
        self.errorMessage = NSLocalizedString(@"user_psd_error", nil);
    }else if ([errorCode isEqualToString:kLoginErrorCode01]) {
        self.errorMessage = NSLocalizedString(@"user_login_error01", nil);
    }else if ([errorCode isEqualToString:kLoginErrorCode02]) {
        self.lock = YES;
        self.errorMessage = NSLocalizedString(@"user_login_error02", nil);;
    }else if ([errorCode isEqualToString:kLoginErrorCode03]) {
        self.errorMessage = NSLocalizedString(@"user_psd_error", nil);
    }else {
        self.errorMessage = NSLocalizedString(@"user_psd_error", nil);
    }
    return YES;
}

@end
