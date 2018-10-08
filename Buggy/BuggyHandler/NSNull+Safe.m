//
//  NSNull+Safe.m
//  Buggy
//
//  Created by sgcy on 2018/10/9.
//

#import "NSNull+Safe.h"
#import "NSObject+SafeCore.h"

@implementation NSNull(Safe)

+ (void)openSafeProtector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=[self class];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(forwardingTargetForSelector:) newSel:@selector(safe_forwardingTargetForSelector:)];
    });
}

//NSNull是可以接受部分消息的
- (id)safe_forwardingTargetForSelector:(SEL)aSelector
{
    static NSArray *sTmpOutput = nil;
    if (sTmpOutput == nil) {
        sTmpOutput = @[@"", @0, @[], @{}];
    }
    
    for (id tmpObj in sTmpOutput) {
        if ([tmpObj respondsToSelector:aSelector]) {
            return tmpObj;
        }
    }
    NSException *exception = [NSException exceptionWithName:@"NSNullMessageException" reason:@"SendingMessageToNSNull" userInfo:@{}];
    [NSObject safe_logCrashWithException:exception crashType:LSSafeProtectorCrashTypeUIViewMainThread];
    return [self safe_forwardingTargetForSelector:aSelector];
}


@end
