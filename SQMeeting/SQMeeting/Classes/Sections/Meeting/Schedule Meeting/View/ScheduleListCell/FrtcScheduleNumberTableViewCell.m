#import "FrtcScheduleNumberTableViewCell.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIImage+Extensions.h"
#import "FrtcHistoryMeetingListView.h"
#import "FrtcNewMeetingRoomListModel.h"

@interface FrtcScheduleNumberTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation FrtcScheduleNumberTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        [self configView];
    }
    return self;
}

- (void)dealloc {
   
}

- (void)configView {
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:stackView];
    
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(50);
    }];
    
    [stackView addArrangedSubviews:@[self.nameLabel,self.noiseSwitch]];
    
    [self.meetingNumberBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.equalTo(stackView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
}

- (void)setMeetingRoomList:(NSArray<FNewMeetingRoomListInfo *> *)meetingRoomList {
    _meetingRoomList = meetingRoomList;
    self.meetingNumbertextField.text = _meetingRoomList[0].meeting_number;
    self.meetingNumberBottomView.hidden = NO;
}

#pragma mark - action

- (void)popUpHistoryMeetingVC {
    if (self.popUpPersonalNumber) {
        self.popUpPersonalNumber();
    }
}

#pragma mark - lazy

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = NSLocalizedString(@"meeting_user_people_number", nil);
        _nameLabel.font = [UIFont systemFontOfSize:16.f];
        _nameLabel.textColor = KTextColor;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UISwitch *)noiseSwitch {
    if (!_noiseSwitch) {
        _noiseSwitch = [UISwitch new];
        @WeakObj(self);
        [_noiseSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            UISwitch *noiseSwitch = (UISwitch *)sender;
            @StrongObj(self)
            if (!noiseSwitch.isOn) {
                self.meetingNumberBottomView.hidden = YES;
            }
            if (self.numberSwitchCallBack) {
                self.numberSwitchCallBack(noiseSwitch.isOn);
            }
        }];
        _noiseSwitch.onTintColor = kMainColor;
        [self.contentView addSubview:_noiseSwitch];
    }
    return _noiseSwitch;
}

- (UIView *)meetingNumberBottomView {
    if (!_meetingNumberBottomView) {
        _meetingNumberBottomView = [[UIView alloc]init];
        _meetingNumberBottomView.hidden = YES;
        _meetingNumberBottomView.layer.borderColor = KLineColor.CGColor;
        _meetingNumberBottomView.layer.borderWidth = 1.0;
        _meetingNumberBottomView.layer.cornerRadius = KCornerRadius;
        _meetingNumberBottomView.layer.masksToBounds = YES;
        [self.contentView addSubview:_meetingNumberBottomView];
        UIStackView *stackView = [UIStackView new];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        [_meetingNumberBottomView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.right.mas_equalTo(-14);
            make.top.bottom.mas_equalTo(0);
        }];
        [stackView addArrangedSubviews:@[self.meetingNumbertextField,self.rightBtn]];
    }
    return _meetingNumberBottomView;
}

- (UITextField *)meetingNumbertextField {
    if (!_meetingNumbertextField) {
        _meetingNumbertextField = [UITextField new];
        _meetingNumbertextField.enabled =  NO;
        _meetingNumbertextField.placeholder = NSLocalizedString(@"please_you_meetingN", nil);
        _meetingNumbertextField.borderStyle = UITextBorderStyleNone;
    }
    return _meetingNumbertextField;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        @WeakObj(self);
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"btn_more_normal_22x22_"] forState:UIControlStateNormal];
        [_rightBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self popUpHistoryMeetingVC];
        }];
    }
    return _rightBtn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
