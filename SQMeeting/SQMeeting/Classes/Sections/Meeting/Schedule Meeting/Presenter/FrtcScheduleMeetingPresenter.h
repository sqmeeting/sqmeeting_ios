#import <Foundation/Foundation.h>
#import "FrtcScheduleMeetingProtocol.h"
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleMeetingPresenter : NSObject

- (void)bindView:(id<FrtcScheduleMeetingProtocol>)view;

- (void)loadLocalScheduleMeetingListDataWithDetailModel:(FrtcScheduleDetailModel * _Nullable)model;

- (void)changeScheduleMeetingListDataWith:(NSIndexPath *)indexPath content:(NSString *)content;
- (void)changeScheduleMeetingListSwitchStatusWith:(NSIndexPath *)indexPath status:(BOOL)status;
- (void)changeScheduleMeetingListCustomInfo:(NSIndexPath *)indexPath customInfo:(id)customInfo;

- (void)addLocalScheduleListDataWith:(NSIndexPath *)indexPath;

- (void)getRateListDataWithRate:(NSString *)rate;

- (void)getJoiningTimeDataWithTime:(NSString *)selectTime;

- (void)requestCreateNonRecurrenceMeeting;

- (void)requestUpdateNonRecurrenceMeetingWithModel:(FrtcScheduleDetailModel *)model;

- (void)requestUserListDataWithPage:(NSInteger)pageNum filter:(NSString *)filter;

@end

NS_ASSUME_NONNULL_END
