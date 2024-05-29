#import "FrtcDuplicateDateSelectView.h"
#import "Masonry.h"
#import "FrtcDuplicateDateCCell.h"
#import "MBProgressHUD+Extensions.h"

@interface FrtcDuplicateDateSelectView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSString *_defaultDate;
    FRecurrentMeetingResutModel *_currentModel;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) FDuplicateType duplicateType;
@property (nonatomic, strong) NSMutableArray <NSString *> *weekSelectList;
@property (nonatomic, strong) NSMutableArray <NSString *> *monthSelectList;
@property (nonatomic, strong) NSArray <NSString *> *weekList;

@end

@implementation FrtcDuplicateDateSelectView

- (instancetype)initWithFrame:(CGRect)frame
                duplicateType:(FDuplicateType)duplicateType
                        model:(FRecurrentMeetingResutModel *)editSettingModel
                  defaultDate:(NSString *)defaultDate {
    self = [super initWithFrame:frame];
    if (self) {
        _duplicateType = duplicateType;
        _defaultDate   = defaultDate;
        _currentModel  = editSettingModel;

        if (_duplicateType == FDuplicateWeek) {
            _defaultDate = f_dayOfWeekForMilliseconds(_defaultDate);
            [self.weekSelectList addObject:_defaultDate];
        }else{
            _defaultDate = f_dayOfDayForMilliseconds(_defaultDate);
            [self.monthSelectList addObject:_defaultDate];
        }
        
        [self configDefaultValue];
        [self loadUI];
    }
    return self;
}

- (void)configDefaultValue {
    if (self->_currentModel) {
        if (_duplicateType == FDuplicateWeek) {
            [self.weekSelectList removeAllObjects];
            [self.weekSelectList addObjectsFromArray:f_convertToChineseWeekday(self->_currentModel.recurrentDaysOfWeek)];
            if (![self.weekSelectList containsObject:_defaultDate]) {
                [self.weekSelectList addObject:_defaultDate];
            }
        }else if (_duplicateType == FDuplicateMonth) {
            [self.monthSelectList removeAllObjects];
            NSArray *months = self->_currentModel.recurrentDaysOfMonth;
            for (NSNumber * item in months) {
                [self.monthSelectList addObject:[NSString stringWithFormat:@"%@",item]];
            }
            if (![self.monthSelectList containsObject:_defaultDate]) {
                [self.monthSelectList addObject:_defaultDate];
            }
        }
    }
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)loadUI {
    
    self.backgroundColor = UIColor.whiteColor;
    [self loadHeaderView];

    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.right.mas_equalTo(-KLeftSpacing12);
        make.top.mas_equalTo(42);
        make.bottom.mas_equalTo(-10);
    }];
    
}

#pragma mark - UICollectionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_duplicateType == FDuplicateWeek) {
        return self.weekList.count;
    }
    return  31;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kDuplicateDateWidth, kDuplicateDateWidth);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrtcDuplicateDateCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FrtcDuplicateDateCCell class]) forIndexPath:indexPath];
    
    if (_duplicateType == FDuplicateWeek) {
        cell.week = YES ;
        NSString *weekValue = self.weekList[indexPath.item];
        [cell.dateButton setTitle:weekValue forState:UIControlStateNormal];
        cell.dateButton.highlighted = [self.weekSelectList containsObject:weekValue];
        cell.dateButton.selected = [weekValue isEqualToString:self->_defaultDate];
    }else{
        cell.week = NO;
        NSString *monthValue = [NSString stringWithFormat:@"%td",indexPath.item + 1];
        [cell.dateButton setTitle:monthValue forState:UIControlStateNormal];
        cell.dateButton.highlighted =  [self.monthSelectList containsObject:monthValue];
        cell.dateButton.selected = [monthValue isEqualToString:self->_defaultDate];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_duplicateType == FDuplicateWeek) {
        NSString *weekValue = self.weekList[indexPath.item];
        if ([weekValue isEqualToString:_defaultDate]) {
            [MBProgressHUD showMessage:FLocalized(@"recurrence_unableCancel", nil)];
        }else{
            if ([self.weekSelectList containsObject:weekValue]) {
                [self.weekSelectList removeObject:weekValue];
            }else{
                [self.weekSelectList addObject:weekValue];
            }
        }
    }else{
        NSString *monthValue = [NSString stringWithFormat:@"%td",indexPath.item + 1];
        if ([monthValue isEqualToString:_defaultDate]) {
            [MBProgressHUD showMessage:FLocalized(@"recurrence_unableCancel", nil)];
        }else{
            if ([self.monthSelectList containsObject:monthValue]) {
                [self.monthSelectList removeObject:monthValue];
            }else{
                [self.monthSelectList addObject:monthValue];
            }
        }
    }
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didDuplicateDateSelectResult:type:)]) {
        [self.delegate didDuplicateDateSelectResult:(_duplicateType == FDuplicateWeek) ? self.weekSelectList : self.monthSelectList type:_duplicateType];
    }
}

#pragma mark - lzay

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate   = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[FrtcDuplicateDateCCell class] forCellWithReuseIdentifier:NSStringFromClass([FrtcDuplicateDateCCell class])];
    }
    return _collectionView;
}

- (void) loadHeaderView {
    UIView *headerView = [[UIView alloc]init];
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.top.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = (_duplicateType == FDuplicateWeek) ? FLocalized(@"recurrence_selectWeek", nil) : FLocalized(@"recurrence_selectMoth", nil);
    titleLabel.textColor = KTextColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.centerY.equalTo(headerView);
    }];
}

- (NSMutableArray *)weekSelectList {
    if (!_weekSelectList) {
        _weekSelectList = [NSMutableArray arrayWithCapacity:7];
    }
    return _weekSelectList;
}

- (NSMutableArray *)monthSelectList {
    if (!_monthSelectList) {
        _monthSelectList = [NSMutableArray arrayWithCapacity:31];
    }
    return _monthSelectList;
}

- (NSArray *)weekList {
    if (!_weekList) {
        _weekList = @[FLocalized(@"recurrence_sun", nil),FLocalized(@"recurrence_mon", nil),FLocalized(@"recurrence_tue", nil),FLocalized(@"recurrence_wed", nil),FLocalized(@"recurrence_thu", nil),FLocalized(@"recurrence_fri", nil),FLocalized(@"recurrence_sat", nil)];
    }
    return _weekList;
}

@end
