//
//  UIBarButtonItem+WZLBadge.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/8/10.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "UIBarButtonItem+WZLBadge.h"
#import <objc/runtime.h>

#define kActualView     [self getActualBadgeSuperView]


@implementation UIBarButtonItem (WZLBadge)

#pragma mark -- public methods

- (void)showBadge
{
    [kActualView showBadge];
}

- (void)showBadgeWithStyle:(WBadgeStyle)style
                     value:(NSInteger)value
             animationType:(WBadgeAnimType)aniType
{
    [kActualView showBadgeWithStyle:style value:value animationType:aniType];
}

- (void)clearBadge
{
    [kActualView clearBadge];
}

- (void)resumeBadge
{
    [kActualView resumeBadge];
}

#pragma mark -- private method

- (UIView *)getActualBadgeSuperView
{
    return [self valueForKeyPath:@"_view"];//use KVC to hack actual view
}

#pragma mark -- setter/getter
- (UILabel *)badge
{
    return kActualView.badge;
}

- (void)setBadge:(UILabel *)label
{
    [kActualView setBadge:label];
}

- (UIFont *)badgeFont
{
	return kActualView.badgeFont;
}

- (void)setBadgeFont:(UIFont *)badgeFont
{
	[kActualView setBadgeFont:badgeFont];
}

- (UIColor *)badgeBgColor
{
    return [kActualView badgeBgColor];
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor
{
    [kActualView setBadgeBgColor:badgeBgColor];
}

- (UIColor *)badgeTextColor
{
    return [kActualView badgeTextColor];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    [kActualView setBadgeTextColor:badgeTextColor];
}

- (WBadgeAnimType)aniType
{
    return [kActualView aniType];
}

- (void)setAniType:(WBadgeAnimType)aniType
{
    [kActualView setAniType:aniType];
}

- (CGRect)badgeFrame
{
    return [kActualView badgeFrame];
}

- (void)setBadgeFrame:(CGRect)badgeFrame
{
    [kActualView setBadgeFrame:badgeFrame];
}

- (CGPoint)badgeCenterOffset
{
    return [kActualView badgeCenterOffset];
}

- (void)setBadgeCenterOffset:(CGPoint)badgeCenterOffset
{
    [kActualView setBadgeCenterOffset:badgeCenterOffset];
}

- (NSInteger)badgeMaximumBadgeNumber
{
    return [kActualView badgeMaximumBadgeNumber];
}

- (void)setBadgeMaximumBadgeNumber:(NSInteger)badgeMaximumBadgeNumber
{
    [kActualView setBadgeMaximumBadgeNumber:badgeMaximumBadgeNumber];
}

@end
