#import "FrtcHDBaseViewController.h"
@class FInviteUserListInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingInviteUserViewController : FrtcHDBaseViewController

@property (nonatomic, copy) void(^inviteUserList)(NSArray *users);

@property (nonatomic, strong) NSArray<FInviteUserListInfo *> *userIds;

@end

NS_ASSUME_NONNULL_END
