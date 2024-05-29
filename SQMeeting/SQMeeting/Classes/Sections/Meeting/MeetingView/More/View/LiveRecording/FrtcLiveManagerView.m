#import "FrtcLiveManagerView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIView+Extensions.h"
#import "UIStackView+Extensions.h"
#import "RosterPresenter.h"

@interface FrtcLiveManagerView ()

@end

@implementation FrtcLiveManagerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 8;
        [self addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        @WeakObj(self)

        _liveView = [[FrtcLiveItemMaskView alloc]init];
        [_liveView setTipsStatus:FLiveTipsStatusLive];
        _liveView.hidden = YES;
        _liveView.layer.cornerRadius  = 4;
        _liveView.layer.masksToBounds = YES;
        _liveView.shareBlock = ^{
            @StrongObj(self)
            if (self.sharLiveUrlBlock) {
                self.sharLiveUrlBlock();
            }
        };
        
        _liveView.stopBlock = ^{
            @StrongObj(self)
            RosterPresenter *recordPresenter = [[RosterPresenter alloc] init];
            [recordPresenter stopLiveWithMeetingNumber:self.meetingNumber];
        };
        
        _recordView = [[FrtcLiveItemMaskView alloc]init];
        [_recordView setTipsStatus:FLiveTipsStatusRecording];
        _recordView.hidden = YES;
        _recordView.layer.cornerRadius  = 4;
        _recordView.layer.masksToBounds = YES;
        _recordView.stopBlock = ^{
            @StrongObj(self)
            RosterPresenter *recordPresenter = [[RosterPresenter alloc] init];
            [recordPresenter stopRecordingWithMeetingNumber:self.meetingNumber];
        };
        
        [stackView addArrangedSubviews:@[_liveView,_recordView]];
        
        [@[_liveView,_recordView] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(stackView);
        }];
    
    }
    return self;
}

- (void)dealloc {
    
}

@end
