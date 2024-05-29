#import "FrtcMediaStaticsInstance.h"
#import "FrtcCall.h"
#import "FrtcMeetingInfoViewController.h"
#import "StaticsViewController.h"
#import "YYModel.h"

typedef struct {
    int upRate;
    int downRate;
} CallRate;

@interface FrtcMediaStaticsInstance ()

@property (nonatomic, strong) NSTimer *staticsTimer;

@end

@implementation FrtcMediaStaticsInstance

+ (FrtcMediaStaticsInstance *)share {
    static FrtcMediaStaticsInstance *share = nil;
    static dispatch_once_t once_taken = 0;
    dispatch_once(&once_taken, ^{
        share = [[FrtcMediaStaticsInstance alloc] init];
    });
    return share;
}

- (void)startGetMediaStatics {
    [self startMeetingStaticsTimer:5.0];
}

- (void)stopGetMediaStatics {
    [self stopGetStatics];
}

- (void)getMediaStatics {
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSString *str = [[FrtcCall frtcSharedCallClient] frtcGetCallStaticsInfomation];
        dispatch_async(dispatch_get_main_queue(), ^{
            FrtcStatisticalModel *staticsModel = [FrtcStatisticalModel yy_modelWithJSON:str];
            FrtcMediaStaticsModel *mediaStaticsModel = [self getSignalStatus:staticsModel];
            self.upRate = mediaStaticsModel.upRate;
            [[NSNotificationCenter defaultCenter] postNotificationName:FMeetingInfoStaticsInfoNotification object:staticsModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:FMeetingInfoMediaStaticsInfoNotNotification object:mediaStaticsModel];
        });
    });
}

- (void)startMeetingStaticsTimer:(NSTimeInterval)timeInterval {
    __weak __typeof(self)weakSelf = self;
    self.staticsTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf getMediaStatics];
    }];
}

- (void)stopGetStatics {
    if(self.staticsTimer != nil) {
        [self.staticsTimer invalidate];
        self.staticsTimer = nil;
    }
}

#pragma mark -- Signal
- (int)getChannelAvgLostRate:(NSArray<MediaDetailModel *> *)mediaArray {
    MediaDetailModel *stat;
    NSInteger size = mediaArray.count;
    int count = 0;
    int avgLostRate = 0;
    
    if (size > 0) {
        for (int i = 0; i < size; i++) {
            stat = mediaArray[i];
            count += [(stat.packageLossRate) intValue];
        }
        avgLostRate = count / size;
    }
    
    return avgLostRate;
}

- (int)getChanelBitRate:(NSArray<MediaDetailModel *> *)mediaArray {
    MediaDetailModel *stat;
    NSInteger size = mediaArray.count;
    int count = 0;
    
    if (size > 0) {
        for (int i = 0; i < size; i++) {
            stat = mediaArray[i];
            count += [(stat.rtpActualBitRate) intValue];
        }
    }
    
    return count;
}

- (int)getChanelRTT:(NSArray<MediaDetailModel *> *)mediaArray {
    MediaDetailModel *stat;
    NSInteger size = mediaArray.count;
    int count = 0;
    
    if (size > 0) {
        for (int i = 0; i < size; i++) {
            stat = mediaArray[i];
            count += [(stat.roundTripTime) intValue];
        }
    }
    
    return count;
}

- (CallRate)getCallRate:(NSNumber *)callRate {
    CallRate rate;
    int rates = [callRate intValue];
    if (rates > 100000) {
        rate.upRate = rates / 100000;
        rate.downRate = rates % 100000;
    } else {
        rate.upRate = rates;
        rate.downRate = 0;
    }
    return rate;
}

- (FrtcMediaStaticsModel *)getSignalStatus:(FrtcStatisticalModel *)model {
    
    int patxLoss = 0;
    int parxLoss = 0;
    int pvtxLoss = 0;
    int pvrxLoss = 0;
    int cvrxLoss = 0;
    int cvtxLoss = 0;
    
    int patxBitrate = 0;
    int parxBitrate = 0;
    int pvtxBitrate = 0;
    int pvrxBitrate = 0;
    int cvrxBitrate = 0;
    int cvtxBitrate = 0;
    
    int patxRTT = 0;
    int pvtxRTT = 0;
    int cvtxRTT = 0;
    
    int upRate = 0;
    int downRate = 0;
    
    parxLoss = [self getChannelAvgLostRate:model.mediaStatistics.apr];
    patxLoss = [self getChannelAvgLostRate:model.mediaStatistics.aps];
    pvrxLoss = [self getChannelAvgLostRate:model.mediaStatistics.vpr];
    pvtxLoss = [self getChannelAvgLostRate:model.mediaStatistics.vps];
    cvrxLoss = [self getChannelAvgLostRate:model.mediaStatistics.vcr];
    cvtxLoss = [self getChannelAvgLostRate:model.mediaStatistics.vcs];
    
    patxBitrate = [self getChanelBitRate:model.mediaStatistics.aps];
    parxBitrate = [self getChanelBitRate:model.mediaStatistics.apr];
    pvtxBitrate = [self getChanelBitRate:model.mediaStatistics.vpr];
    pvrxBitrate = [self getChanelBitRate:model.mediaStatistics.vps];
    cvrxBitrate = [self getChanelBitRate:model.mediaStatistics.vcr];
    cvtxBitrate = [self getChanelBitRate:model.mediaStatistics.vcs];
    
    patxRTT = [self getChanelRTT:model.mediaStatistics.aps];
    pvtxRTT = [self getChanelRTT:model.mediaStatistics.vps];
    cvtxRTT = [self getChanelRTT:model.mediaStatistics.vcs];
    
    upRate = [self getCallRate:model.signalStatistics.callRate].upRate;
    downRate = [self getCallRate:model.signalStatistics.callRate].downRate;
    
    FrtcMediaStaticsModel *mediaStaticsModel= [[FrtcMediaStaticsModel alloc] init];
    mediaStaticsModel.rttTime = patxRTT + pvtxRTT + cvtxRTT;
    
    mediaStaticsModel.upRate = upRate; //patxBitrate + pvtxBitrate;
    mediaStaticsModel.downRate = downRate; //parxBitrate + pvrxBitrate + cvrxBitrate;
    
    mediaStaticsModel.audioUpRate = patxBitrate;
    mediaStaticsModel.audioUpPackLost = patxLoss;
    
    mediaStaticsModel.audioDownRate = parxBitrate;
    mediaStaticsModel.audioDownPackLost = parxLoss;
    
    mediaStaticsModel.videoUpRate = pvrxBitrate;
    mediaStaticsModel.videoUpPackLost = pvrxLoss;
    
    mediaStaticsModel.videoDownRate = pvtxBitrate;
    mediaStaticsModel.videoDownPackLost =  patxLoss;
    
    mediaStaticsModel.contentUpRate = cvtxBitrate;
    mediaStaticsModel.contentUpPackLost = cvtxLoss;
    
    mediaStaticsModel.contentdownRate = cvrxBitrate;
    mediaStaticsModel.contentdownPackLost = cvrxLoss;
    
    return mediaStaticsModel;
}

@end
