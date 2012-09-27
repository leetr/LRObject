//
//  LRObject.m
//
//  Created by Denis Smirnov on 12-06-02.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <objc/runtime.h>
#import "LRObject.h"

static NSMutableDictionary *_aliases;
static NSMutableDictionary *_types;

@interface LRObject () {
    NSMutableDictionary *_fields;
}

@end

@implementation LRObject {
    
}


+ (void)initialize
{
    
}

//
+ (void)setAlias:(NSString *)alias forKey:(NSString *)key
{
    if (_aliases == nil) {
        _aliases = [[NSMutableDictionary alloc] init];
    }
    
    NSString *selfClassName = NSStringFromClass([self class]);
    
    NSMutableDictionary *classAliases = [_aliases objectForKey:selfClassName];
    
    if (classAliases == nil) {
        classAliases = [NSMutableDictionary dictionary];
        [_aliases setObject:classAliases forKey:selfClassName];
    }
    
    [classAliases setValue:[alias lowercaseString] forKey:key];
}

//
+ (void)setClass:(id)clazz forKey:(NSString *)key
{
    if (_types == nil) {
        _types = [[NSMutableDictionary alloc] init];
    }
    
    NSString *selfClassName = NSStringFromClass([self class]);
    
    NSMutableDictionary *classTypes = [_types objectForKey:selfClassName];
    
    if (classTypes == nil) {
        classTypes = [NSMutableDictionary dictionary];
        [_types setObject:classTypes forKey:selfClassName];
    }
    
    [classTypes setValue:clazz forKey:key];
}

- (void)dealloc
{
    [_fields release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _fields = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (id)initWithData:(NSDictionary *)dict
{
    self = [super init];
    
    if (self) {
        _fields = [[NSMutableDictionary alloc] init];
        
        [self setValuesFromDictionary:dict];
    }
    
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    @try {
        [super setValue:value forKey:key];
    }
    @catch (NSException *e) {
        if ([e.name isEqualToString:NSUndefinedKeyException]) {
            [_fields setValue:value forKey:key];
        }
    }
}

//
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *sel = NSStringFromSelector(aSelector);
    
    if ([sel rangeOfString:@"set"].location == 0) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

//
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *key = NSStringFromSelector([anInvocation selector]);
    if ([key rangeOfString:@"set"].location == 0) {
        key = [[key substringWithRange:NSMakeRange(3, [key length]-4)] lowercaseString];
        NSString *obj;
        [anInvocation getArgument:&obj atIndex:2];
        
        if (obj != nil) {
            [_fields setObject:obj forKey:key];
        }
    } else {
        NSString *obj = [self valueForKey:[key lowercaseString]];
        [anInvocation setReturnValue:&obj]; 
    }
}

//
- (id)valueForUndefinedKey:(NSString *)key
{
    if ([[_fields allKeys] containsObject:key]) {
        return [_fields valueForKey:key];
    } else {
        NSException *e = [NSException exceptionWithName:NSUndefinedKeyException reason:@"No such key" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key, @"key", nil]];
        
        NSLog(@"[%@]EXCEPTION:%@, \nDictionary:\n %@", [self class] ,e, e.userInfo);
                          
        return nil;
//        @throw [NSException exceptionWithName:NSUndefinedKeyException reason:@"No such key" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key, @"key", nil]];
    }
}

//
- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    if (dict != nil) {
        
        NSString *selfClass = NSStringFromClass([self class]);
        
        NSMutableDictionary *classAliases = [_aliases objectForKey:selfClass];
        NSMutableDictionary *classTypes = [_types objectForKey:selfClass];
        
        for (NSString *dataKey in dict) {
            //look it up in aliases
            NSString *objKey = [classAliases objectForKey:dataKey];
            
            //if alias doesn't exist, use original dict key
            if (objKey == nil) {
                objKey = dataKey;
            }
            
            //look up type mapping
            Class clz = [classTypes objectForKey:objKey];
            
            //make sure we're KVC compliant
            [self willChangeValueForKey:objKey];
            
            //if type doesn't exist, treat it as NSString
            if (clz == nil) {
                [self setValue:[dict valueForKey:dataKey] forKey:objKey];
            } else {
                id obj = [[[clz alloc] initWithData:[dict valueForKey:dataKey]] autorelease];
                [self setValue:obj forKey:objKey];
            }
            
            //make sure we're KVC compliant
            [self didChangeValueForKey:objKey];
        }
    }
}

//
- (NSDictionary *)toDictionary
{
    NSString *selfClass = NSStringFromClass([self class]);
    
    NSMutableDictionary *classAliases = [_aliases objectForKey:selfClass];
    NSMutableDictionary *classTypes = [_types objectForKey:selfClass];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    for (NSString *field in _fields) {
        
        NSString *dictKey = nil;
        
        for (NSString *aliasKey in classAliases) {
            if ([field isEqualToString:[classAliases valueForKey:aliasKey]]) {
                dictKey = aliasKey;
                break;
            }
        }
        
        if (dictKey == nil) {
            dictKey = field;
        }
        
        //TODO: need to check if class responds to toDictionary
        if ([classTypes objectForKey:field] != nil) {
            [props setValue:[[_fields valueForKey:field] toDictionary] forKey:dictKey];
        } else {
            [props setValue:[_fields valueForKey:field] forKey:dictKey];
        }
            
    }
    
    return props;
}

//
- (NSString *)description
{
    return [[self toDictionary] description];
}

@end
