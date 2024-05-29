#import "FrtcCallNetworkErrorView.h"
#import "Masonry.h"

@interface FrtcCallNetworkErrorView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *titleLable;

@end

@implementation FrtcCallNetworkErrorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        activityIndicatorView.color = UIColor.whiteColor;
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.textColor = [UIColor whiteColor];
        titleLable.font = [UIFont systemFontOfSize:16.f];
        titleLable.text = NSLocalizedString(@"meeting_networkErrorIng", nil);
        [self addSubview:titleLable];
        
        [activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(activityIndicatorView.mas_bottom).offset(10);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

@end
