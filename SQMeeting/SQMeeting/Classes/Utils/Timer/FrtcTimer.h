#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcTimer : NSObject

+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async;

+ (NSString *)timerTask:(id)target
               selector:(SEL)selector
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async;

+ (void)canelTimer:(NSString *)timerName;

+ (void)pauseTimer:(NSString *)timerName;

+ (void)continueTimer:(NSString *)timerName;

@end

NS_ASSUME_NONNULL_END
