#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcAccountProtocol <NSObject>

@optional

- (void)responseChangeUserPasswordWithSuccess:(BOOL)result;

@end

NS_ASSUME_NONNULL_END
