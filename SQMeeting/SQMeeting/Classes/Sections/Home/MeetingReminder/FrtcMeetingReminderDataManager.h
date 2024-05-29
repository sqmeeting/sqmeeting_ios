#import <Foundation/Foundation.h>
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingReminderDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, assign) BOOL hasShownAlert;
@property (class, nonatomic, getter=isAcceptMeetingReminders) BOOL acceptMeetingReminders;

+ (instancetype)sharedInstance;

- (void)addMeetingInfoToLocalNotifications:(NSArray<FrtcScheduleDetailModel *> *)infos;

- (void)removeMeetingInfoFromLocalNotifications:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
