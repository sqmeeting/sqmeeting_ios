#import "FrtcPortraitView.h"

@implementation FrtcPortraitView

- (instancetype)init {
    if ([self isMemberOfClass:[FrtcPortraitView class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    } else {
        self = [super init];
        if (self) {
            [self registerNotification];
            return self;
        }
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([self isMemberOfClass:[FrtcPortraitView class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    } else {
        self = [super initWithFrame:frame];
        if (self) {
            [self registerNotification];
            return self;
        }
    }
    return nil;
}

- (void)dealloc {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
#pragma clang diagnostic pop
}

#pragma mark - Notification

- (void)registerNotification {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#pragma clang diagnostic pop
}

- (void)orientChange:(NSNotification *)noti {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self changeStatusBarOrientation:1];
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self changeStatusBarOrientation:0];
            break;
        default:
            break;
    }
}

- (void)changeStatusBarOrientation:(NSInteger)orientation {
    [self doesNotRecognizeSelector:_cmd];
}

@end
