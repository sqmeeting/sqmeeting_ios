#import "FrtcHDErrorInfo.h"

@implementation FrtcHDErrorInfo

+ (NSString *)getErrorWithCode:(NSInteger)code {

    NSString *errorMsg = @"";
    switch (code) {
        case NSURLErrorUnknown:
            errorMsg = NSLocalizedString(@"network_error_1", nil);
            break;
        case NSURLErrorCancelled:
            errorMsg = NSLocalizedString(@"network_error_999", nil);
            break;
        case NSURLErrorTimedOut:
            errorMsg = NSLocalizedString(@"meeting_network_error", nil);
            break;
        case NSURLErrorUnsupportedURL:
            errorMsg = NSLocalizedString(@"network_error_1002", nil);
            break;;
        case NSURLErrorBadServerResponse:
            errorMsg = NSLocalizedString(@"network_error_1011", nil);
            break;
        case NSURLErrorCannotParseResponse:
            errorMsg = NSLocalizedString(@"network_error_1017", nil);
            break;
        default:
            errorMsg = NSLocalizedString(@"network_error", nil);
            break;
    }
    return errorMsg;
}

@end
