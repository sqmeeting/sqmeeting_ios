#import "NTESVideoUtil.h"

#define NVSVideoUtilCropWidthAlignment 2

@implementation NTESVideoUtil

+ (CMVideoDimensions)outputVideoDimensEnhanced:(CMVideoDimensions)inputDimens crop:(float)ratio {
    inputDimens.width = (inputDimens.width / 2) * 2;
    inputDimens.height = (inputDimens.height / 2) * 2;
    if (ratio <= 0 || ratio > 1) {
        return inputDimens;
    }

    CMVideoDimensions outputDimens = {0, 0};
    int sw = inputDimens.width;
    int sh = inputDimens.height;

    if (sw / sh == ratio) {
        outputDimens.width = sw;
        outputDimens.height = sh;
        return outputDimens;
    }

    if (sw / sh < ratio) {
        for (int cropW = 0; cropW < sw; cropW += 2) {
            for (int cropH = 0; cropH < sh; cropH += 2) {
                if ((sw - cropW) == ratio * (sh - cropH)) {
                    outputDimens.height = sh - cropH;
                    outputDimens.width = sw - cropW;
                    return outputDimens;
                }
            }
        }
    } else {
        for (int cropH = 0; cropH < sh; cropH += 2) {
            for (int cropW = 0; cropW < sw; cropW += 2) {
                if ((sw - cropW) == ratio * (sh - cropH)) {
                    outputDimens.height = sh - cropH;
                    outputDimens.width = sw - cropW;
                    return outputDimens;
                }
            }
        }
    }
    return inputDimens;
}

+ (CMVideoDimensions)outputVideoDimens:(CMVideoDimensions)inputDimens crop:(float)ratio {
    if (ratio <= 0 || ratio > 1) {
        return inputDimens;
    }

    CMVideoDimensions outputDimens = inputDimens;

    if (inputDimens.width > inputDimens.height) {
        if (inputDimens.width * ratio > inputDimens.height) {
            outputDimens.width = inputDimens.height / ratio;
        } else {
            outputDimens.height = inputDimens.width * ratio;
        }
    } else {
        if (inputDimens.height * ratio > inputDimens.width) {
            outputDimens.height = inputDimens.width / ratio;
        } else {
            outputDimens.width = inputDimens.height * ratio;
        }
    }

    outputDimens.width = (outputDimens.width / NVSVideoUtilCropWidthAlignment) * NVSVideoUtilCropWidthAlignment;
    outputDimens.height = (outputDimens.height / NVSVideoUtilCropWidthAlignment) * NVSVideoUtilCropWidthAlignment;

    return outputDimens;
}

+ (CMVideoDimensions)calculateDiemnsDividedByTwo:(int)width andHeight:(int)height {
    CMVideoDimensions dimens = {width, height};
    dimens.width = (dimens.width / NVSVideoUtilCropWidthAlignment) * NVSVideoUtilCropWidthAlignment;
    dimens.height = (dimens.height / NVSVideoUtilCropWidthAlignment) * NVSVideoUtilCropWidthAlignment;
    return dimens;
}

@end


