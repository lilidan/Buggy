//
//  MemoryTracker.m
//  Buggy
//
//  Created by sgcy on 2018/10/13.
//

#import "MemoryTracker.h"

#import <malloc/malloc.h>
#import <mach/mach_host.h>
#import <mach/task.h>
#import "Buggy.h"

@implementation MemoryTracker

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    double maxMemory = [self appMaxMemory];
    double usageMemory = [self appUsageMemory];
    double footprint = [self appFootPrint];
    NSError *error = [NSError errorWithDomain:@"UIApplicationDidReceiveMemoryWarningNotification" code:6666 userInfo:@{NSLocalizedDescriptionKey:UIApplicationDidReceiveMemoryWarningNotification,@"appMaxMemory":@(maxMemory),@"appUsageMemory":@(usageMemory),@"appFootPrint":@(footprint)}];
    [Buggy reportError:error];
}

- (double)appMaxMemory
{
    mach_task_basic_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

- (double)appUsageMemory
{
    mach_task_basic_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.resident_size_max / 1024.0 / 1024.0;
}

- (double)appFootPrint
{
    task_vm_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.phys_footprint / 1024.0 / 1024.0 / 1024.0 / 1024.0;
}

@end
