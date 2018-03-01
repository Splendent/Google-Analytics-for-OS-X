//
//  MPAnalyticsConfiguration.m
//  GoogleAnalyticsTracker
//
//  Created by Denis Stas on 12/11/15.
//  Copyright © 2015 MacPaw Inc. All rights reserved.
//

#import "MPAnalyticsConfiguration.h"


@interface MPAnalyticsConfiguration ()

@property (nonatomic, copy) NSString *analyticsIdentifier;
@property (nonatomic, strong) NSMutableDictionary *duplicateIdentifiers;
@property (nonatomic, strong) NSMutableDictionary *addtionalIdentifiers;

@end


@implementation MPAnalyticsConfiguration

- (instancetype)init
{
    return [self initWithAnalyticsIdentifier:nil];
}

- (instancetype)initWithAnalyticsIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self)
    {
        _addtionalIdentifiers = [NSMutableDictionary dictionary];
        _duplicateIdentifiers = [NSMutableDictionary dictionary];
        _analyticsIdentifier = identifier;
    }
    
    return self;
}
#pragma mark - duplicate event id
- (void)duplicateEventsForCategory:(NSString *)category toGAID:(NSString *)identifier
{
    if (category && identifier)
    {
        self.duplicateIdentifiers[category] = identifier;
    }
}

- (void)stopDuplicatingEventsForCategory:(NSString *)category
{
    [self.duplicateIdentifiers removeObjectForKey:category];
}

- (NSDictionary *)duplicatedEventIdentifiers
{
    return [self.duplicateIdentifiers copy];
}

#pragma mark - addtional event id
- (void)addEventsForCategory:(NSString *)category toGAID:(NSString *)identifier
{
    if (category && identifier)
    {
        self.addtionalIdentifiers[category] = identifier;
    }
}
- (void)stopAddingEventsForCategory:(NSString *)category
{
    [self.addtionalIdentifiers removeObjectForKey:category];
}
- (NSDictionary *)addtionalEventIdentifiers
{
    return [self.addtionalIdentifiers copy];
}
@end
