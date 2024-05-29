#import "FrtcStopDateView.h"
#import "Masonry.h"
#import "FrtcRecurrenceDatePickerView.h"

@interface FrtcStopDateView ()

@property (nonatomic, strong) UIButton *stopDateButton;
@property (nonatomic, strong) NSString *meetingStartTime;

@end


@implementation FrtcStopDateView

- (instancetype)initWithFrame:(CGRect)frame defaultDate:(NSString *)defaultDate; 

{
    self = [super initWithFrame:frame];
    if (self) {
        _meetingStartTime = defaultDate;
        [self loadView];
    }
    return self;
}


- (void)setStopDate:(NSDate *)stopDate {
    _stopDate = stopDate;
    [self.stopDateButton setTitle:f_getDateForNSDate(stopDate) forState:UIControlStateNormal];
}

- (void)loadView{
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = FLocalized(@"recurrence_dueDate", nil);
    titleLabel.textColor = KTextColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.centerY.equalTo(self);
    }];
    
    UIImageView *righLabel = [[UIImageView alloc]init];
    righLabel.image = [[UIImage imageNamed:@"frtc_meetingDetail_right"]
                       imageWithTintColor:KDetailTextColor];
    [self addSubview:righLabel];
    [righLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing12);
        make.centerY.equalTo(self);
    }];
    
    self.stopDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stopDateButton setTitle:@"" forState:UIControlStateNormal];
    [self.stopDateButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [self.stopDateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.stopDateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    //self.stopDateButton.backgroundColor = UIColor.redColor;
    [self.stopDateButton addTarget:self action:@selector(didStopDatePickerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopDateButton];
    [self.stopDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- KLeftSpacing);
        make.left.equalTo(titleLabel.mas_right);
        make.centerY.equalTo(self);
    }];
    
}

- (void)didStopDatePickerAction:(UIButton *)sender {
    @WeakObj(self)
    NSString *yearLaterMill = f_calculateOneYearLaterEvent(_meetingStartTime);
    NSDate *yearLaterDate = f_dateFromMilliseconds(yearLaterMill);
    [FrtcRecurrenceDatePickerView showRecurrenceDatePickerViewWithDefaultDate:_stopDate
                                                                   maxDate:yearLaterDate
                                                                     block:^(NSString * _Nonnull timeStamp) {
        @StrongObj(self)
        self->_stopDate = f_dateFromMilliseconds(timeStamp);

        [self.stopDateButton setTitle:f_formattedDateStringFromTimestamp(timeStamp) forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(didSelectedStopDate:)]) {
            [self.delegate didSelectedStopDate:timeStamp];
        }
    }];
}

@end
