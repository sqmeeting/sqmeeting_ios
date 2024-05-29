#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OverlayMessageModel : NSObject

@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *displaySpeed;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSNumber *backgroundTransparency;
@property (nonatomic, strong) NSNumber *displayRepetition;
@property (nonatomic, strong) NSNumber *fontSize;
@property (nonatomic, strong) NSNumber *verticalPosition;
@property (nonatomic, assign) BOOL enabledMessageOverlay;

@end

NS_ASSUME_NONNULL_END
