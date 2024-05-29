#import "FrtcHomeScheduleListHeaderView.h"
#import "Masonry.h"

@interface FrtcHomeScheduleListHeaderView ()

@property (nonatomic, strong) UILabel *titleLable;

@end

@implementation FrtcHomeScheduleListHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self headerViewLayout];
    }
    return self;
}

- (void)headerViewLayout {
    self.contentView.backgroundColor = KBGColor;
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.bottom.right.mas_equalTo(0);
    }];
}

- (void)setMeetingTime:(NSString *)meetingTime {
    _meetingTime = meetingTime;
    self.titleLable.text = _meetingTime;
}

#pragma mark - lazy

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]init];
        _titleLable.textColor = KTextColor;
        _titleLable.font = [UIFont boldSystemFontOfSize:15];
        [self.contentView addSubview:_titleLable];
    }
    return _titleLable;
}

@end
