#import "FrtcTimer.h"

@implementation FrtcTimer

static NSMutableDictionary *timers_;
dispatch_semaphore_t semaphore_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL) repeats
                  async:(BOOL)async{
    
    if (!task || start < 0 || (interval <= 0 && repeats)) {
        return nil;
    }
    
    dispatch_queue_t queue = async ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : dispatch_get_main_queue();
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);

    NSString *timerName = [NSString stringWithFormat:@"%zd", timers_.count];

    timers_[timerName] = timer;
    dispatch_semaphore_signal(semaphore_);
    
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self canelTimer:timerName];
        }
    });

    dispatch_resume(timer);
    
    return timerName;
}

+ (NSString*)timerTask:(id)target
              selector:(SEL)selector
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async{
    
    if (!target || !selector) return nil;
    
    return [self timerTask:^{
        
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
        
    } start:start interval:interval repeats:repeats async:async];
}

+ (void)canelTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    
    dispatch_source_t timer = timers_[timerName];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:timerName];
    }
    
    dispatch_semaphore_signal(semaphore_);
}

+ (void)pauseTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
        
    dispatch_source_t timer = timers_[timerName];
    if (timer) {
        dispatch_suspend(timer);
    }
}

+ (void)continueTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
        
    dispatch_source_t timer = timers_[timerName];
    if (timer) {
        dispatch_resume(timer);
    }
}


@end
