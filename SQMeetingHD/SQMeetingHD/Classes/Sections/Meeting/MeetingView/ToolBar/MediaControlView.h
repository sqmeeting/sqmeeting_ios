#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MediaControlViewDelegate <NSObject>

- (void)changeCameraPosition;

@end

@interface MediaControlView : UIView

@property (strong, nonatomic)  UIImageView *mediaControlBackView;

@property (strong, nonatomic)  UIButton *btnChangeCamera;

@property (weak, nonatomic) id<MediaControlViewDelegate> delegate;

@property (nonatomic, getter=isAudioCall) BOOL audioCall;

- (instancetype)initWithFrame:(CGRect)frame withAudioCall:(BOOL)audioCall;

@end

NS_ASSUME_NONNULL_END
