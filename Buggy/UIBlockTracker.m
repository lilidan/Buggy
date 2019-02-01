//
//  UIBlockTracker.m
//  Buggy
//
//  Created by sgcy on 2018/10/12.
//

#import "UIBlockTracker.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>

#import "Buggy.h"


@interface UIBlockTracker ()
{
    int timeoutCount;
    CFRunLoopObserverRef observer;
    
@public
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
}

@property (nonatomic,strong) NSDate *lastReportTime;

@end

@implementation UIBlockTracker

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    
    if (activity == kCFRunLoopBeforeWaiting) {
        NSLog(@"------------------%f",CACurrentMediaTime());
    }
    if (activity == kCFRunLoopAfterWaiting) {
        NSLog(@"======%f",CACurrentMediaTime());
    }
    
    
//    UIBlockTracker *moniotr = (__bridge UIBlockTracker*)info;
//
//    moniotr->activity = activity;
//    dispatch_semaphore_t semaphore = moniotr->semaphore;
//    dispatch_semaphore_signal(semaphore);
}

- (void)stop
{
    if (!observer)
        return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = NULL;
}

- (void)start
{
    if (observer)
        return;
    
    // 信号
    semaphore = dispatch_semaphore_create(0);
    
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAfterWaiting|kCFRunLoopBeforeWaiting
                                                            
                                                            ,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
//
//    // 在子线程监控时长
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        while (YES)
//        {
//            long st = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 100*NSEC_PER_MSEC));
//            if (st != 0)
//            {
//                if (!observer)
//                {
//                    timeoutCount = 0;
//                    semaphore = 0;
//                    activity = 0;
//                    return;
//                }
//
//
//                if (activity==kCFRunLoopBeforeSources || activity==kCFRunLoopAfterWaiting)
//                {
//                    if (++timeoutCount < 5)
//                        continue;
//
//                    if (!self.lastReportTime || [[NSDate date] timeIntervalSinceDate:self.lastReportTime] > 10.f) {
//                        NSError *error = [NSError errorWithDomain:@"UIApplicationDidMainRunloopBlock4" code:6667 userInfo:@{NSLocalizedDescriptionKey:@"UIApplicationDidMainRunloopBlock4",@"cpuUsage":@([self getCpuUsage])}];
//                        [Buggy reportErrorWithMainStackFrame:error];
//                    }
//                    self.lastReportTime = [NSDate date];
//                }
//
//            }
//            timeoutCount = 0;
//        }
//    });
}



- (void)handleTick
{
    [self getCpuUsage];
}

- (float)getCpuUsage
{
    kern_return_t           kr;
    thread_array_t          thread_list;
    mach_msg_type_number_t  thread_count;
    thread_info_data_t      thinfo;
    mach_msg_type_number_t  thread_info_count;
    thread_basic_info_t     basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    float cpu_usage = 0;
    
    for (int i = 0; i < thread_count; i++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            cpu_usage += basic_info_th->cpu_usage;
        }
    }
    
    cpu_usage = cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return cpu_usage;
}


@end
