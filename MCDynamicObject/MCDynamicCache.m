//
//  MCCache.m
//  MCDynamicObject
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCDynamicCache.h"
#import <TMCache.h>

@interface MCDynamicCache ()

@property (strong, nonatomic) TMCache *cache;

@end

@implementation MCDynamicCache

- (void)setup {
	NSString *name = [NSString stringWithFormat:@"MCDynamicCache_%@", [self class]];
	_cache = [[TMCache alloc] initWithName:name];
}

- (void)setDynamicValue:(id)value forKey:(NSString *)key {
	if (value == nil) {
		[self.cache removeObjectForKey:key];
	}
	else {
		[self.cache setObject:value forKey:key];
	}
}

- (id)dynamicValueForKey:(NSString *)key {
	return [self.cache objectForKey:key];
}

@end
