#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^onDataRecved) (void* buffer, size_t width, size_t height, OSType format, size_t roration);

@interface FrtcMeetingClientBufferSocketManager : NSObject

+ (FrtcMeetingClientBufferSocketManager *)sharedManager;

- (void)stopSocket;

- (void)setupSocket;

@property(nonatomic, copy) onDataRecved dataReceived;


@end

NS_ASSUME_NONNULL_END
