#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FInviteUserListInfo : NSObject

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *real_name;
@property (nonatomic, getter=isSelect) BOOL select;

@end

@interface FrtcInviteUserModel : NSObject

@property (nonatomic, assign) NSInteger total_page_num;
@property (nonatomic, assign) NSInteger total_size;
@property (nonatomic, strong) NSArray<FInviteUserListInfo *> *users;

@end


NS_ASSUME_NONNULL_END
