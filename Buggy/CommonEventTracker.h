//
//  CommonEventTracker.h
//  Buggy
//
//  Created by sgcy on 2018/10/11.
//

#import <Foundation/Foundation.h>



// SentryBreadcrumbTracker 不好用，要跟CocoaLumberJack的日志整合在一起，参考实现

// 包括App的生命周期，viewController的生命周期， 用户点击事件

@interface CommonEventTracker : NSObject


@end
