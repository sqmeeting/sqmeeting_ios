#import <Foundation/Foundation.h>
#import "FrtcSignLoginProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FrtcSignLoginPresenter : NSObject

- (void)bindView:(id<FrtcSignLoginProtocol>)view;

- (void)requestLoginWithName:(NSString *)name password:(NSString *)password;

- (void)requestLogOut;

+ (void)refreshUserToken;

@end

NS_ASSUME_NONNULL_END
