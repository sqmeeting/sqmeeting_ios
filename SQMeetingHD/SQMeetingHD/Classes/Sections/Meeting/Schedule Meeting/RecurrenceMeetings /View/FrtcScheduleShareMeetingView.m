#import "FrtcScheduleShareMeetingView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "NSBundle+FLanguage.h"
#import "FrtcInvitationInfoManage.h"
#import "FrtcScheduleDetailModel.h"
#import "UILabel+LineSpacing.h"

#define KHistoryMeetingHeight  250

static FrtcScheduleShareMeetingView *shareMeetingView = nil;
static ScheduleShareMeetingViewBlock shareMeetingResultBlock = nil;

@interface FrtcScheduleShareMeetingView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FrtcScheduleDetailModel *detailModel;
@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *topBtn;

@end

@implementation FrtcScheduleShareMeetingView

+ (void)showScheduleShareMeetingViewModel:(FrtcScheduleDetailModel *)model block:(ScheduleShareMeetingViewBlock)datePickerBlock {
    shareMeetingView = [[FrtcScheduleShareMeetingView alloc]initWithFrame:UIScreen.mainScreen.bounds model:model];
    shareMeetingResultBlock = datePickerBlock;
    shareMeetingView.detailModel = model;
    [[[UIApplication sharedApplication].delegate window] addSubview:shareMeetingView];
}

- (instancetype)initWithFrame:(CGRect)frame model:(FrtcScheduleDetailModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        _detailModel = model;
        
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = UIColor.clearColor;
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        bgView.userInteractionEnabled = YES;
        @WeakObj(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
        }];
        [bgView addGestureRecognizer:tap];

        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(kIPAD_WIDTH);
            make.centerX.equalTo(self);
        }];
        
        [self.contentView addSubview:self.topBtn];
        [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.top.mas_equalTo(25);
        }];
        
        UIView *lablelBGView = [[UIView alloc]init];
        lablelBGView.backgroundColor = UIColorHex(0xf6f8fb);
        [self.contentView addSubview:lablelBGView];
        [lablelBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.top.equalTo(self.topBtn.mas_bottom).mas_offset(25);
        }];
        
        UILabel *meetingLabel = [[UILabel alloc]init];
        meetingLabel.numberOfLines = 0;
        NSString *str = [NSString stringWithFormat:@"\n%@",[FrtcInvitationInfoManage getShareInvitationMeetingInfo:model]];
        meetingLabel.text = str;
        meetingLabel.backgroundColor = UIColorHex(0xf6f8fb);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:meetingLabel.text attributes:attributes];
        meetingLabel.attributedText = attributedString;
        meetingLabel.textColor = KTextColor;
        
        [lablelBGView addSubview:meetingLabel];
        [meetingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.top.bottom.equalTo(lablelBGView);
        }];
        
        [self.contentView addSubview:self.doneBtn];
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40));
            make.top.equalTo(meetingLabel.mas_bottom).offset(20);
            make.bottom.mas_equalTo(-KSafeAreaBottomHeight-10);
            make.centerX.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setCornerRadius:16 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)disMiss{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect rect =  self.contentView.frame;
        rect.origin.y = KScreenHeight;
        self.contentView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        shareMeetingView = nil;
        shareMeetingResultBlock = nil;
    }];
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
            [FrtcInvitationInfoManage shareInvitationMeetingInfo:self->_detailModel];
            [self disMiss];
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
