//
//  UINavigationController+NestedPushCrashSafety.h
//  DrLightDemo
//
//  Created by apple on 2017/2/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 1、prevent pushing viewcontroller  frequently within a short perid.
    for example,add push code in viewDidLoad，before viewDidAppear has called,it is dangerous.It may caused crash "cannot addsubView:self".  
 2、prevent pushing the same viewcontroller into one stack.
 */

@interface UINavigationController (NestedPushCrashSafety)

@end
