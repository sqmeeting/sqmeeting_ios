#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kToolBarHeight 88

@protocol TalkingToolBarViewDelegate <NSObject>

- (void)participent;

- (void)hiddenLocalView:(BOOL)hidden;

- (void)muteCamera:(BOOL)mute;

- (void)muteMicroPhone:(BOOL)mute;

- (void)shareContent:(BOOL)isShare;

- (void)clickMoreBtn:(UIButton *)button;

@end

@interface TalkingToolBarView : UIView

@property (strong, nonatomic)  UIButton *btnMuteMicrophone;
@property (strong, nonatomic)  UIButton *btnTurnOffCamera;
@property (strong, nonatomic)  UIButton *btnFloatingFrame;
@property (strong, nonatomic)  UIButton *btnParticipent;
@property (strong, nonatomic)  UIButton *btnShareContent;
@property (strong, nonatomic)  UIButton *btnMore;
@property (strong, nonatomic)  UIView   *redDotView;

@property (nonatomic, getter=isAudioCall) BOOL audioCall;
@property (nonatomic, getter=isSharingContent) BOOL sharingContent;

@property (nonatomic, weak) id<TalkingToolBarViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withAudioCall:(BOOL)audioCall;

- (void)updateMicrophoneImageForValue:(int)microphoneValue;

@end

NS_ASSUME_NONNULL_END
