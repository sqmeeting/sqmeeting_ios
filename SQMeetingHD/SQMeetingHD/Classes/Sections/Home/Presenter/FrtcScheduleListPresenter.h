#import <Foundation/Foundation.h>
#import "FrtcScheduleListResultProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleListPresenter : NSObject

- (void)bindView:(id<FrtcScheduleListResultProtocol>)view;

- (void)requestScheduledListDataWithPageNum:(NSInteger)pageNum;
- (NSArray *)handleTimeSectionWithData:(NSArray<FrtcScheduleDetailModel *> *)scheduleList;


- (void)requestScheduledDetailDataWithId:(NSString *)reservationId;

- (void)handelDetailDataWithInfo:(FrtcScheduleDetailModel *)info;

- (void)deleteScheduledMeetingWithId:(NSString *)reservationId;
void f_deleteScheduledMeetingWithId(NSString *reservationId, void (^resposeResult)(bool result, NSError * _Nonnull error));
- (void)deleteRecurrenceMeetingWithId:(NSString *)reservationId;

- (void)requestDetailDataWithId:(NSString *)reservationId;
void f_requestDetailDataWithId(NSString *reservationId, void (^ResponseResult)(FrtcScheduleDetailModel *detailInfo, NSString *errorMsg));

- (void)requestGroupListDataWithGroupId:(NSString *)groupId;

- (void)removeMeetingFromHomeList:(NSString *)identifier;

void f_addMeetingIntoHomeMeetingList(NSString *identifier);
void f_removeMeetingFromHomeList(NSString *identifier , void (^resposeResult)(bool result, NSError * _Nonnull error));

@end

NS_ASSUME_NONNULL_END
