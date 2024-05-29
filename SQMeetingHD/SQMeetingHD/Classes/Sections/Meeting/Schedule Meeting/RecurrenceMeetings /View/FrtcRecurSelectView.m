#import "FrtcRecurSelectView.h"
#import "Masonry.h"
#import "FrtcMeetingRecurrenceDateManager.h"

#define kHeaderViewHeight 40

@interface FrtcRecurSelectView () <UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSString *timeUnit;
    NSString *timeNumber;
    BOOL _updateComponentOne;
    NSInteger _backComponentOne;
    FRecurrentMeetingResutModel *_currentModel;
    FRecurrenceType _currentType;
}
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *numberList1;
@property (nonatomic, strong) NSArray *numberList2;
@property (nonatomic, strong) NSArray *dateSelectList;

@end


@implementation FrtcRecurSelectView

- (instancetype)initWithRecurrentMeetingModel:(FRecurrentMeetingResutModel *)editSettingModel
                                         tyle:(FRecurrenceType)tyle
{
    self = [super init];
    if (self) {
        self->_currentModel = editSettingModel;
        self->_currentType = tyle;
        [self loadUI];
        [self configDefaultValue];
    }
    return self;
}

- (void)configDefaultValue {
    
    self->timeNumber = @"1";
    if (self->_currentType == FRecurrenceDay) {
        self->timeUnit = FLocalized(@"recurrence_days", nil);
    }else if (self->_currentType == FRecurrenceWeek) {
        self->timeUnit = FLocalized(@"recurrence_weeks", nil);
        [self.pickerView selectRow:1 inComponent:1 animated:YES];
    }else if (self->_currentType == FRecurrenceMonth) {
        self->timeUnit = FLocalized(@"recurrence_months", nil);
        [self.pickerView selectRow:2 inComponent:1 animated:YES];
    }
    
    if (self->_currentModel && (self->_currentModel.recurrent_Enum_Type == self->_currentType)) {
        NSInteger iterval = [self->_currentModel.recurrentInterval intValue];
        self->timeNumber = self->_currentModel.recurrentInterval;
        if (self->_currentModel.recurrent_Enum_Type == FRecurrenceDay) {
            [self.pickerView selectRow:iterval - 1 inComponent:0 animated:YES];
        }else if (self->_currentModel.recurrent_Enum_Type == FRecurrenceWeek) {
            [self.pickerView selectRow:iterval - 1 inComponent:0 animated:YES];
            [self.pickerView selectRow:1 inComponent:1 animated:YES];
        }else if (self->_currentModel.recurrent_Enum_Type == FRecurrenceMonth) {
            [self.pickerView selectRow:iterval - 1 inComponent:0 animated:YES];
            [self.pickerView selectRow:2 inComponent:1 animated:YES];
        }
    }
    
    if (self->_currentType && (self->_currentModel.recurrent_Enum_Type != self->_currentType)) {
        if (self->_currentType == FRecurrenceDay) {
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
        }else if (self->_currentType == FRecurrenceWeek) {
            _updateComponentOne = YES;
            [self.pickerView reloadComponent:0];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
            [self.pickerView selectRow:1 inComponent:1 animated:YES];
        }else if (self->_currentType == FRecurrenceMonth) {
            _updateComponentOne = YES;
            [self.pickerView reloadComponent:0];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
            [self.pickerView selectRow:2 inComponent:1 animated:YES];
        }
    }
    
    [self duplicateLabelText];
}

- (void)loadUI {
    self.backgroundColor = UIColor.whiteColor;
    [self loadHeaderView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kHeaderViewHeight);
        make.size.mas_equalTo(CGSizeMake(200, 200));
        make.centerX.equalTo(self);
    }];
}

- (void)duplicateLabelText {
    NSString *timeNumbers =  [timeNumber isEqualToString:@"1"] ? @"" : timeNumber;
    self.heaer_duplicateLabel.text = [NSString stringWithFormat:@"%@%@%@",FLocalized(@"recurrence_every", nil),timeNumbers,timeUnit];
}

#pragma mark - pickDataSouce

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        if (_updateComponentOne) {
            return self.numberList2.count;
        }
        return self.numberList1.count;
    }else{
        return self.dateSelectList.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger)component {
    if (component == 0) {
        if (_updateComponentOne) {
            return self.numberList2[row];
        }
        return self.numberList1[row];
    }else{
        return self.dateSelectList[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 1) {
        _updateComponentOne = row > 0;
        [self.pickerView reloadComponent:0];
        _backComponentOne = row;
    }
    
    if (component == 1) {
        self->timeUnit  = self.dateSelectList[row];
    }else{
        self->timeNumber = _updateComponentOne ? self.numberList2[row] : self.numberList1[row];
    }
    
    if (![self->timeUnit isEqualToString:FLocalized(@"recurrence_days", nil)] && [self->timeNumber intValue] > 12) {
        self->timeNumber = @"12";
    }
    
    [self duplicateLabelText];

    FRecurrenceType type = FRecurrenceDay;
    if ([self->timeUnit isEqualToString:FLocalized(@"recurrence_months", nil)]) {
        type = FRecurrenceMonth;
    }else if ([self->timeUnit isEqualToString:FLocalized(@"recurrence_weeks", nil)]){
        type = FRecurrenceWeek;
    }
    
    if ([self.delegate respondsToSelector:@selector(didRecurSelectResult:value:)]) {
        [self.delegate didRecurSelectResult:type value:timeNumber];
    }
}

#pragma mark - lazy

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
        [self addSubview:_pickerView];
    }
    return _pickerView;
}

- (NSMutableArray *)numberList1 {
    if (!_numberList1) {
        _numberList1 = [[NSMutableArray alloc]init];
        for (int i = 1; i < 100; i ++) {
            [_numberList1 addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _numberList1;
}

- (NSArray *)numberList2 {
    if (!_numberList2) {
        _numberList2 = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    }
    return _numberList2;
}

- (NSArray *)dateSelectList {
    if (!_dateSelectList) {
        _dateSelectList = @[FLocalized(@"recurrence_days", nil),FLocalized(@"recurrence_weeks", nil),FLocalized(@"recurrence_months", nil)];
    }
    return _dateSelectList;
}

- (void)loadHeaderView{
    UIView *headerView = [[UIView alloc]init];
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kHeaderViewHeight);
        make.left.right.top.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = FLocalized(@"recurrence_recurEvery", nil);
    titleLabel.textColor = KTextColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.centerY.equalTo(headerView);
    }];
    
    self.heaer_duplicateLabel = [[UILabel alloc]init];
    [self duplicateLabelText];
    self.heaer_duplicateLabel.textColor = kMainColor;
    self.heaer_duplicateLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:self.heaer_duplicateLabel];
    [self.heaer_duplicateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing12);
        make.centerY.equalTo(headerView);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = KLineColor;
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
}


@end
