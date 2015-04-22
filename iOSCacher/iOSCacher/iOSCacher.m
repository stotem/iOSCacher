//
//  iOSCacher.m
//  iOSCacher
//
//  Created by WuJianjun on 15/3/19.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import <objc/runtime.h>
#import "iOSCacher.h"
#import "iOSCacheEntry.h"

#define  STORE_ROOT_DIR      [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"cacher"]
#define  STORE_TYPE_CODING   @"coding"
#define  STORE_TYPE_OBJECT   @"object"
#define  IGNORE_FILE_TYPE    [NSSet setWithObjects:@"", nil]

static const NSString *OBJ_PROPERTY_INFO = @"cache_info";

@implementation iOSCacher {
@private
    NSTimer *_clearExpireStoreTimer;
    NSTimer *_spaceLimitTimer;
}

+ (instancetype) share {
    
    static dispatch_once_t pred;
    static iOSCacher *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = YES;
        if (![fileManager fileExistsAtPath:STORE_ROOT_DIR isDirectory:&isDirectory]) {
            [fileManager createDirectoryAtPath:STORE_ROOT_DIR withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return instance;
}

- (void)startup {
//    _numMaxDiskSpace = maxDiskSpace;

    // 启动存储清理定时器
    _clearExpireStoreTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(clearExpireStoreTask:) userInfo:nil repeats:YES];
    //    _spaceLimitTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(spaceLimitTask:) userInfo:nil repeats:YES];
    
}

- (void)clearExpireStoreTask:(NSTimer*)timer {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrFiles = [fileManager contentsOfDirectoryAtPath:STORE_ROOT_DIR error:nil];
    for (NSString* filePath in [arrFiles objectEnumerator]) {
        if (![IGNORE_FILE_TYPE containsObject:[filePath pathExtension]]
            && [self isExpireObject:[self getFromDisk:filePath]]) {
            NSLog(@"clear--%@", filePath);
            [fileManager removeItemAtPath:[STORE_ROOT_DIR stringByAppendingPathComponent:filePath] error:nil];
            continue;
        }
    }
}

- (void)spaceLimitTask:(NSTimer*)timer {
    NSLog(@"--spaceLimitTask-");
}

- (BOOL)isExpireObject:(iOSCacheEntry*)entry {
    double expireTime = [[NSDate date] timeIntervalSince1970] - entry.numExpireTime.doubleValue;
    return expireTime >= 0;
}

#pragma mark - disk store
- (NSString *)disk:(iOSCacheEntry*)entry expireTime:(double)time {
    if (!entry) {
        return nil;
    }

    NSString *storeId = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:NSStringFromClass([entry class])];
    // attach key and time
    entry.strObjectId = storeId;
    entry.numExpireTime = [NSNumber numberWithDouble:time];
    NSData *data = [entry encodeData];
    [data writeToFile:[STORE_ROOT_DIR stringByAppendingPathComponent:storeId] atomically:YES];
    return storeId;
}

- (iOSCacheEntry*)getFromDisk:(NSString*)storeId {
    NSString *filePath = [STORE_ROOT_DIR stringByAppendingPathComponent:storeId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    iOSCacheEntry* entry = [[NSClassFromString([storeId pathExtension]) alloc] initWithData:data];
    return entry;
}

-(void)clearDiskStore {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrFiles = [fileManager contentsOfDirectoryAtPath:STORE_ROOT_DIR error:nil];
    for (NSString* fileName in [arrFiles objectEnumerator]) {
        NSString *filePath = [STORE_ROOT_DIR stringByAppendingString:fileName];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

-(NSNumber*)diskSize {
    unsigned long long totalSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arrFiles = [fileManager contentsOfDirectoryAtPath:STORE_ROOT_DIR error:nil];
    for (NSString* fileName in [arrFiles objectEnumerator]) {
        NSString *filePath = [STORE_ROOT_DIR stringByAppendingString:fileName];
        totalSize += [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return [NSNumber numberWithLongLong:totalSize];
}

-(void)removeFromDisk:(NSString *)storeId {
    [[NSFileManager defaultManager] removeItemAtPath:[STORE_ROOT_DIR stringByAppendingString:storeId] error:nil];
}

#pragma mark - disk memory
-(NSString *)memory:(id)object expireTime:(double)time {
    return nil;
}

-(NSNumber *)memorySize {
    return 0;
}

-(void)clearMemoryStore {
    
}

-(void)removeFromMemory:(NSString *)storeId {
    
}

-(iOSCacheEntry*)getFromMemory:(NSString *)storeId {
    return nil;
}

@end
