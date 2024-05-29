#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PEOPLE_VIDEO_AND_CONTENT_NUMBER 9

typedef NS_ENUM(NSInteger, MeetingLayoutNumber) {
    MEETING_LAYOUT_NUMBER_1,
    MEETING_LAYOUT_NUMBER_2,
    MEETING_LAYOUT_NUMBER_3,
    MEETING_LAYOUT_NUMBER_4,
    MEETING_LAYOUT_NUMBER_5,
    MEETING_LAYOUT_NUMBER_6,
    MEETING_LAYOUT_NUMBER_7,
    MEETING_LAYOUT_NUMBER_8,
    MEETING_LAYOUT_NUMBER_9,
    MEETING_LAYOUT_NUMBER
};

typedef struct MeetingLayoutDescription
{
    float peopleViewDetail[PEOPLE_VIDEO_AND_CONTENT_NUMBER + 2][4];
}SDKMeetingLayout;

@protocol MeetingLayoutContextDelegate

@optional
- (void)updateRemoteUserNumber:(MeetingLayoutNumber)number Views:(NSArray *)userArray;
@end

@interface MeetingLayoutContext : NSObject

+ (MeetingLayoutContext *)SingletonInstance;

@property (nonatomic, copy)   NSMutableArray *participantsList;
@property (nonatomic, assign) MeetingLayoutNumber meetingNumber;
@property (nonatomic, weak)   id<MeetingLayoutContextDelegate> delegate;

-(void)updateMeetingUserList:(NSMutableArray *)meetingUserList;

@end

NS_ASSUME_NONNULL_END
