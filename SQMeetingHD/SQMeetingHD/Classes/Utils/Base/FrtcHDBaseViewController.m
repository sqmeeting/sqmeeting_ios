#import "FrtcHDBaseViewController.h"
#import "PYHDNavigationController.h"

@interface FrtcHDBaseViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation FrtcHDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    _contentView = [[UIView alloc]init];
    _contentView.backgroundColor = KBGColor;
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(56);
        make.left.right.bottom.mas_equalTo(0);
    }];
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
            [leftBarButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
        }
    }
}

- (void)leftButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
