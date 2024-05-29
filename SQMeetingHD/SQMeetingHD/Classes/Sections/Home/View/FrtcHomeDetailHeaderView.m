#import "FrtcHomeDetailHeaderView.h"
#import "FrtcScheduleDetailModel.h"
#import "Masonry.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"

@interface FrtcHomeDetailHeaderView ()
@property (nonatomic, strong) UILabel *meetingNameLabel;
@property (nonatomic, strong) UIView  *headerView;
@end

@implementation FrtcHomeDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.meetingNameLabel];
        [self.meetingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(20);
            make.centerX.equalTo(self);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(8);
        }];
        
        [self loadHeaderView];
        
        UIView *lineLayer = [[UIView alloc]init];
        lineLayer.backgroundColor = KLineColor;
        [self addSubview:lineLayer];
        [lineLayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)setDetailModel:(FrtcScheduleDetailModel *)detailModel {
    _detailModel = detailModel;
    self.meetingNameLabel.text = detailModel.meeting_name;
    if (detailModel.isRecurrence) {
        self.headerView.hidden = NO;
        self.heaer_duplicateLabel.text = detailModel.recurrenceInterval_result;
    }else{
        self.headerView.hidden = YES;
        [self.meetingNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
    }
    [self.headerView addGradientWithStartColor:UIColorHex(0xe5fff1) endColor:UIColor.whiteColor];
}

#pragma mark - lazy

- (UILabel *)meetingNameLabel {
    if (!_meetingNameLabel) {
        _meetingNameLabel = [[UILabel alloc]init];
        _meetingNameLabel.textColor = KTextColor;
        _meetingNameLabel.font = [UIFont boldSystemFontOfSize:26];
    }
    return _meetingNameLabel;
}

- (void)loadHeaderView{
    
    self.headerView = [[UIView alloc]init];
    self.headerView.layer.borderColor = KRecurrenceColor.CGColor;
    self.headerView.layer.borderWidth = 1;
    self.headerView.layer.cornerRadius = 3;
    self.headerView.clipsToBounds = YES;
    self.headerView.userInteractionEnabled = YES;
    @WeakObj(self)
    [self.headerView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                           initWithActionBlock:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.didSelectRecurrenceView) {
            self.didSelectRecurrenceView();
        }
    }]];
    [self addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(KLeftSpacing12);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = FLocalized(@"recurrence_recurring", nil);
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.backgroundColor = KRecurrenceColor;
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
    }];
    [titleLabel addGradientWithStartColor:UIColorHex(0x3ec76e) endColor:UIColorHex(0x72e5a7)];

    self.heaer_duplicateLabel = [[UILabel alloc]init];
    self.heaer_duplicateLabel.text = [NSString stringWithFormat:@" "];
    self.heaer_duplicateLabel.textColor = KTextColor;
    self.heaer_duplicateLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:self.heaer_duplicateLabel];
    [self.heaer_duplicateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.equalTo(titleLabel.mas_right).mas_offset(8);
    }];
    
    UIImageView *rightImage = [[UIImageView alloc]init];
    rightImage.image = [UIImage imageNamed:@"frtc_meetingDetail_right"];
    rightImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.headerView addSubview:rightImage];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.heaer_duplicateLabel.mas_right).mas_offset(8);
        make.right.mas_equalTo(-KLeftSpacing12);
        make.centerY.equalTo(self.headerView);
    }];
}

@end

