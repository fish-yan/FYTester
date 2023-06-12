//
//  FYHardware.h
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FYHardware : NSObject
+ (NSString *)hardwareModel;

+ (BOOL)biometryAvailable;

+ (BOOL)touch3DAvailable;

+ (NSString *)backCameraResolution;

+ (NSString *)frontCameraResolution;

+ (NSString *)screenResolution;

+ (NSString *)ramCapacity;

+ (NSString *)gpuType;

+ (NSString *)cpuArch;

+ (NSString *)deviceModel;

+ (NSString *)romCapacity;

+ (NSString *)wifiIPAddress;

+ (BOOL)isDeviceJailbroken;

+ (unsigned int)countOfCores;
@end

NS_ASSUME_NONNULL_END
