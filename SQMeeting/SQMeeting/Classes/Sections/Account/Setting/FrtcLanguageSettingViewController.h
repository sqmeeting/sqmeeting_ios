#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcLanguageSettingViewController : BaseViewController

@end


@interface FLanguageModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) BOOL select;

@end

NS_ASSUME_NONNULL_END
