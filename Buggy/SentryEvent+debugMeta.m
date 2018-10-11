//
//  SentryEvent+debugMeta.m
//  Buggy
//
//  Created by sgcy on 2018/10/11.
//

#import "SentryEvent+debugMeta.h"
#import "NSObject+SafeCore.h"

@implementation SentryEvent(debugMeta)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass=[self class];
        [self safe_exchangeInstanceMethod:dClass originalSel:@selector(addDebugImages:) newSel:@selector(safe_addDebugImages:)];
    });
}

- (void)safe_addDebugImages:(id)images
{

}


@end
