#import "FrtcHDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcLanguageSettingViewController : FrtcHDBaseViewController

@end


@interface FLanguageModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) BOOL select;

@end

NS_ASSUME_NONNULL_END
