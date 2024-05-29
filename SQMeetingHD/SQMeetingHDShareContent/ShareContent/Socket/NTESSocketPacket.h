//
//  NTESSocketPacket.h
//  NIMEducationDemo
//
//  Created by He on 2019/5/6.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    uint8_t version;
    uint8_t service_id;
    uint8_t command_id;
    uint8_t serial_id;
    uint64_t data_len;
    uint8_t roration_dev;
    bool    isPro;
} NTESPacketHead;

#define kRecvBufferMaxSize 1024 * 1024 *15
#define kRecvBufferPerSize 1024

NS_ASSUME_NONNULL_BEGIN

@interface NTESSocketPacket : NSObject

+ (NSData *)packetWithBuffer:(NSData *)rawData roration:(uint8_t)roration ipadPro:(bool)ipadPro;
+ (NSData *)packetWithBuffer:(NSData *)rawData head:(NTESPacketHead *)head;

@end

NS_ASSUME_NONNULL_END
