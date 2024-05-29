//
//  UIViewController+hack.m
//  FrtcMeetingHD
//
//  Created by yafei on 2022/3/14.
//

#import "UIViewController+hack.h"

@implementation UIViewController (hack)

+ (void)load
{
    
    SEL orig_present = @selector(presentViewController:animated:completion:);
    SEL swiz_present = @selector(swiz_presentViewController:animated:completion:);
    [UIViewController swizzleMethods:[self class] originalSelector:orig_present swizzledSelector:swiz_present];
}

//exchange implementation of two methods
+ (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel
{
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    //class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        //origMethod and swizMethod already exist
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

- (void)swiz_presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void(^)(void))completion
{
    if ([vc isKindOfClass:NSClassFromString(@"RPBroadcastPickerStandaloneViewController")]) {
        // 保存这个vc，在适当的时机调用DismissViewController
        NSLog(@"12345678");
    }
    if (self.presentedViewController == nil) {
            [self swiz_presentViewController:vc animated:animated completion:completion];
    }
}

@end
