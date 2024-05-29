#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

- (void)setHomeViewRootViewController;
- (void)setEntryViewRootViewController;

- (void)resetRootViewController;

@end

