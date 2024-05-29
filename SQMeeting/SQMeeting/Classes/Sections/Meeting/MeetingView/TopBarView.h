#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TopBarViewDelegate <NSObject>

@optional

- (void)showStaticsView;

@end

@interface TopBarView : UIView

@property (strong, nonatomic)  UIButton *signalButton;

@property (nonatomic, strong) UIImageView *muteAudioImageView;

@property (nonatomic, strong) UIImageView *muteVideoImageView;

@property (weak, nonatomic) id<TopBarViewDelegate> topBarViewDelegate;

@property (nonatomic, getter = isMuteMic) BOOL  muteMic;

@property (nonatomic, getter = isMuteCamera) BOOL  muteCamera;

@property (nonatomic, getter = isEncrypt) BOOL encrypt;

@property (nonatomic, getter = isAudioCall) BOOL audioCall;

- (instancetype)initWithFrame:(CGRect)frame withMuteMic:(BOOL)muteMic withMuteCamera:(BOOL)muteCamera withEncrypt:(BOOL)encrypt withAudioCall:(BOOL)audioCall;

- (void)reLayoutTopLayoutView:(BOOL)isMuteMic withCameraMute:(BOOL)isCameraMute;

@end

NS_ASSUME_NONNULL_END
