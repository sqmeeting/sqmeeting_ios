#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TalkingToolBarView.h"
#import "MediaControlView.h"
#import "TopLayoutBarView.h"
#import "TopBarView.h"
#import "EndMeetingController.h"
#import "WZLBadgeImport.h"
#import "RostListDlgController.h"
#import "FrtcStatisticalModel.h"
#import "OverlayMessageModel.h"
#import "TopOverLayMessageView.h"
#import "FrtcMeetingPasscodeController.h"
#include <FrtcCall.h>

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
