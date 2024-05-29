//
//  SDKCallAgent.m
//  frtc_sdk
//
//  Created by yafei on 2021/11/23.
//  Copyright © 2021 徐亚飞. All rights reserved.
//

#import "SDKCallAgent.h"
#import "FMeetingViewController.h"
#import "AudioUnitCapture.h"
#import "VideoCapture.h"
#import "SDKContextWrapper.h"
#import "PluaMacro.h"
#import "SDKCallStateTransition.h"
#import "NSTimer+Enhancement.h"
#import "SDKUserDefault.h"
#import "NSData+AESTest.h"
#import "GTMBase64.h"

typedef void (^SDKInputPasswordBlock)();


@interface SDKCallAgent ()

@property (nonatomic) FRTCSDKCallState callState;
@property (nonatomic, weak) UIViewController *parentViewController;

@property (nonatomic, copy) NSString *clientName;
@property (nonatomic, copy) NSString *conferenceName;
@property (nonatomic, copy) NSString *conferenceAlias;
@property (nonatomic, copy) NSString *overLayMessage;
@property (nonatomic, copy) NSString *serverAddress;
@property (nonatomic, copy) NSMutableArray * _Nullable callStateTransitions;

@property (nonatomic, copy) FRTCSDKCallCompletionHandler completionHandler;
@property (nonatomic, copy) SDKInputPasswordBlock passwordBlock;

@property (nonatomic, assign) int repete;

@property (nonatomic, assign, getter = isAudioCall) BOOL audioCall;
@property (nonatomic, assign, getter = isMuteCamera) BOOL muteCamera;
@property (nonatomic, assign, getter = isMuteMicrophone) BOOL muteMicrophone;

@property (nonatomic) int reason;

@property (strong, nonatomic) NSTimer  *waitCallTimer;

@end

@implementation SDKCallAgent

- (id)init {
    if(self = [super init]) {
        _callState = FRTCSDK_CALL_STATE_IDLE;
        _callStateTransitions = [NSMutableArray array];
        [self setupCallStateTransition];
    }
    
    return self;
}

- (void)addCallStateTransitions:(FRTCSDKCallState)theCurState newState:(FRTCSDKCallState)theNewState andAction:(SDKCallStateAction)theAction {
    SDKCallStateTransition* transition = [[SDKCallStateTransition alloc] initWithCurrentCallState:theCurState newCallState:theNewState andAction:theAction];
    [self.callStateTransitions addObject:transition];
}

- (void)setupCallStateTransition {
    __weak __typeof(self)weakSelf = self;
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_IDLE
                                  newState:FRTCSDK_CALL_STATE_IDLE
                                 andAction:^{
                                     // do nothing, just update _contentState from Invalid to Idle
        NSLog(@"callState transition from FR_CALL_STATE_IDLE to FR_CALL_STATE_IDLE");
                                 }];
    
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_IDLE
                                  newState:FRTCSDK_CALL_STATE_CONNECTED
                                 andAction:^{
                                     // CC maybe notify UI Idle status more than one time.
                                     // do nothing, just update _contentState from Idle to Idle
        TEST_DEBUG("callState transition from FR_CALL_STATE_IDLE to FR_CALL_STATE_CONNECTED");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                                        [weakSelf presentCallView];
                                    });
                                 }];
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_IDLE
                                  newState:FRTCSDK_CALL_STATE_DISCONNECTED
                                 andAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.parentViewController.presentedViewController) {
                [weakSelf.parentViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            FRTCSDKCallResult result = [weakSelf convertToSDKResult:weakSelf.reason];
            weakSelf.completionHandler(FRTCSDK_CALL_STATE_DISCONNECTED, result, @"error", @"error");
        });
    }];
    
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_CONNECTED
                         newState:FRTCSDK_CALL_STATE_CONNECTED
                        andAction:^{
        // do nothing

    }];
    
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_CONNECTED
                         newState:FRTCSDK_CALL_STATE_DISCONNECTED
                        andAction:^{
                            __strong __typeof(weakSelf)strongSelf = weakSelf;
                            [strongSelf callDisconnected];
    }];
    
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_DISCONNECTED
                         newState:FRTCSDK_CALL_STATE_CONNECTED
                        andAction:^{
                            TEST_DEBUG("callState transition from FR_CALL_STATE_DISCONNECTED to FR_CALL_STATE_CONNECTED");
                
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                                [weakSelf presentCallView];
                            });

    }];
    
    [self addCallStateTransitions:FRTCSDK_CALL_STATE_DISCONNECTED
                         newState:FRTCSDK_CALL_STATE_DISCONNECTED
                        andAction:^{
                            TEST_DEBUG("callState transition from FR_CALL_STATE_DISCONNECTED to FR_CALL_STATE_DISCONNECTED");
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(weakSelf.parentViewController.presentedViewController) {
                                    [weakSelf.parentViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                }
            
                                FRTCSDKCallResult result = [weakSelf convertToSDKResult:weakSelf.reason];
                                weakSelf.completionHandler(FRTCSDK_CALL_STATE_DISCONNECTED, result, @"error", @"error");
                            });
    }];
}

- (void)presentCallView {
    FMeetingViewController *meetingVC = [[FMeetingViewController alloc] init];
    meetingVC.modalPresentationStyle = UIModalPresentationFullScreen;
    meetingVC.callName = self.clientName;
    meetingVC.muteCamera = self.muteCamera;
    meetingVC.muteMicrophone = self.muteMicrophone;
    meetingVC.conferenceAlias = self.conferenceAlias;
    meetingVC.conferenceName = self.conferenceName;
    meetingVC.messageOverLay = self.overLayMessage;
    meetingVC.audioCall = self.audioCall;
    meetingVC.repete = self.repete;
    
    __weak __typeof(self)weakSelf = self;

    [self.parentViewController presentViewController:meetingVC animated:YES completion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf callConnected];
    }];
}

- (void)callConnected {
    [[AudioUnitCapture sharedAudioUnitCapture] runAudioUnit];
    FRTCSDKCallResult reason = FRTCSDK_CALL_CONNECTED;
    self.completionHandler(FRTCSDK_CALL_STATE_CONNECTED, reason, self.conferenceAlias, self.conferenceName);
}

- (void)callDisconnected {
    [[AudioUnitCapture sharedAudioUnitCapture] stopAudioUnit];
    [[VideoCapture getInstance] stop];
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [(FMeetingViewController *)(weakSelf.parentViewController.presentedViewController) stopRender];
        [weakSelf.parentViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        FRTCSDKCallResult result = [self convertToSDKResult:self.reason];
        weakSelf.completionHandler(FRTCSDK_CALL_STATE_DISCONNECTED, result, @"error", @"error");
    });
}

- (void)callStateTransition:(CallState)callState {
    for (SDKCallStateTransition* transition in self.callStateTransitions) {
        if (transition.curState == self.callState && transition.newState == static_cast<FRTCSDKCallState>(callState)) {
            TEST_DEBUG("callState transition from %s to %s", [[self stringFromCallState:self.callState] UTF8String], [[self stringFromCallState:transition.newState] UTF8String]);
        
            self.callState = transition.newState;
            transition.action();
            break;
        }
    }
}

- (void)sdkAgentMakeCall:(SDKCallParam)callParam
              controller:(UIViewController * _Nonnull )controller
   callCompletionHandler:(void (^)(FRTCSDKCallState callState, FRTCSDKCallResult reason,
                                   NSString *conferenceNumber, NSString *conferenceName))callCompletionHandler
   inputPassCodeCallBack:(void(^)(void))inputPassCodeBlock {
    
}

@end
