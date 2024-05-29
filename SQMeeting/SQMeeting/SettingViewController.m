#import "SettingViewController.h"
#import "StatusTableViewCell.h"
#import "PopUpViewController.h"
#import "PopUpRateController.h"
#import "FUserDefault.h"
#import "FRtcsdk.h"

#define KScreen                 [UIScreen mainScreen].bounds
#define KScreenWidth            [UIScreen mainScreen].bounds.size.width
#define KScreenHeight           [UIScreen mainScreen].bounds.size.height

#define COLOR_RGBA(r, g, b, a)             [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]
#define COLOR(r, g, b)                     COLOR_RGBA(r, g, b, 1.0)
#define TABLE_VIEW_BK_COLOR     COLOR(230, 230, 230)
#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

#define STATUS_CELL_MIN_HEIGHT       52.0f

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource, PopUpViewControllerDelegate>

@property (nonatomic, strong) UIImageView *backGroundView;
@property (strong, nonatomic) UITableView *statusTableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //[self.backGroundView setImage:[UIImage imageNamed:@"bg_default"]];
    self.title = NSLocalizedString(@"app_settings", nil);
    [self configTableView];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    //self.automaticallyAdjustsScrollViewInsets = false;
    // Do any additional setup after loading the view.
}

- (void)configTableView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.statusTableView.backgroundColor = TABLE_VIEW_BK_COLOR;
}

#pragma mark- PopUpViewControllerDelegate
- (void)saveNewAddress:(NSString *)newServerAddress {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    StatusTableViewCell *selectCell = (StatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    
    selectCell.detailLabel.text = newServerAddress;
    
    [[FUserDefault sharedUserDefault] setObject:newServerAddress forKey:SERVER_ADDRESS];
    [[FMeetingClient sharedClient] setConfig:CFG_SERVER_ADDR withSDKConfigValue:newServerAddress];
}

#pragma mark- PopUpRateControllerDelegate
- (void)saveNewCallRate:(NSString *)newCallRate {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    StatusTableViewCell *selectCell = (StatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    
    selectCell.detailLabel.text = newCallRate;
    
    [[FUserDefault sharedUserDefault] setObject:newCallRate forKey:CALL_RATE];
}

#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 1;
            break;
        case 2:
            count = 1;
            break;
        default:
            count = 0;
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
  
    if (nil == cell) {
        cell = [[StatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailLabel.textColor = KColorRGB(122,122,122,1.0);
        
        if([indexPath section] == 0) {
            cell.nameLabel.text = NSLocalizedString(@"server_address", nil);
            cell.detailLabel.text = [[FUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
        } else if([indexPath section] == 1) {
            //if(indexPath.row == 0) {
                cell.nameLabel.text = NSLocalizedString(@"phone_logs", nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
            //} else if(indexPath.row == 1) {
            if(indexPath.row == 0) {
                cell.nameLabel.text = NSLocalizedString(@"app_version", nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSString *errorDesc = nil;
                NSPropertyListFormat format;
                NSString *version;
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
                NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
                NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                                      propertyListFromData:plistXML
                                                      mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                      format:&format
                                                      errorDescription:&errorDesc];
                version = [temp objectForKey:@"Version"];
                if (version == nil) {
                    version = NSLocalizedString(@"version_unknown", nil);
                }
                cell.detailLabel.text = version;
            }
        } else if([indexPath section] == 2) {
            if(indexPath.row == 0) {
                cell.nameLabel.text = NSLocalizedString(@"phone_testing", nil);
                cell.detailLabel.text = [[FUserDefault sharedUserDefault] objectForKey:CALL_RATE];
                cell.hidden = true;
            }
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}



#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0;
    } else {
        return 6;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath section] == 0) {
        NSString *signStatus = [[FUserDefault sharedUserDefault] objectForKey:SIGN_STATUS];
        if (![signStatus isEqualToString:@"true"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                PopUpViewController *vc = [PopUpViewController new];
                vc.delegate = self;
                vc.modalPresentationStyle = UIModalPresentationCustom;
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:vc animated:YES completion:nil];
                
            });
        }
        //end add
       
    } else if([indexPath section] == 2) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            PopUpRateController *vcRate = [PopUpRateController new];
            vcRate.delegate = self;
            vcRate.modalPresentationStyle = UIModalPresentationCustom;
            vcRate.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:vcRate animated:YES completion:nil];
            
        });
    } else if([indexPath section] == 1) {
    
        if([indexPath row] == 0){
            NSIndexPath *indexPathOne=[NSIndexPath indexPathForRow:0 inSection:2];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPathOne];
            cell.hidden = false;
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- lazy load
- (UIImageView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _backGroundView.userInteractionEnabled = YES;
        [_backGroundView setImage:[UIImage imageNamed:@"bg-image"]];
        //[self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UITableView *)statusTableView {
    if(!_statusTableView) {
        _statusTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _statusTableView.delegate = self;
        _statusTableView.dataSource = self;
        _statusTableView.tableFooterView = [UIView new];
        _statusTableView.estimatedRowHeight = 0;
        _statusTableView.estimatedSectionHeaderHeight = 0;
        _statusTableView.estimatedSectionFooterHeight = 0;
        _statusTableView.rowHeight = UITableViewAutomaticDimension;
        _statusTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _statusTableView.backgroundView = self.backGroundView;
        [_statusTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        [self.view addSubview:_statusTableView];
    }
    
    return _statusTableView;
}

@end
