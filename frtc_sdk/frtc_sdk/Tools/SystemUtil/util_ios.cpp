//
//  util_ios.cpp
//  frtc_sdk
//
//  Created by dev on 2024/4/26.
//  Copyright © 2024 FRTC Team. All rights reserved.
//

#include "util_ios.h"
#import <Foundation/Foundation.h>

std::string SystemUtiliOS::GetApplicationDocumentDirectory()
{
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
    return std::string([[pathList objectAtIndex:0] UTF8String]);
}
   
