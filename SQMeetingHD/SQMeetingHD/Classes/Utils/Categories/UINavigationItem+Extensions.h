#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationItem (Extensions)

- (void)initWithLeftButtonTitle:(NSString *)leftButtonTitle
                           back:(void(^)())back;

- (void)initWithLeftButtonTitleCallBack:(void(^)())back;

- (void)initWithLeftButtonImage:(NSString *)leftButtonImage
                           back:(void(^)())back;

- (void)initWithRightButtonTitle:(NSString *)RightButtonTitle
                            back:(void(^)())back;

- (void)initWithRightImage:(NSString *)imageStr
                      back:(void(^)())back;

@end

NS_ASSUME_NONNULL_END
