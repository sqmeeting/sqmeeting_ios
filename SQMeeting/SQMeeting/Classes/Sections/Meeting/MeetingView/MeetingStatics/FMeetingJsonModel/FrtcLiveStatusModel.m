#import "FrtcLiveStatusModel.h"

@implementation FrtcLiveStatusModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {

    _live = [self.liveStatus isEqualToString:@"STARTED"]; //NOT_STARTED
    _recording = [self.recordingStatus isEqualToString:@"STARTED"]; //NOT_STARTED

    return YES;
}

@end
