#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcLiveAndRecordErrorModel : NSObject

@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
