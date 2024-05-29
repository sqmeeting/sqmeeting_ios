#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FNewMeetingScheduleMeetingInfo : NSObject

@property (nonatomic, copy) NSString *meeting_name;
@property (nonatomic, copy) NSString *meeting_number;
@property (nonatomic, copy) NSString *meeting_password;
@property (nonatomic, copy) NSString *meeting_type;

@end

@interface FNewMeetingRoomListInfo : NSObject

@property (nonatomic, copy) NSString *created_time;
@property (nonatomic, copy) NSString *creator_id;
@property (nonatomic, copy) NSString *creator_name;
@property (nonatomic, copy) NSString *meeting_number;
@property (nonatomic, copy) NSString *meeting_password;
@property (nonatomic, copy) NSString *meetingroom_name;
@property (nonatomic, copy) NSString *meeting_room_id;
@property (nonatomic, copy) NSString *owner_id;
@property (nonatomic, copy) NSString *owner_name;

@end


@interface FrtcNewMeetingRoomListModel : NSObject

@property (nonatomic, strong) NSArray <FNewMeetingRoomListInfo *> *meeting_rooms;

@end

NS_ASSUME_NONNULL_END
