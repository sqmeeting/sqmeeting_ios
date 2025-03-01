#import "UIViewController+Orientations.h"
#import "FrtcUIMacro.h"

@implementation UIViewController (Orientations)

- (void)f_setNeedsUpdateOfSupportedInterfaceOrientations {
    
    if (@available(iOS 16.0, *)) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
#else
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL supportedInterfaceSelector = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
            [self performSelector:supportedInterfaceSelector];
#pragma clang diagnostic pop
            
#endif
        });
        
    }
}

- (BOOL)f_rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        __block BOOL result = YES;
        UIInterfaceOrientationMask mask = 1 << interfaceOrientation;
        UIWindow *window = self.view.window ?: UIApplication.sharedApplication.delegate.window;
        [window.windowScene requestGeometryUpdateWithPreferences:[[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask] errorHandler:^(NSError * _Nonnull error) {
            if (error) {
                result = NO;
            }
        }];
        return result;
    }
#endif
    
    [[UIDevice currentDevice] setValue:@(interfaceOrientation) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
    
    return YES;
}

@end
