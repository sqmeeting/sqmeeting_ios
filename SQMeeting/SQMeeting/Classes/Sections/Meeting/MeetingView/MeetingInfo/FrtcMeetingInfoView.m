#import "FrtcMeetingInfoView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcMeetingInfoLeftView.h"
#import "FrtcMeetingNetWorkView.h"

#define KMeetingInfoTopSpacing  15

@interface FrtcMeetingInfoView () <UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *crossBarView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation FrtcMeetingInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self meetingInfoViewLayout];
    }
    return self;
}

- (void)meetingInfoViewLayout {
    
    self.layer.backgroundColor = UIColor.clearColor.CGColor;
    [self addSubview:self.bgView];
    self.bgView.mas_key = @"bgview>123";
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(LAND_SCAPE_WIDTH/2);
        make.centerX.equalTo(self);
    }];
    
    self.crossBarView.mas_key = @"crossBar>123";
    [self.crossBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.centerX.equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(60, 4));
    }];
    
    self.titleLabel.mas_key = @"titleLabel>123";
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing * 0.6);
        make.right.mas_equalTo(-KLeftSpacing *0.6);
        make.top.equalTo(self.crossBarView.mas_bottom).mas_offset(14);
    }];
    
    self.segmentedControl.mas_key = @"segmentedControl>123";
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
    }];
    
    self.scrollView.mas_key = @"scrollView>123";
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).mas_offset(10);
        make.left.right.equalTo(self.titleLabel);
        make.bottom.mas_equalTo(0);
    }];
    
    self.infoLeftView.mas_key = @"sinfoLeftView>123";
    [self.infoLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.scrollView);
    }];
    
    self.staticsView.mas_key = @"staticsView>123";
    [self.staticsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.left.equalTo(self.infoLeftView.mas_right);
        make.width.mas_equalTo(self.scrollView);
    }];
    
    @WeakObj(self);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self disMiss];
    }];
    [self addGestureRecognizer:tap];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LAND_SCAPE_HEIGHT * 0.7);
            }];
            [self.bgView.superview layoutIfNeeded];
            [self.bgView setCornerRadius:KCornerRadius * 4 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
        }];
    });
    
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)disMiss{
    [UIView animateWithDuration:0.25 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self disMiss];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
    }
}

-(void)changeIndex{
  
}

#pragma mark - UIScrollerViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
}

#pragma mark - lazy

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.userInteractionEnabled = YES;
        _bgView.layer.backgroundColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:0.95].CGColor;
    }
    return _bgView;
}

- (UIView *)crossBarView {
    if (!_crossBarView) {
        _crossBarView = [[UIView alloc]init];
        _crossBarView.backgroundColor = UIColorHex(0xcccccc);
        _crossBarView.layer.cornerRadius = 2.5;
        [self.bgView addSubview:_crossBarView];
    }
    return _crossBarView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[NSLocalizedString(@"meeting_info", nil),NSLocalizedString(@"meeting_nerworkstate", nil)]];
        _segmentedControl.tintColor = [UIColor redColor];
        _segmentedControl.selectedSegmentIndex=0;
        [_segmentedControl addTarget:self action:@selector(changeIndex) forControlEvents:UIControlEventValueChanged];
        [self.bgView addSubview:_segmentedControl];
    }
    return _segmentedControl;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"";
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.bgView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.delegate = self;
        [self.bgView addSubview:_scrollView];
    }
    return _scrollView;
}

- (FrtcMeetingInfoLeftView *)infoLeftView {
    if (!_infoLeftView) {
        _infoLeftView = [[FrtcMeetingInfoLeftView alloc]init];
        _infoLeftView.backgroundColor = UIColor.redColor;
        [self.scrollView addSubview:_infoLeftView];
    }
    return _infoLeftView;
}

- (FrtcMeetingNetWorkView *)staticsView {
    if (!_staticsView) {
        _staticsView = [[FrtcMeetingNetWorkView alloc]init];
        [self.scrollView addSubview:_staticsView];
    }
    return _staticsView;
}

@end
