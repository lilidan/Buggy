//
//  Buggy.m
//  BuggyDemo
//
//  Created by sgcy on 2018/10/8.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "Buggy.h"

#import <Sentry/Sentry.h>
#import <Sentry/SentryBreadcrumbTracker.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "LSSafeProtector.h"

#if DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@interface Buggy()

@property (nonatomic,strong) DDFileLogger *logger;

@end

@implementation Buggy

+ (instancetype)sharedInstance
{
    static Buggy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ 
        sharedInstance = [[Buggy alloc] init];
    });
    return sharedInstance;
}

+ (void)installWithSentryToken:(NSString *)sentryToken
{
    [[self sharedInstance] installCrashHandlerWithSentryToken:sentryToken];
}

- (void)installCrashHandlerWithSentryToken:(NSString *)sentryToken
{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    [DDLog addLogger:fileLogger];
    self.logger = fileLogger;
    
    NSError *error = nil;
    SentryClient *client = [[SentryClient alloc] initWithDsn:sentryToken didFailWithError:&error];
    SentryClient.sharedClient = client;
    SentryClient.sharedClient.extra = [self queryDDLog];
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    if (nil != error) {
        NSLog(@"%@", error);
    }
    [LSSafeProtector openSafeProtectorWithIsDebug:NO block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
        
    }];
}

- (NSDictionary *)queryDDLog
{
    NSInteger segmentLength = 17;//kb
    NSInteger totalLength = 40;
    NSInteger segmentCount = totalLength / segmentLength;
    NSArray<DDLogFileInfo *> *logInfos = self.logger.logFileManager.sortedLogFileInfos;
    if (logInfos.count < 1) {
        return @{};
    }
    DDLogFileInfo *lastInfo = logInfos.firstObject;
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:lastInfo.filePath];
    NSData *lastData = [fileHandler readDataToEndOfFile];
    if (logInfos.count >= 2 && lastInfo.fileSize < 1024 * totalLength) {
        DDLogFileInfo *recentInfo = [logInfos objectAtIndex:1];
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:recentInfo.filePath];
        NSMutableData *recentData = [[fileHandler readDataToEndOfFile] mutableCopy];
        [recentData appendData:lastData];
        lastData = [recentData copy];
    }
    NSString *logStr = [[NSString alloc] initWithData:lastData encoding:NSUTF8StringEncoding];
    if (logStr.length > 1024 * totalLength) {
        logStr = [logStr substringFromIndex:logStr.length - 1024 * totalLength];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSInteger residual = logStr.length % (segmentLength * 1024);
    if (residual > 0) {
        segmentCount = logStr.length / (segmentLength * 1024) + 1;
    }
    for (int i = 0 ; i < segmentCount ; i++) {
        NSString *key = [NSString stringWithFormat:@"log%d",i];
        NSInteger loc = i * segmentLength * 1024;
        NSInteger length = segmentLength * 1024;
        if (logStr.length < loc + length) {
            length = residual;
        }
        NSString *value = [logStr substringWithRange:NSMakeRange(loc, length)];
        [dic setObject:value forKey:key];
    }
    return [dic copy];
}

+ (void)reportError:(NSError *)error
{
    
}

@end
