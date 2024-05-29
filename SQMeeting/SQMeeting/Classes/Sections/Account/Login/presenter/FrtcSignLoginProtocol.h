#import <Foundation/Foundation.h>
@class UserInfoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcSignLoginProtocol <NSObject>

@optional

- (void)loadLoginSuccess:(UserInfoModel * _Nullable )userInfo errMsg:(NSString * _Nullable)errMsg isLock:(BOOL)isLock;

- (void)responseLogOutResultWithSuccess:(BOOL)result errMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
