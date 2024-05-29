#import "FrtcMeetingReminderDataManager.h"
#import <UserNotifications/UserNotifications.h>
#import "FrtcAuthorizationTool.h"

@interface FrtcMeetingReminderDataManager ()



@end

@implementation FrtcMeetingReminderDataManager

+ (instancetype)sharedInstance {
    static FrtcMeetingReminderDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notifications = [[NSMutableArray alloc]init];
        _hasShownAlert = NO;
    }
    return self;
}

+ (void)setAcceptMeetingReminders:(BOOL)isAccept {
    [[NSUserDefaults standardUserDefaults] setBool:isAccept forKey:@"AcceptMeetingReminders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAcceptMeetingReminders {
    return  ![[NSUserDefaults standardUserDefaults] boolForKey:@"AcceptMeetingReminders"];
}

- (void)addMeetingInfoToLocalNotifications:(NSArray<FrtcScheduleDetailModel *> *)infos {
    
    [self removeMeetingInfoFromLocalNotifications:@""];

    [infos enumerateObjectsUsingBlock:^(FrtcScheduleDetailModel * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (info.timeDiff > 5) {
            
            NSString *notificationId = info.reservation_id;
            
            [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                
                UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                content.title = [NSString localizedUserNotificationStringForKey:info.meeting_name arguments:nil];
                NSString *subtitle = [NSString stringWithFormat:@"%@  %@:%@",info.meeting_timeSlot,NSLocalizedString(@"MEETING_REMINDER_MEETINGOWNER", nil),info.owner_name];
                content.subtitle = [NSString localizedUserNotificationStringForKey:subtitle arguments:nil];
                content.sound = UNNotificationSound.defaultSound;
                content.userInfo = @{@"reservation_id":info.reservation_id,@"title":info.meeting_name,@"subtitle":subtitle,@"meeting_number":info.meeting_number,@"meeting_password":info.meeting_password};
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[info.schedule_start_time doubleValue]/1000];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
                if (dateComponents.minute < 5 && dateComponents.minute > 0) {
                    dateComponents.minute = (60 - dateComponents.minute);
                    dateComponents.hour -= 1;
                }if (dateComponents.minute == 0) {
                    dateComponents.minute = 60 - 5;
                    dateComponents.hour -= 1;
                }else{
                    dateComponents.minute -= 5;
                }
            
                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
                
                UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:notificationId content:content trigger:trigger];
                
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (error != nil) {
                    }
                }];
            }];
        }
    }];
}

- (void)removeMeetingInfoFromLocalNotifications:(NSString *)identifier {
    if (kStringIsEmpty(identifier)) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    }else {
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
    }
}

@end
