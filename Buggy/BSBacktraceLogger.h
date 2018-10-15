//
//  BSBacktraceLogger.h
//  BSBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BSLOG NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfCurrentThread]);
#define BSLOG_MAIN NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfMainThread]);
#define BSLOG_ALL NSLog(@"%@",[BSBacktraceLogger bs_backtraceOfAllThread]);

@interface BSBacktraceLogger : NSObject

+ (NSArray *)bs_backtraceOfAllThread;
+ (NSArray *)bs_backtraceOfCurrentThread;
+ (NSArray *)bs_backtraceOfMainThread;
+ (NSArray *)bs_backtraceOfNSThread:(NSThread *)thread;

@end
