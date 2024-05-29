#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (Extensions)

- (void)removeAllTargets;

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block;

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block;

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
