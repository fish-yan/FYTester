//
//  FYHardware.m
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

#import "FYHardware.h"
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vm.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <mach/machine.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/stat.h>
#import <OpenGLES/ES3/gl.h>
#import <AVFoundation/AVFoundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <arpa/inet.h>
@implementation FYHardware
+ (NSString *)hardwareModel
{
    size_t size;
    char *kHwModel = "hw.model";
    sysctlbyname(kHwModel, NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname(kHwModel, answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    NSProcessInfo *info = [NSProcessInfo processInfo];
    [info activeProcessorCount];

    free(answer);
    return results;
}
+ (NSString *)cpuArch
{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);

    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);

    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86 "];
        // check for subtype ...

    } else if (type == CPU_TYPE_ARM) {
        [cpu appendString:@"ARM"];
        switch(subtype)
        {
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"V7"];
                break;
            case CPU_SUBTYPE_ARM_V4T:
                [cpu appendString:@"V4T"];
                break;
            case CPU_SUBTYPE_ARM_V6:
                [cpu appendString:@"V6"];
                break;
            case CPU_SUBTYPE_ARM_V5TEJ:
                [cpu appendString:@"V5TEJ"];
                break;
            case CPU_SUBTYPE_ARM_XSCALE:
                [cpu appendString:@"XSCALE"];
                break;
            case CPU_SUBTYPE_ARM_V7F:
                [cpu appendString:@"V7F"];
                break;
            case CPU_SUBTYPE_ARM_V7S:
                [cpu appendString:@"V7S"];
                break;
            case CPU_SUBTYPE_ARM_V7K:
                [cpu appendString:@"V7K"];
                break;
            case CPU_SUBTYPE_ARM_V6M:
                [cpu appendString:@"V6M"];
                break;
            case CPU_SUBTYPE_ARM_V7M:
                [cpu appendString:@"V7M"];
                break;
            case CPU_SUBTYPE_ARM_V7EM:
                [cpu appendString:@"V7EM"];
                break;
            case CPU_SUBTYPE_ARM_V8:
                [cpu appendString:@"V8"];
                break;
        }
    } else if( type == CPU_TYPE_ARM64 ) {
        [cpu appendString:@"ARM64"];
        switch (subtype) {
            case CPU_SUBTYPE_ARM64_V8:
                [cpu appendString:@"V8"];
                break;

            default:
                break;
        }
    }

    return cpu;
}
// GPU type
+ (NSString *) gpuType
{
    NSString *renderString = @"";
    NSInteger type = kEAGLRenderingAPIOpenGLES3;
    if ([[self platformString] isEqualToString:@"iPhone 5c"] || [[self platformString] isEqualToString:@"iPhone 5"] ) {
        type = kEAGLRenderingAPIOpenGLES2;
    }

    EAGLContext *context = [[EAGLContext alloc] initWithAPI:type];
    EAGLContext *currentContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:context]; // 1

    char *render = (char *)glGetString(GL_RENDERER);
    if( render ) {
        renderString = [NSString stringWithUTF8String: render];
        renderString = [renderString stringByReplacingOccurrencesOfString:@"Apple " withString: @""];
    }
    [EAGLContext setCurrentContext: currentContext]; // 1
    return renderString;

}
+ (NSString *)ramCapacity {
    unsigned long long ram = [NSProcessInfo processInfo].physicalMemory;

    return [self formatRamSizeInG: ram];
}

+ (NSString *) formatRamSizeInG: (unsigned long long)capacity
{

    unsigned long long freespace = capacity / 1024 / 1024;
    NSString *ret = nil;


    unsigned long long start = 128;

    if (freespace <= start * 2) {
        ret = [NSString stringWithFormat: @"%quM", start * 2];
    }else if (freespace > start * 2 && freespace <= start * 4) {
        ret = [NSString stringWithFormat: @"%quM", start * 4];
    }else if (freespace > start * 4 && freespace <= start * 8) {
        ret = [NSString stringWithFormat: @"%quG", start * 8 / 1024 ];
    }else if (freespace > start * 8 && freespace <= start * 16) {
        ret = [NSString stringWithFormat: @"%quG", start * 16 / 1024 ];
    }else if (freespace > start * 16 && freespace <= start * 24) {
        ret = [NSString stringWithFormat: @"%quG", start * 24 / 1024 ];
    }else if (freespace > start * 24 && freespace <= start * 32) {
        ret = [NSString stringWithFormat: @"%quG", start * 32 / 1024 ];
    }else if (freespace > start * 32 && freespace <= start * 40) {
        ret = [NSString stringWithFormat: @"%quG", start * 40 / 1024 ];
    }else if (freespace > start * 40 && freespace <= start * 48) {
        ret = [NSString stringWithFormat: @"%quG", start * 48 / 1024 ];
    };

    return ret;
}
+ (NSString *)screenResolution
{
    NSString *resolution = @"";

    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
        CGRect rect_screen = [[UIScreen mainScreen] nativeBounds];
        CGSize size_screen = rect_screen.size;

        resolution = [NSString stringWithFormat: @"%dx%d", (int)(size_screen.height), (int)(size_screen.width)];
    } else {
        CGRect rect_screen = [[UIScreen mainScreen] bounds];
        CGSize size_screen = rect_screen.size;

        CGFloat scale = [[UIScreen mainScreen] scale];

        resolution = [NSString stringWithFormat: @"%dx%d", (int)(scale*size_screen.height), (int)(scale*size_screen.width)];
    }
    return resolution;
}
+ (NSString *) backCameraResolution
{
    CMVideoDimensions max = [self getCameraMaxStillImageResolution: AVCaptureDevicePositionBack];
    return [NSString stringWithFormat: @"%dx%d",max.width, max.height];
}
+ (NSString *) frontCameraResolution
{
    CMVideoDimensions max = [self getCameraMaxStillImageResolution: AVCaptureDevicePositionFront];
    return [NSString stringWithFormat: @"%dx%d",max.width, max.height];
}
+ (CMVideoDimensions) getCameraMaxStillImageResolution:(AVCaptureDevicePosition) cameraPosition {

    CMVideoDimensions max_resolution;
    max_resolution.width = 0;
    max_resolution.height = 0;

    AVCaptureDevice *captureDevice = nil;

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == cameraPosition) {
            captureDevice = device;
            break;
        }
    }
    if (captureDevice == nil) {
        return max_resolution;
    }

    NSArray* availFormats=captureDevice.formats;

    for (AVCaptureDeviceFormat* format in availFormats) {
        CMVideoDimensions resolution = format.highResolutionStillImageDimensions;
        int w = resolution.width;
        int h = resolution.height;
        if ((w * h) > (max_resolution.width * max_resolution.height)) {
            max_resolution.width = w;
            max_resolution.height = h;
        }
    }

    return max_resolution;
}

+ (NSString *) platformString {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);

    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";

    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";

    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";

    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";

    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";

    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";

    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 plus";

    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8 plus";
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8 plus";

    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X";

    if ([platform isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max";//A2104
    if ([platform isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";//A1921,A2101,A2102,
    if ([platform isEqualToString:@"iPhone11,8"])    return @"iPhone XR";

    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";

    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+WCDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+WCDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+WCDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini4";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini4";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";

    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (12.9 inch)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (12.9 inch)";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro (9.7 inch)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro (9.7 inch)";
    if ([platform isEqualToString:@"iPad6,11"])     return @"iPad 5";
    if ([platform isEqualToString:@"iPad6,12"])     return @"iPad 5 (Cellular)";
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro 2 (12.9 inch)";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro 2 (12.9 inch)";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5 inch)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5 inch)";
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6";//A1893 WIFI
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6 (Cellular)";//A1954 WIFI+Cellular

    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    if( platform == nil || [platform length] == 0 ) {
        platform = @"Unknown";
    }
    return platform;
}
+ (BOOL) touch3DAvailable
{
    BOOL isAvail = NO;
    if( [[[UIApplication sharedApplication].delegate window] respondsToSelector: @selector(traitCollection) ]) {
        if( [[UIApplication sharedApplication].delegate window].traitCollection ) {

            if( [[[UIApplication sharedApplication].delegate window].traitCollection respondsToSelector:
                 @selector(forceTouchCapability)]) {

                if (@available(iOS 9.0, *)) {
                    if(UIForceTouchCapabilityAvailable == [[UIApplication sharedApplication].delegate window].traitCollection.forceTouchCapability ) {

                        isAvail = YES;
                    }
                }
            }
        }
    }
    return isAvail;
}
+ (BOOL)biometryAvailable {
    BOOL support = YES;
    NSError *authError = nil;

    LAContext *myContext = [[LAContext alloc] init];
    if( myContext != nil ) {
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {

        } else {
            if( authError.code == LAErrorTouchIDNotAvailable ) {
                support = NO;
            }else if (authError.code == LAErrorPasscodeNotSet ) {
                if (sizeof(void*) == 4) support = NO;
            }
        }
    } else {
        support = NO;
    }

    return support;
}

+ (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
}

+ (NSString *)romCapacity {
    struct statfs buf1;
    long long freespace = -1;
    if(statfs("/var", &buf1) >= 0){
        freespace = (long long)(buf1.f_bsize * (buf1.f_blocks));
    }

    if( freespace <= (long long)8*1024*1024*1024 ) {
        freespace = (long long)8*1024*1024*1024;
    } else if( freespace <= (long long)16*1024*1024*1024 ) {
        freespace = (long long)16*1024*1024*1024;
    } else if( freespace <= (long long)32*1024*1024*1024 ) {
        freespace = (long long)32*1024*1024*1024;
    } else if( freespace <= (long long)64*1024*1024*1024 ) {
        freespace = (long long)64*1024*1024*1024;
    } else if( freespace <= (long long)128*1024*1024*1024 ) {
        freespace = (long long)128*1024*1024*1024;
    } else if( freespace <= (long long)256*1024*1024*1024 ) {
        freespace = (long long)256*1024*1024*1024;
    } else if( freespace <= (long long)512*1024*1024*1024 ) {
        freespace = (long long)512*1024*1024*1024;
    } else if( freespace <= (long long)1024*1024*1024*1024 ) {
        freespace = (long long)1024*1024*1024*1024;
    }
    return [NSString stringWithFormat:@"%qiGB" ,freespace/1024/1024/1024];
}

+ (BOOL)isDeviceJailbroken
{

#if !TARGET_IPHONE_SIMULATOR

    //Apps and System check list
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Cyd", @"ia.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"bla", @"ckra1n.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Fake", @"Carrier.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Ic", @"y.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Inte", @"lliScreen.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"MxT", @"ube.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Roc", @"kApp.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"SBSet", @"ttings.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Wint", @"erBoard.a", @"pp"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/l", @"ib/a", @"pt/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/l", @"ib/c", @"ydia/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/mobile", @"Library/SBSettings", @"Themes/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/t", @"mp/cyd", @"ia.log"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/s", @"tash/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"us", @"r/l",@"ibe", @"xe", @"c/cy", @"dia/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"us", @"r/b",@"in", @"s", @"shd"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"us", @"r/sb",@"in", @"s", @"shd"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"us", @"r/l",@"ibe", @"xe", @"c/cy", @"dia/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"us", @"r/l",@"ibe", @"xe", @"c/sftp-", @"server"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@",@"/Syste",@"tem/Lib",@"rary/Lau",@"nchDae",@"mons/com.ike",@"y.bbot.plist"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@%@",@"/Sy",@"stem/Lib",@"rary/Laun",@"chDae",@"mons/com.saur",@"ik.Cy",@"@dia.Star",@"tup.plist"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"/Libr",@"ary/Mo",@"bileSubstra",@"te/MobileSubs",@"trate.dylib"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"/va",@"r/c",@"ach",@"e/a",@"pt/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@", @"/va",@"r/l",@"ib",@"/apt/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@", @"/va",@"r/l",@"ib/c",@"ydia/"] isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@", @"/va",@"r/l",@"og/s",@"yslog"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@", @"/bi",@"n/b",@"ash"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@", @"/b",@"in/",@"sh"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@", @"/et",@"c/a",@"pt/"]isDirectory:&isDirectory]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@", @"/etc/s",@"sh/s",@"shd_config"]]
        || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@", @"/us",@"r/li",@"bexe",@"c/ssh-k",@"eysign"]])

    {
        return YES;
    }

    // SandBox Integrity Check
    int pid = fork();
    if(!pid){
        exit(0);
    }
    if(pid>=0)
    {
        return YES;
    }

    //Symbolic link verification
    struct stat s;
    if(lstat("/Applications", &s) || lstat("/var/stash/Library/Ringtones", &s) || lstat("/var/stash/Library/Wallpaper", &s)
       || lstat("/var/stash/usr/include", &s) || lstat("/var/stash/usr/libexec", &s)  || lstat("/var/stash/usr/share", &s) || lstat("/var/stash/usr/arm-apple-darwin9", &s))
    {
        if(s.st_mode & S_IFLNK){
            return YES;
        }
    }

    //Try to write file in private
    NSError *error;

    [[NSString stringWithFormat:@"Jailbreak test string"]
     writeToFile:@"/private/test_jb.txt"
     atomically:YES
     encoding:NSUTF8StringEncoding error:&error];

    if(nil==error){
        //Wrote?: JB device
        //cleanup what you wrote
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
        return YES;
    }
#endif
    return NO;
}

+ (NSString *)wifiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }

    return @"";
}

+ (unsigned int)countOfCores {
    unsigned int ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);

    return ncpu;
}
@end
