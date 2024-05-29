#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Orientations)

- (void)f_setNeedsUpdateOfSupportedInterfaceOrientations;

- (BOOL)f_rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

NS_ASSUME_NONNULL_END
