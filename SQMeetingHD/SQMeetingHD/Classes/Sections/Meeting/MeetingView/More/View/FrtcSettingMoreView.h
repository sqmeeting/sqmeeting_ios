#import <UIKit/UIKit.h>
#import "FrtcLiveStatusModel.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcMoreCustomButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FMoreViewTypeNol,
    FMoreViewTypeShare,
    FMoreViewTypeRecord,
    FMoreViewTypeLive,
    FMoreViewTypeOverlay,
    FMoreViewTypeStopOverlay,
    FMoreViewTypeSetting,
    FMoreViewTypeReceivingVideo,
    FMoreViewTypeFloating,
} FMoreViewType;

typedef void(^SettingMoreViewBlock) (FMoreViewType type,NSInteger index);
typedef void(^DisMissSettingMoreViewBlock) (void);

@interface FrtcSettingMoreView : UIView

@property (nonatomic, copy) SettingMoreViewBlock moreViewBlock;
@property (nonatomic, copy) DisMissSettingMoreViewBlock disMissMoreViewBlock;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic, strong) UIButton *overlayButton;
@property (nonatomic, strong) UIButton *stopOverlayButton;
@property (nonatomic, strong) FrtcMoreCustomButton *videoButton;

- (instancetype)initWithFrame:(CGRect)frame
              meetingOperator:(FHomeMeetingListModel *)meetingInfo
              liveStatusModel:(FrtcLiveStatusModel *)liveStatusModel
                serverUrlSame:(BOOL)isServerUrlSame;

@end

NS_ASSUME_NONNULL_END
