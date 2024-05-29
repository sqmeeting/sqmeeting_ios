#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcErrorInfo : NSObject

+ (NSString *)getErrorWithCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
