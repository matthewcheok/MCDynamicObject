//
//  MCTestingCache.h
//  MCDynamicObjectDemo
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <MCDynamicCache.h>

@interface MCTestingCache : MCDynamicCache

@property (assign, nonatomic) NSUInteger userID;
@property (assign, nonatomic) CGPoint lastTapPoint;

@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSDate *lastUpdatedDate;

@end
