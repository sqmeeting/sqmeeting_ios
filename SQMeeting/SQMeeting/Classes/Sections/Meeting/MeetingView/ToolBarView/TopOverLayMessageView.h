#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TopOverLayMessageViewDelegate <NSObject>

- (void)repeateUpdateView;

@end

@interface TopOverLayMessageView : UIView

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) int repeateTime;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, weak) id<TopOverLayMessageViewDelegate> delegate;

- (void)updateView:(NSTimeInterval)duration;

- (void)configSize:(CGSize)size;

- (void)updateNewAnimation;

- (void)registerBecomeActiveNotification;

- (void)staticDisplayMessageView:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
