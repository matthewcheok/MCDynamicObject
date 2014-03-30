//
//  MCKeychainBindings.m
//  MCDynamicObject
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCDynamicKeychain.h"
#import <PDKeychainBindings.h>

@interface MCDynamicKeychain ()

@property (strong, nonatomic) PDKeychainBindings *bindings;

@end

@implementation MCDynamicKeychain

- (void)setup {
	_bindings = [PDKeychainBindings sharedKeychainBindings];
}

- (void)setDynamicValue:(id)value forKey:(NSString *)key {
	NSString *prefixedKey = [NSString stringWithFormat:@"%@_%@", [self class], key];
	if (value == nil) {
		[self.bindings removeObjectForKey:prefixedKey];
	}
	else {
		[self.bindings setObject:value forKey:prefixedKey];
	}
}

- (id)dynamicValueForKey:(NSString *)key {
	NSString *prefixedKey = [NSString stringWithFormat:@"%@_%@", [self class], key];
	return [self.bindings objectForKey:prefixedKey];
}

@end
