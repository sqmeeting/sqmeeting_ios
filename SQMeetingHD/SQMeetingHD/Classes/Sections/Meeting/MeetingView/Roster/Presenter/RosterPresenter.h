#import <Foundation/Foundation.h>
#import "RosterViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RosterPresenter : NSObject

- (void)bindView:(id<RosterViewProtocol>)view;

- (void)muteAllParticipantsWithMeetingNumber:(NSString *)meetingNumber
                                 allowUnmute:(BOOL)allowUnmute;

- (void)unMuteAllParticipantsWithMeetingNumber:(NSString *)meetingNumber;

- (void)muteParticipantWithMeetingNumber:(NSString *)meetingNumber
                             allowUnmute:(BOOL)allowUnmute
                         participantList:(NSArray<NSString *> *)participantList;

- (void)unMuteParticipantWithMeetingNumber:(NSString *)meetingNumber
                           participantList:(NSArray<NSString *> *)participantList;

- (void)updateParticipantInfoWithMeetingNumber:(NSString *)meetingNumber
                                   disPlayName:(NSString *)disPlayName
                                     userToken:(NSString *)userToken;

- (void)setLecturerWithMeetingNumber:(NSString *)meetingNumber
                         participant:(NSString *)participant;

- (void)unSetLecturerWithMeetingNumber:(NSString *)meetingNumber;

- (void)disconnectParticipantsWithMeetingNumber:(NSString *)meetingNumber
                                participantList:(NSArray<NSString *> *)participantList;

- (void)startTextOverlayWithMeetingNumber:(NSString *)meetingNumber
                                  content:(NSString *)content
                                   repeat:(NSNumber *)repeat
                                 position:(NSNumber *)position
                            enable_scroll:(NSNumber *)enable;

- (void)stopTextOverlayWithMeetingNumber:(NSString *)meetingNumber;

- (void)startRecordingWithMeetingNumber:(NSString *)meetingNumber;

- (void)stopRecordingWithMeetingNumber:(NSString *)meetingNumber;

- (void)startLiveWithMeetingNumber:(NSString *)meetingNumber livePassword:(NSString *)livePassword;

- (void)stopLiveWithMeetingNumber:(NSString *)meetingNumber;

- (void)requestUnmuteWithMeetingNumber:(NSString *)meetingNumber;

- (void)allowUnmuteWithMeetingNumber:(NSString *)meetingNumber parameters:(NSArray<NSString *> *)parameters;

- (void)pinParticipantWithMeetingNumber:(NSString *)meetingNumber parameters:(NSArray<NSString *> *)parameters;

- (void)unPinParticipantWithMeetingNumber:(NSString *)meetingNumber;

@end

NS_ASSUME_NONNULL_END

