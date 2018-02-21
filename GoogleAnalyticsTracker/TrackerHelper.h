//
//  TrackerHelper.h
//  Google-Analytics-for-OS-X-macOS
//
//  Created by Splenden on 2018/2/21.
//

#import <Foundation/Foundation.h>

@interface TrackerHelper : NSObject
- (NSString * _Nonnull)userIdentifier;

- (NSString * _Nonnull)userAgentString;

- (NSString * _Nonnull)systemInfo;

- (NSString * _Nonnull)applicationName;

- (NSString * _Nonnull)applicationVersion;
@end
