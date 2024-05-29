#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AskToUnmuteDelegate <NSObject>

- (void)unMute;

- (void)stayMute;

@end

@interface AskToUnmuteView : UIView

@property (nonatomic, weak) id<AskToUnmuteDelegate> delegate;

- (void)updateAskUnMuteView;

@end

NS_ASSUME_NONNULL_END
