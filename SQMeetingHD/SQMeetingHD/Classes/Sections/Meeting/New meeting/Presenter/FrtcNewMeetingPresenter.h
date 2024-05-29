#import <Foundation/Foundation.h>
#import "FrtcNewMeetingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcNewMeetingPresenter : NSObject

- (void)bindView:(id<FrtcNewMeetingProtocol>)view;

- (void)requestMeetingRoomList;

- (void)requestScheduleMeeting;

@end

NS_ASSUME_NONNULL_END
