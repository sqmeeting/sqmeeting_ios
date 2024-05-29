#import <UIKit/UIKit.h>

@class SiteNameView;

NS_ASSUME_NONNULL_BEGIN

@interface MuteSiteNameView : UIView

@property (nonatomic, strong) UIView      *backGroudView;
@property (nonatomic, strong) UIImageView *backGroudImageView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) SiteNameView *siteNameView;

@property (nonatomic, getter=isLocalView) BOOL localView;
@property (nonatomic, strong) UIImageView *localImageView;

@end

NS_ASSUME_NONNULL_END
