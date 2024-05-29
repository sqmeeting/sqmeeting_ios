#import "NSNotificationCenter+NotificationCenterAdditions.h"
#include <pthread.h>

@implementation NSNotificationCenter (NotificationCenterAdditions)

#pragma mark - private method

+ (void)doPostNotification:(NSDictionary *)info {
    NSString* aName = [info objectForKey:@"name"];
    id anObject = [info objectForKey:@"object"];
    NSDictionary* aUserInfo = [info objectForKey:@"userInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

#pragma mark - public method

- (void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject {
    [self postNotificationNameOnMainThread:aName object:anObject userInfo:nil];
}

- (void)postNotificationNameOnMainThread:(NSString *)aName object:(id )anObject userInfo:(NSDictionary *)aUserInfo {
    if (pthread_main_np()) {
        return [self postNotificationName:aName object:anObject userInfo:aUserInfo];
    }
    
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    if (aName != nil) {
        [info setObject:aName forKey:@"name"];
    }
    
    if (anObject != nil) {
        [info setObject:anObject forKey:@"object"];
    }
    
    if (aUserInfo != nil) {
        [info setObject:aUserInfo forKey:@"userInfo"];
    }
    
    [[self class] performSelectorOnMainThread:@selector(doPostNotification:) withObject:info waitUntilDone:NO];

    info = nil;
}

@end
