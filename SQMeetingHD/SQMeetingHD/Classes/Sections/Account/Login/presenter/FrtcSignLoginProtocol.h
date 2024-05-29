#import <Foundation/Foundation.h>
@class HDUserInfoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcSignLoginProtocol <NSObject>

@optional

- (void)loadLoginSuccess:(HDUserInfoModel * _Nullable )userInfo errMsg:(NSString * _Nullable)errMsg isLock:(BOOL)isLock;

- (void)responseLogOutResultWithSuccess:(BOOL)result errMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
