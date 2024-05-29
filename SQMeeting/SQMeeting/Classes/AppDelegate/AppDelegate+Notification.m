#import "AppDelegate+Notification.h"
#import "FrtcAuthorizationTool.h"
#import "FrtcScheduleMeetingDetailViewController.h"
#import "FrtcMeetingReminderDataManager.h"
#import "FrtcMeetingReminderView.h"
#import "FrtcManager.h"
#import "UIViewController+Extensions.h"
#import <objc/runtime.h>

@interface AppDelegate (Notification)

@property (nonatomic, strong) FrtcMeetingReminderView *reminderView;

@end

@implementation AppDelegate (Notification)

static const char *kReminderMeetingKey = "ReminderMeetingKey";

- (FrtcMeetingReminderView *)reminderView {
    return objc_getAssociatedObject(self, kReminderMeetingKey);
}

- (void)setReminderView:(FrtcMeetingReminderView *)reminderView {
    objc_setAssociatedObject(self, kReminderMeetingKey, reminderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNotificationDelegate {
    UNUserNotificationCenter* center = [UNUserNotificationCenter  currentNotificationCenter];
    center.delegate = self;
    
    [FrtcAuthorizationTool checkNotificationAuthorizationWithCompletion:^(BOOL granted) {
        
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *conten = request.content;
    NSDictionary *userInfo = conten.userInfo;
    
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    }else {
        if (!FrtcManager.inMeeting) {
            [[FrtcMeetingReminderDataManager sharedInstance].notifications addObject:userInfo];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (![FrtcMeetingReminderDataManager sharedInstance].hasShownAlert) {
                    [FrtcMeetingReminderDataManager sharedInstance].hasShownAlert = YES;
                    self.reminderView = [[FrtcMeetingReminderView alloc]init];
                    self.reminderView.notificationList = [FrtcMeetingReminderDataManager sharedInstance].notifications;
                    [self.reminderView show];
                    [[FrtcMeetingReminderDataManager sharedInstance].notifications removeAllObjects];
                }else{
                    if (self.reminderView) {
                        self.reminderView.notificationList = [FrtcMeetingReminderDataManager sharedInstance].notifications;
                        [[FrtcMeetingReminderDataManager sharedInstance].notifications removeAllObjects];
                    }
                }
            });
        }else{
            completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBadge);
        }
    }
    completionHandler(UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    
    UNNotificationRequest *request = response.notification.request;
    UNNotificationContent *conten = request.content;
    NSDictionary *userInfo = conten.userInfo;
    
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    }else {
        if (!FrtcManager.inMeeting) {
            FrtcScheduleMeetingDetailViewController *detailVC = [[FrtcScheduleMeetingDetailViewController alloc]init];
            detailVC.isPush = YES;
            detailVC.meetingId = userInfo[@"reservation_id"];
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:detailVC animated:YES];
        }
    }
    completionHandler();
}

@end
