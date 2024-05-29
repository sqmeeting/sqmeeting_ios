#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcUserModel : NSObject

+ (BOOL)saveUserInfo:(UserInfoModel *)userInfo;

+ (UserInfoModel *)fetchUserInfo;

+ (BOOL)deleteUserInfo;

@end

NS_ASSUME_NONNULL_END
