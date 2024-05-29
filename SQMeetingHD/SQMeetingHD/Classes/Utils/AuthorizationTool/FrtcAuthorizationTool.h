#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcAuthorizationTool : NSObject

+ (void)checkNotificationAuthorizationWithCompletion:(void (^) (BOOL granted))completion;

@end

NS_ASSUME_NONNULL_END
