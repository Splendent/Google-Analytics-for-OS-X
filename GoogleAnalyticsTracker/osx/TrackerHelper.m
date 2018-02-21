//
//  TrackerHelper.m
//  Google-Analytics-for-OS-X-macOS
//
//  Created by Splenden on 2018/2/21.
//

#import "TrackerHelper.h"
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
        NSString *serialNumber = NULL;
        io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
        
        if (platformExpert)
        {
            serialNumber = (__bridge_transfer NSString *)IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
            IOObjectRelease(platformExpert);
        }
        
        NSString *userIdentifier = NSUserName();
        NSString *userOnSystemIdentifier = [NSString stringWithFormat:@"%@%@", serialNumber, userIdentifier];
        _userIdentifier = [[userOnSystemIdentifier dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    }
    
    return _userIdentifier;
}

- (NSString *)userAgentString
{
    if (!_userAgentString)
    {
        WebView * webView = [[WebView alloc] initWithFrame:NSRectFromCGRect(CGRectZero)];
        NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        _userAgentString = secretAgent?secretAgent:@"Unknown-userAgentString";
    }
    
    return _userAgentString;
}

- (NSString *)systemInfo
{
    if (!_systemInfo)
    {
        NSRect screenFrame = NSScreen.mainScreen.frame;
        NSString *preferredLanguage = NSLocale.preferredLanguages[0];
        _systemInfo = [NSString stringWithFormat:@"&sr=%ldx%ld&ul=%@",
                       (NSInteger)NSWidth(screenFrame), (NSInteger)NSHeight(screenFrame),
                       preferredLanguage];
    }
    
    return _systemInfo;
}

- (NSString *)applicationName
{
    if (!_applicationName)
    {
        NSString *applicationName = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        _applicationName = applicationName ?: @"Unknown";
    }
    
    return _applicationName;
}

- (NSString *)applicationVersion
{
    if (!_applicationVersion)
    {
        NSMutableString *result = [NSMutableString string];
        NSString *versionString = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        [result appendString:versionString ?: @"Unknown"];
#ifdef DEBUG
        [result appendString:@"-debug"];
#endif
        
        _applicationVersion = [result copy];
    }
    
    return _applicationVersion;
}
@end
