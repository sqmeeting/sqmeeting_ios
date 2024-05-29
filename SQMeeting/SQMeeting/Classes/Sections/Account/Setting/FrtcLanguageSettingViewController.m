#import "FrtcLanguageSettingViewController.h"
#import "StatusTableViewCell.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"
#import "FrtcLanguageConfig.h"
#import "NSBundle+FLanguage.h"
#import "UIViewController+Extensions.h"
#import "AppDelegate.h"

@interface FrtcLanguageSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *statusTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) FLanguageModel *languageModel;

@end

@implementation FrtcLanguageSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"language_setting", nil);
    self.statusTableView.backgroundColor = KBGColor;
    [self.statusTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    
    @WeakObj(self)
    [self.navigationItem initWithRightButtonTitle:NSLocalizedString(@"string_done", nil) back:^{
        @StrongObj(self)
        NSString *language = self->_languageModel.language;
        if (kStringIsEmpty(language)){return;}
        if (![[NSBundle currentLanguage] hasPrefix:language]) {
            [self showAlertWithTitle:NSLocalizedString(@"language_setting_restart", nil) message:NSLocalizedString(@"language_setting_auto", nil) buttonTitles:@[NSLocalizedString(@"call_cancel", nil),NSLocalizedString(@"language_now", nil)] alerAction:^(NSInteger index) {
                if (index == 1) {
                    FrtcLanguageConfig.userLanguage = self->_languageModel.language;
                    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [myAppDelegate resetRootViewController];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
    cell.detailLabel.textColor = KDetailTextColor;
    cell.isShowRightView = NO;
    FLanguageModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.accessoryType = (model.select) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLanguageModel *model = self.dataArr[indexPath.row];
    if (model.select) {
        return;
    }
    for (FLanguageModel *model in self.dataArr) {
        model.select = NO;
    }
    model.select = !model.select;
    _languageModel = model;
    [tableView reloadData];
}

#pragma mark- lazy load

- (UITableView *)statusTableView {
    if(!_statusTableView) {
        _statusTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _statusTableView.delegate     = self;
        _statusTableView.dataSource  = self;
        _statusTableView.rowHeight   = Status_Cell_Height;
        _statusTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        [_statusTableView registerClass:[StatusTableViewCell class] forCellReuseIdentifier:@"UITableViewCellIdentifier"];
        if (@available(iOS 15.0, *)) { [_statusTableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_statusTableView];
    }
    return _statusTableView;
}


- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        {
            FLanguageModel *model = [FLanguageModel new];
            model.title = @"简体中文";
            model.language = @"zh-Hans";
            model.select = [[NSBundle currentLanguage] hasPrefix:model.language];
            [_dataArr addObject:model];
        }
        {
            FLanguageModel *model = [FLanguageModel new];
            model.title = @"繁體中文";
            model.language = @"zh-HK";
            NSString *currentLan = [NSBundle currentLanguage];
            model.select = [currentLan hasPrefix:model.language] || [currentLan hasPrefix:@"zh-Hant"];
            [_dataArr addObject:model];
        }
        {
            FLanguageModel *model = [FLanguageModel new];
            model.title = @"English";
            model.language = @"en";
            model.select = [[NSBundle currentLanguage] hasPrefix:model.language];
            [_dataArr addObject:model];
        }
    }
    return _dataArr;
}



@end



@implementation FLanguageModel

@end
