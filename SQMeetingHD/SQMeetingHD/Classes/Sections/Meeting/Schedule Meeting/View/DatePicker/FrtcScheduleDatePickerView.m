#import "FrtcScheduleDatePickerView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcScheduleDatePickerHeaderView.h"
#import "UIView+Extensions.h"
#import "NSBundle+FLanguage.h"

#define KHistoryMeetingHeight  250

static FrtcScheduleDatePickerView *datePickerView = nil;
static DatePickerViewBlock datePickerResultBlock = nil;

@interface FrtcScheduleDatePickerView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, strong) NSString *minDate;
@property (nonatomic, strong) NSString *maxDate;
@property (nonatomic, strong) NSString *dafaultDate;

@end

@implementation FrtcScheduleDatePickerView

+ (void)showDatePickerViewWithMinimumDate:(NSString *)minDate
                                  maxDate:(NSString *)maxDate
                              DefaultDate:(NSString *)dafaultDate
                                dateBlock:(DatePickerViewBlock)datePickerBlock {

    datePickerView = [[FrtcScheduleDatePickerView alloc]initWithFrame:UIScreen.mainScreen.bounds
                                                           minDate:minDate
                                                           maxDate:maxDate
                                                       DefaultDate:dafaultDate];
    datePickerView.timeStamp = minDate;
    datePickerView.minDate = minDate;
    datePickerView.maxDate = maxDate;
    datePickerView.dafaultDate = dafaultDate;
    datePickerResultBlock = datePickerBlock;
    [[FrtcHelpers getCurrentVC].view addSubview:datePickerView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        [datePickerView disMiss];
    }];
    tap.delegate = datePickerView;
    [datePickerView addGestureRecognizer:tap];
}

- (instancetype)initWithFrame:(CGRect)frame minDate:(NSString *)minDate maxDate:(NSString *)maxDate DefaultDate:(NSString *)dafaultDate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.contentView];
        CGFloat width =kIPAD_WIDTH;
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(width);
            make.bottom.mas_equalTo(-80);
        }];
        
        FrtcScheduleDatePickerHeaderView *headerView = [FrtcScheduleDatePickerHeaderView new];
        @WeakObj(self);
        headerView.dateHeaderViewBlock = ^(BOOL index) {
            @StrongObj(self)
            if (index) {
                if (datePickerResultBlock) {
                    datePickerResultBlock(self.timeStamp);
                }
                [self disMiss];
            }else{
                [self disMiss];
            }
        };
        headerView.titleLabel.text = NSLocalizedString(@"meeting_start_time", nil);
        [self.contentView addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        [datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[NSBundle currentLanguage]]];
        datePicker.backgroundColor = UIColor.brownColor;
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.minuteInterval = 1;
        
        if (!kStringIsEmpty(dafaultDate)) {
            datePicker.date = f_dateFromMilliseconds(dafaultDate);
        }

        if (!kStringIsEmpty(minDate)) {
            datePicker.minimumDate = f_dateFromMilliseconds(minDate);
        }
        if (!kStringIsEmpty(maxDate)) {
            datePicker.maximumDate = f_dateFromMilliseconds(maxDate);
        }

        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        [datePicker addTarget:self action:@selector(dateChange:)forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:datePicker];
        [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setCornerRadius:16 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
}

- (void)disMiss{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect rect =  self.contentView.frame;
        rect.origin.y = KScreenHeight;
        self.contentView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        datePickerView = nil;
        datePickerResultBlock = nil;
    }];
}

#pragma mark - UIDatePicker change

- (void)dateChange:(UIDatePicker *)date
{
    _timeStamp  = [NSString stringWithFormat:@"%ld", (long)[date.date timeIntervalSince1970] * 1000];
}

@end
