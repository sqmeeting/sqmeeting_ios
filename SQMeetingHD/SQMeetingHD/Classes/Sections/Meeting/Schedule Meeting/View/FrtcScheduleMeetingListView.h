#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcScheduleMeetingListViewDelegate <NSObject>

@optional
- (void)updateScheduleListViewWithInfo:(NSString *)info indexPath:(NSIndexPath *)indexPath;
- (void)updateScheduleListSwitchStatusWithOpen:(BOOL)open indexPath:(NSIndexPath *)indexPath;
- (void)updateScheduleListViewCustomInfo:(id)customInfo indexPath:(NSIndexPath *)indexPath;

- (void)addScheduleListCellIndexPath:(NSIndexPath *)indexPath;

@end

@interface FrtcScheduleMeetingListView : UIView

@property (nonatomic, strong) NSArray<NSArray *> *scheduleListData;
 
@property (nonatomic, weak) id<FrtcScheduleMeetingListViewDelegate> delegate;

@property (nonatomic, getter=isEditing) BOOL edit;

@end

NS_ASSUME_NONNULL_END
