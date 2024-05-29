#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "FrtcCall.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    int upRate;
    int downRate;
} CallRate;

typedef void(^CallSuccessBlock) (void);
typedef void(^CallFailureBlock) (FRTCMeetingStatusReason status, NSString *errMsg);
typedef void(^InputPassCodeCallBack) (void);

@interface FrtcMakeCallClient : NSObject

+ (FrtcMakeCallClient *)sharedSDKContext;

- (void)makeCall:(UIViewController *)parentViewController withCallParam:(FRTCSDKCallParam)param withCallSuccessBlock :(CallSuccessBlock)callSuccessBlock withCallFailureBlock:(CallFailureBlock)callFailureBlock withInputPassCodeCallBack:(InputPassCodeCallBack)inputPassCodeBlock;

@end

NS_ASSUME_NONNULL_END
