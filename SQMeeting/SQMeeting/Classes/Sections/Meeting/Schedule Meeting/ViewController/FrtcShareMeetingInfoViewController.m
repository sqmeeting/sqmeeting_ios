#import "FrtcShareMeetingInfoViewController.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcInvitationInfoManage.h"

@interface FrtcShareMeetingInfoViewController ()

@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *topBtn;
@property (strong, nonatomic) UILabel *meetingLabel;

@end

@implementation FrtcShareMeetingInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)configUI {
    
    [self.contentView addSubview:self.meetingLabel];
    [self.contentView addSubview:self.doneBtn];
    [self.contentView addSubview:self.topBtn];
    
    [self.contentView addSubview:self.topBtn];
    [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(25);
    }];
   
    [self.contentView addSubview:self.meetingLabel];
    [self.meetingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.equalTo(self.topBtn.mas_bottom).mas_offset(25);
    }];
    
    [self.contentView addSubview:self.doneBtn];
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.top.equalTo(self.meetingLabel.mas_bottom).offset(20);
        make.bottom.mas_equalTo(-KSafeAreaBottomHeight-10);
        make.centerX.equalTo(self.contentView);
    }];
}

- (UILabel *)meetingLabel {
    if (!_meetingLabel) {
        _meetingLabel = [[UILabel alloc]init];
        _meetingLabel.numberOfLines = 0;
        NSString *str = [NSString stringWithFormat:@"\n%@",[FrtcInvitationInfoManage getShareInvitationMeetingInfo:self.detailModel]];
        _meetingLabel.text = str;
        _meetingLabel.backgroundColor = UIColorHex(0xf6f8fb);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_meetingLabel.text attributes:attributes];
        _meetingLabel.attributedText = attributedString;
        _meetingLabel.textColor = KTextColor;
    }
    return _meetingLabel;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setImage:[UIImage imageNamed:@"frtc_copy"] forState:UIControlStateNormal];
        [_doneBtn setTitle:NSLocalizedString(@"meeting_inviteJoinCopy", nil) forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _doneBtn.layer.cornerRadius = 4;
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.backgroundColor = kMainColor;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        @WeakObj(self);
        [_doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [FrtcInvitationInfoManage shareInvitationMeetingInfo:self.detailModel];
        }];
    }
    return _doneBtn;
}

- (UIButton *)topBtn {
    if (!_topBtn) {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn setImage:[UIImage imageNamed:@"meeting_uploadlog_done"] forState:UIControlStateNormal];
        [_topBtn setTitle:FLocalized(@"recurrence_scheduledOK", nil) forState:UIControlStateNormal];
        [_topBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        _topBtn.backgroundColor = UIColor.whiteColor;
        _topBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.f];
    }
    return _topBtn;
}
@end
