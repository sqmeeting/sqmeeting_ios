//
//  NSObject+WAnimation.h
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/26.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WAxis)
{
    WAxisX = 0,
    WAxisY,
    WAxisZ
};

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface CAAnimation (WAnimation)

+(CABasicAnimation *)opacityForever_Animation:(float)time;

+(CABasicAnimation *)opacityTimes_Animation:(float)repeatTimes durTimes:(float)time;

+(CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(WAxis)axis repeatCount:(int)repeatCount;

+(CABasicAnimation *)scaleFrom:(CGFloat)fromScale toScale:(CGFloat)toScale durTimes:(float)time rep:(float)repeatTimes;

+(CAKeyframeAnimation *)shake_AnimationRepeatTimes:(float)repeatTimes durTimes:(float)time forObj:(id)obj;

+(CAKeyframeAnimation *)bounce_AnimationRepeatTimes:(float)repeatTimes durTimes:(float)time forObj:(id)obj;

@end
