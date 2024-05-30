#import "NTESYUVConverter.h"
#import "NTESVideoUtil.h"
#import "libyuv.h"

@implementation NTESYUVConverter

+ (NTESI420Frame *)I420ScaleWithSourceI420Frame:(NTESI420Frame *)I420Frame
                                       dstWidth:(float)width
                                      dstHeight:(float)height{
    
    NTESI420Frame *scaledI420Frame = [[NTESI420Frame alloc] initWithWidth:width height:height];
    
    
    libyuv::I420Scale([I420Frame dataOfPlane:NTESI420FramePlaneY],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneY],
                      [I420Frame dataOfPlane:NTESI420FramePlaneU],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneU],
                      [I420Frame dataOfPlane:NTESI420FramePlaneV],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneV],
                      I420Frame.width, I420Frame.height,
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneY],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneY],
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneU],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneU],
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneV],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneV],
                      width, height, libyuv::kFilterNone);
    
    return scaledI420Frame;
    
}

+ (NTESI420Frame *)pixelBufferToI420:(CVImageBufferRef)pixelBuffer
                            withCrop:(float)cropRatio
                          targetSize:(CGSize)size
                      andOrientation:(NTESVideoPackOrientation)orientation {
    if (pixelBuffer == NULL) {
        return nil;
    }
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    
    
    size_t bufferWidth = 0;
    size_t bufferHeight = 0;
    size_t rowSize = 0;
    uint8_t *pixel = NULL;
    
    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        int basePlane = 0;
        pixel = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, basePlane);
        bufferHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, basePlane);
        bufferWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, basePlane);
        rowSize = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, basePlane);
        
    } else {
        pixel = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
        rowSize = CVPixelBufferGetBytesPerRow(pixelBuffer);
    }
    
    NTESI420Frame *convertedI420Frame = [[NTESI420Frame alloc] initWithWidth:(int)bufferWidth height:(int)bufferHeight];
    
    int error = -1;
    
    if ( kCVPixelFormatType_32BGRA == sourcePixelFormat ) {
        
        error = libyuv::ARGBToI420(
                                   pixel, (int)rowSize,
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
                                   (int)bufferWidth, (int)bufferHeight);
    }
    else if (kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange == sourcePixelFormat || kCVPixelFormatType_420YpCbCr8BiPlanarFullRange == sourcePixelFormat) {
        error = libyuv::NV12ToI420(
                                   pixel,
                                   (int)rowSize,
                                   (const uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),
                                   (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1),
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneY],
                                   (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneU],
                                   (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
                                   [convertedI420Frame dataOfPlane:NTESI420FramePlaneV],
                                   (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
                                   (int)bufferWidth,
                                   (int)bufferHeight);
    }
    
    
    if (error) {
        CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
        return nil;
    }
    else {
        rowSize = [convertedI420Frame strideOfPlane:NTESI420FramePlaneY];
        pixel = convertedI420Frame.data;
    }
    
    CMVideoDimensions inputDimens = {(int32_t)bufferWidth, (int32_t)bufferHeight};
    CMVideoDimensions outputDimens = [NTESVideoUtil outputVideoDimensEnhanced:inputDimens crop:cropRatio];
    CMVideoDimensions sizeDimens = {(int32_t)size.width, (int32_t)size.height};
    CMVideoDimensions targetDimens = [NTESVideoUtil outputVideoDimensEnhanced:sizeDimens crop:cropRatio];
    int cropX = (inputDimens.width - outputDimens.width)/2;
    int cropY = (inputDimens.height - outputDimens.height)/2;
    
    if (cropX % 2) {
        cropX += 1;
    }
    
    if (cropY % 2) {
        cropY += 1;
    }
    
    NTESI420Frame *i420Frame;
    i420Frame = [[NTESI420Frame alloc] initWithWidth:(int)bufferWidth height:(int)bufferHeight];
    
    int dstWidth, dstHeight;
    libyuv::RotationModeEnum rotateMode = [NTESYUVConverter rotateMode:orientation];
    dstWidth = i420Frame.height;
    dstHeight = i420Frame.width;
    
    NTESI420Frame *rotatedI420Frame = [[NTESI420Frame alloc]initWithWidth:dstWidth height:dstHeight];
    
    libyuv::I420Rotate([convertedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
                       [convertedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
                       [convertedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
                       [rotatedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneY],
                       [rotatedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneU],
                       [rotatedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneV],
                       i420Frame.width, i420Frame.height,
                       rotateMode);
    i420Frame = rotatedI420Frame;
    
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    return i420Frame;
}

+ (CVPixelBufferRef)i420FrameToPixelBuffer:(NTESI420Frame *)i420Frame
{
    if (i420Frame == nil) {
        return NULL;
    }
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    
    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey,
                                           nil];
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          i420Frame.width,
                                          i420Frame.height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &pixelBuffer);
    
    if (result != kCVReturnSuccess) {
        return NULL;
    }
    
    
    
    result = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        CFRelease(pixelBuffer);
        return NULL;
    }
    
    
    uint8 *dstY = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int dstStrideY = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    uint8* dstUV = (uint8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int dstStrideUV = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    
    int ret = libyuv::I420ToNV12([i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
                                 [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
                                 [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
                                 dstY, dstStrideY, dstUV, dstStrideUV,
                                 i420Frame.width, i420Frame.height);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    if (ret) {
        CFRelease(pixelBuffer);
        return NULL;
    }
    
    return pixelBuffer;
}

+ (libyuv::RotationModeEnum)rotateMode:(NTESVideoPackOrientation)orientation {
    switch (orientation) {
        case NTESVideoPackOrientationPortraitUpsideDown:
            return libyuv::kRotate270;
        case NTESVideoPackOrientationLandscapeLeft:
            return libyuv::kRotate90;
        case NTESVideoPackOrientationLandscapeRight:
            return libyuv::kRotate270;
        case NTESVideoPackOrientationPortrait:
        default:
            return libyuv::kRotate90;
    }
}


+ (CMSampleBufferRef)pixelBufferToSampleBuffer:(CVPixelBufferRef)pixelBuffer {
    if(pixelBuffer == NULL) {
        return NULL;
    }
    CMSampleBufferRef sampleBuffer;
    CMTime frameTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000000000);
    CMSampleTimingInfo timing = {kCMTimeInvalid, frameTime, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    
    OSStatus status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create sample buffer with error %zd.", status);
    }
    
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    
    CVPixelBufferRelease(pixelBuffer);
    if(videoInfo)
        CFRelease(videoInfo);
    
    return sampleBuffer;
}

@end
