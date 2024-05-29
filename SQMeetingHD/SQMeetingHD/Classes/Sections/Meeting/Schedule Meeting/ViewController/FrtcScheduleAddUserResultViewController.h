#import "FrtcHDBaseViewController.h"
@class FInviteUserListInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleAddUserResultViewController : FrtcHDBaseViewController

@property (nonatomic, copy) void(^deleteUser)(FInviteUserListInfo *info);

@property (nonatomic, copy) void(^inviteBtnCallBack)(void);

@property (nonatomic, strong) NSMutableArray<FInviteUserListInfo *> *selectListData;

@end

NS_ASSUME_NONNULL_END
