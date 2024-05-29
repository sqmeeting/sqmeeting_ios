#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FAudioLevelBlock)(int audioLevel);

@interface FrtcAudioVideoAuthManager : NSObject

- (void)f_audioSizeChange:(FAudioLevelBlock)block;

- (void)f_stopAudioTimer;

+ (BOOL)isHeadsetPluggedIn;

+ (BOOL)isSpeakerMode;

@end

NS_ASSUME_NONNULL_END
