#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrtcStopDateViewDelegate <NSObject>

- (void)didSelectedStopDate:(NSString *)stopDate;

@end

@interface FrtcStopDateView : UIView

@property (nonatomic, strong) NSDate *stopDate;

@property (nonatomic, weak) id<FrtcStopDateViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame defaultDate:(NSString *)defaultDate;

@end

NS_ASSUME_NONNULL_END
