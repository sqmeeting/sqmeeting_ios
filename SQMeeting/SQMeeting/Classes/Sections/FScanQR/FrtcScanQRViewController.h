#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcScanQRViewControllerDelegate <NSObject>

- (void)scanUrlResult:(NSString *)callUrl;

@end

@interface FrtcScanQRViewController : BaseViewController

@property (nonatomic, weak) id<FrtcScanQRViewControllerDelegate> scanDelegate;

@end

NS_ASSUME_NONNULL_END
