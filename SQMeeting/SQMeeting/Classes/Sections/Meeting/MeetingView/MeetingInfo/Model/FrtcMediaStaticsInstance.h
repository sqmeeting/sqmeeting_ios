#import <Foundation/Foundation.h>
#import "FrtcMediaStaticsModel.h"
#import "FrtcStatisticalModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMediaStaticsInstance : NSObject

@property (nonatomic, assign) NSInteger upRate;

+ (FrtcMediaStaticsInstance *)share;

- (void)startGetMediaStatics;

- (void)stopGetMediaStatics;

@end

NS_ASSUME_NONNULL_END
