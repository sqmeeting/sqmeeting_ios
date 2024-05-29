#import "ContentCaptureAdaper.h"
#import "ScreenContentCaptureIOS.h"
#import "ObjectInterface.h"

@interface ContentCaptureAdaper ()

@property (nonatomic, strong) id <ContentCapture> capture;

@end

@implementation ContentCaptureAdaper

+(ContentCaptureAdaper *)SingletonInstance {
    static ContentCaptureAdaper *kSingleInstance = nil;
    static dispatch_once_t once_taken = 0;
    dispatch_once(&once_taken, ^{
        kSingleInstance = [[ContentCaptureAdaper alloc] init];
        
    });
    
    return kSingleInstance;
}

-(instancetype) init {
    self = [super init];
    if(self) {
        self.capture = [[ScreenContentCaptureIOS alloc] init];
    }
    
    return  self;
}

- (void)dealloc {

}

-(void)setDelegate:(id<ContentCaptureOutputBufferDelegate>) delegate {
    if(self.capture) {
        [self.capture setBufOutputDelegate:delegate];
    }
}

- (void)setMediaID:(NSString *)mediaID {
    [self.capture setMediaID:mediaID];
}

- (NSString *)getMediaID {
    return [self.capture getMediaID];
}

- (BOOL)startContentSharing {
    [[ObjectInterface sharedObjectInterface] startSendContentObject];
    [self.capture startContentSharing];
    
    if(self.screenCaptureCB) {
        self.screenCaptureCB(true);
    }
    
    return false;
}

- (void)stopContentSharing {
    [self.capture stopContentSharing];
    [[ObjectInterface sharedObjectInterface] stopSendContentObject];
}

- (void)onContentBufferReady:(void*_Nonnull) buffer width:(size_t)width height:(size_t)height pixFormmat:(OSType)pixFormmat roration:(size_t)roration{
    if(self.capture) {
        [self.capture onContentBufferReady:buffer width:width height:height pixFormmat:pixFormmat roration:roration];
    }
}

@end
