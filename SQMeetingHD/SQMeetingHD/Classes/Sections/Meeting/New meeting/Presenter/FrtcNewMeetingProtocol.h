#import <Foundation/Foundation.h>
@class FNewMeetingRoomListInfo;
@class FNewMeetingScheduleMeetingInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcNewMeetingProtocol <NSObject>

@optional

- (void)responseMeetingRoomSuccess:(NSArray <FNewMeetingRoomListInfo *> * _Nullable)result errMsg:(NSString * _Nullable)errMsg;

- (void)responseScheduleMeetingInfoSuccess:(FNewMeetingScheduleMeetingInfo * _Nullable)info errMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
