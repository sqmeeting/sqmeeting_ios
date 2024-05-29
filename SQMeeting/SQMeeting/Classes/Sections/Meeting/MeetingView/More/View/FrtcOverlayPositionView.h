#import <UIKit/UIKit.h>
@class FOverlayPositionItemView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^FOverlayPositionItemBlock)(FOverlayPositionItemView *itemView);

@interface  FOverlayPositionItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        image:(NSString *)image
                        block:(FOverlayPositionItemBlock)block;

@end



@interface FrtcOverlayPositionView : UIView

@property (nonatomic, assign, readonly) NSInteger positionNmber;

@end

NS_ASSUME_NONNULL_END
