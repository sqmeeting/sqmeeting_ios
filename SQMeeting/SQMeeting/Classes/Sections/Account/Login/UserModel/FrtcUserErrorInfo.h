#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kLoginErrorCode00 @"0x00003000"
#define kLoginErrorCode01 @"0x00003001"
#define kLoginErrorCode02 @"0x00003002"
#define kLoginErrorCode03 @"0x00003003"

@interface FrtcUserErrorInfo : NSObject

@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, getter=isLock) BOOL lock;

@end

NS_ASSUME_NONNULL_END
