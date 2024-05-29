#import "FrtcCallWarnView.h"
#import "Masonry.h"

@interface FrtcCallWarnView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLable;

@end

@implementation FrtcCallWarnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(0);
        }];
        [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).mas_offset(8);
            make.centerY.equalTo(self.imageView.mas_centerY);
        }];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    self.titleLable.text = content;
}

#pragma mark - lazy

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"setting_warn"];;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}


- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]init];
        _titleLable.textColor = KTextColor666666;
        _titleLable.font = [UIFont systemFontOfSize:12.f];
        _titleLable.clipsToBounds = YES;
        [self addSubview:_titleLable];
    }
    return _titleLable;
}

@end
