//
//  ViewController.m
//  GoogleAnalyticsSample
//
//  Created by Denis Stas on 12/13/15.
//  Copyright © 2015 MacPaw Inc. All rights reserved.
//

#import "ViewController.h"

@import GoogleAnalyticsTracker;
@interface ViewController()
@property (nonatomic) NSUInteger eventCount;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MPAnalyticsConfiguration *configuration = [[MPAnalyticsConfiguration alloc] initWithAnalyticsIdentifier:@"UA-TEST-X"];
    [MPGoogleAnalyticsTracker activateConfiguration:configuration];
    self.eventCount = 0;
}

- (IBAction)trackEvent:(id)sender
{
    [MPGoogleAnalyticsTracker trackEventOfCategory:@"Interaction" action:[NSString stringWithFormat:@"OSX Button Click - %lu",(unsigned long)self.eventCount]
                                             label:nil value:nil];
    self.eventCount += 1;
}

- (IBAction)trackTiming:(id)sender
{
    [MPGoogleAnalyticsTracker trackTimingOfCategory:@"Timings" variable:@"App Launch Duration"
                                               time:@100 label:@""];
}

- (IBAction)showDebugWindow:(id)sender
{
    [MPAnalyticsDebugWindowController showWindow:sender];
}

@end

