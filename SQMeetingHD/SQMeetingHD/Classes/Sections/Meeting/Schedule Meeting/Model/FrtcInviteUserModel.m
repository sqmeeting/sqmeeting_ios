#import "FrtcInviteUserModel.h"

@implementation FInviteUserListInfo

@end

@implementation FrtcInviteUserModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [FInviteUserListInfo class]};
}

@end
