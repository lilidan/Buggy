//
//  NSTimer+Safe.m
//  Buggy
//
//  Created by sgcy on 2018/10/9.
//

#import "NSTimer+Safe.h"
#import <objc/runtime.h>
#import "NSObject+SafeCore.h"

@interface XXTimerProxy : NSObject

@property (nonatomic, weak) NSTimer *sourceTimer;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL aSelector;

@end

@implementation XXTimerProxy

- (void)trigger:(id)userinfo  {
    id strongTarget = self.target;
    if (strongTarget && ([strongTarget respondsToSelector:self.aSelector])) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [strongTarget performSelector:self.aSelector withObject:userinfo];
#pragma clang diagnostic pop
    } else {
        NSTimer *sourceTimer = self.sourceTimer;
        if (sourceTimer) {
            [sourceTimer invalidate];
        }
        NSException *exception = [NSException exceptionWithName:@"NSTimerNotDeallocException" reason:@"NSTimerNotDealloc" userInfo:@{}];
        [XXTimerProxy safe_logCrashWithException:exception crashType:LSSafeProtectorCrashTypeNSTimerNotDealloc];
    }
}

@end


@interface NSTimer (proxy)

@property (nonatomic, strong) XXTimerProxy *timerProxy;

@end

@implementation NSTimer (proxy)

- (void)setTimerProxy:(XXTimerProxy *)timerProxy {
    objc_setAssociatedObject(self, @selector(timerProxy), timerProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XXTimerProxy *)timerProxy {
    return objc_getAssociatedObject(self, @selector(timerProxy));
}

@end


@implementation NSTimer(safe)

+ (void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=[self class];
        [self safe_exchangeClassMethod:dClass originalSel:@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:) newSel:@selector(safe_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)];
    });
}

+ (NSTimer *)safe_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    if (yesOrNo) {
        NSTimer *timer =  nil ;
        @autoreleasepool {
            XXTimerProxy *proxy = [XXTimerProxy new];
            proxy.target = aTarget;
            proxy.aSelector = aSelector;
            timer.timerProxy = proxy;
            timer = [self safe_scheduledTimerWithTimeInterval:ti target:proxy selector:@selector(trigger:) userInfo:userInfo repeats:yesOrNo];
            proxy.sourceTimer = timer;
        }
        return  timer;
    }
    return [self safe_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}


@end
