#import "FrtcErrorInfo.h"

@implementation FrtcErrorInfo

+ (NSString *)getErrorWithCode:(NSInteger)code {

    NSString *errorMsg = @"";
    switch (code) {
        case NSURLErrorUnknown: //-1
            errorMsg = NSLocalizedString(@"network_error_1", nil);
            break;
        case NSURLErrorCancelled: //-999
            errorMsg = NSLocalizedString(@"network_error_999", nil);
            break;
        case NSURLErrorTimedOut: //-1001
            errorMsg = NSLocalizedString(@"meeting_network_error", nil);
            break;
        case NSURLErrorUnsupportedURL: //-1002
            errorMsg = NSLocalizedString(@"network_error_1002", nil);
            break;;
        case NSURLErrorBadServerResponse: //-1011
            errorMsg = NSLocalizedString(@"network_error_1011", nil);
            break;
        case NSURLErrorCannotParseResponse: //-1017
            errorMsg = NSLocalizedString(@"network_error_1017", nil);
            break;
        default:
            errorMsg = NSLocalizedString(@"network_error", nil);
            break;
    }
    return errorMsg;
}

@end
