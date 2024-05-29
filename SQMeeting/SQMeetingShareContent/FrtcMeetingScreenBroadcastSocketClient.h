#import <ReplayKit/ReplayKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcMeetingSampleHandlerDelegate <NSObject>

-(void)frtcBroadcastFinished;

@end

@interface FrtcMeetingScreenBroadcastSocketClient : NSObject

+ (FrtcMeetingScreenBroadcastSocketClient *)singleClient;

- (void)setUpSocket;

- (void)socketDelloc;

- (void)sendVideoBufferToHostApp:(CMSampleBufferRef)sampleBuffer;

@property(nonatomic, weak) id<FrtcMeetingSampleHandlerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
