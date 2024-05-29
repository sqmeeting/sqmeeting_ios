#import <UIKit/UIKit.h>
@class ParticipantListModel;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    KMuteViewTypeNol,
    KMuteViewTypeName,
    KMuteViewTypeMute,
    KMuteViewTypeLecture,
    KMuteViewTypeRemove,
    KMuteViewTypePin
} KMuteType;

typedef void(^MuteViewCallBack)(KMuteType type);

@interface MuteView : UIView

+ (void)showMuteAlertViewWithModel:(ParticipantListModel *)model
                    isExistLecture:(BOOL)isExistLecture
                   meetingOperator:(BOOL)isMeetingOperator
                          lectures:(BOOL)isLecture
                               pin:(BOOL)isPin
                  muteViewCallBack:(MuteViewCallBack)muteBlock;

+ (void)disMissView;

@end

NS_ASSUME_NONNULL_END
