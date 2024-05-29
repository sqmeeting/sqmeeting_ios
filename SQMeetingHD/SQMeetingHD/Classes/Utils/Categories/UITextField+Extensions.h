#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Extensions)

@property (nonatomic, assign) NSInteger fLengthLimit;

@property (nonatomic,copy) void (^didChangeBlock) (NSInteger);

- (NSRange)selectedRange;

- (void)setSelectedRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
