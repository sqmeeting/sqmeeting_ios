
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RosterViewProtocol <NSObject>

@optional

- (void)muteAllResultWithMsg:(NSString * _Nullable)errMsg;

- (void)unMuteAllResultWithMsg:(NSString * _Nullable)errMsg;

- (void)muteOneOrListResultWithMsg:(NSString * _Nullable)errMsg;

- (void)unMuteOneOrListResultWithMsg:(NSString * _Nullable)errMsg;

- (void)updateParticipantInfoResultWithMsg:(NSString * _Nullable)errMsg;

- (void)setLecturerResultWithMsg:(NSString * _Nullable)errMsg;

- (void)unSetLecturerResultWithMsg:(NSString * _Nullable)errMsg;

- (void)disconnectParticipantsResultWithMsg:(NSString * _Nullable)errMsg;

- (void)startTextOverlayResultWithMsg:(NSString * _Nullable)errMsg;

- (void)stopTextOverlayResultWithMsg:(NSString * _Nullable)errMsg;

- (void)requestUnmuteResultMsg:(NSString * _Nullable)errMsg;

- (void)requestPeoplePinResultMsg:(NSString * _Nullable)errMsg;

@end

NS_ASSUME_NONNULL_END
