//
//  MCAppDelegate.m
//  MCDynamicObjectDemo
//
//  Created by Matthew Cheok on 30/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCTestingCache.h"
#import "MCTestingKeychain.h"

@implementation MCAppDelegate

- (void)test {
	MCTestingCache *cache = [MCTestingCache sharedInstance];
	NSLog(@"cache %@", cache);

	// read and write userID
	NSLog(@"userID: %lu", (unsigned long)cache.userID);
	cache.userID = 123;
	NSLog(@"userID: %lu", (unsigned long)cache.userID);

	// read and write lastTapPoint
	NSLog(@"lastTapPoint: %@", NSStringFromCGPoint(cache.lastTapPoint));
	cache.lastTapPoint = CGPointMake(120, 100);
	NSLog(@"lastTapPoint: %@", NSStringFromCGPoint(cache.lastTapPoint));

	// read and write authToken
	NSLog(@"authToken: %@", cache.authToken);
	cache.authToken = @"3232n423jn4i32n4i23j4i23j4";
	NSLog(@"authToken: %@", cache.authToken);

	// read and write lastUpdatedDate
	NSLog(@"lastUpdatedDate: %@", cache.lastUpdatedDate);
	cache.lastUpdatedDate = [NSDate date];
	NSLog(@"lastUpdatedDate: %@", cache.lastUpdatedDate);


	MCTestingKeychain *keychain = [MCTestingKeychain sharedInstance];
	NSLog(@"keychain %@", keychain);

	// read and write email
	NSLog(@"email: %@", keychain.email);
	keychain.email = @"test@email.com";
	NSLog(@"email: %@", keychain.email);

	// read and write password
	NSLog(@"password: %@", keychain.password);
	keychain.password = @"really_fancy_password";
	NSLog(@"password: %@", keychain.password);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self test];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
