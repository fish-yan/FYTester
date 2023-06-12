//
//  FYMemoryInfo.m
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

#import "FYMemoryInfo.h"
// stat
#import <sys/stat.h>

// mach
#import <mach/mach.h>
typedef NS_ENUM(NSInteger, NaturalType) {
    NaturalTypeFree = 0,
    NaturalTypeActive,
    NaturalTypeInactive,
    NaturalTypeWire,
    NaturalTypePurgeable
};

@implementation FYMemoryInfo
// Total MEmory
+ (uint64_t)memoryTotal {
    @try {
        return (uint64_t)[NSProcessInfo processInfo].physicalMemory;
    } @catch (NSException *exception) {
        return 0;
    }
}

// Free Memory
+ (uint64_t)memoryFree {
    return [self memoryWith:NaturalTypeFree];
}

// Used Memory
+ (uint64_t)memoryUsed {
    uint64_t active = [self memoryWith:NaturalTypeActive];
    uint64_t inactive = [self memoryWith:NaturalTypeInactive];
    uint64_t wire = [self memoryWith:NaturalTypeWire];
    uint64_t purgeable = [self memoryWith:NaturalTypePurgeable];
    return active + inactive + wire + purgeable;
}

+ (uint64_t)memoryWith:(NaturalType)type {
    // Find the total amount of free memory
    @try {
        // Set up the variables
        uint64_t memory = 0;
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);

        if(kernReturn != KERN_SUCCESS) {
            return 0;
        }
        switch (type) {
            case NaturalTypeFree:
                memory = vm_page_size * vmStats.free_count;
                break;
            case NaturalTypeActive:
                memory = vm_page_size * vmStats.active_count;
                break;
            case NaturalTypeInactive:
                memory = vm_page_size * vmStats.inactive_count;
                break;
            case NaturalTypeWire:
                memory = vm_page_size * vmStats.wire_count;
                break;
            case NaturalTypePurgeable:
                memory = vm_page_size * vmStats.purgeable_count;
                break;
            default:
                break;
        }
        if (memory <= 0) {
            return 0;
        }
        return memory;
    }
    @catch (NSException *exception) {
        return 0;
    }
}

/// app 占用内存
/// 参考资料 http://www.samirchen.com/ios-app-memory-usage/
+ (uint64_t)memoryAppUsed {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS){
        return (uint64_t) vmInfo.phys_footprint;;
    }else{
        return 0;
    }
}

@end
