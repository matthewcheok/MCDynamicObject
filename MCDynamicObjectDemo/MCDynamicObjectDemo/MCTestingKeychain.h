//
//  MCTestingKeychain.h
//  MCDynamicObjectDemo
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <MCDynamicKeychain.h>

@interface MCTestingKeychain : MCDynamicKeychain

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@end
