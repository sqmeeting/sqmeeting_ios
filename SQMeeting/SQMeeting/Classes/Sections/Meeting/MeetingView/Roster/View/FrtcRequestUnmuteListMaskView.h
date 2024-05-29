#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FRequestUnmuteSelectedBlock)(void);

@interface FrtcRequestUnmuteListMaskView : UIView

@property (nonatomic, strong) NSString *unmuteName;

@property (nonatomic, copy) FRequestUnmuteSelectedBlock selectedBlock;

@end

NS_ASSUME_NONNULL_END
