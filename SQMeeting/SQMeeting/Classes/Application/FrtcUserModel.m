#import "FrtcUserModel.h"

#define FAccountFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FAccount.data"]

@implementation FrtcUserModel

+ (BOOL)saveUserInfo:(UserInfoModel *)userInfo{
    NSError *error = nil;
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userInfo requiringSecureCoding:NO error:&error];
    if (!error && userData) {
        return [userData writeToFile:FAccountFile atomically:YES];
    }else{
        return NO;
    }
}

+ (UserInfoModel *)fetchUserInfo{
    NSError *error = nil;
    NSSet *set = [NSSet setWithObjects:[NSArray class],[NSString class],[NSDictionary class],[UserInfoModel class],[NSNumber class],nil];
    UserInfoModel *userInfo = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:[NSData dataWithContentsOfFile:FAccountFile] error:&error];
    if (!error && userInfo) {
        return userInfo;
    }else{
    }
    return userInfo;
}

+ (BOOL)deleteUserInfo
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isExist = [fileMgr fileExistsAtPath:FAccountFile];
    if (isExist) {
        return [fileMgr removeItemAtPath:FAccountFile error:nil];
    }
    return YES;
}

@end
