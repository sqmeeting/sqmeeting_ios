#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcHDScanQRViewControllerDelegate <NSObject>

- (void)scanUrlResult:(NSString *)callUrl;

@end

@interface FrtcHDScanQRViewController : UIViewController

@property (nonatomic, weak) id<FrtcHDScanQRViewControllerDelegate> scanDelegate;

@end

NS_ASSUME_NONNULL_END
