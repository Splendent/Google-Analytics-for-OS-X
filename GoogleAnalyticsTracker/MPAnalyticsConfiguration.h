//
//  MPAnalyticsConfiguration.h
//  GoogleAnalyticsTracker
//
//  Created by Denis Stas on 12/11/15.
//  Copyright © 2015 MacPaw Inc. All rights reserved.
//

@import Foundation;


@interface MPAnalyticsConfiguration : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *analyticsIdentifier;
@property (nonatomic, copy, readonly, nonnull) NSDictionary *duplicatedEventIdentifiers;
@property (nonatomic, copy, readonly, nonnull) NSDictionary *addtionalEventIdentifiers;

- (instancetype _Nullable)initWithAnalyticsIdentifier:(NSString * _Nonnull)identifier NS_DESIGNATED_INITIALIZER;

/**
 * register duplicated events, which will send event with analyticsIdentifier and registered identifier
 **/
- (void)duplicateEventsForCategory:(NSString * _Nonnull)category toGAID:(NSString * _Nonnull)identifier;
- (void)stopDuplicatingEventsForCategory:(NSString * _Nonnull)category;

/**
 * register addtional events, which will send event with registered identifier only.
 **/
- (void)addEventsForCategory:(NSString * _Nonnull)category toGAID:(NSString * _Nonnull)identifier;
- (void)stopAddingEventsForCategory:(NSString * _Nonnull)category;

@end
