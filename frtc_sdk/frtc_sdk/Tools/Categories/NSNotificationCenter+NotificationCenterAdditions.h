#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (NotificationCenterAdditions)

- (void)postNotificationNameOnMainThread:(NSString *)aName object:(id __nullable)anObject;
- (void)postNotificationNameOnMainThread:(NSString *)aName object:(id __nullable)anObject userInfo:(NSDictionary * __nullable)aUserInfo;

@end

NS_ASSUME_NONNULL_END
