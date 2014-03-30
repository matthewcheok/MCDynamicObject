//
//  MCDynamicObject.h
//  MCDynamicObject
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCDynamicObject : NSObject

+ (instancetype)sharedInstance;

// subclasses should overwrite the following methods to provide a backing store

- (void)setup;
- (void)setDynamicValue:(id)value forKey:(NSString *)key;
- (id)dynamicValueForKey:(NSString *)key;

@end
