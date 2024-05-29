#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcEntryViewController : BaseViewController

@property (nonatomic, strong) UIImageView *backGroundView;

@property (nonatomic, assign, getter=isInitialized) BOOL initialized;

@end

NS_ASSUME_NONNULL_END
