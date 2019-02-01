//
//  ViewController.m
//  aaa
//
//  Created by sgcy on 2018/10/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.\
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serial.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(dispatch_get_main_queue(), "key", "main", NULL);
    dispatch_queue_set_specific(serialQueue, "key", "serialQueue", NULL);

    dispatch_sync(serialQueue, ^{
        BOOL res1 = [NSThread isMainThread];
        void *res2 = dispatch_get_specific("key");
        NSLog(@"is main thread: %zd --- is main queue: %s", res1, res2); //YES NO
        //serialQueue，但是MainThread
    });
    
    dispatch_async(serialQueue, ^{
        NSThread *globalThread = [NSThread currentThread];
        dispatch_sync(dispatch_get_main_queue(), ^{
            BOOL res1 = [NSThread isMainThread];
            void *res2 = dispatch_get_specific("key");
            printf("main thread: %d--- queue:%s", res1,res2);  //YES
        });
    });
    
    
    
    
    
    dispatch_block_t log = ^{
        printf("main thread: %zd", [NSThread isMainThread]); //YES
        void *value = dispatch_get_specific("key");
        printf("main queue: %s", value);  //YES
        //async 在main queue，但是子thread。
    };
    
    dispatch_async(serialQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), log);
    });
}


@end
