#import <UIKit/UIKit.h>

#define Status_Cell_Height 55

NS_ASSUME_NONNULL_BEGIN

typedef void (^SwitchEventValueChanged)(BOOL isOn);

@protocol HDStatusTableViewCellDelegate <NSObject>

- (void)signOut;

@end


@interface HDStatusTableViewCell : UITableViewCell

@property (nonatomic, copy) SwitchEventValueChanged valueChangeBlock;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, assign) BOOL isShowRightView;
@property (nonatomic, strong) UISwitch *noiseSwitch;

@property (nonatomic, strong) UIButton *signOutButton;

@property (nonatomic, weak) id <HDStatusTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
