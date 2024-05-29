#import <Foundation/Foundation.h>
@class FHomeDetailMeetingInfo;
NS_ASSUME_NONNULL_BEGIN

@protocol FrtcHomeMeetingDetailProtocol <NSObject>

@optional

- (void)loadHomeDetailDataWithList:(NSArray <FHomeDetailMeetingInfo *>*)ListData;

@end

NS_ASSUME_NONNULL_END
