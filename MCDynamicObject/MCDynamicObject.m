//
//  MCDynamicObject.m
//  MCDynamicObject
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCDynamicObject.h"
#import "MCProperty.h"

@interface MCDynamicObject ()

@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSDictionary *getters;
@property (strong, nonatomic) NSDictionary *setters;

@end

@implementation MCDynamicObject

static NSMutableDictionary *_sharedInstances = nil;

+ (void)load {
	if (!_sharedInstances) {
		_sharedInstances = [NSMutableDictionary dictionary];
	}
}

+ (instancetype)sharedInstance {
	id sharedInstance = nil;

	@synchronized(self)
	{
		NSString *instanceClass = NSStringFromClass(self);

		// Looking for existing instance
		sharedInstance = [_sharedInstances objectForKey:instanceClass];

		// If there's no instance – create one and add it to the dictionary
		if (!sharedInstance) {
			sharedInstance = [[self alloc] init];
			[_sharedInstances setObject:sharedInstance forKey:instanceClass];
		}
	}

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		NSMutableDictionary *properties = [NSMutableDictionary dictionary];
		NSMutableDictionary *getters = [NSMutableDictionary dictionary];
		NSMutableDictionary *setters = [NSMutableDictionary dictionary];

        NSArray *array = [MCProperty propertiesForClass:[self class]];
        [self __validateProperties:array];
        
		for (MCProperty *property in array) {
			if ([property isDynamic]) {
				[properties setObject:property forKey:property.name];
				[getters setObject:property forKey:property.getterName];
				if (![property isReadonly]) {
					[setters setObject:property forKey:property.setterName];
				}
			}
			else {
				NSLog(@"Warning: The property \"%@\" on class <%@> is not dynamic and will not be persisted.", property.name, [self class]);
			}
		}

		_properties = [properties copy];
		_getters = [getters copy];
		_setters = [setters copy];

        [self setup];
	}
	return self;
}

#pragma mark - MCDynamicObject

- (void)setup {
    [NSException raise:NSInternalInconsistencyException format:@"Use a concrete subclass of MCDynamicObject."];
}

- (void)setDynamicValue:(id)value forKey:(NSString *)key {
}

- (id)dynamicValueForKey:(NSString *)key {
    return nil;
}

#pragma mark - Private

- (void)__validateProperties:(NSArray *)properties {
}

#pragma mark - Key-Value Coding

- (id)valueForUndefinedKey:(NSString *)key {
	if ([[self.properties allKeys] containsObject:key]) {
		return [self dynamicValueForKey:key];
	}
	else {
		return [super valueForUndefinedKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	if ([[self.properties allKeys] containsObject:key]) {
		[self setDynamicValue:value forKey:key];
	}
	else {
		[super setValue:value forKey:key];
	}
}

#pragma mark - Direct Access

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	NSString *selectorAsString = NSStringFromSelector(aSelector);
	MCProperty *property = nil;

	// getter
	property = [self.getters objectForKey:selectorAsString];
	if (property) {
		return [NSMethodSignature signatureWithObjCTypes:[property.getterSignature UTF8String]];
	}

	// setter
	property = [self.setters objectForKey:selectorAsString];
	if (property) {
		return [NSMethodSignature signatureWithObjCTypes:[property.setterSignature UTF8String]];
	}

	return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	NSString *selectorAsString = NSStringFromSelector([anInvocation selector]);
	MCProperty *property = nil;

	// getter
	property = [self.getters objectForKey:selectorAsString];
	if (property) {
		id value = [self dynamicValueForKey:property.name];

        switch (property.type) {
            case MCPropertyTypeObject: {
                [anInvocation setReturnValue:&value];
                [anInvocation retainArguments];
                break;
            }

            default: {
                NSUInteger bufferSize = 0;
                NSGetSizeAndAlignment([property.encoding UTF8String], &bufferSize, NULL);
                void* buffer = malloc(bufferSize);
                
                [(NSValue *)value getValue:buffer];
                [anInvocation setReturnValue:buffer];
                [anInvocation retainArguments];
                
                free(buffer);
                break;
            }
        }

		return;
	}

	// setter
	property = [self.setters objectForKey:selectorAsString];
	if (property) {
        switch (property.type) {
            case MCPropertyTypeObject: {
                __unsafe_unretained id value = nil;
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:value forKey:property.name];
                break;
            }

            default: {
                NSUInteger bufferSize = 0;
                NSGetSizeAndAlignment([property.encoding UTF8String], &bufferSize, NULL);
                void* buffer = malloc(bufferSize);
                
                [anInvocation getArgument:buffer atIndex:2];
                NSValue *value = [NSValue valueWithBytes:buffer objCType:[property.encoding UTF8String]];
                [self setDynamicValue:value forKey:property.name];
                
                free(buffer);
                break;
            }
        }

		return;
	}

	[super forwardInvocation:anInvocation];
}


@end
