#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParticipantListModel : NSObject

@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, assign, getter=isMuteAudio) BOOL muteAudio;
@property (nonatomic, assign, getter=isMuteVideo) BOOL muteVideo;
@property (nonatomic, assign, getter=isMe) BOOL me;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
