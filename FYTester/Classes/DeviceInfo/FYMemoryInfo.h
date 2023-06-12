//
//  FYMemoryInfo.h
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FYMemoryInfo : NSObject

+ (uint64_t)memoryTotal;
// Free Memory
+ (uint64_t)memoryFree;

// Used Memory
+ (uint64_t)memoryUsed;

// App Memory
+ (uint64_t)memoryAppUsed;

@end

NS_ASSUME_NONNULL_END
