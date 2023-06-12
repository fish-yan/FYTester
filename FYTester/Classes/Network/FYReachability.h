//
//  FYReachability.h
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
typedef NS_ENUM(NSInteger, FYNetworkStatus) {
    FYNotReachable = 0,
    FYReachableViaWiFi,
    FYReachableViaWWAN
};

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NS_ASSUME_NONNULL_BEGIN

@interface FYReachability : NSObject

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;


- (FYNetworkStatus)currentReachabilityStatus;
@end

NS_ASSUME_NONNULL_END
