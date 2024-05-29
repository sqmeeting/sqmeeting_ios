#import "FrtcRecurrenceDatePickerView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcScheduleDatePickerHeaderView.h"
#import "UIView+Extensions.h"
#import "NSBundle+FLanguage.h"

#define KHistoryMeetingHeight  250

static FrtcRecurrenceDatePickerView *datePickerView = nil;
static RecurrenceDatePickerViewBlock datePickerResultBlock = nil;

@interface FrtcRecurrenceDatePickerView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSString *timeStamp;
@property (nonatomic, strong) NSDate *dafaultDate;
@property (nonatomic, strong) NSDate *maxDate;

@end

@implementation FrtcRecurrenceDatePickerView

+ (void)showRecurrenceDatePickerViewWithDefaultDate:(NSDate *)dafaultDate
                                            maxDate:(NSDate *)maxDate
                                              block:(RecurrenceDatePickerViewBlock)datePickerBlock {
    datePickerView = [[FrtcRecurrenceDatePickerView alloc]initWithFrame:UIScreen.mainScreen.bounds
                                                         dafaultDate:dafaultDate
                                                             maxDate:maxDate];
    datePickerView.timeStamp   = f_millisecondsFromDate(dafaultDate);
    datePickerResultBlock      = datePickerBlock;
    datePickerView.dafaultDate = dafaultDate;
    datePickerView.maxDate     = maxDate;
    [[[UIApplication sharedApplication].delegate window] addSubview:datePickerView];
}


- (instancetype)initWithFrame:(CGRect)frame dafaultDate:(NSDate *)dafaultDate maxDate:(NSDate *)maxDate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = UIColor.whiteColor;
        CGFloat width = kIPAD_WIDTH;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(width);
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
        headerView.titleLabel.text = NSLocalizedString(@"recurrence_dueDate", nil);
        [self.contentView addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        datePicker.date = dafaultDate;
        [datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[NSBundle currentLanguage]]];
        datePicker.backgroundColor = UIColor.brownColor;
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.minimumDate = [NSDate date];
        datePicker.minuteInterval = 1;
        datePicker.maximumDate = maxDate;
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
        datePickerView = nil;
        datePickerResultBlock = nil;
    }];
}

#pragma mark - UIDatePicker change

- (void)dateChange:(UIDatePicker *)date
{
    NSDate *selectedDate = date.date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:selectedDate];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *endDate = [calendar dateFromComponents:components];
    _timeStamp  = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970] * 1000];
}

@end
