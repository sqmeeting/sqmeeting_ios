#import "UITableView+Extensions.h"
#import <objc/runtime.h>


NSString * const kFNoDataViewObserveKeyPath = @"frame";

@implementation FNoDataView

- (void)dealloc {
}

@end


@protocol FTableViewDelegate <NSObject>
@optional
- (UIView   *)f_noDataView;                  //  完全自定义占位图
- (UIImage  *)f_noDataViewImage;           //  使用默认占位图, 提供一张图片,    可不提供, 默认不显示
- (NSString *)f_noDataViewMessage;         //  使用默认占位图, 提供显示文字,    可不提供, 默认为暂无数据
- (UIColor  *)f_noDataViewMessageColor;    //  使用默认占位图, 提供显示文字颜色, 可不提供, 默认为灰色
- (NSNumber *)f_noDataViewCenterYOffset;   //  使用默认占位图, CenterY 向下的偏移量
@end


@implementation UITableView (Extensions)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method reloadData    = class_getInstanceMethod(self, @selector(reloadData));
        Method f_reloadData = class_getInstanceMethod(self, @selector(f_reloadData));
        method_exchangeImplementations(reloadData, f_reloadData);
        
        Method dealloc       = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method f_dealloc    = class_getInstanceMethod(self, @selector(f_dealloc));
        method_exchangeImplementations(dealloc, f_dealloc);
    });
}

- (void)f_reloadData {
    
    [self f_reloadData];
    
    if (![self isInitFinish]) {
        [self f_havingData:YES];
        [self setIsInitFinish:YES];
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger numberOfSections = [self numberOfSections];
        BOOL havingData = NO;
        for (NSInteger i = 0; i < numberOfSections; i++) {
            if ([self numberOfRowsInSection:i] > 0) {
                havingData = YES;
                break;
            }
        }
        
        [self f_havingData:havingData];
    });
}

- (void)f_havingData:(BOOL)havingData {
    
    if (havingData) {
        [self freeNoDataViewIfNeeded];
        self.backgroundView = nil;
        return ;
    }
    
    if (self.backgroundView) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(f_noDataView)]) {
        self.backgroundView = [self.delegate performSelector:@selector(f_noDataView)];
        return ;
    }
    
    UIImage  *img   = nil;
    NSString *msg   = @"";
    UIColor  *color = [UIColor lightGrayColor];
    CGFloat  offset = 0;
    
    if ([self.delegate    respondsToSelector:@selector(f_noDataViewImage)]) {
        img = [self.delegate performSelector:@selector(f_noDataViewImage)];
    }
    if ([self.delegate    respondsToSelector:@selector(f_noDataViewMessage)]) {
        msg = [self.delegate performSelector:@selector(f_noDataViewMessage)];
    }
    if ([self.delegate      respondsToSelector:@selector(f_noDataViewMessageColor)]) {
        color = [self.delegate performSelector:@selector(f_noDataViewMessageColor)];
    }
    if ([self.delegate        respondsToSelector:@selector(f_noDataViewCenterYOffset)]) {
        offset = [[self.delegate performSelector:@selector(f_noDataViewCenterYOffset)] floatValue];
    }
    
    self.backgroundView = [self f_defaultNoDataViewWithImage  :img message:msg color:color offsetY:offset];
}

- (UIView *)f_defaultNoDataViewWithImage:(UIImage *)image message:(NSString *)message color:(UIColor *)color offsetY:(CGFloat)offset {
    
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat cY = self.bounds.size.height * (1 - 0.618) + offset;
    CGFloat iW = image.size.width;
    CGFloat iH = image.size.height;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame        = CGRectMake(cX - iW / 2, cY - iH / 2, iW, iH);
    imgView.image        = image;
    
    UILabel *label       = [[UILabel alloc] init];
    label.font           = [UIFont systemFontOfSize:17];
    label.textColor      = color;
    label.text           = message;
    label.textAlignment  = NSTextAlignmentCenter;
    label.frame          = CGRectMake(0, CGRectGetMaxY(imgView.frame) + 24, sW, label.font.lineHeight);
    
    FNoDataView *view   = [[FNoDataView alloc] init];
    [view addSubview:imgView];
    [view addSubview:label];
    
    [view addObserver:self forKeyPath:kFNoDataViewObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return view;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kFNoDataViewObserveKeyPath]) {
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (frame.origin.y != 0) {
            frame.origin.y  = 0;
            self.backgroundView.frame = frame;
        }
    }
}

#pragma mark - 属性

- (void)setIsInitFinish:(BOOL)finish {
    objc_setAssociatedObject(self, @selector(isInitFinish), @(finish), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInitFinish {
    id obj = objc_getAssociatedObject(self, _cmd);
    return [obj boolValue];
}

- (void)freeNoDataViewIfNeeded {
    
    if ([self.backgroundView isKindOfClass:[FNoDataView class]]) {
        [self.backgroundView removeObserver:self forKeyPath:kFNoDataViewObserveKeyPath context:nil];
    }
}

- (void)f_dealloc {
    [self freeNoDataViewIfNeeded];
    [self f_dealloc];
}

@end
