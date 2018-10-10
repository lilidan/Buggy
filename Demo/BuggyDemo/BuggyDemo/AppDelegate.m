//
//  AppDelegate.m
//
//  Created by Karl Stenerud on 2012-03-04.
//

#import "AppDelegate.h"
#import "AppDelegate+UI.h"
#import <Buggy/Buggy.h>

@interface AppDelegate()

@end


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize crasher = _crasher;

- (BOOL)application:(__unused UIApplication*) application didFinishLaunchingWithOptions:(__unused NSDictionary*) launchOptions
{
    [Buggy installWithSentryToken:@"https://c57c6ad155a04955b934e4f164e655b7@sentry.io/1279289"];
    self.crasher = [[Crasher alloc] init];
    self.crashToHanlder = [[CrashToHandle alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self createRootViewController];
    [self.window makeKeyAndVisible];
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"errorrrrtest"}];
    [Buggy reportError:error];
    return YES;
}

@end
