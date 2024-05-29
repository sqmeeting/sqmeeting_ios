#import <Foundation/Foundation.h>
#import "HDUserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcUserModel : NSObject

+ (BOOL)saveUserInfo:(HDUserInfoModel *)userInfo;

+ (HDUserInfoModel *)fetchUserInfo;

+ (BOOL)deleteUserInfo;

@end

NS_ASSUME_NONNULL_END
