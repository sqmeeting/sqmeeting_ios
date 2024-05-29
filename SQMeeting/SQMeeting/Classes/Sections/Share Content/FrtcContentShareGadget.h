#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcContentShareGadget : NSObject

+ (instancetype) sharedInstance;

- (void)startRecordScreenSharing:(BOOL)isSharing;

- (void)startSendContentStream;

@end

NS_ASSUME_NONNULL_END
