#import <Foundation/Foundation.h>
#import "FrtcScheduleMeetingModel.h"
#import "FrtcScheduleCustomModel.h"
#import "FrtcInviteUserModel.h"
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcScheduleMeetingProtocol <NSObject>

@optional

- (void)responseScheduleMeetingListSuccess:(NSArray<NSArray *>* _Nullable)result errMsg:(NSString * _Nullable)errMsg;

- (void)responseRateListData:(NSArray<FrtcScheduleCustomModel *>* _Nullable)result;

- (void)responseJoiningTimeListData:(NSArray<FrtcScheduleCustomModel *>* _Nullable)result;

- (void)responseInviteUserListData:(FrtcInviteUserModel * _Nullable)result errMsg:(NSString * _Nullable)errMsg;

- (void)responseScheduleMeetingSuccess:(FrtcScheduleDetailModel * _Nullable)model errMsg:(NSString * _Nullable)errMsg;

- (void)responseupdateNonRecurrenceMeeting:(FrtcScheduleDetailModel * _Nullable)model  errMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
