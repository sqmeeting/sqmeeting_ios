#import "FrtcHomeScheduleCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "FrtcScheduleDetailModel.h"
#import "UIImage+Extensions.h"

@interface FrtcHomeScheduleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *inviteImage;
@property (nonatomic, strong) UILabel *meetingStatus;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *recurrenceLabel;

@property (nonatomic, strong) UIImageView *accessoryImgView;
@property (nonatomic, strong) NSMutableAttributedString *attributedStr;

@end

@implementation FrtcHomeScheduleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        UIStackView *topStack = [[UIStackView alloc]init];
        topStack.spacing = 10;
        [topStack addArrangedSubviews:@[self.titleLabel,self.meetingStatus]];
        
        UIView *bgView = [UIView new];
        [self.contentView addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-5);
            make.centerY.equalTo(self.contentView);
        }];
        
        [bgView addSubview:topStack];
        [topStack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(0);
        }];
        
        UIStackView *bottomStack = [[UIStackView alloc]init];
        bottomStack.spacing = 8;
        [bottomStack addArrangedSubviews:@[self.timeLabel,self.inviteImage,self.recurrenceLabel]];
                
        [bgView addSubview:bottomStack];
        [bottomStack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topStack.mas_bottom).mas_offset(8);
            make.left.bottom.mas_equalTo(0);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(KScreenWidth/1.5);
        }];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(KLeftSpacing, HomeScheduleCellHeight - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)setScheduledInfo:(FrtcScheduleDetailModel *)scheduledInfo {
    _scheduledInfo = scheduledInfo;
    self.titleLabel.text = _scheduledInfo.meeting_name;
    self.inviteImage.hidden = _scheduledInfo.isJoinYourself || _scheduledInfo.isYourSelf;
    self.recurrenceLabel.hidden = !_scheduledInfo.isRecurrence;
    self.meetingStatus.text = _scheduledInfo.meeting_statusStr;

    NSString *meetingNumber = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"call_number", nil), _scheduledInfo.meeting_number];
    NSString * showStr = [NSString stringWithFormat:@"%@    %@", _scheduledInfo.meeting_timeSlot,meetingNumber];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:showStr];
    [str addAttribute:NSForegroundColorAttributeName value:KTextColor666666 range:NSMakeRange(0,_scheduledInfo.meeting_timeSlot.length)];
     
    self.timeLabel.attributedText = str;
            
    self.meetingStatus.textColor = _scheduledInfo.isInMeeting ? UIColorHex(0x23d862) : UIColorHex(0xff7218);
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

- (UILabel *)meetingStatus {
    if (!_meetingStatus) {
        _meetingStatus = [[UILabel alloc]init];
        _meetingStatus.textColor = UIColorHex(0xff7218);
        _meetingStatus.font = [UIFont boldSystemFontOfSize:12.f];
    }
    return _meetingStatus;
}


- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = KDetailTextColor;
        _timeLabel.font = [UIFont systemFontOfSize:13.f];
    }
    return _timeLabel;
}

- (UIImageView *)accessoryImgView {
    if (!_accessoryImgView) {
        _accessoryImgView = [[UIImageView alloc]init];
        _accessoryImgView.image = [UIImage imageNamed:@"setting_accessory"];
        _accessoryImgView.clipsToBounds = YES;
        [self.contentView addSubview:_accessoryImgView];
    }
    return _accessoryImgView;
}

- (NSMutableAttributedString *)attributedStr {
    if (!_attributedStr) {
        _attributedStr = [[NSMutableAttributedString alloc]init];
    }
    return _attributedStr;
}

- (UILabel *)recurrenceLabel {
    if (!_recurrenceLabel) {
        _recurrenceLabel = [[UILabel alloc]init];
        _recurrenceLabel.hidden = YES;
        _recurrenceLabel.text = FLocalized(@"recurrence_recurring", nil);
        _recurrenceLabel.textColor = UIColor.whiteColor;
        _recurrenceLabel.backgroundColor = KRecurrenceColor;
        _recurrenceLabel.font = [UIFont systemFontOfSize:13.f];
        _recurrenceLabel.layer.cornerRadius = 3;
        _recurrenceLabel.layer.masksToBounds = YES;
    }
    return _recurrenceLabel;
}

@end
