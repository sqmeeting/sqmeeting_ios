//
//  UIView+WZLBadge.h
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//  Project description: this is a solution to enable any UIView to display badge

#import <UIKit/UIKit.h>
#import "WZLBadgeProtocol.h"

#pragma mark -- badge apis

@interface UIView (WZLBadge)<WZLBadgeProtocol>

- (void)showBadge;

- (void)showBadgeWithStyle:(WBadgeStyle)style
                     value:(NSInteger)value
             animationType:(WBadgeAnimType)aniType;

- (void)showNumberBadgeWithValue:(NSInteger)value
              animationType:(WBadgeAnimType)aniType;

- (void)showNumberBadgeWithValue:(NSInteger)value;

- (void)clearBadge;

- (void)resumeBadge;

@end
