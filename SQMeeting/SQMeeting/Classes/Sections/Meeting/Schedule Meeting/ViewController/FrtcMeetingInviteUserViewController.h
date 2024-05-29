#import "BaseViewController.h"
#import "FrtcInviteUserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingInviteUserViewController : BaseViewController

@property (nonatomic, copy) void(^inviteUserList)(NSArray<FInviteUserListInfo *> *users);

@property (nonatomic, strong) NSArray<FInviteUserListInfo *> *userIds;

@end

NS_ASSUME_NONNULL_END
