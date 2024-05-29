#import "AppDelegate.h"
#import "FrtcHDEntryViewController.h"
#import "FrtcUserDefault.h"
#import "PYHDNavigationController.h"
#import <FrtcCall.h>
#import "FrtcCrash.h"
#import "MBProgressHUD.h"
#include <pthread.h>
#import "FrtcRtcsdkExtention.h"
#import "FrtcMakeCallClient.h"
#import "FrtcManagement.h"
#import "FrtcHDHomeViewController.h"
#import "FrtcSignLoginPresenter.h"
#import "FrtcUserModel.h"
#import "AppDelegate+Bugly.h"
#import "FrtcManager.h"
#import "AppDelegate+Notification.h"

#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

@interface AppDelegate ()

@property (nonatomic) UIBackgroundTaskIdentifier task;

@property (nonatomic, strong) NSTimer *backgroundtimer;

@property (nonatomic, copy) NSString *urlValue;

@property (nonatomic, assign, getter = isCurrentVideoMuteStatus) BOOL currentVideoMuteStatus;
@property (nonatomic, assign, getter = isCurrentRemotePeopleVideoMuteStatus) BOOL currentRemotePeopleVideoMuteStatus;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
#pragma clang diagnostic pop
    
    [self resetRootViewController];
    
    [FrtcCrash registerHandler];
    [FrtcCrash signalRegister];
    
    FrtcManager.inMeeting = NO;
    FrtcManager.guestUser = NO;
    [[FrtcCall frtcSharedCallClient] frtcGetCurrentVersion];
    NSString *conferenceServer = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    if(conferenceServer != nil || ![conferenceServer isEqualToString:@""]) {
    }
    [self setNotificationDelegate];
    [self configBugly];
    return YES;
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)terminateApp {
}

- (void)setHomeViewRootViewController {
    FrtcHDHomeViewController *vc1 = [[FrtcHDHomeViewController alloc]init];
    PYHDNavigationController *navCtr = [[PYHDNavigationController alloc] initWithRootViewController:vc1];
    self.window.rootViewController =navCtr;
}

- (void)setEntryViewRootViewController {
    // SDK login status
    FrtcSignLoginPresenter *loginPresenter = [FrtcSignLoginPresenter new];
    [loginPresenter requestLogOut];
    [FrtcUserModel deleteUserInfo];

    FrtcHDEntryViewController *vc1 = [[FrtcHDEntryViewController alloc] init];
    PYHDNavigationController *navCtr = [[PYHDNavigationController alloc] initWithRootViewController:vc1];
    self.window.rootViewController =navCtr;
}

- (void)resetRootViewController {
    if (isLoginSuccess) {
        [self setHomeViewRootViewController];
    }else{
        [self setEntryViewRootViewController];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
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
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    if ([self.backgroundtimer isValid]) {
        [self.backgroundtimer invalidate];
        self.backgroundtimer = nil;
    }
    
    if (self.task != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.task];
        self.task = UIBackgroundTaskInvalid;
    }
    
    if(!self.isCurrentVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteLocalCamera:NO];
    }
    
    if (!self.isCurrentRemotePeopleVideoMuteStatus) {
        [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:NO];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}


@end
