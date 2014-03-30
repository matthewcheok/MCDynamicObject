MCDynamicObject ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
===============

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MCDynamicObject/badge.png)](https://github.com/matthewcheok/MCDynamicObject)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/MCDynamicObject/badge.svg)](https://github.com/matthewcheok/MCDynamicObject)

Automatic persistence for your next iOS project. MCDynamicObject inspects your properties and allows getters to read from and setters to make changes to the underlying data store.

## Installation

Add the following to your [CocoaPods](http://cocoapods.org/) Podfile

    pod 'MCDynamicObject'

or clone as a git submodule,

or just copy files in the ```MCDynamicObject``` folder into your project.

## Setting up

Two concrete singleton subclasses `MCDynamicCache` (using [TMCache](https://github.com/tumblr/TMCache)) for general-purpose caching and `MCDynamicKeychain` (using [PDKeychainBindingsController](https://github.com/carlbrown/PDKeychainBindingsController)) for Keychain Access are provided.

Simply create a subclass and add your own properties:

    @interface MCTestingCache : MCDynamicCache

    @property (assign, nonatomic) NSUInteger userID;
    @property (assign, nonatomic) CGPoint lastTapPoint;

    @property (strong, nonatomic) NSString *authToken;
    @property (strong, nonatomic) NSDate *lastUpdatedDate;

    @end

Remember to make the properties dynamic:

    @implementation MCTestingCache

    @dynamic userID, lastTapPoint, authToken, lastUpdatedDate;

    @end

Then just add water! (Or not...)

## Using MCDynamicObject

Read from and write to your properties as normal:

    MCTestingCache *cache = [MCTestingCache sharedInstance];

    // read and write userID
    NSLog(@"userID: %lu", (unsigned long)cache.userID);
    cache.userID = 123;

    // read and write lastTapPoint
    NSLog(@"lastTapPoint: %@", NSStringFromCGPoint(cache.lastTapPoint));
    cache.lastTapPoint = CGPointMake(120, 100);

    // read and write authToken
    NSLog(@"authToken: %@", cache.authToken);
    cache.authToken = @"3232n423jn4i32n4i23j4i23j4";

    // read and write lastUpdatedDate
    NSLog(@"lastUpdatedDate: %@", cache.lastUpdatedDate);
    cache.lastUpdatedDate = [NSDate date];

## Subclassing MCDynamicObject

You can subclass `MCDynamicObject` to provide your own data store.

Override `- (void)setup` to setup your data store. Then override `- (id)dynamicValueForKey:(NSString *)key` and `- (void)setDynamicValue:(id)value forKey:(NSString *)key` to provide read and write access.

The getters and setters take a `NSObject` subclass for objects or `NSValue` subclass for primitives.

## License

MCDynamicObject is under the MIT license.
