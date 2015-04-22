//
//  iOSCacheEntry.h
//  iOSCacher
//
//  Created by WuJianjun on 15/4/10.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSCacheProtocol.h"

@interface iOSCacheEntry : NSObject <iOSCacheProtocol>

@property(nonatomic) NSString *strObjectId;
@property(nonatomic) NSNumber *numExpireTime;

@end
