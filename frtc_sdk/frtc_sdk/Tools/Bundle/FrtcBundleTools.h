#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcBundleTools : NSObject

+ (NSString *)getBundlePath: (NSString *) assetName;

+ (NSBundle *)getBundle;

@end

NS_ASSUME_NONNULL_END
