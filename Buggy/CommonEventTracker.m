//
//  CommonEventTracker.m
//  Buggy
//
//  Created by sgcy on 2018/10/11.
//

#import "CommonEventTracker.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <Sentry/Sentry.h>

#if DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@implementation CommonEventTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(event:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [self swizzleSendAction];
        [self swizzleViewDidAppear];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)swizzleSendAction {
    static const void *swizzleSendActionKey = &swizzleSendActionKey;
    //    - (BOOL)sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event;
    SEL selector = NSSelectorFromString(@"sendAction:to:from:forEvent:");
    SentrySwizzleInstanceMethod(UIApplication.class,
                                selector,
                                SentrySWReturnType(BOOL),
                                SentrySWArguments(SEL action, id target, id sender, UIEvent * event),
                                SentrySWReplacement({
        if (nil != SentryClient.sharedClient) {
            NSString *logInfo = @"TouchEvent:";
            for (UITouch *touch in event.allTouches) {
                if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded) {
                    logInfo = [logInfo stringByAppendingFormat:@"View:%@",touch.view];
                }
            }
            
            logInfo = [logInfo stringByAppendingFormat:@"Action:%s", sel_getName(action)];
            DDLogInfo(logInfo);
        }
        return SentrySWCallOriginal(action, target, sender, event);
    }), SentrySwizzleModeOncePerClassAndSuperclasses, swizzleSendActionKey);
}

- (void)swizzleViewDidAppear {
    static const void *swizzleViewDidAppearKey = &swizzleViewDidAppearKey;
    SEL selector = NSSelectorFromString(@"viewDidAppear:");
    SentrySwizzleInstanceMethod(UIViewController.class,
                                selector,
                                SentrySWReturnType(void),
                                SentrySWArguments(BOOL animated),
                                SentrySWReplacement({
        if (nil != SentryClient.sharedClient) {
            NSString *viewControllerName = [CommonEventTracker sanitizeViewControllerName:[NSString stringWithFormat:@"%@", self]];
            NSString *logInfo = [NSString stringWithFormat:@"ViewDidAppear:%@-%@",viewControllerName,[self title]];
            DDLogInfo(logInfo);
        }
        SentrySWCallOriginal(animated);
    }), SentrySwizzleModeOncePerClassAndSuperclasses, swizzleViewDidAppearKey);
}

- (void)event:(NSNotification *)notification
{
    DDLogInfo(notification.name);
}

+ (NSRegularExpression *)viewControllerRegex {
    static dispatch_once_t onceTokenRegex;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceTokenRegex, ^{
        NSString *pattern = @"[<.](\\w+)";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    });
    return regex;
}

+ (NSString *)sanitizeViewControllerName:(NSString *)controller {
    NSRange searchedRange = NSMakeRange(0, [controller length]);
    NSArray *matches = [[self.class viewControllerRegex] matchesInString:controller options:0 range:searchedRange];
    NSMutableArray *strings = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        [strings addObject:[controller substringWithRange:[match rangeAtIndex:1]]];
    }
    if ([strings count] > 0) {
        return [strings componentsJoinedByString:@"."];
    }
    return controller;
}


@end
