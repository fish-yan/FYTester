//
//  FYCPU.m
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

#import "FYCPU.h"
#import <mach/mach.h>

@implementation FYCPU

/// 核心函数
/// 1. 使用task_threads函数，获取当前App进程中所有的线程列表
/// 2. 对于第一步中获取的线程列表进行遍历，通过thread_info函数获取每一个非闲置线程的cpu使用率，进行相加
/// 3. 使用vm_deallocate函数释放资源
+ (CGFloat)cpuUsage {
    kern_return_t kr;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;

    // get threads in the task
    //  获取当前进程中 线程列表
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
        return -1;

    float tot_cpu = 0;

    for (int j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        //获取每一个线程信息
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
            return -1;

        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            // cpu_usage : Scaled cpu usage percentage. The scale factor is TH_USAGE_SCALE.
            //宏定义TH_USAGE_SCALE返回CPU处理总频率：
            tot_cpu += basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    } // for each thread

    // 注意方法最后要调用 vm_deallocate，防止出现内存泄漏
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    if (tot_cpu < 0) {
        tot_cpu = 0.;
    }

    return tot_cpu;
}
@end
