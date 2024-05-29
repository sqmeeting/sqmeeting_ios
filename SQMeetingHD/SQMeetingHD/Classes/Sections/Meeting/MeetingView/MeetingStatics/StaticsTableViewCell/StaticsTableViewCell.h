#import <UIKit/UIKit.h>
#import "MediaDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface StaticsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *participantLabel;

@property (nonatomic, strong) UILabel *channelLabel;

@property (nonatomic, strong) UILabel *formatLabel;

@property (nonatomic, strong) UILabel *rateUsedLabel;

@property (nonatomic, strong) UILabel *packetLostLable;

@property (nonatomic, strong) UILabel *jitterLabel;

@property (nonatomic, strong) UILabel *errorConcealmentLable;

- (void)updateCellInfomation:(MediaDetailModel *)model;

@end

NS_ASSUME_NONNULL_END
