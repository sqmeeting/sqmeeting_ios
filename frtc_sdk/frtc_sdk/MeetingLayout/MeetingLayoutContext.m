#import "MeetingLayoutContext.h"
#import "MeetingUserInformation.h"

static MeetingLayoutContext *sharedSVCLayoutManager = nil;

SDKMeetingLayout sdkMeetingLayoutDescription[MEETING_LAYOUT_NUMBER] = {0};

void layoutStrategy(void)
{
    for (MeetingLayoutNumber mode = MEETING_LAYOUT_NUMBER_1; mode < MEETING_LAYOUT_NUMBER ; mode++)
    {
        switch (mode) {
            case MEETING_LAYOUT_NUMBER_1:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){
                    {0, 0, 1.0, 1.0}
                };
                break;
            case MEETING_LAYOUT_NUMBER_2:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0.25, 0.5, 0.5},
                    {0.5, 0.25, 0.5, 0.5}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_3:
                sdkMeetingLayoutDescription[mode]=(SDKMeetingLayout){{
                    {0.25, 0, 0.5, 0.5},
                    {0, 0.5, 0.5, 0.5},
                    {0.5, 0.5, 0.5, 0.5}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_4:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.5, 0.5},
                    {0.5, 0, 0.5, 0.5},
                    {0, 0.5, 0.5, 0.5},
                    {0.5, 0.5, 0.5, 0.5}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_5:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.33, 0.33},
                    {0.33, 0, 0.33, 0.33},
                    {0.66, 0, 0.33, 0.33},
                    {0, 0.33, 0.33, 0.33},
                    {0.33, 0.33, 0.33, 0.33}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_6:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.33, 0.33},
                    {0.33, 0, 0.33, 0.33},
                    {0.66, 0, 0.33, 0.33},
                    {0, 0.33, 0.33, 0.33},
                    {0.33, 0.33, 0.33, 0.33},
                    {0.66, 0.33, 0.33, 0.33}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_7:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.33, 0.33},
                    {0.33, 0, 0.33, 0.33},
                    {0.66, 0, 0.33, 0.33},
                    {0, 0.33, 0.33, 0.33},
                    {0.33, 0.33, 0.33, 0.33},
                    {0.66, 0.33, 0.33, 0.33},
                    {0, 0.66, 0.33, 0.33}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_8:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.33, 0.33},
                    {0.33, 0, 0.33, 0.33},
                    {0.66, 0, 0.33, 0.33},
                    {0, 0.33, 0.33, 0.33},
                    {0.33, 0.33, 0.33, 0.33},
                    {0.66, 0.33, 0.33, 0.33},
                    {0, 0.66, 0.33, 0.33},
                    {0.33, 0.66, 0.33, 0.33}}
                };
                break;
            case MEETING_LAYOUT_NUMBER_9:
                sdkMeetingLayoutDescription[mode] = (SDKMeetingLayout){{
                    {0, 0, 0.33, 0.33},
                    {0.33, 0, 0.33, 0.33},
                    {0.66, 0, 0.33, 0.33},
                    {0, 0.33, 0.33, 0.33},
                    {0.33, 0.33, 0.33, 0.33},
                    {0.66, 0.33, 0.33, 0.33},
                    {0, 0.66, 0.33, 0.33},
                    {0.33, 0.66, 0.33, 0.33},
                    {0.66, 0.66, 0.33, 0.33}}
                };
                break;
            default:
                break;
        }
    }
}

@implementation MeetingLayoutContext

- (id)init {
    self = [super init];
    if (self) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_1;
        _participantsList = [[NSMutableArray alloc] init];
        layoutStrategy();
    }
    return self;
}

#pragma mark - public functions
+ (MeetingLayoutContext *)SingletonInstance {
    if (sharedSVCLayoutManager == nil) {
        @synchronized(self) {
            if (sharedSVCLayoutManager == nil) {
                sharedSVCLayoutManager = [[MeetingLayoutContext alloc] init];
            }
        }
    }
    
    return sharedSVCLayoutManager;
}

- (void)updateUserNumber {
    NSInteger listCount = [_participantsList count];
    if(listCount == 1) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_1;
    } else if(listCount == 2) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_2;
    } else if(listCount == 3) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_3;
    } else if(listCount == 4) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_4;
    } else if(listCount == 5) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_5;
    } else if(listCount == 6) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_6;
    } else if(listCount == 7) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_7;
    } else if(listCount == 8) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_8;
    } else if(listCount == 9) {
        _meetingNumber = MEETING_LAYOUT_NUMBER_9;
    }
}

-(void)updateMeetingUserList:(NSMutableArray *)meetingUserList {
    NSMutableArray *removeArray = [NSMutableArray array];
    for (int j = (int)[_participantsList count] - 1; j >= 0; j--) {
        MeetingUserInformation *videoInfo = [_participantsList objectAtIndex:j];
        
        BOOL bFind = NO;
        for (int i = 0; i < meetingUserList.count; i++) {
            MeetingUserInformation * videoParam = (MeetingUserInformation *)meetingUserList[i];
            if ([videoParam.mediaID isEqualToString:videoInfo.mediaID ]) {
                
                videoInfo.resolution_height     = videoParam.resolution_height;
                videoInfo.resolution_width      = videoParam.resolution_width;
                videoInfo.pin                   = videoParam.pin;
                videoInfo.display_name          = videoParam.display_name;
                videoInfo.uuid                  = videoParam.uuid;
                bFind = YES;
                break;
            }
        }
        
        if (!bFind) {
            videoInfo.removed = YES;
            [removeArray addObject:[NSNumber numberWithInt:j]];
        }
    }
    
    for(int i = 0; i < removeArray.count; i++) {
        NSNumber *number = removeArray[i];
        printf("%d ", [number intValue]);
    }
    
    if(_participantsList.count == 0) {
        [_participantsList addObjectsFromArray:meetingUserList];
    }
    
    for (int i = 0; i < meetingUserList.count; i++) {
        BOOL bFind = NO;
        MeetingUserInformation * videoParam = (MeetingUserInformation *)meetingUserList[i];
        for (MeetingUserInformation *videoInfo in _participantsList) {
            if ([videoInfo.mediaID isEqualToString:videoParam.mediaID]) {
                bFind = YES;
                break;
            }
        }
        
        if (!bFind) {
            MeetingUserInformation *newVideoInfo = [[MeetingUserInformation alloc] init];
            newVideoInfo.mediaID        = videoParam.mediaID;
            newVideoInfo.display_name   = videoParam.display_name;
            newVideoInfo.resolution_width = videoParam.resolution_width;
            newVideoInfo.resolution_height = videoParam.resolution_height;
            newVideoInfo.removed = videoParam.isRemoved;
            newVideoInfo.uuid = videoParam.uuid;
            newVideoInfo.pin = videoParam.pin;
            
            if(removeArray.count == 0) {
                [_participantsList addObject:newVideoInfo];
            } else {
                [_participantsList replaceObjectAtIndex:[(NSNumber *)removeArray[0] intValue]  withObject:newVideoInfo];
                [removeArray removeObjectAtIndex:0];
            }
        }
    }
    
    for(int i = 0; i < removeArray.count; i++) {
        [_participantsList removeObjectAtIndex:[(NSNumber *)removeArray[i] intValue]];
    }
    
    [removeArray removeAllObjects];
    
    for(int i = 0; i < _participantsList.count; i++) {
        MeetingUserInformation * tempVideoInfo = (MeetingUserInformation *)_participantsList[i];
        
        if(i == 0 && tempVideoInfo.isPin) {
            break;
        }
        
        if(tempVideoInfo.isPin) {
            MeetingUserInformation * videoInfo = _participantsList[0];
            _participantsList[0] = tempVideoInfo;
            _participantsList[i] = videoInfo;
            break;
        }
    }
    
    [self updateUserNumber];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate updateRemoteUserNumber:self.meetingNumber Views:self.participantsList];
    });
}

@end
