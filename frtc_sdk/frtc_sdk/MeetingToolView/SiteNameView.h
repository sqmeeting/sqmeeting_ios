#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SiteNameView : UIView

@property (nonatomic, copy) NSString *nameStr;

@property (nonatomic, assign, getter=isPinStatus) BOOL pinStatus;

@property (nonatomic, assign, getter=isUserMuteStatus) BOOL userMuteStatus;

- (void)setSiteNameWithUserPinStatus:(BOOL)pin;

- (void)renewSiteNameViewByUserMuteStatus:(BOOL)userMute;

@end

NS_ASSUME_NONNULL_END
