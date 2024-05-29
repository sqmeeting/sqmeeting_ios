#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, KNavBarHeight, KScreenWidth, KScreenHeight - KNavBarHeight)];
    _contentView.backgroundColor = KBGColor;
    [self.view addSubview:_contentView];
    [self confignavigationbar];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configUI { }

- (void)confignavigationbar {
    if (self.navigationController.visibleViewController == self) {
        if (self.navigationController.viewControllers.count > 1) {
            UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftBarButton setImage:[UIImage imageNamed:@"nav_back_icon"] forState:UIControlStateNormal];
            leftBarButton.frame = CGRectMake(0, 0, 40, 40);
            leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
            [leftBarButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
        }
    }
}

- (void)leftButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
