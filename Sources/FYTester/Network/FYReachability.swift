//
//  FYReachablity.swift
//  FYTester
//
//  Created by yan on 2025-04-27.
//

import UIKit
import SystemConfiguration

enum FYNetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}

@objcMembers
class FYReachability {
    private let reachability: SCNetworkReachability
    
    public convenience init?() {
        var zero = sockaddr()
        zero.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zero.sa_family = sa_family_t(AF_INET)

        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zero) else { return nil }

        self.init(reachability: reachability)
    }
    
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }

        self.init(reachability: reachability)
    }
    
    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
    }
    
    func currentReachabilityStatus() -> FYNetworkStatus {
        var returnValue: FYNetworkStatus = .notReachable
        var flags: SCNetworkReachabilityFlags = []

        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            returnValue = networkStatus(for: flags)
        }

        return returnValue
    }
    
    func networkStatus(for flags: SCNetworkReachabilityFlags) -> FYNetworkStatus {
        if (flags.contains(.reachable)) == false {
            // The target host is not reachable.
            return .notReachable
        }

        var returnValue: FYNetworkStatus = .notReachable

        if (flags.contains(.connectionRequired)) == false {
            /*
             If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
             */
            returnValue = .reachableViaWiFi
        }

        if (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)) {
            /*
             ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
             */

            if (flags.contains(.interventionRequired)) == false {
                /*
                 ... and no [user] intervention is needed...
                 */
                returnValue = .reachableViaWiFi
            }
        }

        if flags.contains(.isWWAN) {
            /*
             ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
             */
            returnValue = .reachableViaWWAN
        }

        return returnValue
    }
}
