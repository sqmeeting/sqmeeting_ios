#import "FrtcOverlayPositionView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"
#import "UIButton+Extensions.h"

@interface FrtcOverlayPositionView ()

@property (nonatomic, assign, readwrite) NSInteger positionNmber;

@property (nonatomic, strong) FOverlayPositionItemView *leftBtn;
@property (nonatomic, strong) FOverlayPositionItemView *centerBtn;
@property (nonatomic, strong) FOverlayPositionItemView *rightBtn;

@end

@implementation FrtcOverlayPositionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.positionNmber = 0;
    
    UIStackView *stackview = [[UIStackView alloc]init];
    stackview.spacing = 8;
    stackview.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackview];
    [stackview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSArray *buttons = @[self.leftBtn,self.centerBtn,self.rightBtn];
    [stackview addArrangedSubviews:buttons];
}

#pragma mark - action

-(void)selectedAction:(FOverlayPositionItemView *)sender
{
    __block NSArray *array = @[self.leftBtn,self.centerBtn,self.rightBtn];
    for (FOverlayPositionItemView *item in array) {
        item.imageView.hidden = YES;
    }
    sender.imageView.hidden = NO;
    self.positionNmber = sender.tag;
}

#pragma mark - lazy

- (FOverlayPositionItemView *)leftBtn {
    if (!_leftBtn) {
        @WeakObj(self)
        _leftBtn = [[FOverlayPositionItemView alloc]initWithFrame:CGRectZero
                                                            title:NSLocalizedString(@"meeting_top_overlay", nil)
                                                            image:@"frtc_meeting_top_position"
                                                            block:^(FOverlayPositionItemView * _Nonnull itemView) {
            @StrongObj(self)
            [self selectedAction:itemView];
        }];
        _leftBtn.tag = 0;
        _leftBtn.imageView.hidden = NO;
    }
    return _leftBtn;
}

- (FOverlayPositionItemView *)centerBtn {
    if (!_centerBtn) {
        @WeakObj(self)
        _centerBtn = [[FOverlayPositionItemView alloc]initWithFrame:CGRectZero
                                                              title:NSLocalizedString(@"meeting_center_overlay", nil)
                                                              image:@"frtc_meeting_center_position"
                                                              block:^(FOverlayPositionItemView * _Nonnull itemView) {
            @StrongObj(self)
            [self selectedAction:itemView];
        }];
        _centerBtn.tag = 50;
    }
    return _centerBtn;
}

- (FOverlayPositionItemView *)rightBtn {
    if (!_rightBtn) {
        @WeakObj(self)
        _rightBtn = [[FOverlayPositionItemView alloc]initWithFrame:CGRectZero
                                                             title:NSLocalizedString(@"meeting_bottom_overlay", nil)
                                                             image:@"frtc_meeting_botton_position"
                                                             block:^(FOverlayPositionItemView * _Nonnull itemView) {
            @StrongObj(self)
            [self selectedAction:itemView];
        }];
        _rightBtn.tag = 100;
    }
    return _rightBtn;
}

@end



//Item View
@interface FOverlayPositionItemView ()
{
    NSString *title;
    NSString *image;
}
@end

static FOverlayPositionItemBlock itemBlock = nil;

@implementation FOverlayPositionItemView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(nonnull NSString *)title
                        image:(nonnull NSString *)image
                        block:(FOverlayPositionItemBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        itemBlock = block;
        self->title = title;
        self->image = image;
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    itemBlock = nil;
    ISMLog(@"%s",__func__);
}

- (void)setupView {
    
    UIButton *button = [self getCustonButtonWithName:title image:image];
    [self addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(5);
        make.bottom.right.mas_equalTo(-5);
    }];
    
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"frtc_meeting_cornerMarker"]];
    self.imageView.hidden = YES;
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
    }];
    
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = UIColorHex(0x26ff5).CGColor;
    self.layer.borderWidth = 1;
}

- (UIButton *)getCustonButtonWithName:(NSString *)title image:(NSString *)image{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:11.f];
    [button setTitleColor:KTextColor forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image]
            forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    @WeakObj(self)
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (itemBlock) {
            itemBlock(self);
        }
    }];
    [button setImageLayout:UIButtonLayoutImageTop space:5];
    button.isSizeToFit = true;
    return button;
}

@end
