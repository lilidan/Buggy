//
//  Buggy.h
//  BuggyDemo
//
//  Created by sgcy on 2018/10/8.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buggy : NSObject

+ (void)installWithSentryToken:(NSString *)sentryToken;

+ (void)reportError:(NSError *)error;
+ (void)reportError:(NSError *)error withStackFrame:(BOOL)withStackFrame;
+ (void)reportErrorWithMainStackFrame:(NSError *)error;

+ (void)reportLog;

@end
