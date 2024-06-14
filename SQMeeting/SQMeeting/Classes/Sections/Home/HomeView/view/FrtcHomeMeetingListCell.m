#import "FrtcHomeMeetingListCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "FrtcScheduleDetailModel.h"
#import "UIImage+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"

@interface FrtcHomeMeetingListCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *accessibilityLabel;

@property (nonatomic, strong) UILabel *meetingStatus;
@property (nonatomic, strong) UIImageView *inviteImage;

@end

@implementation FrtcHomeMeetingListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        UIStackView *topStack = [[UIStackView alloc]init];
        topStack.axis = UILayoutConstraintAxisHorizontal;
        topStack.spacing = 10;
        [topStack addArrangedSubviews:@[self.titleLabel,self.inviteImage,self.meetingStatus]];
        
        UIStackView *verticalStackView = [[UIStackView alloc]init];
        verticalStackView.axis = UILayoutConstraintAxisVertical;
        verticalStackView.spacing = 8;
        [verticalStackView addArrangedSubviews:@[topStack,self.detailLabel]];
        
        UIStackView *horizontalStackView = [[UIStackView alloc]init];
        horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
        horizontalStackView.distribution = UIStackViewDistributionEqualSpacing;
        horizontalStackView.alignment = UIStackViewAlignmentCenter;
        [self.contentView addSubview:horizontalStackView];
        [horizontalStackView addArrangedSubviews:@[verticalStackView, self.accessibilityLabel]];
        
        [verticalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
        }];
        
        [horizontalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-5);
            make.bottom.top.mas_equalTo(0);
        }];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(KLeftSpacing, HomeMeetingListCellHeight - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setScheduledInfo:(FrtcScheduleDetailModel *)scheduledInfo {
    _scheduledInfo = scheduledInfo;
    self.titleLabel.text = _scheduledInfo.meeting_name;
    self.detailLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"call_number", nil), _scheduledInfo.meeting_number];
    self.meetingStatus.text = _scheduledInfo.meeting_statusStr;
    self.accessibilityLabel.text = _scheduledInfo.start_time;
    self.inviteImage.hidden = _scheduledInfo.isYourSelf;
}

- (void)setInfo:(FHomeMeetingListModel *)info {
    _info = info;
    self.titleLabel.text =  info.meetingName;
    self.detailLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"call_number", nil), info.meetingNumber];
    self.accessibilityLabel.text = [FrtcHelpers getDateStringWithTimeStr:info.historyMeetingStartTime];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark - lazy

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = KDetailTextColor;
        _detailLabel.font = [UIFont systemFontOfSize:13.f];
    }
    return _detailLabel;
}

- (UILabel *)accessibilityLabel {
    if (!_accessibilityLabel) {
        _accessibilityLabel = [[UILabel alloc]init];
        _accessibilityLabel.textColor = KDetailTextColor;
        _accessibilityLabel.font = [UIFont systemFontOfSize:13.f];
    }
    return _accessibilityLabel;
}

- (UILabel *)meetingStatus {
    if (!_meetingStatus) {
        _meetingStatus = [[UILabel alloc]init];
        _meetingStatus.textColor = UIColorHex(0xff7218);
        _meetingStatus.font = [UIFont boldSystemFontOfSize:12.f];
    }
    return _meetingStatus;
}

- (UIImageView *)inviteImage {
    if (!_inviteImage) {
        _inviteImage = [[UIImageView alloc]init];
        _inviteImage.hidden = YES;
        _inviteImage.image = [UIImage imageNamed:@"meeting_list_invite"];
        
        UILabel *title = [UILabel new];
        title.textColor = UIColor.whiteColor;
        title.font = [UIFont systemFontOfSize:12];
        title.text = NSLocalizedString(@"meeting_invited", nil);
        [_inviteImage addSubview:title];
        
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_inviteImage);
        }];
    }
    return _inviteImage;
}

@end
