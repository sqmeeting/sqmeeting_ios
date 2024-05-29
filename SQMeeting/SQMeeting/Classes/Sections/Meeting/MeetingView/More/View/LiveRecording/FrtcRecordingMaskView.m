#import "FrtcRecordingMaskView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"

@interface FrtcRecordingMaskView ()

@end

@implementation FrtcRecordingMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.text = NSLocalizedString(@"FM_VIDEO_RECORDING_SUCCESS_TITLE", @"Recording");
        titleLable.font = [UIFont boldSystemFontOfSize:16.f];
        titleLable.textColor = KTextColor;
        [self addSubview:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(KLeftSpacing12);
        }];
        
        UILabel *descriptionLable = [[UILabel alloc]init];
        descriptionLable.text = NSLocalizedString(@"FM_VIDEO_RECORDING_SUCCESS_DESCRIPTION", @"After recording ended, go to “SQ MeetingCE Webpotal-Meeting Recording” to check recorded files.");
        descriptionLable.font = [UIFont systemFontOfSize:14.f];
        descriptionLable.textColor = KTextColor666666;
        descriptionLable.numberOfLines = 0;
        [self addSubview:descriptionLable];
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [okBtn setTitle:NSLocalizedString(@"FM_VIDEO_RECORDING_SUCCESS_BUTTON", @"Got It") forState:UIControlStateNormal];
        [okBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        okBtn.layer.cornerRadius = 4;
        okBtn.layer.masksToBounds = YES;
        okBtn.backgroundColor = kMainColor;
        @WeakObj(self)
        [okBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.dismissViewBlock) {
                self.dismissViewBlock();
            }
        }];
        [self addSubview:okBtn];
        
        [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing12);
            make.size.mas_equalTo(CGSizeMake(60, 30));
            make.centerY.equalTo(descriptionLable);
        }];
        
        [descriptionLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLable);
            make.top.equalTo(titleLable.mas_bottom).offset(10);
            make.bottom.mas_equalTo(-KLeftSpacing);
            make.right.equalTo(okBtn.mas_left).offset(-KLeftSpacing12);
        }];
        
    }
    return self;
}

- (void)dealloc {
    
}

@end
