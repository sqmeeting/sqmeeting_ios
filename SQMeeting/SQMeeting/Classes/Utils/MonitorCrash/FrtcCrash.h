#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcCrash : NSObject

+ (void)registerHandler;

+ (void)signalRegister;

@end

NS_ASSUME_NONNULL_END
