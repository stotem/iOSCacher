//
//  iOSCacherCoding.m
//  iOSCacher
//
//  Created by WuJianjun on 15/4/10.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import "iOSEntryCoding.h"

@implementation iOSEntryCoding

-(NSData *)encodeData {
    NSMutableData *mData = [[NSMutableData alloc] init];
    NSKeyedArchiver *myKeyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mData];
    [myKeyedArchiver encodeObject:self];
    [myKeyedArchiver finishEncoding];
    return mData;
}

-(id)initWithData:(NSData *)data {
    NSKeyedUnarchiver *myKeyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    return [myKeyedUnarchiver decodeObject];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self) {
        self.strObjectId = [aDecoder decodeObjectForKey:@"cache_ObjectId"];
        self.numExpireTime = [aDecoder decodeObjectForKey:@"cache_ExpireTime"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.strObjectId forKey:@"cache_ObjectId"];
    [aCoder encodeObject:self.numExpireTime forKey:@"cache_ExpireTime"];
}

@end
