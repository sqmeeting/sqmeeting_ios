#import "FrtcCycleSettingViewController.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIStackView+Extensions.h"
#import "FrtcDuplicateDateSelectView.h"
#import "FrtcStopDateView.h"
#import "FrtcScheduleMeetingViewController.h"
#import "FrtcMeetingRecurrenceDateManager.h"
#import "UILabel+LineSpacing.h"

@interface FrtcCycleSettingViewController () <FrtcRecurSelectViewDelegate,FrtcDuplicateDateSelectViewDelegate,FrtcStopDateViewDelegate>
{
    NSString *_tempCycleValue;
    FRecurrenceType _tempCycleType;
    NSDate   *_tempStartDate;
    NSString *_tempStopDate;
}

@property (nonatomic, strong) UILabel *tooltipLabel;
@property (nonatomic, strong) FrtcRecurSelectView *recurSelectView;
@property (nonatomic, strong) FrtcDuplicateDateSelectView *duplicateWeekDateView;
@property (nonatomic, strong) FrtcDuplicateDateSelectView *duplicateMonthDateView;
@property (nonatomic, strong) FrtcStopDateView *stopDateView;

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentView;

@property (nonatomic, strong) NSMutableArray <NSString *> *tempWeekSelectList;
@property (nonatomic, strong) NSMutableArray <NSString *> *tempMonthSelectList;

@end

@implementation FrtcCycleSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = FLocalized(@"recurrence_end_series", nil);
    
    self->_tempCycleValue = @"1";
    self->_tempCycleType  = self.settingType;
    
    self->_tempStartDate = f_dateFromMilliseconds(self.startTime);
    
    [self configDefaultValue];
}

- (void)configDefaultValue {
    
    self.duplicateWeekDateView.hidden =
    self.duplicateMonthDateView.hidden = YES;
    
    NSString * dateSelectResult = @"";
    NSDate *stopDate ;
    
    if (self.settingType == FRecurrenceDay) {
        dateSelectResult = f_daysDateResultWithInterval(@"1");
        stopDate = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitDay, 1, kDafaultRecurrenceNumber);
    }else if (self.settingType == FRecurrenceWeek) {
        self.duplicateWeekDateView.hidden = NO;
        f_weekDateResultWithInterval(@"1", @[f_dayOfWeekForMilliseconds(self.startTime)]);
        dateSelectResult = f_weekDateResultWithInterval(@"1", @[f_dayOfWeekForMilliseconds(self.startTime)]);
        stopDate = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitWeekOfYear, 1, kDafaultRecurrenceNumber);
    }else if (self.settingType == FRecurrenceMonth) {
        self.duplicateMonthDateView.hidden = NO;
        dateSelectResult = f_monthDateResultWithInterval(@"1", @[f_dayOfDayForMilliseconds(self.startTime)]);
        stopDate = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitMonth, 1, kDafaultRecurrenceNumber);
    }
    
    if (self.editSettingModel && (self.editSettingModel.recurrent_Enum_Type == self.settingType)) {
        self->_tempCycleValue = self.editSettingModel.recurrentInterval;
        stopDate = f_dateFromMilliseconds(self.editSettingModel.recurrentStopTime);
        
        if (self.editSettingModel.recurrent_Enum_Type == FRecurrenceDay) {
            dateSelectResult = f_daysDateResultWithInterval(self.editSettingModel.recurrentInterval);
        }else if (self.editSettingModel.recurrent_Enum_Type == FRecurrenceWeek) {
            dateSelectResult = f_weekDateResultWithInterval(self.editSettingModel.recurrentInterval ,f_convertToChineseWeekday(self.editSettingModel.recurrentDaysOfWeek));
        }else if (self.editSettingModel.recurrent_Enum_Type == FRecurrenceMonth) {
            dateSelectResult = f_monthDateResultWithInterval(self.editSettingModel.recurrentInterval ,self.editSettingModel.recurrentDaysOfMonth);
        }
    }
    self->_tempStopDate = f_millisecondsFromDate(stopDate);
    self.tooltipLabel.text = dateSelectResult;
    self.stopDateView.stopDate = stopDate;
}

- (void)dealloc
{
}

- (void)configUI {
    @WeakObj(self)
    [self.navigationItem initWithRightButtonTitle:FLocalized(@"string_done", nil) back:^{
        @StrongObj(self)
        [self cycleResultBlock];
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.bottom.equalTo(self.scrollView);
        make.width.mas_equalTo(KScreenWidth);
    }];
    
    [self.scrollContentView addSubview:self.tooltipLabel];
    [self.tooltipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60);
        make.left.mas_equalTo(KLeftSpacing12);
        make.right.mas_equalTo(-KLeftSpacing12);
        make.top.mas_equalTo(0);
    }];
    
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollContentView);
        make.top.equalTo(self.tooltipLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self.scrollContentView.mas_bottom).offset(-KTabbarHeight);
    }];
    
    [self.stackView addArrangedSubviews:@[self.recurSelectView,self.duplicateWeekDateView,
                                          self.duplicateMonthDateView,self.stopDateView]];
    
    [self.recurSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(240);
    }];
    
    [self.duplicateWeekDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100);
    }];
    
    CGFloat height = kDuplicateDateWidth * 5 + 100;
    [self.duplicateMonthDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [self.stopDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60);
    }];
    
    self.duplicateWeekDateView.hidden =
    self.duplicateMonthDateView.hidden = YES;
}

- (void)cycleResultBlock {
    
    FRecurrentMeetingResutModel *model = [[FRecurrentMeetingResutModel alloc]init];
    model.recurrent = YES;
    model.recurrentInterval = self->_tempCycleValue;
    model.recurrentDaysOfWeek  = @[];
    model.recurrentDaysOfMonth = @[];
    model.recurrentStopTime = self->_tempStopDate;
    
    NSInteger meetingNumber = 0 ;
    
    if (self->_tempCycleType == FRecurrenceDay) {
        model.recurrentType = @"DAILY";
        model.recurrent_Enum_Type = FRecurrenceDay;
        model.recurrentTitle = f_everyNumberDaya(self->_tempCycleValue);
        meetingNumber = f_calculateMeetingCountWithStartDate(self.startTime, self->_tempStopDate, [self->_tempCycleValue intValue], NSCalendarUnitDay);
    }else if (self->_tempCycleType == FRecurrenceWeek) {
        model.recurrentType = @"WEEKLY";
        model.recurrentDaysOfWeek = f_convertToNumber(self.tempWeekSelectList);
        model.recurrent_Enum_Type = FRecurrenceWeek;
        model.recurrentTitle = f_everyNumberWeeks(self->_tempCycleValue);
        meetingNumber = f_calculateMeetingCountWithStartDate(self.startTime, self->_tempStopDate, [self->_tempCycleValue intValue], NSCalendarUnitWeekOfYear);
        if (self.tempWeekSelectList.count > 1) {
            meetingNumber = meetingNumber * self.tempWeekSelectList.count;
        }
    }else if (self->_tempCycleType == FRecurrenceMonth) {
        model.recurrentType = @"MONTHLY";
        model.recurrentDaysOfMonth = self.tempMonthSelectList;
        model.recurrent_Enum_Type = FRecurrenceMonth;
        model.recurrentTitle = f_everyNumberMonths(self->_tempCycleValue);
        meetingNumber = f_calculateMeetingCountWithStartDate(self.startTime, self->_tempStopDate, [self->_tempCycleValue intValue], NSCalendarUnitMonth);
        if (self.tempMonthSelectList.count > 1) {
            meetingNumber = meetingNumber * self.tempMonthSelectList.count;
        }
    }
    
    NSString *stopDateStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingStopTime", nil),[FrtcHelpers getDateCustomStringWithTimeStr:self->_tempStopDate]];
    NSString *meetingNumberStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingTotalNumber", nil),meetingNumber];
    model.stopTimeAndMeetingNumber = [NSString stringWithFormat:@"%@ %@",stopDateStr,meetingNumberStr];
    
    if (self.recurrentMeetingResult) {
        self.recurrentMeetingResult(model);
    }
    
    [MBProgressHUD showActivityMessage:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FrtcScheduleMeetingViewController class]]) {
                [MBProgressHUD hideHUD];
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    });
}

#pragma mark - FrtcRecurSelectViewDelegate
- (void)didRecurSelectResult:(FRecurrenceType)type value:(NSString *)value {
    self->_tempCycleValue = value;
    self->_tempCycleType  = type;
    
    NSDate *resultDateForCycle ;
    NSString *dateSelectResult ;
    self.duplicateWeekDateView.hidden =
    self.duplicateMonthDateView.hidden = YES;
    
    if (type == FRecurrenceDay) {
        dateSelectResult = f_daysDateResultWithInterval(value);
        resultDateForCycle = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitDay, [value integerValue], kDafaultRecurrenceNumber);
    }else if (type == FRecurrenceWeek) {
        self.duplicateWeekDateView.hidden = NO;
        dateSelectResult = f_weekDateResultWithInterval(value, self.tempWeekSelectList);
        resultDateForCycle = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitWeekOfYear, [value integerValue], kDafaultRecurrenceNumber);
    }else if (type == FRecurrenceMonth) {
        self.duplicateMonthDateView.hidden = NO;
        dateSelectResult = f_monthDateResultWithInterval(value, self.tempMonthSelectList);
        resultDateForCycle = f_calculateEndDate(self->_tempStartDate, NSCalendarUnitMonth, [value integerValue], kDafaultRecurrenceNumber);
    }
    
    self.stopDateView.stopDate = resultDateForCycle;
    self->_tempStopDate = f_millisecondsFromDate(resultDateForCycle);
    self.tooltipLabel.text = dateSelectResult;
}

#pragma mark - FrtcDuplicateDateSelectViewDelegate
- (void)didDuplicateDateSelectResult:(NSArray<NSString *> *)resultList type:(FDuplicateType)type {
    NSString *dateSelectResult = @"";
    if (type == FDuplicateWeek) {
        [self.tempWeekSelectList removeAllObjects];
        [self.tempWeekSelectList addObjectsFromArray:resultList];
        dateSelectResult = f_weekDateResultWithInterval (self->_tempCycleValue, self.tempWeekSelectList);
    }else{
        [self.tempMonthSelectList removeAllObjects];
        [self.tempMonthSelectList addObjectsFromArray:resultList];
        dateSelectResult = f_monthDateResultWithInterval(self->_tempCycleValue, self.tempMonthSelectList);
    }
    self.tooltipLabel.text = dateSelectResult;
}

#pragma mark - FrtcStopDateViewDelegate

- (void)didSelectedStopDate:(NSString *)stopDate {
    
    self->_tempStopDate = stopDate;
}

#pragma mark - lazy

- (UILabel *)tooltipLabel {
    if (!_tooltipLabel) {
        _tooltipLabel = [[UILabel alloc]init];
        _tooltipLabel.textColor = KTextColor;
        _tooltipLabel.numberOfLines = 2;
        _tooltipLabel.font = [UIFont systemFontOfSize:15.f];
        _tooltipLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _tooltipLabel;
}

- (FrtcRecurSelectView *)recurSelectView {
    if (!_recurSelectView) {
        _recurSelectView = [[FrtcRecurSelectView alloc]initWithRecurrentMeetingModel:_editSettingModel
                                                                             tyle:_settingType];
        _recurSelectView.delegate = self;
    }
    return _recurSelectView;
}

- (FrtcDuplicateDateSelectView *)duplicateWeekDateView {
    if (!_duplicateWeekDateView) {
        _duplicateWeekDateView = [[FrtcDuplicateDateSelectView alloc] initWithFrame:CGRectZero
                                                                   duplicateType:FDuplicateWeek
                                                                           model:_editSettingModel
                                                                     defaultDate:_startTime];
        _duplicateWeekDateView.delegate = self;
    }
    return _duplicateWeekDateView;
}

- (FrtcDuplicateDateSelectView *)duplicateMonthDateView {
    if (!_duplicateMonthDateView) {
        _duplicateMonthDateView = [[FrtcDuplicateDateSelectView alloc] initWithFrame:CGRectZero
                                                                    duplicateType:FDuplicateMonth
                                                                            model:_editSettingModel
                                                                      defaultDate:_startTime];
        _duplicateMonthDateView.delegate = self;
    }
    return _duplicateMonthDateView;
}

- (FrtcStopDateView *)stopDateView {
    if (!_stopDateView) {
        _stopDateView = [[FrtcStopDateView alloc]initWithFrame:CGRectZero defaultDate:_startTime];
        _stopDateView.delegate = self;
        _stopDateView.backgroundColor = UIColor.whiteColor;
    }
    return _stopDateView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.backgroundColor = KBGColor;
        [self.contentView addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (!_scrollContentView) {
        _scrollContentView = [[UIView alloc]init];
        _scrollContentView.backgroundColor = KBGColor;
        [self.scrollView addSubview:_scrollContentView];
    }
    return _scrollContentView;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc]init];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.spacing = 10;
        _stackView.alignment = UIStackViewAlignmentFill;
        [self.scrollContentView addSubview:_stackView];
    }
    return _stackView;
}

- (NSMutableArray *)tempWeekSelectList {
    if (!_tempWeekSelectList) {
        _tempWeekSelectList = [NSMutableArray arrayWithCapacity:7];
        [_tempWeekSelectList addObject:f_dayOfWeekForMilliseconds(self.startTime)];
    }
    return _tempWeekSelectList;
}

- (NSMutableArray *)tempMonthSelectList {
    if (!_tempMonthSelectList) {
        _tempMonthSelectList = [NSMutableArray arrayWithCapacity:31];
        [_tempMonthSelectList addObject:f_dayOfDayForMilliseconds(self.startTime)];
    }
    return _tempMonthSelectList;
}


@end

