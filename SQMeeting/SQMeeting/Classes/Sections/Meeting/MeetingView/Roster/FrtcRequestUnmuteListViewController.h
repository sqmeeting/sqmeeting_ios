#import <UIKit/UIKit.h>
#import "FrtcRequestUnmuteModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestUnmuteListViewBlock)(void);

@interface FrtcRequestUnmuteListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<FrtcRequestUnmuteModel *>  *requestUnmuteList;
@property (nonatomic, strong) NSString  *meetingNumber;
@property (nonatomic, copy)   RequestUnmuteListViewBlock unmuteListCallBack;

@end

NS_ASSUME_NONNULL_END
 
