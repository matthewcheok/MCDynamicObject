//
//  MCProperty.m
//  Test
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCProperty.h"
#import "EXTScope.h"

static NSString *const kObjectClassRegexPattern = @"^T@\\\"(\\w+)\\\"$";
static NSString *const kObjectStructRegexPattern = @"^\\{(\\w+)=.+\\}$";

@implementation MCProperty

+ (NSArray *)propertiesForClass:(Class)class {
	unsigned count = 0;
	objc_property_t *properties = class_copyPropertyList(class, &count);
	if (properties == NULL) {
		return nil;
	}

	@onExit {
		free(properties);
	};

	NSMutableArray *array = [NSMutableArray array];
	for (unsigned i = 0; i < count; i++) {
		MCProperty *property = [[self alloc] initWithDeclaration:properties[i]];
		[array addObject:property];
	}
	return [array copy];
}

+ (instancetype)propertyForKey:(NSString *)key inClass:(Class)class {
	return [[self alloc] initWithDeclaration:class_getProperty(class, [key UTF8String])];
}

- (instancetype)initWithDeclaration:(objc_property_t)property {
	self = [super init];
	if (self) {
		_name = [NSString stringWithUTF8String:property_getName(property)];

		const char *attributeString = property_getAttributes(property);
		NSArray *attributes = [[NSString stringWithUTF8String:attributeString] componentsSeparatedByString:@","];

		// type
		NSString *type = [attributes firstObject];
		if ([type hasPrefix:@"T"]) {
            _encoding = [type substringFromIndex:1];
			_type = [[self class] typeForEncoding:_encoding];
            
            if (_type == MCPropertyTypeObject) {
                _encoding = @"@";
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kObjectClassRegexPattern options:0 error:nil];
                NSTextCheckingResult *result = [[regex matchesInString:type options:NSMatchingAnchored range:NSMakeRange(0, [type length])] firstObject];
                if ([result numberOfRanges] > 1) {
                    _className = [type substringWithRange:[result rangeAtIndex:1]];
                }
            }
		}
		
		// attributes
		if ([attributes containsObject:@"R"]) {
			_readonly = YES;
		}
		if ([attributes containsObject:@"&"]) {
			_retained = YES;
		}
		if ([attributes containsObject:@"C"]) {
			_copied = YES;
		}
		if ([attributes containsObject:@"N"]) {
			_nonatomic = YES;
		}
		if ([attributes containsObject:@"D"]) {
			_dynamic = YES;
		}
		if ([attributes containsObject:@"W"]) {
			_weak = YES;
		}

		// getter
		char *getterName = property_copyAttributeValue(property, "G");
		if (getterName) {
			_getterName = [NSString stringWithUTF8String:getterName];
			free(getterName);
		}
		else {
			_getterName = _name;
		}
        _getterSignature = [NSString stringWithFormat:@"%@@:", _encoding];

		// setter
		if (!_readonly) {
			char *setterName = property_copyAttributeValue(property, "S");
			if (setterName) {
				_setterName = [NSString stringWithUTF8String:setterName];
				free(setterName);
			}
			else {
				NSString *selectorString = [_name stringByReplacingCharactersInRange:NSMakeRange(0, 1)withString:[[_name substringToIndex:1] uppercaseString]];
				_setterName = [NSString stringWithFormat:@"set%@:", selectorString];
			}
            _setterSignature = [NSString stringWithFormat:@"v@:%@", _encoding];
		}
	}
	return self;
}

- (Class)propertyClass {
	if (self.className) {
		return NSClassFromString(self.className);
	}
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p, %@>",
	        [self class],
	        self,
	        @{
	            @"name": self.name,
	            @"type": [[self class] stringForType:self.type],
	            @"className": self.className ? : [NSNull null]
			}];
}

#pragma mark - Private

+ (MCPropertyType)typeForEncoding:(NSString *)encoding {
	if ([encoding hasPrefix:@"@"]) {
		return MCPropertyTypeObject;
	}
	else if ([encoding isEqualToString:@"c"]) {
		return MCPropertyTypeChar;
	}
	else if ([encoding isEqualToString:@"s"]) {
		return MCPropertyTypeShort;
	}
	else if ([encoding isEqualToString:@"i"]) {
		return MCPropertyTypeInt;
	}
	else if ([encoding isEqualToString:@"l"]) {
		return MCPropertyTypeLong;
	}
	else if ([encoding isEqualToString:@"f"]) {
		return MCPropertyTypeFloat;
	}
	else if ([encoding isEqualToString:@"d"]) {
		return MCPropertyTypeDouble;
	}
	else if ([encoding isEqualToString:@"B"]) {
		return MCPropertyTypeBoolean;
	}
	else if ([encoding isEqualToString:@"q"]) {
		return MCPropertyTypeNSInteger;
	}
	else if ([encoding isEqualToString:@"Q"]) {
		return MCPropertyTypeNSUInteger;
	}
    else if ([encoding hasPrefix:@"{"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kObjectStructRegexPattern options:0 error:nil];
        NSTextCheckingResult *result = [[regex matchesInString:encoding options:NSMatchingAnchored range:NSMakeRange(0, [encoding length])] firstObject];
        NSString *structName = nil;
        if ([result numberOfRanges] > 1) {
            structName = [encoding substringWithRange:[result rangeAtIndex:1]];
        }

        // identify struct
        if ([structName isEqualToString:@"_NSRange"]) {
            return MCPropertyTypeNSRange;
        }
        else if ([structName isEqualToString:@"CGPoint"]) {
            return MCPropertyTypeCGPoint;
        }
        else if ([structName isEqualToString:@"CGSize"]) {
            return MCPropertyTypeCGSize;
        }
        else if ([structName isEqualToString:@"CGRect"]) {
            return MCPropertyTypeCGRect;
        }
        else if ([structName isEqualToString:@"CGAffineTransform"]) {
            return MCPropertyTypeCGAffineTransform;
        }
        else if ([structName isEqualToString:@"CATransform3D"]) {
            return MCPropertyTypeCATransform3D;
        }

		return MCPropertyTypeUnknown;
    }
	else {
		return MCPropertyTypeUnknown;
	}
}

+ (NSString *)stringForType:(MCPropertyType)type {
	switch (type) {
		case MCPropertyTypeUnknown:
			return @"MCPropertyTypeUnknown";

		case MCPropertyTypeObject:
			return @"MCPropertyTypeObject";

		case MCPropertyTypeChar:
			return @"MCPropertyTypeChar";

		case MCPropertyTypeShort:
			return @"MCPropertyTypeShort";

		case MCPropertyTypeInt:
			return @"MCPropertyTypeInt";

		case MCPropertyTypeLong:
			return @"MCPropertyTypeLong";

		case MCPropertyTypeFloat:
			return @"MCPropertyTypeFloat";

		case MCPropertyTypeDouble:
			return @"MCPropertyTypeDouble";

		case MCPropertyTypeBoolean:
			return @"MCPropertyTypeBoolean";

		case MCPropertyTypeNSInteger:
			return @"MCPropertyTypeNSInteger";

		case MCPropertyTypeNSUInteger:
			return @"MCPropertyTypeNSUInteger";
            
        case MCPropertyTypeNSRange:
            return @"MCPropertyTypeNSRange";

        case MCPropertyTypeCGPoint:
            return @"MCPropertyTypeCGPoint";
        
        case MCPropertyTypeCGSize:
            return @"MCPropertyTypeCGSize";
        
        case MCPropertyTypeCGRect:
            return @"MCPropertyTypeCGRect";
            
        case MCPropertyTypeCGAffineTransform:
            return @"MCPropertyTypeCGAffineTransform";
            
        case MCPropertyTypeCATransform3D:
            return @"MCPropertyTypeCATransform3D";
	}
}

@end
