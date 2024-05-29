#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingUserInformation : NSObject

@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, copy) NSString *display_name;

@property (nonatomic)  int resolution_width;
@property (nonatomic)  int resolution_height;

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, assign, getter = isRemoved) BOOL removed;
@property (nonatomic, assign, getter = isPin) BOOL pin;


@end

NS_ASSUME_NONNULL_END
