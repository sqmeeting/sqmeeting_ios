#import "FrtcSettingMoreView.h"
#import "UIButton+Extensions.h"
#import "UIControl+Extensions.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "UIImage+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcUserModel.h"
#import "FrtcCall.h"

#define KButtonBgColor  UIColorHex(0x1b1c1e)

@interface FrtcSettingMoreView ()

@property (nonatomic, strong) UIStackView *hStackView;
@property (nonatomic, strong) UIStackView *vStackView;

//@property (nonatomic, getter=isMeetingOperator) BOOL meetingOperator;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *floatingButton;

@end

@implementation FrtcSettingMoreView

- (instancetype)initWithFrame:(CGRect)frame
              meetingOperator:(FHomeMeetingListModel *)meetingInfo
              liveStatusModel:(FrtcLiveStatusModel *)liveStatusModel
                serverUrlSame:(BOOL)isServerUrlSame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        [self addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(-8);
            make.left.mas_equalTo(8);
            make.height.mas_equalTo(40);
        }];
            
        UIView *containerView = [UIView new];
        [self addSubview:containerView];
        
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.bottom.equalTo(self.cancelButton.mas_top).offset(-8);
        }];
        
        BOOL isMeetingManager = meetingInfo.isMeetingOperator || meetingInfo.isSystemAdmin || [meetingInfo.ownerID isEqualToString:[FrtcUserModel fetchUserInfo].user_id];
        
        if (!isServerUrlSame) {
            isMeetingManager =
            meetingInfo.meetingOperator =
            meetingInfo.systemAdmin = NO;
        }

        self.videoButton.selected = [[FrtcCall frtcSharedCallClient] frtcGetCurrentRemotePeopleVideoMuteStatus];
        self.recordButton.selected = liveStatusModel.isRecording;
        self.liveButton.selected   = liveStatusModel.isLive;
        
        NSArray *viewsArray = @[self.shareButton,self.videoButton,self.floatingButton];
        
        if (meetingInfo.isMeetingOperator || meetingInfo.isSystemAdmin) {
            viewsArray = @[self.shareButton,self.overlayButton,self.stopOverlayButton,self.recordButton,self.liveButton,self.videoButton,self.floatingButton];
        }
        
        if ([meetingInfo.ownerID isEqualToString:[FrtcUserModel fetchUserInfo].user_id] &&  (!meetingInfo.isMeetingOperator && !meetingInfo.isSystemAdmin)) {
            viewsArray = @[self.shareButton,self.overlayButton,self.stopOverlayButton,self.recordButton,self.videoButton,self.floatingButton];
        }
        
        self.videoButton.enabled = !meetingInfo.isAudioCall;

        CGFloat marginX = 8;
        CGFloat gapX    = 0;
        NSInteger col   = viewsArray.count > 5 ? 5 : viewsArray.count;
        CGFloat viewHeight = 70;
        CGFloat viewWidth  = 60;
        
        UIButton *last = nil;
        for (int i = 0 ; i < viewsArray.count; i++) {
            UIButton *item = viewsArray[i];
            [containerView addSubview:item];
            
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(viewWidth);
                make.height.mas_equalTo(viewHeight);
                CGFloat top = gapX + (i/col)*(viewHeight+marginX);
                make.top.mas_offset(top);
                if (!last || (i%col) == 0) {
                    make.left.mas_offset(gapX);
                }else{
                    make.left.mas_equalTo(last.mas_right).mas_offset(marginX);
                }
                
                if (i == (col - 1)) {
                    make.right.mas_equalTo(0);
                }
                
                if (i == viewsArray.count - 1) {
                    make.bottom.mas_equalTo(0);
                }
            }];
            last = item;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setCornerRadius:8 addRectCorners:UIRectCornerAllCorners];
        });
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - lazy

- (UIStackView *)hStackView {
    if (!_hStackView) {
        _hStackView = [[UIStackView alloc]init];
        _hStackView.spacing = 8;
        _hStackView.axis = UILayoutConstraintAxisHorizontal;
    }
    return _hStackView;
}

- (UIStackView *)vStackView {
    if (!_vStackView) {
        _vStackView = [[UIStackView alloc]init];
        _vStackView.spacing = 8;
        _vStackView.axis = UILayoutConstraintAxisVertical;
    }
    return _vStackView;
}

- (UIButton *)shareButton {
   if (!_shareButton) {
      _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _shareButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_shareButton setImage:[UIImage imageNamed:@"frtc_icon_moreShare"]
              forState:UIControlStateNormal];
      [_shareButton setTitle:NSLocalizedString(@"meeting_invite_join", nil) forState:UIControlStateNormal];
      _shareButton.backgroundColor = KButtonBgColor;
      _shareButton.layer.cornerRadius = 6;
      _shareButton.layer.masksToBounds = YES;
      @WeakObj(self)
      [_shareButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeShare,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_shareButton setImageLayout:UIButtonLayoutImageTop space:5];
      _shareButton.isSizeToFit = true;
   }
   return _shareButton;
}

- (UIButton *)recordButton {
   if (!_recordButton) {
      _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _recordButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_recordButton setImage:[UIImage imageNamed:@"frtc_start_record"]
              forState:UIControlStateNormal];
      [_recordButton setImage:[UIImage imageNamed:@"frtc_end_record"]
              forState:UIControlStateSelected];
      [_recordButton setTitle:NSLocalizedString(@"meeting_record", nil) forState:UIControlStateNormal];
      [_recordButton setTitle:NSLocalizedString(@"meeting_stop_record", nil) forState:UIControlStateSelected];
      [_recordButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled | UIControlStateSelected];
      [_recordButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal | UIControlStateSelected];
      _recordButton.backgroundColor = KButtonBgColor;
      _recordButton.layer.cornerRadius = 6;
      _recordButton.layer.masksToBounds = YES;
      //button.enabled = NO;
      @WeakObj(self)
      [_recordButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeRecord,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_recordButton setImageLayout:UIButtonLayoutImageTop space:5];
      _recordButton.isSizeToFit = true;
   }
   return _recordButton;
}

- (UIButton *)liveButton {
   if (!_liveButton) {
      _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _liveButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_liveButton setImage:[UIImage imageNamed:@"frtc_start_live"]
              forState:UIControlStateNormal];
      [_liveButton setImage:[UIImage imageNamed:@"frtc_end_live"]
              forState:UIControlStateSelected];
      [_liveButton setTitle:NSLocalizedString(@"meeting_live", nil) forState:UIControlStateNormal];
      [_liveButton setTitle:NSLocalizedString(@"meeting_stop_live", nil) forState:UIControlStateSelected];
      [_liveButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled | UIControlStateSelected];
      [_liveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal | UIControlStateSelected];
      _liveButton.backgroundColor = KButtonBgColor;
      _liveButton.layer.cornerRadius = 6;
      _liveButton.layer.masksToBounds = YES;
      //button.enabled = NO;
      @WeakObj(self)
      [_liveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeLive,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_liveButton setImageLayout:UIButtonLayoutImageTop space:5];
      _liveButton.isSizeToFit = true;
   }
   return _liveButton;
}

- (UIButton *)overlayButton {
   if (!_overlayButton) {
      _overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _overlayButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_overlayButton setImage:[UIImage imageNamed:@"frtc_start_overlay"]
              forState:UIControlStateNormal];
      [_overlayButton setTitle:NSLocalizedString(@"meeting_start_overlay", nil) forState:UIControlStateNormal];
      [_overlayButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled];
      [_overlayButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
      _overlayButton.backgroundColor = KButtonBgColor;
      _overlayButton.layer.cornerRadius = 6;
      _overlayButton.layer.masksToBounds = YES;
      @WeakObj(self)
      [_overlayButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeOverlay,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_overlayButton setImageLayout:UIButtonLayoutImageTop space:5];
      _overlayButton.isSizeToFit = true;
   }
   return _overlayButton;
}

- (UIButton *)stopOverlayButton {
   if (!_stopOverlayButton) {
      _stopOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _stopOverlayButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_stopOverlayButton setImage:[UIImage imageNamed:@"frtc_end_overlay"]
              forState:UIControlStateNormal];
      [_stopOverlayButton setTitle:NSLocalizedString(@"meeting_stop_overlay", nil) forState:UIControlStateNormal];
      [_stopOverlayButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled];
      [_stopOverlayButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
      _stopOverlayButton.backgroundColor = KButtonBgColor;
      _stopOverlayButton.layer.cornerRadius = 6;
      _stopOverlayButton.layer.masksToBounds = YES;
      @WeakObj(self)
      [_stopOverlayButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeStopOverlay,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_stopOverlayButton setImageLayout:UIButtonLayoutImageTop space:5];
      _stopOverlayButton.isSizeToFit = true;
   }
   return _stopOverlayButton;
}

- (UIButton *)settingButton {
   if (!_settingButton) {
      _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _settingButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
      [_settingButton setImage:[UIImage imageNamed:@"frtc_meeting_setting"]
              forState:UIControlStateNormal];
      [_settingButton setImage:[UIImage imageNamed:@"frtc_meeting_setting"]
              forState:UIControlStateSelected];
      [_settingButton setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
      _settingButton.backgroundColor = KButtonBgColor;
      _settingButton.layer.cornerRadius = 6;
      _settingButton.layer.masksToBounds = YES;
      @WeakObj(self)
      [_settingButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeSetting,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_settingButton setImageLayout:UIButtonLayoutImageTop space:5];
      _settingButton.isSizeToFit = true;
   }
   return _settingButton;
}

- (UIButton *)cancelButton {
   if (!_cancelButton) {
      _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
      [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
      _cancelButton.backgroundColor = KButtonBgColor;
      _cancelButton.layer.cornerRadius = 6;
      _cancelButton.layer.masksToBounds = YES;
      @WeakObj(self)
      [_cancelButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
   }
   return _cancelButton;
}

- (UIButton *)floatingButton {
   if (!_floatingButton) {
       _floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
       _floatingButton.titleLabel.font = [UIFont systemFontOfSize:10.f];
      [_floatingButton setImage:[UIImage imageNamed:@"frtc_meeting_floating"]
              forState:UIControlStateNormal];
      [_floatingButton setTitle:FLocalized(@"meeting_show_floating", nil) forState:UIControlStateNormal];
      [_floatingButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled];
      [_floatingButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal | UIControlStateSelected];
       _floatingButton.backgroundColor = KButtonBgColor;
       _floatingButton.layer.masksToBounds = YES;
       _floatingButton.layer.cornerRadius = 6;
      //button.enabled = NO;
      @WeakObj(self)
      [_floatingButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeFloating,0);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
      [_floatingButton setImageLayout:UIButtonLayoutImageTop space:5];
       _floatingButton.isSizeToFit = true;
   }
   return _floatingButton;
}

- (FrtcMoreCustomButton *)videoButton {
   if (!_videoButton) {
      
      _videoButton = [[FrtcMoreCustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 70)];
      _videoButton.titleLabel.font = [UIFont systemFontOfSize:10.f];
      [_videoButton setImage:[UIImage imageNamed:@"frtc_stop_receivingVideos"]
              forState:UIControlStateNormal];
      [_videoButton setImage:[UIImage imageNamed:@"frtc_receivingVideos"]
              forState:UIControlStateSelected];
      [_videoButton setTitle:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_STOP", nil) forState:UIControlStateNormal];
      [_videoButton setTitle:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_RECEIVING", nil) forState:UIControlStateSelected];
      [_videoButton setTitleColor:KDetailTextColor forState:UIControlStateDisabled | UIControlStateSelected];
      [_videoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal | UIControlStateSelected];
      _videoButton.backgroundColor = KButtonBgColor;
      _videoButton.layer.masksToBounds = YES;
      _videoButton.layer.cornerRadius = 6;

      @WeakObj(self)
      [_videoButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
         @StrongObj(self)
         self.videoButton.selected = !self.videoButton.selected;
         if (self.moreViewBlock) {
            self.moreViewBlock(FMoreViewTypeReceivingVideo,self.videoButton.isSelected);
         }
         if (self.disMissMoreViewBlock) {
            self.disMissMoreViewBlock();
         }
      }];
   }
   return _videoButton;
}
@end
