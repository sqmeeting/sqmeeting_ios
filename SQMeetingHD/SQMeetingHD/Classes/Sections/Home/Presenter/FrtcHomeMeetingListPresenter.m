#import "FrtcHomeMeetingListPresenter.h"
#import "YYModel.h"
#import "FrtcUserModel.h"

//Get Document directory
#define kDocumentPath(user_id)  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@MeetingList.data",user_id]]



@implementation FHomeMeetingListModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

@end


@implementation FHomeDetailMeetingInfo


@end


@interface FrtcHomeMeetingListPresenter ()

@property (nonatomic, weak) id detailView;

@end

@implementation FrtcHomeMeetingListPresenter

- (void)bindView:(id<FrtcHomeMeetingDetailProtocol>)view {
    _detailView = view;
}

- (void)requestHomeDetailDataWithInfo:(FHomeMeetingListModel *)model {
    
    FHomeDetailMeetingInfo *info1 = [FHomeDetailMeetingInfo new];
    info1.title = NSLocalizedString(@"meeting_name", nil);
    info1.content = model.meetingName;
    
    FHomeDetailMeetingInfo *info2 = [FHomeDetailMeetingInfo new];
    info2.title = NSLocalizedString(@"meeting_time", nil);
    info2.content = [FrtcHelpers getDateStringWithTimeStr:model.meetingStartTime];
    
    FHomeDetailMeetingInfo *info3 = [FHomeDetailMeetingInfo new];
    info3.title = NSLocalizedString(@"call_number", nil);
    info3.content = model.meetingNumber;
    
    FHomeDetailMeetingInfo *info4 = [FHomeDetailMeetingInfo new];
    info4.title = NSLocalizedString(@"meeting_timecost", nil);
    info4.content = model.meetingTime;
    
    if (model.isPassword) {
        FHomeDetailMeetingInfo *info5 = [FHomeDetailMeetingInfo new];
        info5.title = NSLocalizedString(@"string_pwd", nil);
        info5.content = model.meetingPassword;
        [_detailView loadHomeDetailDataWithList:@[info1,info2,info3,info4,info5]];
    }else{
        [_detailView loadHomeDetailDataWithList:@[info1,info2,info3,info4]];
    }
}

+ (BOOL)saveMeeting:(FHomeMeetingListModel *)model {
    BOOL result = NO;
    NSMutableArray *meetinglist = [NSMutableArray arrayWithCapacity:20];
    NSArray <FHomeMeetingListModel *> *list = [self getMeetingList];
    if (list.count > 0) {
        [meetinglist addObjectsFromArray:[self dataProcessingWith:list model:model]];
    }
    [meetinglist insertObject:model atIndex:0];
    
    NSError *error = nil;
    NSData *meetingListData = [NSKeyedArchiver archivedDataWithRootObject:meetinglist requiringSecureCoding:NO error:&error];
    if (!error && meetingListData) {
        NSString *localPath = kDocumentPath([FrtcUserModel fetchUserInfo].user_id);
        if ([meetingListData writeToFile:localPath atomically:YES]) {
            result = YES;
        }
    }else{
    }
    return result;
}

+ (NSArray *)dataProcessingWith:(NSArray <FHomeMeetingListModel *> *)listdata model:(FHomeMeetingListModel *)model {
    NSMutableArray *resultarray = [NSMutableArray arrayWithCapacity:20];
    for (FHomeMeetingListModel *info in listdata) {
        if (![info.meetingStartTime isEqualToString:model.meetingStartTime]) {
            [resultarray addObject:info];
        }
    }
    return resultarray;
}

+ (NSArray <FHomeMeetingListModel *> *)getMeetingList{
    NSError *error = nil;
    NSSet *set = [NSSet setWithObjects:[NSArray class],[NSString class],[NSDictionary class],[FHomeMeetingListModel class],[NSNumber class],nil];
    NSString *localPath = kDocumentPath([FrtcUserModel fetchUserInfo].user_id);
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    NSArray *listInfo = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
    if (!error && listInfo) {
        return listInfo;
    }else{
        return @[];
    }
    return @[];
}

+ (BOOL)deleteHistoryMeetingWithMeetingStartTime:(NSString *)time {
    if (kStringIsEmpty(time)) { return NO ; }
    BOOL result = NO;
    NSMutableArray *meetinglist = [NSMutableArray arrayWithCapacity:20];
    NSArray <FHomeMeetingListModel *> *list = [self getMeetingList];
    if (list.count > 0) {
        [meetinglist addObjectsFromArray:list];
    }
    for (FHomeMeetingListModel *info in meetinglist) {
        if ([info.meetingStartTime isEqualToString:time]) {
            [meetinglist removeObject:info];
            result = YES;
            break;
        }
    }
    if (!result) { return NO; }
    NSError *error = nil;
    NSData *meetingListData = [NSKeyedArchiver archivedDataWithRootObject:meetinglist requiringSecureCoding:NO error:&error];
    if (!error && meetingListData) {
        NSString *localPath = kDocumentPath([FrtcUserModel fetchUserInfo].user_id);
        if ([meetingListData writeToFile:localPath atomically:YES]) {
            result = YES;
        }
    }
    return result;
}

+ (BOOL)deleteAllMeeting {
    NSString *localPath = kDocumentPath([FrtcUserModel fetchUserInfo].user_id);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isExist = [fileMgr fileExistsAtPath:localPath];
    if (isExist) {
        return [fileMgr removeItemAtPath:localPath error:nil];
    }
    return YES;
}


@end
