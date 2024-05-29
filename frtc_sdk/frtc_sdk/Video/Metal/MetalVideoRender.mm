#import "MetalVideoRender.h"
#import <MetalKit/MetalKit.h>
#import "ObjectInterface.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreVideo/CVMetalTextureCache.h>
#import <Metal/MTLCommandQueue.h>
#import <Metal/MTLComputePipeline.h>
#import <CoreVideo/CVMetalTexture.h>
#import <Metal/MTLTexture.h>
#import "FrtcBundleTools.h"
#import "FrtcUIMacro.h"
#include "IRender.h"


const float defaultCoords[8] = {
    0, 1,
    1, 1,
    0, 0,
    1, 0
};

const float coords90[8] = {
    1, 1,
    1, 0,
    0, 1,
    0, 0
};

const float coords180[8] =
{
    1, 0,
    0, 0,
    1, 1,
    0, 1,
};

const float coords270[8] = {
    0, 0,
    0, 1,
    1, 0,
    1, 1
};

@interface MetalVideoRender () {
    void *buffer;
    size_t bufferSize;
}

@property (nonatomic, assign) unsigned int cachedWidth;
@property (nonatomic, assign) unsigned int cachedHeight;
@property (nonatomic, assign) unsigned int cachedRotation;
@property (nonatomic, assign) float cachedViewWidth;
@property (nonatomic, assign) float cachedViewHeight;
@property (nonatomic, strong) NSData *cachedVertexArrayData;
@property (nonatomic, strong) NSData *cachedTextureCoordData;

@property (nonatomic, assign) unsigned int length;
@property (nonatomic, assign) unsigned int width;
@property (nonatomic, assign) unsigned int height;
@property (nonatomic, assign) CGFloat  viewWidth;
@property (nonatomic, assign) CGFloat  viewHeight;
@property (nonatomic, assign) unsigned int rotation;

@property (nonatomic, weak)   MTKView* view;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLComputePipelineState> computePipelineState;
@property (nonatomic, strong) id<MTLDevice>device;
@property (nonatomic, strong) CAMetalLayer * metalLayer;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

// Texture for NV12
@property (nonatomic, strong) MTLTextureDescriptor *textureYDes;
@property (nonatomic, strong) id<MTLTexture>textureY;
@property (nonatomic, strong) MTLTextureDescriptor *textureUVDes;
@property (nonatomic, strong) id<MTLTexture>textureUV;

// Texture for I420
@property (nonatomic, strong) MTLTextureDescriptor *textureUDes;
@property (nonatomic, strong) MTLTextureDescriptor *textureVDes;
@property (nonatomic, strong) id<MTLTexture>textureU;
@property (nonatomic, strong) id<MTLTexture>textureV;

@property (nonatomic,assign) int  textureHeight;
@property (nonatomic,assign) int  textureWidth;
@end


@implementation MetalVideoRender

- (MTLSize)threadGroupCount:(nonnull id<MTLTexture>)textrue {
    return MTLSizeMake(8, 8, 1);
}

- (MTLSize)threadGroups:(nonnull id<MTLTexture>)textrue {
    MTLSize size = [self threadGroupCount:textrue];
    return MTLSizeMake(textrue.width/size.width, textrue.height/size.height, 1);
}


- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    _colorFormat = RTC::kI420;
    self.view = view;
    
    bufferSize = kMaxVidePixels;
    buffer = malloc(bufferSize);
    
    [self commonInit];
    return  self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    if (buffer) {
        free(buffer);
    }
}

#pragma mark - private methods
- (void)commonInit {
    [self prepareLayer];
    [self preparePipelineState];
    [self prepareCommandQueue];
}

- (void)prepareLayer {
    self.view.device = MTLCreateSystemDefaultDevice();
    self.device = self.view.device; // MTLCreateSystemDefaultDevice();
    self.metalLayer = (CAMetalLayer*)self.view.layer;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer.framebufferOnly = YES;
    self.metalLayer.drawableSize = self.view.bounds.size;
    self.metalLayer.device = self.device;
}

- (void)preparePipelineState {
    NSBundle *myBundle = [FrtcBundleTools getBundle];
    NSError *error;
    id<MTLLibrary>library = [self.device newDefaultLibraryWithBundle:myBundle error:&error];
    if (error) {
        NSLog(@"library error = %@",error);
    }
    //id<MTLLibrary>library = [self.view.device newDefaultLibrary];
    id<MTLFunction>vertexFunc = [library newFunctionWithName:@"texture_vertex"];
    
    id<MTLFunction>fragmentFunc = nil;
    
    switch (self.colorFormat) {
        case RTC::kI420:
            fragmentFunc = [library newFunctionWithName:@"I420_fragment"];
            break;
            
        case RTC::kNV12:
            fragmentFunc = [library newFunctionWithName:@"nv12_fragment"];
            break;
        default:
            NSAssert(fragmentFunc != nil, @"unknown render video type");
            break;
    }
    
    MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    descriptor.vertexFunction = vertexFunc;
    descriptor.fragmentFunction = fragmentFunc;
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    id<MTLRenderPipelineState> pipelineState = [self.device newRenderPipelineStateWithDescriptor:descriptor error:nil];
    
    self.pipelineState = pipelineState;
}

- (void)prepareCommandQueue {
    id<MTLCommandQueue>commandQueue = [self.device newCommandQueue];
    self.commandQueue = commandQueue;
}

- (void)renderI420With:(uint8_t*)yBuffer uBuffer:(uint8_t*)uBuffer vBuffer:(uint8_t*)vBuffer width:(int)width height:(int)height frame:(Frtc_Render::RenderFrame)frame {
    if (!self.textureY || self.textureWidth != width || self.textureHeight != height) {
        self.textureYDes = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
        self.textureY = [self.device newTextureWithDescriptor:self.textureYDes];
        self.textureUDes = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width/2 height:height/2 mipmapped:NO];
        self.textureU = [self.device newTextureWithDescriptor:self.textureUDes];
        self.textureVDes = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width/2 height:height/2 mipmapped:NO];
        self.textureV = [self.device newTextureWithDescriptor:self.textureVDes];
        self.textureWidth = width;
        self.textureHeight = height;
    }
    
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [self.textureY replaceRegion:region mipmapLevel:0 withBytes:yBuffer bytesPerRow:width];
    
    region = MTLRegionMake2D(0, 0, width/2, height/2);
    [self.textureU replaceRegion:region mipmapLevel:0 withBytes:uBuffer bytesPerRow:width/2];
    [self.textureV replaceRegion:region mipmapLevel:0 withBytes:vBuffer bytesPerRow:width/2];
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    
    MTLRenderPassDescriptor *renderPassDes = [[MTLRenderPassDescriptor alloc] init];
    renderPassDes.colorAttachments[0].texture = [drawable texture];
    renderPassDes.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDes.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDes.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDes];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    
    float vertexArray[16];
    float textureCoord[8];
    [self rotateVertexCoordsAndTextureCoordsForRotation:frame vertexArray:vertexArray textureCoord:textureCoord];
    
    id<MTLBuffer> vertexBuffer = [self.device newBufferWithBytes:vertexArray length:sizeof(vertexArray) options:MTLResourceCPUCacheModeDefaultCache];
    [renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    
    id<MTLBuffer> textureCoordBuffer = [self.device newBufferWithBytes:textureCoord length:sizeof(textureCoord) options:MTLResourceCPUCacheModeDefaultCache];
    [renderEncoder setVertexBuffer:textureCoordBuffer offset:0 atIndex:1];
    
    [renderEncoder setFragmentTexture:self.textureY atIndex:0];
    [renderEncoder setFragmentTexture:self.textureU atIndex:1];
    [renderEncoder setFragmentTexture:self.textureV atIndex:2];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [commandBuffer presentDrawable:drawable];
    [renderEncoder endEncoding];
    [commandBuffer commit];
}

- (void)renderNV12With:(uint8_t*)yBuffer uvBuffer:(uint8_t*)uvBuffer width:(int)width height:(int)height frame:(Frtc_Render::RenderFrame)frame {
    if (!self.textureY || self.textureWidth != width || self.textureHeight != height) {
        self.textureYDes = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
        self.textureY = [self.device newTextureWithDescriptor:self.textureYDes];
        self.textureUVDes = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm width:width/2 height:height/2 mipmapped:NO];
        self.textureUV = [self.device newTextureWithDescriptor:self.textureUVDes];
        self.textureWidth = width;
        self.textureHeight = height;
    }
    
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [self.textureY replaceRegion:region mipmapLevel:0 withBytes:yBuffer bytesPerRow:width];
    
    region = MTLRegionMake2D(0, 0, width/2, height/2);
    [self.textureUV replaceRegion:region mipmapLevel:0 withBytes:uvBuffer bytesPerRow:width];
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    
    MTLRenderPassDescriptor *renderPassDes = [[MTLRenderPassDescriptor alloc] init];
    renderPassDes.colorAttachments[0].texture = [drawable texture];
    renderPassDes.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDes.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDes.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDes];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    
    float vertexArray[16];
    float textureCoord[8];
    [self rotateVertexCoordsAndTextureCoordsForRotation:frame vertexArray:vertexArray textureCoord:textureCoord];
    
    id<MTLBuffer> vertexBuffer = [self.device newBufferWithBytes:vertexArray length:sizeof(vertexArray) options:MTLResourceCPUCacheModeDefaultCache];
    [renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    
    id<MTLBuffer> textureCoordBuffer = [self.device newBufferWithBytes:textureCoord length:sizeof(textureCoord) options:MTLResourceCPUCacheModeDefaultCache];
    [renderEncoder setVertexBuffer:textureCoordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:self.textureY atIndex:0];
    [renderEncoder setFragmentTexture:self.textureUV atIndex:1];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [commandBuffer presentDrawable:drawable];
    [renderEncoder endEncoding];
    [commandBuffer commit];
}

- (void)rotateVertexCoordsAndTextureCoordsForRotation:(Frtc_Render::RenderFrame)frame
                                          vertexArray:(float *)vertexArray
                                         textureCoord:(float *)textureCoord {
    if (self.cachedWidth == frame.width &&
        self.cachedHeight == frame.height &&
        self.cachedRotation == frame.rotation &&
        self.cachedViewWidth == _viewWidth &&
        self.cachedViewHeight == _viewHeight) {
        
        memcpy(vertexArray, self.cachedVertexArrayData.bytes, self.cachedVertexArrayData.length);
        memcpy(textureCoord, self.cachedTextureCoordData.bytes, self.cachedTextureCoordData.length);
        return;
    }
    
    self.cachedWidth = frame.width;
    self.cachedHeight = frame.height;
    self.cachedRotation = frame.rotation;
    self.cachedViewWidth = _viewWidth;
    self.cachedViewHeight = _viewHeight;
    
    unsigned int width  = frame.width;
    unsigned int height = frame.height;
    unsigned int widthAfterRotation  = 0;
    unsigned int heightAfterRotation = 0;
    unsigned int parWidth  = frame.pixelAspectRatioWidth;
    unsigned int parHeight = frame.pixelAspectRatioHeight;
    
    float v_left   = -1.0;
    float v_top    = 1.0;
    float v_right  = 1.0;
    float v_bottom = -1.0;
    
    switch (frame.rotation) {
        case 0:
            memcpy(textureCoord, defaultCoords, sizeof(defaultCoords));
            widthAfterRotation = width;
            heightAfterRotation = height;
            break;
        case 1:
            memcpy(textureCoord, coords90, sizeof(coords90));
            widthAfterRotation = height;
            heightAfterRotation = width;
            break;
        case 2:
            memcpy(textureCoord, coords180, sizeof(coords180));
            widthAfterRotation = width;
            heightAfterRotation = height;
            break;
        case 3:
            memcpy(textureCoord, coords270, sizeof(coords270));
            widthAfterRotation = height;
            heightAfterRotation = width;
            break;
        default:
            memcpy(textureCoord, defaultCoords, sizeof(defaultCoords));
            widthAfterRotation = width;
            heightAfterRotation = height;
    }
    
    float frameAspect = 1.0 * (widthAfterRotation * parWidth) / (heightAfterRotation * parHeight);
    float viewAspect  = 1.0 * _viewWidth / _viewHeight;
    float ratio       = frameAspect / viewAspect;
    
    if (((frameAspect >= 1) && (viewAspect >= 1)) || ((frameAspect <= 1) && (viewAspect <= 1))) {
        if (ratio < 1) {
            v_bottom = -1 / ratio;
            v_top = -v_bottom;
        } else {
            v_left = -ratio;
            v_right = ratio;
        }
    } else {
        if (ratio < 1) {
            v_left = -ratio;
            v_right = ratio;
        } else {
            v_bottom = -1 / ratio;
            v_top = -v_bottom;
        }
    }
    
    vertexArray[0] = vertexArray[8]  = v_left;
    vertexArray[4] = vertexArray[12] = v_right;
    vertexArray[9] = vertexArray[13] = v_top;
    vertexArray[1] = vertexArray[5]  = v_bottom;
    
    vertexArray[2] = vertexArray[6] = vertexArray[10] = vertexArray[14] = 0;
    vertexArray[3] = vertexArray[7] = vertexArray[11] = vertexArray[15] = 1.0;
    
    self.cachedVertexArrayData = [NSData dataWithBytes:vertexArray length:sizeof(float) * 16];
    self.cachedTextureCoordData = [NSData dataWithBytes:textureCoord length:sizeof(float) * 8];
}

#pragma mark MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    if(self.isRendering) {
        
        _viewWidth  = view.frame.size.width;
        _viewHeight = view.frame.size.height;
        
        _width    = 0;
        _height   = 0;
        _length   = 0;
        _rotation = 0;
        
        [[ObjectInterface sharedObjectInterface] receiveVideoFrameObject:self.mediaID buffer:&buffer length:&_length width:&_width height:&_height rotation:&_rotation];
        
        if (buffer == NULL) {
            return;
        }
        
        if (_width == 0 || _height == 0) {
            return;
        }
                
        Frtc_Render::RenderFrame frame;
        frame.width     = _width;
        frame.height    = _height;
        frame.rotation  = _rotation;
        
        frame.colorFormat               = self.colorFormat;
        frame.pixelAspectRatioWidth     = 1;
        frame.pixelAspectRatioHeight    = 1;
        
        unsigned int size = _width * _height;
        uint8_t *yBuffer = (uint8_t *)buffer;
        uint8_t *uvBuffer = yBuffer + size;
        
        switch (self.colorFormat) {
            case RTC::kI420: {
                uint8_t* vBuffer = uvBuffer + size/4;
                [self renderI420With:yBuffer uBuffer:uvBuffer vBuffer:vBuffer width:_width height:_height frame:frame];
            }
                break;
                
            case RTC::kNV12:
                [self renderNV12With:yBuffer uvBuffer:uvBuffer width:_width height:_height frame:frame];
                break;
            default:
                break;
        }
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    return;
}

#pragma mark public function
- (void)startRendering{
    _rendering = true;
}

- (void)stopRendering {
    _rendering = false;
}

- (void)setRenderPixelType:(RTC::VideoColorFormat)colorFormat {
    _colorFormat = colorFormat;
    [self preparePipelineState];
}

@end
