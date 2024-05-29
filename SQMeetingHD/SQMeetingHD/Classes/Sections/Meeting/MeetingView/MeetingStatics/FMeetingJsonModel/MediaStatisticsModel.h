#import <Foundation/Foundation.h>
#import "MediaDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MediaStatisticsModel;

@interface MediaStatisticsModel : NSObject

@property (nonatomic, copy) NSArray<MediaDetailModel > *apr;
@property (nonatomic, copy) NSArray<MediaDetailModel > *aps;
@property (nonatomic, copy) NSArray<MediaDetailModel > *vcr;
@property (nonatomic, copy) NSArray<MediaDetailModel > *vcs;
@property (nonatomic, copy) NSArray<MediaDetailModel > *vps;
@property (nonatomic, copy) NSArray<MediaDetailModel > *vpr;

@end

NS_ASSUME_NONNULL_END
