
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScanQRManager : NSObject

+ (void)f_checkCameraAuthorizationStatusWithGrand:(void(^)(BOOL granted))permissionGranted;

+ (void)f_checkAlbumAuthorizationStatusWithGrand:(void(^)(BOOL granted))permissionGranted;

+ (BOOL)f_isFlashlight ;

+ (void)f_FlashlightOn:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
