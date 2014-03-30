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

		for (MCProperty *property in [MCProperty propertiesForClass:[self class]]) {
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

            case MCPropertyTypeChar: {
                char number = [(NSNumber *)value charValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeShort: {
                short number = [(NSNumber *)value shortValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeInt: {
                int number = [(NSNumber *)value intValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeLong: {
                long number = [(NSNumber *)value longValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeFloat: {
                float number = [(NSNumber *)value floatValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeDouble: {
                double number = [(NSNumber *)value doubleValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeBoolean: {
                BOOL number = [(NSNumber *)value boolValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeNSInteger: {
                NSInteger number = [(NSNumber *)value integerValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeNSUInteger: {
                NSUInteger number = [(NSNumber *)value unsignedIntegerValue];
                [anInvocation setReturnValue:&number];
                break;
            }

            case MCPropertyTypeNSRange: {
                NSRange range = [(NSValue *)value rangeValue];
                [anInvocation setReturnValue:&range];
                break;
            }

            case MCPropertyTypeCGPoint: {
                CGPoint point = [(NSValue *)value CGPointValue];
                [anInvocation setReturnValue:&point];
                break;
            }

            case MCPropertyTypeCGSize: {
                CGSize size = [(NSValue *)value CGSizeValue];
                [anInvocation setReturnValue:&size];
                break;
            }

            case MCPropertyTypeCGRect: {
                CGRect rect = [(NSValue *)value CGRectValue];
                [anInvocation setReturnValue:&rect];
                break;
            }

            case MCPropertyTypeCGAffineTransform: {
                CGAffineTransform transform = [(NSValue *)value CGAffineTransformValue];
                [anInvocation setReturnValue:&transform];
                break;
            }

            case MCPropertyTypeCATransform3D: {
                CATransform3D transform = [(NSValue *)value CATransform3DValue];
                [anInvocation setReturnValue:&transform];
                break;
            }

            default: {
                [NSException raise:NSInternalInconsistencyException format:@"The type \"%@\" for the property \"%@\" is not supported.", property.encoding, property.name];
                break;
            }
        }

		return;
	}

	// setter
	property = [self.setters objectForKey:selectorAsString];
	if (property) {
		__unsafe_unretained id value = nil;

        switch (property.type) {
            case MCPropertyTypeObject: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:value forKey:property.name];
                break;
            }

            case MCPropertyTypeChar: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithChar:(char)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeShort: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithShort:(short)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeInt: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithInt:(int)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeLong: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithLong:(long)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeFloat: {
                float number;
                [anInvocation getArgument:&number atIndex:2];
                [self setDynamicValue:[NSNumber numberWithFloat:number] forKey:property.name];
                break;
            }

            case MCPropertyTypeDouble: {
                double number;
                [anInvocation getArgument:&number atIndex:2];
                [self setDynamicValue:[NSNumber numberWithDouble:number] forKey:property.name];
                break;
            }

            case MCPropertyTypeBoolean: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithBool:(BOOL)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeNSInteger: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithInteger:(NSInteger)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeNSUInteger: {
                [anInvocation getArgument:&value atIndex:2];
                [self setDynamicValue:[NSNumber numberWithUnsignedInteger:(NSUInteger)value] forKey:property.name];
                break;
            }

            case MCPropertyTypeNSRange: {
                NSRange range;
                [anInvocation getArgument:&range atIndex:2];
                [self setDynamicValue:[NSValue valueWithRange:range] forKey:property.name];
                break;
            }

            case MCPropertyTypeCGPoint: {
                CGPoint point;
                [anInvocation getArgument:&point atIndex:2];
                [self setDynamicValue:[NSValue valueWithCGPoint:point] forKey:property.name];
                break;
            }

            case MCPropertyTypeCGSize: {
                CGSize size;
                [anInvocation getArgument:&size atIndex:2];
                [self setDynamicValue:[NSValue valueWithCGSize:size] forKey:property.name];
                break;
            }

            case MCPropertyTypeCGRect: {
                CGRect rect;
                [anInvocation getArgument:&rect atIndex:2];
                [self setDynamicValue:[NSValue valueWithCGRect:rect] forKey:property.name];
                break;
            }

            case MCPropertyTypeCGAffineTransform: {
                CGAffineTransform transform;
                [anInvocation getArgument:&transform atIndex:2];
                [self setDynamicValue:[NSValue valueWithCGAffineTransform:transform] forKey:property.name];
                break;
            }

            case MCPropertyTypeCATransform3D: {
                CATransform3D transform;
                [anInvocation getArgument:&transform atIndex:2];
                [self setDynamicValue:[NSValue valueWithCATransform3D:transform] forKey:property.name];
                break;
            }

            default: {
                [NSException raise:NSInternalInconsistencyException format:@"The type \"%@\" for the property \"%@\" is not supported.", property.encoding, property.name];
                break;
            }
        }

		return;
	}

	[super forwardInvocation:anInvocation];
}


@end
