#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define KLayoutBarHeight 56

@protocol TopLayoutBarViewProtocol <NSObject>

@optional

- (void)changeCameraPosition;

- (void)changeSpeakerStatus:(BOOL)isSpeaker;

- (void)dropCall;

- (void)showDropdownView;

@end


@interface TopLayoutBarView : UIView

@property (strong, nonatomic) UIButton *btnMuteSpeakder;

@property (strong, nonatomic) UIButton *btnChangeCamera;

@property (nonatomic, strong) UIImageView *middleImageView;

@property (nonatomic, strong) UILabel *meetingNameLable;

@property (nonatomic, strong) UILabel *meetingTimeLable;

@property (nonatomic, strong) UILabel *timeLabel;

@property (strong, nonatomic) UIButton *btnHangup;


@property (nonatomic, getter = isMuteMic) BOOL  muteMic;

@property (nonatomic, getter = isMuteCamera) BOOL  muteCamera;

@property (nonatomic, getter = isAudioCall) BOOL audioCall;

@property (weak, nonatomic) id<TopLayoutBarViewProtocol> delegate;

- (instancetype)initWithFrame:(CGRect)frame withMuteMic:(BOOL)muteMic withMuteCamera:(BOOL)muteCamera withAudioCall:(BOOL)audioCall;

@end

NS_ASSUME_NONNULL_END
