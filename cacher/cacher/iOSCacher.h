//
//  iOSCacher.h
//  iOSCacher
//
//  Created by WuJianjun on 15/3/19.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSCacheEntry.h"

@interface iOSCacher : NSObject

//@property(nonatomic,readonly) long numMaxDiskSpace;

+ (instancetype)share;
- (void)startup;

- (NSString*)disk:(iOSCacheEntry*)entry expireTime:(double)time;
- (void)clearDiskStore;
- (void)removeFromDisk:(NSString*)storeId;
- (iOSCacheEntry*)getFromDisk:(NSString*)storeId;
- (NSNumber*)diskSize;

- (NSString*)memory:(iOSCacheEntry*)entry expireTime:(double)time;
- (NSNumber*)memorySize;
- (void)clearMemoryStore;
- (void)removeFromMemory:(NSString*)storeId;
- (iOSCacheEntry*)getFromMemory:(NSString*)storeId;

@end
