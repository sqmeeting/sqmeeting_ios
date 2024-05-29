#import <UIKit/UIKit.h>

#define Status_Cell_Height 50

NS_ASSUME_NONNULL_BEGIN

typedef void (^SwitchEventValueChanged)(BOOL isOn);

@protocol StatusTableViewCellDelegate <NSObject>

- (void)signOut;

@end

@interface StatusTableViewCell : UITableViewCell

@property (nonatomic, copy) SwitchEventValueChanged valueChangeBlock;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, assign) BOOL isShowRightView;
@property (nonatomic, strong) UISwitch *noiseSwitch;
@property (nonatomic, strong) UIButton *signOutButton;

@property (nonatomic, weak) id <StatusTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
