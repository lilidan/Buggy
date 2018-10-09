//
//  CrashToHandle.h
//  BuggyDemo
//
//  Created by sgcy on 2018/10/9.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashToHandle : NSObject

-(void)testUnrecognizedSelector;
-(void)testKVO;
-(void)testArray;
-(void)testMutableArray;
-(void)testDictionary;
-(void)testMutableDictionary;
-(void)testString;
-(void)testMutableString;
-(void)testAttributedString;
-(void)testMutableAttributedString;
-(void)testNotification;
- (void)testNSUserDefaults;
- (void)testNSCache;
- (void)testNSSet;
- (void)testNSMutableSet;
- (void)testNSOrderSet;
- (void)testNSMutableOrderSet;
- (void)testNSData;
- (void)testNSMutableData;
- (void)testUIViewBgThread;
- (void)testNullMessage;
- (void)testTimer;
- (void)testNaviPushPush;

@end
