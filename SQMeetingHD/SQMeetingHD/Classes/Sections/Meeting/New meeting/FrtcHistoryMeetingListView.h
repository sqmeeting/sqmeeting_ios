#import <UIKit/UIKit.h>
@class FNewMeetingRoomListInfo;
@class FHomeMeetingListModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MeetingBlockselection) (FNewMeetingRoomListInfo *info);
typedef void(^HistoryMeetingBlockselection) (FHomeMeetingListModel *info);
typedef void(^ClearHistoryMeetingListBlock)(void);

@interface FrtcHistoryMeetingListView : UIView

@property (nonatomic, strong) NSArray<FNewMeetingRoomListInfo *> *array;
@property (nonatomic, strong) NSArray<FHomeMeetingListModel *> *historyArray;
@property (nonatomic, assign, getter=isHistory) BOOL history;
@property (nonatomic, copy) MeetingBlockselection selectedBlock;
@property (nonatomic, copy) HistoryMeetingBlockselection historySelectedBlock;
@property (nonatomic, copy) ClearHistoryMeetingListBlock clearhistoryBlock;

- (void)disMiss;

@end

NS_ASSUME_NONNULL_END
