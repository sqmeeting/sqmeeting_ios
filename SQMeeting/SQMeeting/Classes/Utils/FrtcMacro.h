#ifndef FMacro_h
#define FMacro_h

#import "FrtcUserDefault.h"
#import "FrtcLocalInforDefault.h"
#import "UIColor+Extensions.h"

#define KScreenBounds           [UIScreen mainScreen].bounds
#define KScreenWidth            [UIScreen mainScreen].bounds.size.width
#define KScreenHeight           [UIScreen mainScreen].bounds.size.height
#define KScreenScale            [UIScreen mainScreen].scale

#define LAND_SCAPE_WIDTH        (KScreenWidth > KScreenHeight ? KScreenWidth : KScreenHeight)
#define LAND_SCAPE_HEIGHT       (KScreenHeight > KScreenWidth ? KScreenWidth : KScreenHeight)

#define WEAK_NETWORK_VIDEO_LOSS_THRESHOLD_1  3
#define WEAK_NETWORK_VIDEO_LOSS_THRESHOLD_2  8
#define WEAK_NETWORK_AUDIO_LOSS_THRESHOLD_1  15
#define WEAK_NETWORK_AUDIO_LOSS_THRESHOLD_2  30

#define SIGNAL_INTENSITY_LOW     0
#define SIGNAL_INTENSITY_MEDIAN  1
#define SIGNAL_INTENSITY_HIGH    2

#define isIPhoneX (UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom > 0.0 ? YES : NO)

#define KStatusBarHeight      (isIPhoneX ? 44 : 20)
#define KNavBarHeight         (isIPhoneX ? 88 : 64)
#define KSafeAreaBottomHeight (isIPhoneX ? 34 : 0)
#define KTabbarHeight         (isIPhoneX ? 83 : 49)
#define isiPhoneX             (isIPhoneX ? YES : NO)
#define kTopSpacing(y)        (KNavBarHeight + y)

#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

#define KScaleWidth(w)  ((KScreenWidth/375.0) * w)
#define KScaleHeight(h) ((KScreenHeight/812.0) * h)

#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define kMainColor           UIColorHex(0x026FFE)
#define kMainHoverColor      UIColorHex(0x1f80ff)
#define KMainDisabledColor   UIColorHex(0xcae1ff)

#define kNavTitleColor       UIColorHex(0x222222)

#define KGreyColor           UIColorHex(0xf0f0f5)
#define KGreyHoverColor      UIColorHex(0xe6eaf7)

#define KTextColor           UIColorHex(0x333333)
#define KDetailTextColor     UIColorHex(0x999999)
#define KTextColor666666     UIColorHex(0x666666)
#define KRecurrenceColor     UIColorHex(0x3ec76e)

#define KLineColor           UIColorHex(0xeeeff0)
#define KBGColor             UIColorHex(0xF8F9FA)
#define kCellSelecteColor    UIColorHex(0xe6eaf7)
#define kRandomColor         [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1]


#define kButtonHeight  44.f

#define KCornerRadius   4.0
#define KLeftSpacing    24.0
#define KLeftSpacing12  12.0

#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

#define CUR_VESION  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define CUR_BUILD_VERSION  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#ifdef DEBUG
#define ISMString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define ISMLog(...) printf("%s 第%d行: %s\n\n",[ISMString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#else
#define ISMLog(...)
#endif



#define isLoginSuccess [[FrtcUserDefault sharedUserDefault] boolForKey:LOGIN_STATUS]

#define kTokenFailureNotification @"TokenFailureNotification"
#define kRefreshHomeMeetingListNotification @"RefreshHomeMeetingListNotification"
#define kShareContentDisconnectNotification @"kShareContentDisconnectNotification"
#define kShareContentStartNotification @"kShareContentStartNotification"


#define kEncryptionKey @"aab7097c02c0493093755c734d150aaf"
#define kRequestErrorDataKey @"com.alamofire.serialization.response.error.data"

#define kUpdateRequestUnmuteList @"UPDATEREQUESTUNMUTELIST"
#define kUpdateUnmuteReuqestList @"kUpdateUnmuteReuqestList"

#define kDafaultRecurrenceNumber 6

#define kAppWebsiteUrl   @"https://shenqi.internetware.cn"
#define kAppGithubUrl    @"https://github.com/sqmeeting"

#endif /* FMacro_h */
