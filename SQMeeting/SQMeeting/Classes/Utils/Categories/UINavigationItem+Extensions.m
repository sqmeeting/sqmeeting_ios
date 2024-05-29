#import "UINavigationItem+Extensions.h"
#import <objc/runtime.h>

static const char *mBackKey = "mBackKey";

static const char *mRightKey = "mRightKey";

@interface  UINavigationItem (Extensions)

@property (nonatomic, copy) void(^mBack)();
@property (nonatomic, copy) void (^mRight)();

@end


@implementation UINavigationItem (Extensions)

- (void(^)())mBack {
    return objc_getAssociatedObject(self, mBackKey);
}

- (void)setMBack:(void(^)())mBack {
    objc_setAssociatedObject(self, mBackKey, mBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)())mRight{
    return objc_getAssociatedObject(self,mRightKey);
}

- (void)setMRight:(void (^)())mRight{
    objc_setAssociatedObject(self, mRightKey, mRight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)initWithLeftButtonTitleCallBack:(void (^)())back {
    self.mBack = back;
    [self leftButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
}

- (void)initWithLeftButtonTitle:(NSString *)leftButtonTitle
                           back:(void(^)())back {
    self.mBack = back;
    [self leftButtonWithTitle:leftButtonTitle];
}

- (void)leftButtonWithTitle:(NSString *)title {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:title forState:UIControlStateNormal];
    [leftBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [leftBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.leftBarButtonItem = returnButtonItem;
}

- (void)initWithLeftButtonImage:(NSString *)leftButtonImage
                           back:(void(^)())back {
    self.mBack = back;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:leftButtonImage] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.leftBarButtonItem = returnButtonItem;
}

- (void)initWithRightButtonTitle:(NSString *)RightButtonTitle
                                   back:(void(^)())back{
    self.mRight = back;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:RightButtonTitle forState:UIControlStateNormal];
    [rightBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.rightBarButtonItem = rightButtonItem;
}

- (void)initWithRightImage:(NSString *)imageStr
                      back:(void(^)())back {
    self.mRight = back;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.rightBarButtonItem = rightButtonItem;
}

- (void)backBtnClick {
    if (self.mBack) {
        self.mBack();
    }
}

- (void)rightBtnClick {
    if (self.mRight) {
        self.mRight();
    }
}

@end
