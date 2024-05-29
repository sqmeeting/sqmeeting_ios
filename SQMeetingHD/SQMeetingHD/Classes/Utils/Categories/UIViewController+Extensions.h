#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FTextFieldPassword,
    FTextFieldRenamed,
} FTextFieldStyle;

@interface UIViewController (Extensions)

- (void)showSheetWithTitle:(NSString *)title
                   message:(NSString *)message
              buttonTitles:(NSArray <NSString *> *)buttonTitles
                alerAction:(void (^)(NSInteger index))alerAction;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
              buttonTitles:(NSArray <NSString *> *)buttonTitles
                alerAction:(void (^)(NSInteger index))alerAction;

- (void)showTextFieldAlertWithTitle:(NSString *)title
                     textFieldStyle:(FTextFieldStyle)style
                         alerAction:(void (^)(NSInteger index, NSString * alertString))alerAction;

- (void)showSheetWithTitle:(NSString *)title
                   message:(NSString *)message
                alerAction:(void (^)(NSString * alertString))alerAction;

- (void)presentHDViewController:(UIViewController *)viewControllerToPresent
                       animated:(BOOL)flag
                     completion:(void (^)(void))completion;

- (void)showPasswordAlertViewWithAlerAction:(void (^)(NSInteger index, BOOL isSelect))alerAction;

- (void)showRadioViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelTitles:(NSArray <NSString *> *)cancelTitles
                    alerAction:(void (^)(NSInteger index, bool isSelect))alerAction;

@end

NS_ASSUME_NONNULL_END
