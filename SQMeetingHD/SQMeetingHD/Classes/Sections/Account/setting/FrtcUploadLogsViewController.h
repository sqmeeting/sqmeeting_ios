#import "FrtcHDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LogUploading = 0,
    LogUploadDone,
    LogUploadError,
} LogUpload;

@interface FrtcUploadLogsViewController : FrtcHDBaseViewController

@property (nonatomic, strong) NSString *issue;

@end

NS_ASSUME_NONNULL_END
