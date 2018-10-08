//
//  UINavigationController+NestedPushCrashSafety.m
//  DrLightDemo
//
//  Created by apple on 2017/2/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "UINavigationController+NestedPushCrashSafety.h"
#import "NSObject+SafeCore.h"


static const void *navStackChangeIntervalKey=&navStackChangeIntervalKey;
static const void *navStackLastChangedTimeKey=&navStackLastChangedTimeKey;


@implementation UINavigationController (NestedPushCrashSafety)

+(void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        [self safe_exchangeInstanceMethod:class originalSel:@selector(pushViewController:animated:) newSel:@selector(zy_pushViewController:animated:)];
    });
}


- (NSTimeInterval)navStackChangeInterval
{
    return 0.1;
}

- (NSTimeInterval)navStackLastChangedTime
{
    NSTimeInterval time = [objc_getAssociatedObject(self, navStackLastChangedTimeKey) doubleValue];

    return time;
}

- (void)setNavStackLastChangedTime:(NSTimeInterval)navStackLastChangedTime
{
    objc_setAssociatedObject(self, navStackLastChangedTimeKey, @(navStackLastChangedTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)zy_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
 
    if (viewController == self.topViewController) {
        NSException *exception = [NSException exceptionWithName:@"PushPushException" reason:@"UINavigationControllerPushSameViewController" userInfo:@{}];
        [[self class] safe_logCrashWithException:exception crashType:LSSafeProtectorCrashTypeUINavigationPush];
        return;
    }
    
    NSTimeInterval now = CACurrentMediaTime();
    if (now - self.navStackLastChangedTime < self.navStackChangeInterval){
        NSException *exception = [NSException exceptionWithName:@"PushPushException" reason:@"UINavigationControllerPushTooFast" userInfo:@{}];
        [[self class] safe_logCrashWithException:exception crashType:LSSafeProtectorCrashTypeUINavigationPush];
        return;
    }

    self.navStackLastChangedTime = now;

    [self pushViewControllerInMainQueue:viewController animated:animated];
}

-(void)pushViewControllerInMainQueue:(UIViewController *)viewController animated:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self zy_pushViewController:viewController animated:animated];
                   });
}



@end
