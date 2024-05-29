#import "AppDelegate+IQKeyboard.h"
#import "IQKeyboardManager.h"

@implementation AppDelegate (IQKeyboard)

- (void)initializationIQkeyboard {
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setShouldShowToolbarPlaceholder:YES];
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:NSLocalizedString(@"string_done", nil)];
}

@end
