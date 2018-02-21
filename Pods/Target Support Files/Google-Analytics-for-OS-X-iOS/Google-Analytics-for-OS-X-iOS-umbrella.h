#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MPAnalyticsConfiguration.h"
#import "MPAnalyticsParamBuilder.h"
#import "MPGoogleAnalyticsTracker.h"
#import "TrackerHelper.h"

FOUNDATION_EXPORT double GoogleAnalyticsTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char GoogleAnalyticsTrackerVersionString[];

