#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcManager : NSObject

@property (class, nonatomic, getter=isInMeeting) BOOL inMeeting;
@property (class, nonatomic, getter=isGuestUser) BOOL guestUser;
@property (class, nonatomic, strong) NSString *serverAddress;

+ (void)handleOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
