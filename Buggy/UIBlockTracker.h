//
//  UIBlockTracker.h
//  Buggy
//
//  Created by sgcy on 2018/10/12.
//

#import <Foundation/Foundation.h>

@interface UIBlockTracker : NSObject

+ (instancetype)sharedInstance;
- (void)start;

@end
