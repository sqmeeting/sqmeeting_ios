#import <UIKit/UIKit.h>
#import "CustomTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingPasscodeController : UIViewController

@property (nonatomic, strong) UIImageView *backGroundView;
@property (nonatomic, strong) UIImageView *passcodeMainView;
@property (nonatomic, strong) UILabel *passcodeLabel;

@property (nonatomic, strong) CustomTextField *setPwdTextOne;
@property (nonatomic, strong) CustomTextField *setPwdTextTwo;
@property (nonatomic, strong) CustomTextField *setPwdTextThree;
@property (nonatomic, strong) CustomTextField *setPwdTextFour;

@property (nonatomic, strong) UILabel *errorNotificationLabel;

@property (nonatomic, strong) UIButton *hangUpButton;

- (void)updateDiss;

- (void)updatePasscode;

@end


NS_ASSUME_NONNULL_END


