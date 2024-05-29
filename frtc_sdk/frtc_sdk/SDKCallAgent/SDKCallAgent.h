//
//  SDKCallAgent.h
//  frtc_sdk
//
//  Created by yafei on 2021/11/23.
//  Copyright © 2021 徐亚飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FrtcCall.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDKCallAgent : NSObject

- (void)sdkAgentMakeCall:(SDKCallParam)callParam
              controller:(UIViewController * _Nonnull )controller
   callCompletionHandler:(void (^)(FRTCSDKCallState callState, FRTCSDKCallResult reason,
                 NSString *conferenceNumber, NSString *conferenceName))callCompletionHandler
   inputPassCodeCallBack:(void(^)(void))inputPassCodeBlock;

@end

NS_ASSUME_NONNULL_END
