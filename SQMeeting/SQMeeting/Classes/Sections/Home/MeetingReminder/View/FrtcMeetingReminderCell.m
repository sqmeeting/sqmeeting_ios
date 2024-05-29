#import "FrtcMeetingReminderCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"

@interface FrtcMeetingReminderCell ()

@property (nonatomic, strong) UILabel *callLable;

@end

@implementation FrtcMeetingReminderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
             
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.callLable];
     
        [self.callLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing12);
            make.size.mas_equalTo(CGSizeMake(KScaleWidth(70), 30));
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing12);
            make.right.equalTo(self.callLable.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView).offset(-12);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing12);
            make.right.equalTo(self.callLable.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView).offset(12);
        }];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(KLeftSpacing, 70 - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - lazy

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = KDetailTextColor;
        _detailLabel.font = [UIFont systemFontOfSize:13.f];
    }
    return _detailLabel;
}

- (UILabel *)callLable {
    if (!_callLable) {
        _callLable = [[UILabel alloc]init];
        _callLable.text = NSLocalizedString(@"join_meeting", nil);
        _callLable.textColor = UIColor.whiteColor;
        _callLable.backgroundColor = kMainColor;
        _callLable.font = [UIFont systemFontOfSize:12.f];
        _callLable.textAlignment = NSTextAlignmentCenter;
        _callLable.layer.masksToBounds = YES;
        _callLable.layer.cornerRadius = 4;
    }
    return _callLable;
}


@end
