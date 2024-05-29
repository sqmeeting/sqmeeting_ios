#import <Foundation/Foundation.h>
#import "FrtcCall.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SDKCallStateAction)(void);

@interface FrtcMeetingStatusMachineTransition : NSObject

@property (nonatomic) FRTCMeetingStatus currentStatus;

@property (nonatomic) FRTCMeetingStatus newMeetingStatus;

@property (nonatomic, copy) SDKCallStateAction action;

- (id)initWithCurrentCallState:(FRTCMeetingStatus)currentStatus
                  newCallState:(FRTCMeetingStatus)newstatus
                     andAction:(SDKCallStateAction)selectorAction;

@end

NS_ASSUME_NONNULL_END
