#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcAVAuthManager : NSObject

+ (BOOL)isHeadsetPluggedIn;

+ (BOOL)isInReceiverMode;

+ (void)getAVAuthorization:(NSString *)mediaType
      withMeidaDescription:(NSString *)description
                  rootView:(UIViewController *)rootView;

+ (void)setAudioSessionPortOverride:(BOOL)isSpeaker;

+ (void)setAudioSessionCategoryOptions;

@end

NS_ASSUME_NONNULL_END
