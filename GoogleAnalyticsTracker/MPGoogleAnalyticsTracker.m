//
//  MPGoogleAnalyticsTracker.m
//  GoogleAnalyticsTracker
//
//  Created by Denis Stas on 11/27/12.
//  Copyright (c) 2012 Denis Stas. All rights reserved.
//

#import "MPGoogleAnalyticsTracker.h"
#import "MPAnalyticsConfiguration.h"
#import "MPAnalyticsParamBuilder.h"
#import "TrackerHelper.h"


NSString *const MPUseDebugGAIDKey = @"AnalyticsUseDebugGAID";
NSString *const MPCustomGAIDKey = @"AnalyticsCustomGAID";
NSString *const MPCDKey = @"cd";


@interface MPGoogleAnalyticsTracker ()

@property (nonatomic, strong) MPAnalyticsConfiguration *activeConfiguration;

@property (nonatomic, strong) NSURLSession *session;

/* Tracker information helper */
@property (nonatomic, strong) TrackerHelper * trackerInfoHelper;

/* Application-specific information */
@property (nonatomic, readonly, getter=isBeta) BOOL beta;
@property (nonatomic, readonly, getter=isDebugEnabled) BOOL debugEnabled;


@property NSString *currentScreen;
@property NSMutableArray *modalScreens;

- (void)activateConfiguration:(MPAnalyticsConfiguration *)configuration;

- (void)trackEventWithParameters:(MPEventParams *)eventParams;
- (void)trackTimingWithParameters:(MPTimingParams *)timingParameters;

- (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value;

- (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value
          contentDescription:(NSString *)contentDescription customDimension:(NSString *)dimension;

- (void)trackTimingOfCategory:(NSString *)category variable:(NSString *)variable
                         time:(NSNumber *)time label:(NSString *)label;

- (void)trackScreen:(NSString *)screen;
- (void)trackModalScreen:(NSString *)modalScreen;
- (void)switchToModalScreen:(NSString *)modalScreen;
- (void)stopTrackingModalScreen;

@end


@implementation MPGoogleAnalyticsTracker

@synthesize beta = _isBeta;
@synthesize debugEnabled = _debugEnabled;

static id _sharedInstance = nil;
+ (instancetype)sharedTracker
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _modalScreens = [NSMutableArray new];
        _trackerInfoHelper = [TrackerHelper new];
        NSURLSessionConfiguration *lightweightConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        lightweightConfiguration.HTTPAdditionalHeaders = @{ @"User-Agent" : _trackerInfoHelper.userAgentString };
        lightweightConfiguration.HTTPMaximumConnectionsPerHost = 1;
        
        _session = [NSURLSession sessionWithConfiguration:lightweightConfiguration];
        
    }
    return self;
}

#pragma mark - Configuration

- (void)activateConfiguration:(MPAnalyticsConfiguration *)configuration
{
    self.activeConfiguration = configuration;
}

#pragma mark - Application and User data

- (BOOL)isBeta
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        self->_isBeta = ([version.lowercaseString rangeOfString:@"b"].location == NSNotFound);
    });
    
    return _isBeta;
}

- (BOOL)isDebugEnabled
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef DEBUG
        self->_debugEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowDebugMenu"];
#else
        self->_debugEnabled = YES;
#endif
    });
    return _debugEnabled;
}


- (NSString *)userIdentifier
{
    return [self.trackerInfoHelper userIdentifier];
}

- (NSString *)userAgentString
{
    return [self.trackerInfoHelper userAgentString];
}

- (NSString *)systemInfo
{
    return [self.trackerInfoHelper systemInfo];
}

#pragma mark - Requests

- (NSString *)contentDescription
{
    if (self.modalScreens.count > 0)
    {
        return self.modalScreens[0];
    }
    
    return self.currentScreen;
}

- (NSDictionary *)filteredDictionaryForParameters:(MPTrackingRequestParams *)parameters
                        includeContentDescription:(BOOL)includeContentDescription
{
    NSDictionary *dictionaryRepresentation = parameters.dictionaryRepresentation;
    NSMutableDictionary *mutableParameters = [dictionaryRepresentation mutableCopy];
    
    NSString *contentDescription = [self contentDescription];
    if (!parameters.contentDescription && includeContentDescription && contentDescription)
    {
        mutableParameters[MPCDKey] = contentDescription;
    }
    
    return [mutableParameters copy];
}

- (NSString *)requestStringForDictionary:(NSDictionary *)requestDictionary GAID:(NSString *)identifier
{
    NSMutableString *result = [NSMutableString stringWithFormat:@"v=1&tid=%@&an=%@&av=%@&cid=%@",
                               identifier, self.trackerInfoHelper.applicationName, self.trackerInfoHelper.applicationVersion, self.trackerInfoHelper.userIdentifier];
    for (NSString *key in requestDictionary)
    {
        NSString *stringValue = [NSString stringWithFormat:@"%@", requestDictionary[key]];
        NSString *escapedValue = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                      (__bridge CFStringRef)stringValue,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                      kCFStringEncodingUTF8);
        [result appendFormat:@"&%@=%@", key, escapedValue];
    }
    [result appendString:self.systemInfo];
    return [NSString stringWithString:result];
}

- (void)sendAnalyticsWithParameters:(NSDictionary *)parameters originalTrackingEvent:(MPTrackingRequestParams *)trackingEvent
{
    if (!self.activeConfiguration)
    {
        return;
    }
    
    NSString *eventCategory = nil;
    if ([trackingEvent isKindOfClass:[MPEventParams class]])
    {
        eventCategory = [(MPEventParams *)trackingEvent category];
    }
    
    MPAnalyticsConfiguration *activeConfiguration = self.activeConfiguration;
    
    NSArray *allIdentifiers = nil;
    BOOL shouldSendAddtionalEvent = eventCategory && activeConfiguration.addtionalEventIdentifiers[eventCategory];
    if (shouldSendAddtionalEvent)
    {
        allIdentifiers = @[ activeConfiguration.addtionalEventIdentifiers[eventCategory] ];
    }
    else
    {
        BOOL shouldDuplicateEvent = eventCategory && activeConfiguration.duplicatedEventIdentifiers[eventCategory];
        if (shouldDuplicateEvent)
        {
            allIdentifiers = @[ activeConfiguration.analyticsIdentifier, activeConfiguration.duplicatedEventIdentifiers[eventCategory] ];
        }
        else
        {
            allIdentifiers = @[ activeConfiguration.analyticsIdentifier ];
        }
    }
    
    
    NSURL *analyticsURL = [NSURL URLWithString:@"https://www.google-analytics.com/collect"];
    
    for (NSString *identifier in allIdentifiers)
    {
        NSString *requestString = [self requestStringForDictionary:parameters GAID:identifier];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:analyticsURL];
        request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
        NSURLSessionDataTask *analyticsTask = [self.session dataTaskWithRequest:request];
        [analyticsTask resume];
        
        if (self.debugEnabled)
        {
            [self debugEvent:parameters forGAID:identifier];
        }
    }
}

- (void)debugEvent:(NSDictionary *)parameters forGAID:(NSString *)identifier
{
    if (![parameters[@"t"] isEqualToString:@"event"])
    {
        return;
    }
    
    NSMutableDictionary *allParameters = [parameters mutableCopy];
    [allParameters addEntriesFromDictionary:@{ @"gaid" : identifier }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalyticsEvent" object:self userInfo:[allParameters copy]];
}

#pragma mark - Tracking Events

- (void)trackEventWithParameters:(MPEventParams *)eventParams
{
    NSDictionary *filteredParameters = [self filteredDictionaryForParameters:eventParams
                                                   includeContentDescription:YES];
    [self sendAnalyticsWithParameters:filteredParameters originalTrackingEvent:eventParams];
}

- (void)trackTimingWithParameters:(MPTimingParams *)timingParams
{
    NSDictionary *filteredParameters = [self filteredDictionaryForParameters:timingParams
                                                   includeContentDescription:YES];
    [self sendAnalyticsWithParameters:filteredParameters originalTrackingEvent:timingParams];
}

- (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value
{
    MPEventParams *eventParams = [MPParamBuilder eventParamsForCategory:category action:action
                                                                  label:label value:value];
    [self trackEventWithParameters:eventParams];
}

- (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value
          contentDescription:(NSString *)contentDescription customDimension:(NSString *)dimension
{
    MPEventParams *eventParams = [MPParamBuilder eventParamsForCategory:category action:action
                                                                  label:label value:value
                                                     contentDescription:contentDescription
                                                        customDimension:dimension];
    [self trackEventWithParameters:eventParams];
}

- (void)trackTimingOfCategory:(NSString *)category variable:(NSString *)variable
                         time:(NSNumber *)time label:(NSString *)label
{
    MPTimingParams *timingParams = [MPParamBuilder timingParamsForCategory:category variable:variable
                                                                      time:time label:label];
    [self trackTimingWithParameters:timingParams];
}

#pragma mark - Tracking Screens

- (void)trackScreen:(NSString *)screen
{
    self.currentScreen = screen;
    
    MPAppViewParams *appViewParams = [MPParamBuilder appViewParamsForScreen:screen];
    [self sendAnalyticsWithParameters:[self filteredDictionaryForParameters:appViewParams
                                                  includeContentDescription:NO]
                originalTrackingEvent:appViewParams];
}

- (void)trackModalScreen:(NSString *)modalScreen
{
    if (![self.modalScreens containsObject:modalScreen])
    {
        [self.modalScreens insertObject:modalScreen atIndex:0];

        MPAppViewParams *appViewParams = [MPParamBuilder appViewParamsForScreen:modalScreen];
        NSDictionary *filteredParameters = [self filteredDictionaryForParameters:appViewParams
                                                       includeContentDescription:NO];
        [self sendAnalyticsWithParameters:filteredParameters originalTrackingEvent:appViewParams];
    }
}

- (void)switchToModalScreen:(NSString *)modalScreen
{
    if (self.modalScreens.count > 0)
    {
        [self.modalScreens replaceObjectAtIndex:0 withObject:modalScreen];
    }
    else
    {
        [self.modalScreens insertObject:modalScreen atIndex:0];
    }
}

- (void)stopTrackingModalScreen
{
    if (self.modalScreens.count > 0)
    {
        [self.modalScreens removeObjectAtIndex:0];
        
        // track current screen if no more modal screens available
        if (self.modalScreens.count == 0)
        {
            [self trackScreen:self.currentScreen];
        }
    }
}

#pragma mark - Class Methods

+ (void)activateConfiguration:(MPAnalyticsConfiguration *)configuration
{
    [[self sharedTracker] activateConfiguration:(MPAnalyticsConfiguration *)configuration];
}

+ (void)trackEventWithParameters:(MPEventParams *)eventParams
{
    [[self sharedTracker] trackEventWithParameters:eventParams];
}

+ (void)trackTimingWithParameters:(MPTimingParams *)timingParameters
{
    [[self sharedTracker] trackTimingWithParameters:timingParameters];
}

+ (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value
{
    [[self sharedTracker] trackEventOfCategory:category action:action
                                         label:label value:value];
}

+ (void)trackEventOfCategory:(NSString *)category action:(NSString *)action
                       label:(NSString *)label value:(NSNumber *)value
          contentDescription:(NSString *)contentDescription customDimension:(NSString *)dimension
{
    [[self sharedTracker] trackEventOfCategory:category action:action label:label
                                         value:value contentDescription:contentDescription
                               customDimension:dimension];
}

+ (void)trackTimingOfCategory:(NSString *)category variable:(NSString *)variable
                         time:(NSNumber *)time label:(NSString *)label
{
    [[self sharedTracker] trackTimingOfCategory:category variable:variable time:time label:label];
}

+ (void)trackScreen:(NSString *)screen
{
    [[self sharedTracker] trackScreen:screen];
}

+ (void)trackModalScreen:(NSString *)modalScreen
{
    [[self sharedTracker] trackModalScreen:modalScreen];
}

+ (void)switchToModalScreen:(NSString *)modalScreen
{
    [[self sharedTracker] switchToModalScreen:modalScreen];
}

+ (void)stopTrackingModalScreen
{
    [[self sharedTracker] stopTrackingModalScreen];
}

@end
