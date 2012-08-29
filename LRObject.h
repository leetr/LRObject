//
//  DataObject.h
//  OttrJam
//
//  Created by Denis Smirnov on 12-06-02.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRObject : NSObject

@property (nonatomic, retain) NSString *_id;

+ (void)setAlias:(NSString *)alias forKey:(NSString *)key;
+ (void)setClass:(id)clazz forKey:(NSString *)key;

+ (NSString *)dateToString:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)dateStr;

- (id)initWithData:(NSDictionary *)dict;
- (void)setValuesFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
