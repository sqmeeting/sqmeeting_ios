#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import "SiteNameView.h"
#import "MetalVideoRender.h"
#import "MuteSiteNameView.h"

NS_ASSUME_NONNULL_BEGIN

@class MetalVideoRender;

typedef enum : NSUInteger {
    VideoViewRotation_0 = 0,
    VideoViewRotation_90,
    VideoViewRotation_180,
    VideoViewRotation_270
} VideoViewRotationNumber;

enum VideoViewRenderPixelType
{
    VideoViewRenderPixelType_I420,
    VideoViewRenderPixelType_NV12,
    VideoViewRenderPixelType_Unsupported,
};

@interface MetalVideoView : MTKView

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, strong) UILabel *contentWaterMaskText;

@property (nonatomic, strong) SiteNameView *siteNameView;

@property (nonatomic, strong) MuteSiteNameView *muteNameCardView;

-(void) startRendering;
-(void) stopRendering;
-(void) renderMuteImage:(BOOL)mute;
-(void) setRenderMediaID:(NSString *)renderMediaID;
-(void) setRenderPixelType:(RTC::VideoColorFormat) type;

-(NSString *) mediaID;
-(MetalVideoRender *) videoRender;

- (instancetype)initWithFrame:(CGRect)frameRect dataMediaID:(NSString *)mediaID;
- (void)setAppearanceWithActive:(BOOL)isActiveSpeaker;
- (void)updateLayoutSiteNameView:(BOOL)userMute;


#pragma mark- content water config
- (void)configContentWaterMask:(NSString *)waterMessage;


@end

NS_ASSUME_NONNULL_END
