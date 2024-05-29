#import "AppDelegate.h"
#import "FrtcEntryViewController.h"
#import "FrtcUserDefault.h"
#import "PYNavigationController.h"
#import "FrtcCall.h"
#import "FrtcCrash.h"
#include <pthread.h>
#import "AppDelegate+IQKeyboard.h"
#import "AppDelegate+Bugly.h"
#import "FrtcHomeViewController.h"
#import "FrtcSignLoginPresenter.h"
#import "FrtcManagement.h"
#import "FrtcManager.h"
#import "AppDelegate+Notification.h"

@interface AppDelegate ()

@property (nonatomic) UIBackgroundTaskIdentifier task;

@property (nonatomic, strong) NSTimer *backgroundtimer;

@property (nonatomic, copy) NSString *urlValue;

@property (nonatomic, assign, getter = isCurrentVideoMuteStatus) BOOL currentVideoMuteStatus;
@property (nonatomic, assign, getter = isCurrentRemotePeopleVideoMuteStatus) BOOL currentRemotePeopleVideoMuteStatus;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if (@available(iOS 16.0, *)) {
    }else {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    
    [self resetRootViewController];
    
    [FrtcCrash registerHandler];
    [FrtcCrash signalRegister];
    
    NSString *iPhoneName = [UIDevice currentDevice].name;
    ISMLog(@"iPhoneName = %@",iPhoneName);
    FrtcManager.inMeeting = NO;
    FrtcManager.guestUser = NO;
    [[FrtcCall frtcSharedCallClient] frtcGetCurrentVersion];
    
    [self setNotificationDelegate];
    [self initializationIQkeyboard];
    [self configBugly];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return  UIInterfaceOrientationMaskAll;
}

- (void)setHomeViewRootViewController {
    FrtcHomeViewController *vc1 = [[FrtcHomeViewController alloc]init];
    PYNavigationController *navCtr = [[PYNavigationController alloc] initWithRootViewController:vc1];
    self.window.rootViewController =navCtr;
}

- (void)logOutSettingEntryRootView {
    FrtcSignLoginPresenter *loginPresenter = [FrtcSignLoginPresenter new];
    [loginPresenter requestLogOut];
    [self setEntryViewRootViewController];
}

- (void)resetRootViewController {
    if (isLoginSuccess) {
        [self setHomeViewRootViewController];
    }else{
        [self setEntryViewRootViewController];
    }
}

- (void)setEntryViewRootViewController {
    FrtcEntryViewController *vc1 = [[FrtcEntryViewController alloc] init];
    PYNavigationController *navCtr = [[PYNavigationController alloc] initWithRootViewController:vc1];
    self.window.rootViewController =navCtr;
}

-(void)terminateApp {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.task != UIBackgroundTaskInvalid) {
        return;
    }
    
    self.task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.task];
        self.task = UIBackgroundTaskInvalid;
    }];
    
    __block int count = 0;
    
    self.backgroundtimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        count ++;
    }];
    
    self.currentVideoMuteStatus = [[FrtcCall frtcSharedCallClient] frtcGetCurrentVideoMuteStatus];
    self.currentRemotePeopleVideoMuteStatus = [[FrtcCall frtcSharedCallClient] frtcGetCurrentRemotePeopleVideoMuteStatus];

    if(!self.isCurrentVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteLocalCamera:YES];
    }
    
    if (!self.isCurrentRemotePeopleVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:YES];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([self.backgroundtimer isValid]) {
        [self.backgroundtimer invalidate];
        self.backgroundtimer = nil;
    }
    
    if (self.task != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.task];
        self.task = UIBackgroundTaskInvalid;
    }
    
    if(!self.currentVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteLocalCamera:NO];
    }
    if (!self.isCurrentRemotePeopleVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:NO];
    }
    
    [FrtcSignLoginPresenter refreshUserToken];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}

@end
