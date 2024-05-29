//
//  NSObject+WAnimation.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/26.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "CAAnimation+WAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation CAAnimation (WAnimation)

+(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.1];
    animation.autoreverses=YES;
    animation.duration=time;
    animation.repeatCount=FLT_MAX;
    animation.removedOnCompletion=NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CABasicAnimation *)opacityTimes_Animation:(float)repeatTimes durTimes:(float)time
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.4];
    animation.repeatCount=repeatTimes;
    animation.duration=time;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses=YES;
    return  animation;
}

+(CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(WAxis)axis repeatCount:(int)repeatCount
{
    CABasicAnimation* animation;
    NSArray *axisArr = @[@"transform.rotation.x", @"transform.rotation.y", @"transform.rotation.z"];
    animation = [CABasicAnimation animationWithKeyPath:axisArr[axis]];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue= [NSNumber numberWithFloat:degree];
    animation.duration= dur;
    animation.autoreverses= NO;
    animation.cumulative= YES;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.repeatCount= repeatCount;
    
    return animation;
}

+(CABasicAnimation *)scaleFrom:(CGFloat)fromScale toScale:(CGFloat)toScale durTimes:(float)time rep:(float)repeatTimes
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(fromScale);
    animation.toValue = @(toScale);
    animation.duration = time;
    animation.autoreverses = YES;
    animation.repeatCount = repeatTimes;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

+(CAKeyframeAnimation *)shake_AnimationRepeatTimes:(float)repeatTimes durTimes:(float)time forObj:(id)obj
{
    NSAssert([obj isKindOfClass:[CALayer class]] , @"invalid target");
    CGPoint originPos = CGPointZero;
    CGSize originSize = CGSizeZero;
    if ([obj isKindOfClass:[CALayer class]]) {
        originPos = [(CALayer *)obj position];
        originSize = [(CALayer *)obj bounds].size;
    }
    CGFloat hOffset = originSize.width / 4;
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"position";
    anim.values=@[
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x-hOffset, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x+hOffset, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)]
                  ];
    anim.repeatCount = repeatTimes;
    anim.duration = time;
    anim.fillMode = kCAFillModeForwards;
    return anim;
}

+(CAKeyframeAnimation *)bounce_AnimationRepeatTimes:(float)repeatTimes durTimes:(float)time forObj:(id)obj
{
    NSAssert([obj isKindOfClass:[CALayer class]] , @"invalid target");
    CGPoint originPos = CGPointZero;
    CGSize originSize = CGSizeZero;
    if ([obj isKindOfClass:[CALayer class]]) {
        originPos = [(CALayer *)obj position];
        originSize = [(CALayer *)obj bounds].size;
    }
    CGFloat hOffset = originSize.height / 4;
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"position";
    anim.values=@[
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y-hOffset)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y+hOffset)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)]
                  ];
    anim.repeatCount=repeatTimes;
    anim.duration=time;
    anim.fillMode = kCAFillModeForwards;
    return anim;
}

@end
