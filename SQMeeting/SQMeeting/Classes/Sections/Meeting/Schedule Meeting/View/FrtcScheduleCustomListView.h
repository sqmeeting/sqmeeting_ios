#import <UIKit/UIKit.h>
@class FrtcScheduleCustomModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleCustomListView : UIView

@property (nonatomic, strong) NSArray<FrtcScheduleCustomModel *> *customListData;

@property (nonatomic, copy) void(^customListCallBack)(NSString *result);

@end

NS_ASSUME_NONNULL_END
