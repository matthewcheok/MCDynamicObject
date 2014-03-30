//
//  MCProperty.h
//  Test
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, MCPropertyType) {
    MCPropertyTypeUnknown = 0,
    MCPropertyTypeObject,
    MCPropertyTypeChar,
    MCPropertyTypeShort,
    MCPropertyTypeInt,
    MCPropertyTypeLong,
    MCPropertyTypeFloat,
    MCPropertyTypeDouble,
    MCPropertyTypeBoolean,
    MCPropertyTypeNSInteger,
    MCPropertyTypeNSUInteger,
    MCPropertyTypeStruct
};

@interface MCProperty : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) MCPropertyType type;
@property (assign, nonatomic, readonly) Class propertyClass;

@property (strong, nonatomic, readonly) NSString *encoding;
@property (strong, nonatomic, readonly) NSString *className;
@property (strong, nonatomic, readonly) NSString *structName;

@property (strong, nonatomic, readonly) NSString *getterName;
@property (strong, nonatomic, readonly) NSString *getterSignature;

@property (strong, nonatomic, readonly) NSString *setterName;
@property (strong, nonatomic, readonly) NSString *setterSignature;

@property (assign, nonatomic, readonly, getter = isReadonly) BOOL readonly;
@property (assign, nonatomic, readonly, getter = isRetained) BOOL retained;
@property (assign, nonatomic, readonly, getter = isCopied) BOOL copied;

@property (assign, nonatomic, readonly, getter = isNonatomic) BOOL nonatomic;
@property (assign, nonatomic, readonly, getter = isDynamic) BOOL dynamic;
@property (assign, nonatomic, readonly, getter = isWeak) BOOL weak;


+ (NSArray *)propertiesForClass:(Class)class;
+ (instancetype)propertyForKey:(NSString *)key inClass:(Class)class;

@end
