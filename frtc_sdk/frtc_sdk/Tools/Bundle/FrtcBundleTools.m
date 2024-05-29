#import "FrtcBundleTools.h"

#define BUNDLE_NAME @"frtc_sdk_bundle"

@implementation FrtcBundleTools

+ (NSBundle *)getBundle {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:BUNDLE_NAME ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    return resourceBundle;
}
 
+ (NSString *)getBundlePath: (NSString *) assetName {
    NSBundle *myBundle = [FrtcBundleTools getBundle];
    
    if (myBundle && assetName) {
        return [[myBundle resourcePath] stringByAppendingPathComponent: assetName];
    }
     
    return nil;
}

@end
