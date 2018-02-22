//
//  ViewController.m
//  GoogleAnalyticsIOSSample
//
//  Created by Splenden on 2018/2/21.
//  Copyright © 2018年 MacPaw Inc. All rights reserved.
//

#import "ViewController.h"
@import GoogleAnalyticsTracker;
@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) IBOutlet UITableView *tv;

@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    MPAnalyticsConfiguration *configuration = [[MPAnalyticsConfiguration alloc] initWithAnalyticsIdentifier:@"UA-TEST-X"];
    [MPGoogleAnalyticsTracker activateConfiguration:configuration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analyticsReceived:)
                                                 name:@"AnalyticsEvent" object:nil];
    self.events = [NSMutableArray new];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)analyticsReceived:(NSNotification *)aNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.events insertObject:aNotification.userInfo atIndex:0];
        [self.tv insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (IBAction)trackEvent:(id)sender
{
    
    [MPGoogleAnalyticsTracker trackEventOfCategory:@"Interaction" action:[NSString stringWithFormat:@"iOS Button Click - %lu",(unsigned long)self.events.count]
                                             label:nil value:nil];
}

- (IBAction)trackTiming:(id)sender
{
    [MPGoogleAnalyticsTracker trackTimingOfCategory:@"Timings" variable:@"App Launch Duration"
                                               time:@100 label:@""];
}

#pragma mark - data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events?self.events.count:0;
}
static NSString * cellId = @"cell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = [self.events[indexPath.row] description];
    return cell;
}


@end
