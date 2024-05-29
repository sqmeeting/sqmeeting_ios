#import "FrtcNewMeetingRoomListModel.h"
#import "YYModel.h"

@implementation FNewMeetingScheduleMeetingInfo
@end

@implementation FNewMeetingRoomListInfo
@end

@implementation FrtcNewMeetingRoomListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"meeting_rooms" : [FNewMeetingRoomListInfo class]};
}

@end
