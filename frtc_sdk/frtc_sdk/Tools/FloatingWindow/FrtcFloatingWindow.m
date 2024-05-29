#import "FrtcFloatingWindow.h"

@implementation FrtcFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 13.0, *)) {
            self.windowScene = f_mainWindowScene();
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        self.windowLevel = 1000000;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.tag = 100000001;
    }
    return self;
}

- (void)destroy {
    self.hidden = YES;
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    self.rootViewController = nil;
}

id f_mainWindowScene(void) {
    __block id scene = nil;
    if (@available(iOS 13.0, *)) {
        [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UIWindowScene.class]) {
                UIWindowScene *windowScene = (UIWindowScene *)obj;
                if (windowScene.screen == UIScreen.mainScreen) {
                    scene = obj;
                    *stop = YES;
                }
            }
        }];
    }
    return scene;
}

@end
