#import <UIKit/UIKit.h>
@class FNewMeetingRoomListInfo;
@class FHomeMeetingListModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MeetingBlockselection) (FNewMeetingRoomListInfo *info);
typedef void(^HistoryMeetingBlockselection) (FHomeMeetingListModel *info);
typedef void(^ClearHistoryMeetingListBlock)(void);

@interface FrtcHistoryMeetingListView : UIView

+ (void)showWithList:(NSArray<FNewMeetingRoomListInfo *> *)listArray selectIndex:(MeetingBlockselection)blockSelect;

+ (void)showHistoryWithList:(NSArray<FHomeMeetingListModel *> *)listArray selectIndex:(HistoryMeetingBlockselection)blockSelect clearData:(ClearHistoryMeetingListBlock)clearBlock;

@end

NS_ASSUME_NONNULL_END
