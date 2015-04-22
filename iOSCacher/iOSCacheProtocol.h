//
//  iOSCacheAction.h
//  iOSCacher
//
//  Created by WuJianjun on 15/4/10.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol iOSCacheProtocol <NSObject>

- (NSData*) encodeData;
- (id) initWithData:(NSData*)data;

@end
