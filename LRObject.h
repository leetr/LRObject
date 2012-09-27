//
//  LRObject.h
//
//  Created by Denis Smirnov on 12-06-02.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRObject : NSObject

+ (void)setAlias:(NSString *)alias forKey:(NSString *)key;
+ (void)setClass:(id)clazz forKey:(NSString *)key;

- (id)initWithData:(NSDictionary *)dict;
- (void)setValuesFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
