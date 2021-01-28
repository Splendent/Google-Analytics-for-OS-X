//
//  TrackerHelper.m
//  Google-Analytics-for-OS-X-macOS
//
//  Created by Splenden on 2018/2/21.
//

#import "TrackerHelper.h"
@import UIKit;
@import WebKit;
@interface TrackerHelper()
/* Application-specific information */
@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationVersion;

/* User-specific information */
@property (nonatomic, strong) NSString *userIdentifier;
@property (nonatomic, strong) NSString *userAgentString;
@property (nonatomic, strong) NSString *systemInfo;
@end
@implementation TrackerHelper
- (NSString *)userIdentifier
{
    if (!_userIdentifier)
    {
        _userIdentifier = [UIDevice currentDevice].identifierForVendor?[UIDevice currentDevice].identifierForVendor.UUIDString:@"Unknown-UUID";
    }
    
    return _userIdentifier;
}

- (NSString *)userAgentString
{
    if (!_userAgentString)
    {
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        NSString *secretAgent = [wkWebView valueForKey:@"userAgent"];
        _userAgentString = secretAgent?secretAgent:@"Unknown-userAgentString";
    }
    
    return _userAgentString;
}

- (NSString *)systemInfo
{
    if (!_systemInfo)
    {
        CGRect screenFrame = UIScreen.mainScreen.bounds     ;
//        NSRect screenFrame = NSScreen.mainScreen.frame;
        NSString *preferredLanguage = NSLocale.preferredLanguages[0];
        _systemInfo = [NSString stringWithFormat:@"&sr=%ldx%ld&ul=%@",
                       (NSInteger)CGRectGetWidth(screenFrame), (NSInteger)CGRectGetHeight(screenFrame),
                       preferredLanguage];
    }
    
    return _systemInfo;
}

- (NSString *)applicationName
{
    if (!_applicationName)
    {
        NSString *applicationName = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        _applicationName = applicationName ?: @"Unknown-AppName";
    }
    
    return _applicationName;
}

- (NSString *)applicationVersion
{
    if (!_applicationVersion)
    {
        NSMutableString *result = [NSMutableString string];
        NSString *versionString = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        [result appendString:versionString ?: @"Unknown-AppVersion"];
#ifdef DEBUG
        [result appendString:@"-debug"];
#endif
        
        _applicationVersion = [result copy];
    }
    
    return _applicationVersion;
}
@end

