#import "NTESYUVConverter.h"
#import "NTESI420Frame.h"
#import "GCDAsyncSocket.h"
#import "NTESSocketPacket.h"
#import "NTESTPCircularBuffer.h"
#import "FrtcMeetingScreenBroadcastSocketClient.h"
#import <mach/mach.h>

#define BROADCAST_SOCKET_QUEUE com.frtc.ScreenCaptureBroadcast.client
#define BROADCAST_SOCKET_WRITE_VIDEO_QUEUE com.frtc.ScreenCaptureBroadcast.captureHandle
#define CAPTURE_DESKTOP_INTERVAL 50

@interface FrtcMeetingScreenBroadcastSocketClient()<GCDAsyncSocketDelegate>

@property (nonatomic, assign) CGFloat captureCutRation;
@property (nonatomic, assign) CGSize  captureSize;
@property (nonatomic, assign) NTESVideoPackOrientation orientation;

@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSString *clientPort;
@property (nonatomic, copy) NSString *serverPort;

@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, assign) long evenlyMem;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) NTESTPCircularBuffer *recvBuffer;
@property (nonatomic) NSTimeInterval timeStamp;


@end

@implementation FrtcMeetingScreenBroadcastSocketClient

+ (FrtcMeetingScreenBroadcastSocketClient *)singleClient {
    static FrtcMeetingScreenBroadcastSocketClient *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    
    if(self) {
        self.captureSize = CGSizeMake(720, 1280);
        self.captureCutRation = 9.0/16;
        self.orientation = NTESVideoPackOrientationPortrait;
        self.ip = @"127.0.0.1";
        self.serverPort = @"8898";
        self.clientPort = [NSString stringWithFormat:@"%d", arc4random() % 9999];
        self.videoQueue = dispatch_queue_create("BROADCAST_SOCKET_WRITE_VIDEO_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;;
}

- (void)setUpSocket {
    _recvBuffer = (NTESTPCircularBuffer *)malloc(sizeof(NTESTPCircularBuffer));
    NTESTPCircularBufferInit(_recvBuffer, kRecvBufferMaxSize);
    self.queue = dispatch_queue_create("BROADCAST_SOCKET_QUEUE", DISPATCH_QUEUE_SERIAL);
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    NSError *error;
    [self.socket connectToHost:@"127.0.0.1" onPort:8999 error:&error];
    [self.socket readDataWithTimeout:-1 tag:0];
    
    self.timeStamp = [NSDate timeIntervalSinceReferenceDate] * 1000;
}

- (void)socketDelloc {
    _connected = NO;
    
    if (_socket) {
        [_socket disconnect];
        _socket = nil;
        NTESTPCircularBufferCleanup(_recvBuffer);
    }
    
    if(_timer) {
        _timer = nil;
    }
}

#pragma mark - 处理分辨率切换等
- (void)onRecvData:(NSData *)data head:(NTESPacketHead *)head {
    if (!data) {
        return;
    }
    
    switch (head->command_id)
    {
        case 1:
        {
            NSString *qualityStr = [NSString stringWithUTF8String:[data bytes]];
            int qualit = [qualityStr intValue];
            switch (qualit) {
                case 0:
                    self.captureSize = CGSizeMake(480, 640);
                    break;
                case 1:
                    self.captureSize = CGSizeMake(144, 177);
                    break;
                case 2:
                    self.captureSize = CGSizeMake(288, 352);
                    break;
                case 3:
                    self.captureSize = CGSizeMake(320, 480);
                    break;
                case 4:
                    self.captureSize = CGSizeMake(480, 640);
                    break;
                case 5:
                    self.captureSize = CGSizeMake(540, 960);
                    break;
                case 6:
                    self.captureSize = CGSizeMake(720, 1280);
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
            break;
        case 3:
        {
            NSString *orientationStr = [NSString stringWithUTF8String:[data bytes]];
            int orient = [orientationStr intValue];
            switch (orient) {
                case 0:
                    self.orientation = NTESVideoPackOrientationPortrait;
                    break;
                case 1:
                    self.orientation = NTESVideoPackOrientationLandscapeLeft;
                    break;
                case 2:
                    self.orientation = NTESVideoPackOrientationPortraitUpsideDown;
                    break;
                case 3:
                    self.orientation = NTESVideoPackOrientationLandscapeRight;
                    break;
                default:
                    break;
            };
            
        }
            break;
        default:
            break;
    }
}

-(void)sendData:(CMSampleBufferRef)sampleBuffer {
    CGImagePropertyOrientation oritation = ((__bridge NSNumber *)CMGetAttachment(sampleBuffer, (__bridge CFStringRef)RPVideoSampleOrientationKey, NULL)).unsignedIntValue;
    if(oritation == kCGImagePropertyOrientationRight) {
        self.orientation = NTESVideoPackOrientationLandscapeRight;
    } else if(oritation == kCGImagePropertyOrientationLeft ) {
        self.orientation = NTESVideoPackOrientationLandscapeLeft;
    } else if(oritation == kCGImagePropertyOrientationUp) {
        self.orientation = NTESVideoPackOrientationPortrait;
    } else if(oritation == kCGImagePropertyOrientationDown) {
        self.orientation = NTESVideoPackOrientationPortraitUpsideDown;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if(!pixelBuffer) {
        CFRelease(sampleBuffer);
        return;
    }
    
    
    dispatch_async(self.videoQueue, ^{
        @autoreleasepool {
            NTESI420Frame *videoFrame = nil;
            videoFrame = [NTESYUVConverter pixelBufferToI420:pixelBuffer
                                                    withCrop:self.captureCutRation
                                                  targetSize:self.captureSize
                                              andOrientation:self.orientation];
            CFRelease(sampleBuffer);
            
            if (videoFrame) {
                NSData *raw = [videoFrame bytes];
                NSData *headerData = [NTESSocketPacket packetWithBuffer:raw roration:self.orientation ipadPro:videoFrame.isIPadPro];
                [self.socket writeData:headerData withTimeout:5 tag:0];
                [self.socket writeData:raw withTimeout:5 tag:0];
            }
        }
        
        if (self.evenlyMem <= 0) {
            self.evenlyMem = [self getCurUsedMemory];
        }
    });
    
}

- (long)getCurUsedMemory {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    }
    return memoryUsageInByte;
}

#pragma mark - Process
- (void)sendVideoBufferToHostApp:(CMSampleBufferRef)sampleBuffer {
    if (!self.socket) {
        return;
    }
  
    long curMem = [self getCurUsedMemory];
    
    if (self.evenlyMem > 0
        && ((curMem - self.evenlyMem) > (5 * 1024 * 1024)
            ||curMem > 40 * 1024 * 1024)) {
        //当前内存暴增2M以上，或者总共超过45M，则不处理
        return;
    }
    
    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate] * 1000;
    
    if (current - self.timeStamp < CAPTURE_DESKTOP_INTERVAL) {
        return;
    } else {
        self.timeStamp = current;
    }
    
    CFRetain(sampleBuffer);
    [self sendData:sampleBuffer];
}

- (NSData *)packetWithBuffer:(NSData *)rawData {
    NSMutableData *mutableData = [NSMutableData data];
    @autoreleasepool {
        if (rawData.length == 0) {
            return NULL;
        }
        
        size_t size = rawData.length;
        void *data = malloc(sizeof(NTESPacketHead));
        NTESPacketHead *head = (NTESPacketHead *)malloc(sizeof(NTESPacketHead));
        head->version = 1;
        head->command_id = 0;
        head->service_id = 0;
        head->serial_id = 0;
        head->data_len = (uint32_t)size;
        
        size_t headSize = sizeof(NTESPacketHead);
        memcpy(data, head, headSize);
        NSData *headData = [NSData dataWithBytes:data length:headSize];
        [mutableData appendData:headData];
        [mutableData appendData:rawData];
        
        free(data);
        free(head);
    }
    
    return [mutableData copy];
}

- (NSData *)packetWithBuffer:(const void *)buffer
                        size:(size_t)size
                  packetSize:(size_t *)packetSize {
    if (0 == size) {
        return NULL;
    }
    
    void *data = malloc(sizeof(NTESPacketHead) + size);
    NTESPacketHead *head = (NTESPacketHead *)malloc(sizeof(NTESPacketHead));
    head->version = 1;
    head->command_id = 0;
    head->service_id = 0;
    head->serial_id = 0;
    head->data_len = (uint32_t)size;
    
    size_t headSize = sizeof(NTESPacketHead);
    *packetSize = size + headSize;
    memcpy(data, head, headSize);
    memcpy(data + headSize, buffer, size);
    
    
    NSData *result = [NSData dataWithBytes:data length:*packetSize];
    
    free(head);
    free(data);
    return result;
}

#pragma mark - Socket
- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.socket readDataWithTimeout:-1 tag:0];
    self.connected = YES;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NTESTPCircularBufferProduceBytes(self.recvBuffer, data.bytes, (int32_t)data.length);
    [self handleRecvBuffer];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self.connected = NO;
    [self.socket disconnect];
    self.socket = nil;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(frtcBroadcastFinished)]) {
        [self.delegate frtcBroadcastFinished];
    }
}

- (void)handleRecvBuffer {
    if (!self.socket) {
        return;
    }
    
    int32_t availableBytes = 0;
    void * buffer = NTESTPCircularBufferTail(self.recvBuffer, &availableBytes);
    int32_t headSize = sizeof(NTESPacketHead);
    
    if (availableBytes <= headSize) {
        return;
    }
    
    NTESPacketHead head;
    memset(&head, 0, sizeof(head));
    memcpy(&head, buffer, headSize);
    uint64_t dataLen = head.data_len;
    
    if(dataLen > availableBytes - headSize && dataLen >0) {
        return;
    }
    
    void *data = malloc(dataLen);
    memset(data, 0, dataLen);
    memcpy(data, buffer + headSize, dataLen);
    NTESTPCircularBufferConsume(self.recvBuffer, (int32_t)(headSize+dataLen));
    
    
    if([self respondsToSelector:@selector(onRecvData:head:)]) {
        @autoreleasepool {
            [self onRecvData:[NSData dataWithBytes:data length:dataLen] head:&head];
        };
    }
    
    free(data);
    
    if (availableBytes - headSize - dataLen >= headSize) {
        [self handleRecvBuffer];
    }
}

@end
