#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kRosterCellHeight 55

typedef void(^DidSelectedCellCallBack)(void);

@interface RosterListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatrImageView;
@property (nonatomic, strong) UIButton *audioImageBtn;
@property (nonatomic, strong) UIButton *videoImageBtn;
@property (nonatomic, strong) UIImageView *pinImageView;

@property (nonatomic, copy) DidSelectedCellCallBack didSelectedCell;

@end

NS_ASSUME_NONNULL_END
