#import "FrtcUserModel.h"

#define FAccountFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FipadAccount.data"]


@implementation FrtcUserModel

+ (BOOL)saveUserInfo:(HDUserInfoModel *)userInfo{
    NSError *error = nil;
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userInfo requiringSecureCoding:NO error:&error];
    if (!error && userData) {
        return [userData writeToFile:FAccountFile atomically:YES];
    }else{
        return NO;
    }
}

+ (HDUserInfoModel *)fetchUserInfo{
    NSError *error = nil;
    NSSet *set = [NSSet setWithObjects:[NSArray class],[NSString class],[NSDictionary class],[HDUserInfoModel class],[NSNumber class],nil];
    HDUserInfoModel *userInfo = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:[NSData dataWithContentsOfFile:FAccountFile] error:&error];
    if (!error && userInfo) {
        return userInfo;
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
