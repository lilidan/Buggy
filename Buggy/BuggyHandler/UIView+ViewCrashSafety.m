//
//  UIView+ViewCrashSafety.m
//  ZYLightKit
//
//  Created by apple on 2017/2/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "UIView+ViewCrashSafety.h"
#import <objc/runtime.h>
#import "NSObject+SafeCore.h"

@implementation UIView (ViewCrashSafety)


+(void)openSafeProtector{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        [class swizzleSetNeedsLayout];
        [class swizzleSetNeedsDisplay];
        [class swizzleSetNeedsDisplayInRect];
        [class swizzleSetNeedsUpdateConstraints];

    });
    
}

+(void)swizzleSetNeedsLayout{
    

    SEL originalSelector = @selector(setNeedsLayout);
    SEL swizzledSelector = @selector(zy_setNeedsLayout);
    Class class = [self class];
    [self safe_exchangeInstanceMethod:class originalSel:originalSelector newSel:swizzledSelector];
}

+(void)swizzleSetNeedsDisplay{
    
    SEL originalSelector = @selector(setNeedsDisplay);
    SEL swizzledSelector = @selector(zy_setNeedsDisplay);
 
    Class class = [self class];
    [self safe_exchangeInstanceMethod:class originalSel:originalSelector newSel:swizzledSelector];

}

+(void)swizzleSetNeedsDisplayInRect{
    
    SEL originalSelector = @selector(setNeedsDisplayInRect:);
    SEL swizzledSelector = @selector(zy_setNeedsDisplayInRect:);
    
    Class class = [self class];
    [self safe_exchangeInstanceMethod:class originalSel:originalSelector newSel:swizzledSelector];

}

+(void)swizzleSetNeedsUpdateConstraints{
    
    SEL originalSelector = @selector(setNeedsUpdateConstraints);
    SEL swizzledSelector = @selector(zy_setNeedsUpdateConstraints);
    
    Class class = [self class];
    [self safe_exchangeInstanceMethod:class originalSel:originalSelector newSel:swizzledSelector];

}

- (void)reportError
{
    NSException *exception = [NSException exceptionWithName:@"UIViewThreadException" reason:@"UIViewUpdateNotInMainThread" userInfo:@{}];
    [[self class] safe_logCrashWithException:exception crashType:LSSafeProtectorCrashTypeUIViewMainThread];
}


-(void)zy_setNeedsLayout{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        //running on main thread
        [self zy_setNeedsLayout];
        
    }else{
        [self reportError];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self zy_setNeedsLayout];
                       });
    }
    
    
}


-(void)zy_setNeedsDisplay{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        //running on main thread
        [self zy_setNeedsDisplay];
        
    }else{
        [self reportError];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self zy_setNeedsDisplay];
                       });
    }
    
    
}


-(void)zy_setNeedsDisplayInRect:(CGRect)rect{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        //running on main thread
        [self zy_setNeedsDisplayInRect:rect];
        
    }else{
        [self reportError];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self zy_setNeedsDisplayInRect:rect];
                       });
    }
    
    
}

-(void)zy_setNeedsUpdateConstraints{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        //running on main thread
        [self zy_setNeedsUpdateConstraints];
        
    }else{
        [self reportError];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self zy_setNeedsUpdateConstraints];
                       });
    }
    
    
}






@end
