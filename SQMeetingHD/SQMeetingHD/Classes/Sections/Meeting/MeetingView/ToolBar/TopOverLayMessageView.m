#import "TopOverLayMessageView.h"
#import "Masonry.h"
@interface TopOverLayMessageView ()

@property(nonatomic, assign) NSTimeInterval animateDuration;
@property (nonatomic, assign, getter = isStaticMode) BOOL staticMode;

@end

@implementation TopOverLayMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self configView];
        
    }
    
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configSize:(CGSize)size {
    self.size = size;
    self.messageLabel.frame = CGRectMake(self.frame.size.width, (self.frame.size.height - size.height)/2, size.width, size.height);
    self.staticMode = FALSE;
}

- (void)staticDisplayMessageView:(CGSize)size {
    self.size = size;
    CGFloat fx = self.size.width >= (LAND_SCAPE_WIDTH - 20) ? 10 : (self.frame.size.width - size.width)/2;
    if (fx <= 0) {fx = 1;}
    self.messageLabel.frame = CGRectMake(fx, (self.frame.size.height - size.height)/2, LAND_SCAPE_WIDTH - 60 , size.height);
    self.staticMode = TRUE;
}

- (void)updateNewAnimation {
    [_messageLabel.layer removeAllAnimations];
}

- (void)resumeAnimation:(NSNotification *)ntf {
    if(self.isStaticMode){
        CGFloat fx = self.size.width >= (LAND_SCAPE_WIDTH - 20) ? 0 : (self.frame.size.width - _size.width)/2;
        self.messageLabel.frame = CGRectMake(fx, (self.frame.size.height - _size.height)/2, LAND_SCAPE_WIDTH - 60 , _size.height);
        return;
    }
    [_messageLabel.layer removeAllAnimations];
    self.messageLabel.frame = CGRectMake(self.frame.size.width, (self.frame.size.height - _size.height)/2, _size.width, _size.height);
    [self updateView:self.animateDuration];
}

- (void)registerBecomeActiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(resumeAnimation:)
        name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)configView {
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.numberOfLines = 1.0;
    _messageLabel.font = [UIFont systemFontOfSize:20.0];
    _messageLabel.textColor = [UIColor whiteColor];
    [self addSubview:_messageLabel];
}

- (void)updateView:(NSTimeInterval)duration {
    self.animateDuration = duration;
    
    [UIView animateWithDuration:duration animations:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [UIView setAnimationRepeatCount:self.repeateTime];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
#pragma clang diagnostic pop
        self.messageLabel.frame = CGRectMake(-self.size.width, (self.frame.size.height - self.size.height)/2, self.size.width, self.size.height);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if(self.delegate && [self.delegate respondsToSelector:@selector(repeateUpdateView)]) {
                [self.delegate repeateUpdateView];
            }
        }
    }];
}

- (CGFloat)getScreenLandscapeWidth {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width > size.height ? size.width : size.height;
}

- (UILabel *)messageLabel {
    if(!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.numberOfLines = 1.0;
        _messageLabel.font = [UIFont systemFontOfSize:20.0];
        _messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:_messageLabel];
    }
    
    return _messageLabel;
}

@end
