#import "FrtcScheduleTimePickerView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcScheduleDatePickerHeaderView.h"
#import "UIView+Extensions.h"

#define KHistoryMeetingHeight  250

static FrtcScheduleTimePickerView *timePickerView = nil;
static TimePickerViewBlock timePickerResultBlock = nil;

@interface FrtcScheduleTimePickerView () <UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *dataSouce;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, copy) NSString *hourStr;
@property (nonatomic, copy) NSString *minuteStr;

@end

@implementation FrtcScheduleTimePickerView

+ (void)showTimePickerViewWithTimeStr:(TimePickerViewBlock)datePickerBlock {
    timePickerView = [[FrtcScheduleTimePickerView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    //datePickerView.dateString = [timePickerView getDateStringWithDate:[NSDate date]];
    timePickerView.hourStr = @"";
    timePickerView.minuteStr = @"";
    timePickerResultBlock = datePickerBlock;
    [[[UIApplication sharedApplication].delegate window] addSubview:timePickerView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hourStr = @"";
        self.minuteStr = @"";
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(280);
        }];
        
        FrtcScheduleDatePickerHeaderView *headerView = [FrtcScheduleDatePickerHeaderView new];
        @WeakObj(self);
        headerView.dateHeaderViewBlock = ^(BOOL index) {
            @StrongObj(self)
            if (index) {
                if (timePickerResultBlock) {
                    
                    if ((kStringIsEmpty(self.hourStr) || [self.hourStr intValue] == 0) &&
                        (kStringIsEmpty(self.minuteStr) || [self.minuteStr intValue] == 0)) {
                        self.minuteStr = @"30";
                    }
                    
                    if (kStringIsEmpty(self.hourStr) || [self.hourStr intValue] == 0) {
                        self.hourStr   = @"";
                    }
                    
                    timePickerResultBlock(self.hourStr,self.minuteStr);
                }
                [self disMiss];
            }else{
                [self disMiss];
            }
        };
        headerView.titleLabel.text = NSLocalizedString(@"meeting_duration", nil);
        [self.contentView addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
        
        CGFloat left_spacing = self.pickerView.bounds.size.width / 3 + 20;
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.pickerView);
            make.left.mas_equalTo(left_spacing);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.pickerView);
            make.right.mas_equalTo(-KLeftSpacing12);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setCornerRadius:16 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)dealloc {
   
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
        timePickerView = nil;
        timePickerResultBlock = nil;
    }];
}

#pragma mark - dataSouce

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSouce.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataSouce[component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger)component {
    return self.dataSouce[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.hourStr = self.dataSouce[component][row];
    }else{
        self.minuteStr = self.dataSouce[component][row];
    }
    ISMLog(@"HH = %@, MM = %@",self.hourStr,self.minuteStr);
}

#pragma mark - lazy

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
        [self.contentView addSubview:_pickerView];
    }
    return _pickerView;
}

- (UILabel *) dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.text = NSLocalizedString(@"hour", nil); //@"小时";
        _dateLabel.textColor = KTextColor;
        _dateLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.pickerView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UILabel *) timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.text = NSLocalizedString(@"minute", nil);
        _timeLabel.textColor = KTextColor;
        _timeLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.pickerView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (NSArray *)dataSouce {
    if (!_dataSouce) {
        _dataSouce = @[@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"],@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",@"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20",@"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30",@"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40",@"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50",@"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60"]];
    }
    return _dataSouce;
}

@end
