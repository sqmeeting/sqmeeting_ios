#import <Foundation/Foundation.h>
#import "FrtcScheduleDetailModel.h"
#import "FrtcHomeMeetingDetailProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcScheduleListResultProtocol <NSObject>

@optional

- (void)responseScheduledMeetingListData:(FScheduleListDataModel * _Nullable)resultList errMsg:(NSString * _Nullable)errMsg;

- (void)responseScheduledMeetingDetail:(NSArray<FHomeDetailMeetingInfo * > * _Nullable)detailList detailInfo:(FrtcScheduleDetailModel * _Nullable)detailInfo errMsg:(NSString * _Nullable)errMsg;

- (void)responseDeleteMeetingResult:(BOOL)result errMsg:(NSString * _Nullable)errMsg;

- (void)responseDetailDataResult:(FrtcScheduleDetailModel *_Nullable)model errMsg:(NSString * _Nullable)errMsg;

- (void)responseGroupListDetail:(FScheduleListDataModel *_Nullable)model errMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
