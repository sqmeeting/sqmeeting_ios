#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import "object_impl.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalVideoRender : NSObject<MTKViewDelegate>

@property BOOL renderUI;
@property (readonly, nonnull) NSString* info;

@property (nonatomic, strong) NSString *mediaID;
@property (readonly, nonatomic, getter=isRendering) BOOL rendering;

@property (nonatomic, assign) RTC::VideoColorFormat colorFormat;

// Initialization.
-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

#pragma mark public function
- (void)startRendering;
- (void)stopRendering;
- (void)setRenderPixelType:(RTC::VideoColorFormat)colorFormat;

@end

NS_ASSUME_NONNULL_END
