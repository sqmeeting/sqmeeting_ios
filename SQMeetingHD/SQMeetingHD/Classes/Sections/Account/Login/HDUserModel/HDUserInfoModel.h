#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDUserInfoModel : NSObject <NSCoding,NSSecureCoding>

@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *real_name;
@property (nonatomic, assign) NSInteger password_expired_time;
@property (nonatomic, copy) NSString *security_level;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *vmrs;
@property (nonatomic, copy) NSString *user_token;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSArray <NSString *> *role;
@property (nonatomic, assign, getter=isMeetingOperator) BOOL meetingOperator;
@property (nonatomic, assign, getter=isSystemAdmin) BOOL systemAdmin;
@property (nonatomic, assign, getter=isLevelHigh) BOOL levelHigh;

@end

NS_ASSUME_NONNULL_END
