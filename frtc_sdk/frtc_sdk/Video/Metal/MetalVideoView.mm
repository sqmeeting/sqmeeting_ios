#import "MetalVideoView.h"
#import "MetalVideoRender.h"
#import "Masonry.h"
#import "FrtcCall.h"
#import "FrtcUIMacro.h"

@interface MetalVideoView (){
    MetalVideoRender* _render;
}

@property (nonatomic, assign, getter = isRenderMutePic) BOOL renderMutePic;
@property (nonatomic, assign, getter = isRendering) BOOL rendering;
@property (nonatomic, copy) NSString *mediaID;

@end


@implementation MetalVideoView

+(Class)layerClass {
    return [CAMetalLayer class];
}

- (void)initRender {
    if(_render == nil) {
        _render = [[MetalVideoRender alloc] initWithMetalKitView:self];
    }
    
    self.delegate = _render;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
    [kNotificationCenter removeObserver:self name:FMeetingUIDisappearOrNotNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frameRect dataMediaID:(NSString *)mediaID {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = UIColorHex(0x111111);
        self.mediaID = mediaID;
        
        if([mediaID isEqualToString:kLocalVideoMediaID]) {
            self.siteNameView.hidden     = YES;
            self.muteNameCardView.hidden = YES;
        }
        
        [self initRender];
        [self configView];
        self.preferredFramesPerSecond = 30;
        [kNotificationCenter addObserver:self
                                selector:@selector(siteNameHidden:)
                                    name:FMeetingUIDisappearOrNotNotification
                                  object:nil];
    }
    
    return self;
}

- (void)configView {
    
    [self.siteNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.muteNameCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

-(MetalVideoRender*) videoRender {
    return _render;
}

#pragma mark - notification

- (void)siteNameHidden:(NSNotification *)notification {
    if([self.mediaID isEqualToString:kLocalVideoMediaID]) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    NSInteger disappearOrNotKey = [[userInfo valueForKey:FMeetingUIDisappearOrNotKey] integerValue];
    
    switch (disappearOrNotKey) {
        case FMeetingUIDisappear:
            self.siteNameView.hidden = YES;
            break;
        case FMeetingUIAppear:
            self.siteNameView.hidden = NO;
            break;
    }
}

#pragma mark- content water config
-(void)configContentWaterMask:(NSString *)waterMessage {
    NSString *str = waterMessage;
    for(int i = 0; i < 10; i++) {
        waterMessage = [waterMessage stringByAppendingFormat:@" %@", str];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentWaterMaskText.text = waterMessage;
    });
}

- (void)updateLayoutSiteNameView:(BOOL)userMute {
    [self.siteNameView renewSiteNameViewByUserMuteStatus:userMute];
    [self.muteNameCardView.siteNameView renewSiteNameViewByUserMuteStatus:userMute];
}

-(NSString*)mediaID {
    return self.videoRender.mediaID;
}

#pragma mark- public functions
- (void)setRenderMediaID:(NSString *)renderMediaID {
    self.videoRender.mediaID = renderMediaID;
}

-(void)renderMuteImage:(BOOL)mute {
    self.renderMutePic = mute;
    if(self.isRenderMutePic) {
        self.siteNameView.hidden        = YES;
        self.muteNameCardView.hidden    = NO;
        self.muteNameCardView.localView = [self.mediaID isEqualToString:kLocalVideoMediaID] ? YES : NO;
    } else {
        self.muteNameCardView.hidden     = YES;
        self.siteNameView.hidden         = [self.mediaID isEqualToString:kLocalVideoMediaID] ? YES : NO;
    }
}

- (void)startRendering {
    if(!self.rendering) {
        self.rendering = true;
        [self.videoRender startRendering];
    }
}

-(void)stopRendering {
    if(self.isRendering) {
        self.rendering = NO;
        [self.videoRender stopRendering];
    }
}

- (void)setRenderPixelType:(RTC::VideoColorFormat)type {
    [self.videoRender setRenderPixelType:type];
}

- (void)setAppearanceWithActive:(BOOL)isActiveSpeaker {
    if(isActiveSpeaker) {
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor greenColor].CGColor;
    } else {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
}

- (SiteNameView *)siteNameView {
    if (!_siteNameView) {
        _siteNameView = [[SiteNameView alloc]init];
        [self addSubview:_siteNameView];
    }
    return _siteNameView;
}

- (MuteSiteNameView *)muteNameCardView {
    if (!_muteNameCardView) {
        _muteNameCardView = [[MuteSiteNameView alloc]init];
        [self addSubview:_muteNameCardView];
    }
    return _muteNameCardView;
}

- (UILabel *)contentWaterMaskText {
    if (!_contentWaterMaskText) {
        _contentWaterMaskText = [[UILabel alloc] init];
        _contentWaterMaskText.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.16];
        _contentWaterMaskText.font = [UIFont fontWithName:@"Helvetica-Bold" size:40];
        _contentWaterMaskText.textAlignment = NSTextAlignmentCenter;
        _contentWaterMaskText.lineBreakMode = NSLineBreakByCharWrapping;
        _contentWaterMaskText.numberOfLines = 1.0;
        [self addSubview:_contentWaterMaskText];
        [_contentWaterMaskText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.center.equalTo(self);
            make.height.mas_equalTo(40);
        }];
        _contentWaterMaskText.transform = CGAffineTransformMakeRotation(-M_PI / 6);
    }
    
    return _contentWaterMaskText;
}

@end
