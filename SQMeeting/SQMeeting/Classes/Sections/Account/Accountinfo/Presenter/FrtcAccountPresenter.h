#import <Foundation/Foundation.h>
#import "FrtcAccountProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcAccountPresenter : NSObject

- (void)bindAccountView:(id<FrtcAccountProtocol>)view;

- (void)modiyUserPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

@end

NS_ASSUME_NONNULL_END
