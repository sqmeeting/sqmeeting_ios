#import "FrtcContentShareGadget.h"
#import <ReplayKit/ReplayKit.h>
#import "FrtcMakeCallClient.h"
#import "FrtcRtcsdkExtention.h"
#import "FrtcMeetingClientBufferSocketManager.h"

NSString * const CFNotificationReceiveBroadcastStart = @"kDarvinNotificationNamePushStart";
NSString * const CFNotificationReceiveBroadcastStop  = @"kDarvinNotificationNamePushStop";

NSString * const FrtcMeetingSendContent = @"com.frtcmeeting.sendContent";
NSString * const FrtcMeetingStopContent = @"com.frtcmeeting.stopContent";

static void StartRecordScreenCallback(CFNotificationCenterRef center,
                                      void  *observer,
                                      CFStringRef name,
                                      const void *object,
                                      CFDictionaryRef userInfo)
{
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)observer;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"frtcmeeting://"]
                                       options:@{}
                             completionHandler:nil];
    
    NSDictionary *notiUserInfo = @{@"identifier":identifier};
    [[NSNotificationCenter defaultCenter] postNotificationName:FrtcMeetingSendContent
                                                        object:sender
                                                      userInfo:notiUserInfo];
}

static void StopRecordScreenCallback(CFNotificationCenterRef center,
                                     void *observer,
                                     CFStringRef name,
                                     const void *object,
                                     CFDictionaryRef userInfo)
{
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)observer;
    NSDictionary *notiUserInfo = @{@"identifier":identifier};
    [[NSNotificationCenter defaultCenter] postNotificationName:FrtcMeetingStopContent
                                                        object:sender
                                                      userInfo:notiUserInfo];
}

@interface FrtcContentShareGadget()

@property (nonatomic, strong) RPSystemBroadcastPickerView *systemPicker;
@property (nonatomic, strong) UIView* broadCastPickerView;
@property (nonatomic) BOOL isSharing;

@end

@implementation FrtcContentShareGadget

+ (instancetype) sharedInstance {
    static FrtcContentShareGadget *instance = nil;
    static dispatch_once_t once_taken = 0;
    dispatch_once(&once_taken, ^{
        instance = [[FrtcContentShareGadget alloc]init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerNotification];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStart:) name:FrtcMeetingSendContent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStop:) name:FrtcMeetingStopContent object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotification {
    [self registerCFNotification:CFNotificationReceiveBroadcastStart notificationCallBack:StartRecordScreenCallback];
    [self registerCFNotification:CFNotificationReceiveBroadcastStop notificationCallBack:StopRecordScreenCallback];
}

- (void)registerCFNotification:(NSString *)notificationName notificationCallBack:(CFNotificationCallback)callBack {
    CFStringRef cfNotificationName = (__bridge CFStringRef)notificationName;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center,
                                    (const void *)self,
                                    callBack,
                                    cfNotificationName,
                                    NULL,
                                    kCFNotificationDeliverImmediately);
}

#pragma mark --Notification

- (void)contentStart:(NSNotification *)notification {
    if (!self.isSharing) {
        self.isSharing = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareContentStartNotification object:nil];
        [[FrtcCall frtcSharedCallClient] frtcShareContent:YES];
    } else {
        [[FrtcCall frtcSharedCallClient] frtcShareContent:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareContentStartNotification object:nil];
    }
}

- (void)contentStop:(NSNotification *)notification {
    self.isSharing = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kShareContentDisconnectNotification object:nil];
}

- (void)startScreenSharing:(BOOL)isSharing {
    [[FrtcHelpers getCurrentVC].view addSubview:self.systemPicker];
}

- (void)startRecordScreenSharing:(BOOL)isSharing {
    if (isSharing) {
        [self setupSocket];
        [self showBroadcastPicker:nil];
    } else {
        if (self.isSharing) {
            [self closeSocket];
        }
        [[FrtcRtcsdkExtention frtcSharedCallClientExtention] contentSharing:NO];
        [[FrtcCall frtcSharedCallClient] frtcChangeFloatButtonTitle:NSLocalizedString(@"meeting_share_inMeeting", nil)];
    }
    self.isSharing = isSharing;
}

- (void)startSendContentStream {
    [FrtcMeetingClientBufferSocketManager sharedManager].dataReceived = ^(void * _Nonnull buffer, size_t width, size_t height, OSType format, size_t roration) {
        [[FrtcRtcsdkExtention frtcSharedCallClientExtention] contentDataReady:buffer width:width height:height pixformat:format roration:roration];
    };
}

- (void)showBroadcastPicker:(UIButton *)sender {
    if (self.broadCastPickerView) {
        for (UIView *view in self.broadCastPickerView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        return;
    }
    
    RPSystemBroadcastPickerView *picker = [[RPSystemBroadcastPickerView alloc] initWithFrame:sender ? sender.frame : CGRectMake(0, 0, 60, 60)];
    picker.preferredExtension = @"com.frtc.hk.FrtcMeetingAppStore.ScreenCaptureBroadcast";
    picker.showsMicrophoneButton = NO;
    
    self.broadCastPickerView = picker;
    for (UIView *view in self.broadCastPickerView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)closeSocket {
    [[FrtcMeetingClientBufferSocketManager sharedManager] stopSocket];
}

- (void)setupSocket {
    [[FrtcMeetingClientBufferSocketManager sharedManager] setupSocket];
}

@end

