#import <UIKit/UIKit.h>
@class ParticipantListModel,FrtcRequestUnmuteModel;
NS_ASSUME_NONNULL_BEGIN

@protocol RostListDlgControllerDelegate <NSObject>

- (void)rostListMuteMicroPhone:(BOOL)mute;

- (void)rostShareInvitationInfo;

- (void)updateParticipantInfo:(ParticipantListModel *)info;

- (void)hiddenRedDotView;

@end

@interface RostListDlgController : UIViewController

@property (nonatomic, weak) id<RostListDlgControllerDelegate> delegate;

@property (nonatomic, assign, getter=isMeetingOperator) BOOL meetingOperator;

@property (nonatomic, copy) NSString *meetingNumber;

@property (nonatomic, strong) NSMutableArray<FrtcRequestUnmuteModel *>  *requestUnmuteList;

- (id)initWithRosterList:(NSMutableArray <ParticipantListModel *> *)rosterArray
            lecturesList:(NSArray <NSString *> *)lecturesList
                 pinList:(nonnull NSArray<NSString *> *)pinList;

- (void)updateRosterList:(NSMutableArray <ParticipantListModel *> *)rosterArray;

- (void)updateLecturesList:(NSArray <NSString *> *)lecturesList;

- (void)updatePinList:(NSArray <NSString *> *)pinList;

- (void)updateUnmuteRequestList:(NSMutableArray<FrtcRequestUnmuteModel *> *)requestUnmuteList;

- (void)updateMicrophoneImage:(int)microphoneValue;

@end

NS_ASSUME_NONNULL_END
