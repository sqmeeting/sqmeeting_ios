//
//  UIBarButtonItem+WZLBadge.h
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/8/10.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WZLBadge.h"
#import "WZLBadgeProtocol.h"

@interface UIBarButtonItem (WZLBadge)<WZLBadgeProtocol>

- (void)showBadge;

- (void)showBadgeWithStyle:(WBadgeStyle)style
                     value:(NSInteger)value
             animationType:(WBadgeAnimType)aniType;


- (void)clearBadge;

- (void)resumeBadge;


@end
