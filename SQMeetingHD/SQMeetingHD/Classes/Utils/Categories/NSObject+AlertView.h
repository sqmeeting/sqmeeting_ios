#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AlertView)

- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
                   buttons:(NSArray * _Nullable)buttons
                 doneBlock:(void(^)(void))doneBlock;


- (void)showTextFieldWithTitle:(NSString * _Nullable)title
                   placeholder:(NSString * _Nullable)placeholder
                       buttons:(NSArray * _Nullable)buttons
                textFieldBlock:(void(^)(NSString *text))textBlock
                     doneBlock:(void(^)(void))doneBlock;
@end

NS_ASSUME_NONNULL_END
