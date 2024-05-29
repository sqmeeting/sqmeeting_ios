#import "FrtcDuplicateDateCCell.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"

@implementation FrtcDuplicateDateCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dateButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_dateButton];
        [_dateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40 , 40));
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setWeek:(BOOL)week {
    _week = week;
    if (week) {
        [_dateButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0xbbc3ce)] forState:UIControlStateNormal];
        [_dateButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateHighlighted];
        [_dateButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0x6aaafe)] forState:UIControlStateSelected | UIControlStateHighlighted];
        _dateButton.layer.cornerRadius = 6;
        _dateButton.layer.masksToBounds = YES;
        [_dateButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal | UIControlStateHighlighted | UIControlStateSelected];
    }else{
        [_dateButton setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateNormal];
        [_dateButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateHighlighted];
        [_dateButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0x6aaafe)] forState:UIControlStateSelected | UIControlStateHighlighted];
        _dateButton.layer.cornerRadius = 20;
        _dateButton.layer.masksToBounds = YES;
        [_dateButton setTitleColor:KTextColor forState:UIControlStateNormal];
        [_dateButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        [_dateButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}


@end
