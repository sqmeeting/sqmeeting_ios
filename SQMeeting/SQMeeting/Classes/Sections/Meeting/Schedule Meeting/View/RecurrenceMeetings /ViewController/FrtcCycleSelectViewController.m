#import "FrtcCycleSelectViewController.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcCycleSettingViewController.h"
#import "FrtcCycleSelectTableViewCell.h"
#import "NSBundle+FLanguage.h"

#define FCycleTableViewCellIdentifier @"FCycleTableViewCellIdentifier"

#pragma mark - Class  FCycleSelectModel

@interface FCycleSelectModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, assign) FRecurrenceType cycleType;
@property (nonatomic, getter=isSelected) BOOL select;

@end

@implementation FCycleSelectModel

@end


#pragma mark - Class  FrtcCycleSelectViewController

@interface FrtcCycleSelectViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *cycleTableView;
@property (nonatomic, strong) NSMutableArray<FCycleSelectModel *> *cycleListData;

@end

@implementation FrtcCycleSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = FLocalized(@"recurrence_frequency", nil);
    [self loadData];
}

- (void)configUI {
    [self.cycleTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)loadData {
    
    self.cycleListData = [[NSMutableArray alloc]init];
    FCycleSelectModel *model1 = [[FCycleSelectModel alloc]init];
    model1.title = FLocalized(@"recurrence_no", nil);;
    model1.select = self.editModel ? (self.editModel.isRecurrent ? NO : YES) : YES;
    model1.cycleType = FRecurrenceNone;
    [self.cycleListData addObject:model1];
    
    FCycleSelectModel *model2 = [[FCycleSelectModel alloc]init];
    if (self.editModel && (self.editModel.recurrent_Enum_Type == FRecurrenceDay)) {
        model2.title = self.editModel.recurrentTitle;
        model2.select = YES;
    }else{
        model2.title = FLocalized(@"recurrence_daily", nil);
        model2.select = NO;
    }
    model2.cycleType = FRecurrenceDay;
    [self.cycleListData addObject:model2];
    
    FCycleSelectModel *model3 = [[FCycleSelectModel alloc]init];
    if (self.editModel && (self.editModel.recurrent_Enum_Type == FRecurrenceWeek)) {
        model3.title = self.editModel.recurrentTitle;
        model3.select = YES;
    }else{
        model3.title = FLocalized(@"recurrence_weekly", nil);
        model3.select = NO;
    }
    model3.cycleType = FRecurrenceWeek;
    [self.cycleListData addObject:model3];
    
    FCycleSelectModel *model4 = [[FCycleSelectModel alloc]init];
    if (self.editModel && (self.editModel.recurrent_Enum_Type == FRecurrenceMonth)) {
        model4.title = self.editModel.recurrentTitle;
        model4.select = YES;
    }else{
        model4.title = FLocalized(@"recurrence_monthly", nil);
        model4.select = NO;
    }
    model4.cycleType = FRecurrenceMonth;
    [self.cycleListData addObject:model4];
    
    [self.cycleTableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cycleListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcCycleSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FCycleTableViewCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        if (self.isEditing && self.editModel.isRecurrent) {
            cell.titleLabel.textColor = KTextColor;
        }
    }
    FCycleSelectModel *model = self.cycleListData[indexPath.row];
    if (model.isSelected) {
        cell.titleLabel.textColor = kMainColor;
        cell.detailLabel.text = self.editModel.stopTimeAndMeetingNumber;
        if ([NSBundle isLanguageEn] && !kStringIsEmpty(self.editModel.stopTimeAndMeetingNumber)) {
            cell.detailLabel.text = [NSString stringWithFormat:@"End %@",self.editModel.stopTimeAndMeetingNumber];
        }
    }else{
        cell.titleLabel.textColor = KTextColor;
    }
    cell.titleLabel.text = model.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        if (self.isEditing && self.editModel.isRecurrent) {
            [MBProgressHUD showMessage:@"周期性会议无法修改为非周期性会议"];
            return;
        }
        if (self.recurrentSelectMeetingResult) {
            FRecurrentMeetingResutModel *resultModel = [[FRecurrentMeetingResutModel alloc]init];
            resultModel.recurrent = NO;
            self.recurrentSelectMeetingResult(resultModel);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        FCycleSelectModel *model = self.cycleListData[indexPath.row];
        FrtcCycleSettingViewController *cycleSettingVC = [[FrtcCycleSettingViewController alloc]init];
        cycleSettingVC.editSettingModel = self.editModel;
        cycleSettingVC.startTime = self.startTime;
        cycleSettingVC.settingType = model.cycleType;
        @WeakObj(self)
        cycleSettingVC.recurrentMeetingResult = ^(FRecurrentMeetingResutModel * _Nonnull model1) {
            @StrongObj(self)
            if (self.recurrentSelectMeetingResult) {
                self.recurrentSelectMeetingResult(model1);
            }
        };
        [self.navigationController pushViewController:cycleSettingVC animated:YES];
    }
}

#pragma mark - lazy

- (UITableView *)cycleTableView {
    if (!_cycleTableView) {
        _cycleTableView = [[UITableView alloc]init];
        _cycleTableView.backgroundColor = UIColor.whiteColor;
        _cycleTableView.delegate   = self;
        _cycleTableView.dataSource = self;
        _cycleTableView.backgroundColor = KBGColor;
        [_cycleTableView registerClass:[FrtcCycleSelectTableViewCell class] forCellReuseIdentifier:FCycleTableViewCellIdentifier];
        _cycleTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _cycleTableView.rowHeight = 50;
        _cycleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _cycleTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) { [_cycleTableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_cycleTableView];
    }
    return _cycleTableView;
}

@end
