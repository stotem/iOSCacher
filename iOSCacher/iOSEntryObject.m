//
//  iOSCacherObject.m
//  iOSCacher
//
//  Created by WuJianjun on 15/4/10.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import "iOSEntryObject.h"
#import <objc/runtime.h>
#define IGNORE_CLASS    [[NSSet alloc]initWithObjects:[NSObject class], nil]
#define IGNORE_PROPERTY [[NSSet alloc]initWithObjects:@"superclass", @"debugDescription", @"description", nil]

@implementation iOSEntryObject

-(NSData *)encodeData {
    NSDictionary * dicProperties = [self propertiesByObject:self];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicProperties options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}

-(id)initWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    NSLog(@"获取到数据：%@", dic);
    [self setPropertiesValue:self values:dic];
//    NSLog(@"组装数据：%@", self);
    return self;
}

- (void) setPropertiesValue:(id)object values:(NSDictionary*) values {
//    NSLog(@"-设置%@属性,value=%@",object,values);
    // 获取到需要设置的父级类
    NSMutableArray *mArrClass = [[NSMutableArray alloc]init];
    Class tmp = [object class];
    while (tmp) {
        if (![IGNORE_CLASS containsObject:tmp]) {
            [mArrClass addObject:tmp];
        }
        tmp = [tmp superclass];
    }
    
    unsigned int outCount, i;
    for (NSInteger idx = mArrClass.count-1; idx >= 0; idx--) {
        objc_property_t *properties = class_copyPropertyList(mArrClass[idx], &outCount);
        for (i = 0; i<outCount; i++) {
            objc_property_t property = properties[i];
            const char* char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            // 属性名存在于忽略列表中
            if ([IGNORE_PROPERTY containsObject:propertyName]) {
                continue;
            }
            // 未找到属性值
            id propertyValue = [values valueForKey:propertyName];
            if (!propertyValue) {
                continue;
            }
            const char * type = property_getAttributes(property);
            NSString * typeString = [NSString stringWithUTF8String:type];
            NSArray * attributes = [typeString componentsSeparatedByString:@","];
//            NSLog(@"-%@属性:%@,typeString:%@",object,propertyName, typeString);
            // 如果为只读属性，则放弃到此属性
            if ([attributes containsObject:@"R"]) {
                continue;
            }
            NSString * propertyType = [attributes[0] substringFromIndex:1];
            propertyType = [propertyType substringWithRange:NSMakeRange(2, propertyType.length - 3)];
            if ([NSBundle bundleForClass:NSClassFromString(propertyType)] == [NSBundle mainBundle]) {
                id propertyObj = [[NSClassFromString(propertyType) alloc]init];
                [object setValue:propertyObj forKey:propertyName];
                [self setPropertiesValue:propertyObj values:propertyValue];
                continue;
            }
            [object setValue:propertyValue forKey:propertyName];
        }
        free(properties);
    }
}

- (NSDictionary *)propertiesByObject:(id)object {
    NSMutableArray *mArrClass = [[NSMutableArray alloc]init];
    Class tmp = [object class];
    while (tmp) {
        if (![IGNORE_CLASS containsObject:tmp]) {
            [mArrClass addObject:tmp];
        }
        tmp = [tmp superclass];
    }
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    for (NSInteger i=mArrClass.count-1; i >= 0; i--) {
        [props setValuesForKeysWithDictionary:[self getPropertiesByClass:mArrClass[i] object:object]];
    }
    return props;
}

- (NSDictionary *)getPropertiesByClass:(Class)class object:(id)object {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        if ([IGNORE_PROPERTY containsObject:propertyName]) {
            continue;
        }
        id propertyValue = [object valueForKey:propertyName];
        if (!propertyValue) {
            continue;
        }
        if ([NSBundle bundleForClass:[propertyValue class]] == [NSBundle mainBundle]) {
            propertyValue = [self propertiesByObject:propertyValue];
        }
        [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

@end
