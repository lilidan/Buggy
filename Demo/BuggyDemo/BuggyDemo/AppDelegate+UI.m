//
//  AppDelegate+UI.m
//
//  Created by Karl Stenerud on 2012-03-04.
//

#import "AppDelegate+UI.h"
#import "LoadableCategory.h"
#import "CommandTVC.h"
#import "Crasher.h"

#import "CRLCrashAsyncSafeThread.h"
#import "CRLCrashCXXException.h"
#import "CRLCrashObjCException.h"
#import "CRLCrashNSLog.h"
#import "CRLCrashObjCMsgSend.h"
#import "CRLCrashReleasedObject.h"
#import "CRLCrashROPage.h"
#import "CRLCrashPrivInst.h"
#import "CRLCrashUndefInst.h"
#import "CRLCrashNULL.h"
#import "CRLCrashGarbage.h"
#import "CRLCrashNXPage.h"
#import "CRLCrashStackGuard.h"
#import "CRLCrashTrap.h"
#import "CRLCrashAbort.h"
#import "CRLCrashCorruptMalloc.h"
#import "CRLCrashCorruptObjC.h"
#import "CRLCrashOverwriteLinkRegister.h"
#import "CRLCrashSmashStackBottom.h"
#import "CRLCrashSmashStackTop.h"
#import "CRLFramelessDWARF.h"


#import <objc/runtime.h>

MAKE_CATEGORIES_LOADABLE(AppDelegate_UI)


@implementation AppDelegate (UI)

#pragma mark Public Methods

- (UIViewController*) createRootViewController
{
    CommandTVC* cmdController = [self commandTVCWithCommands:[self topLevelCommands]];
    cmdController.getTitleBlock = ^NSString* (__unused UIViewController* controller)
    {
        return [NSString stringWithFormat:@"Crash Tester: %@",@""];
    };
    return [[UINavigationController alloc] initWithRootViewController:cmdController];
}


#pragma mark Utility

- (CommandTVC*) commandTVCWithCommands:(NSArray*) commands
{
    CommandTVC* cmdController = [[CommandTVC alloc] initWithStyle:UITableViewStylePlain];
    [cmdController.commands addObjectsFromArray:commands];
    [self setBackButton:cmdController];
    return cmdController;
}

- (void) setBackButton:(UIViewController*) controller
{
    controller.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleDone
                                    target:nil
                                    action:nil];
}

#pragma mark Commands

- (NSArray*) topLevelCommands
{
    __unsafe_unretained id blockSelf = self;
    NSMutableArray* commands = [NSMutableArray array];
    
    [commands addObject:
     [CommandEntry commandWithName:@"test crash handle"
                     accessoryType:UITableViewCellAccessoryDisclosureIndicator
                             block:^(UIViewController* controller)
      {
          CommandTVC* cmdController = [self commandTVCWithCommands:[blockSelf crashToHandleCommand]];
          cmdController.getTitleBlock = ^NSString* (__unused UIViewController* controllerInner)
          {
              return [NSString stringWithFormat:@"Manage (%@)", @""];
          };
          [controller.navigationController pushViewController:cmdController animated:YES];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Crash"
                     accessoryType:UITableViewCellAccessoryDisclosureIndicator
                             block:^(UIViewController* controller)
      {
          CommandTVC* cmdController = [self commandTVCWithCommands:[blockSelf crashCommands]];
          cmdController.title = @"Crash";
          [controller.navigationController pushViewController:cmdController animated:YES];
      }]];
    
    
    [commands addObject:
     [CommandEntry commandWithName:@"CrashProbe Crashes"
                     accessoryType:UITableViewCellAccessoryDisclosureIndicator
                             block:^(UIViewController* controller)
      {
          CommandTVC* cmdController = [self commandTVCWithCommands:[blockSelf crash2Commands]];
          cmdController.title = @"CrashProbe Crashes";
          [controller.navigationController pushViewController:cmdController animated:YES];
      }]];
    return commands;
}

- (NSArray *)crashToHandleCommand
{
    NSMutableArray* commands = [NSMutableArray array];
    __block AppDelegate* blockSelf = self;
    
    [commands addObject:
     [CommandEntry commandWithName:@"testUnrecognizedSelector"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testUnrecognizedSelector];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testKVO"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testKVO];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testArray"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testArray];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testMutableArray"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testMutableArray];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testDictionary"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testDictionary];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testMutableDictionary"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testMutableDictionary];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testString"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testString];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testMutableString"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testMutableString];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testAttributedString"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testAttributedString];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testMutableAttributedString"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testMutableAttributedString];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testNotification"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testNotification];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testNSUserDefaults"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testNSUserDefaults];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testNSCache"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testNSCache];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testNSSet"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testNSSet];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"testNSData"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crashToHanlder testNSMutableSet];
      }]];
    [commands addObject:[CommandEntry commandWithName:@"testNSMutableSet"
                    accessoryType:UITableViewCellAccessoryNone
                            block:^(__unused UIViewController* controller)
     {
         [self.crashToHanlder testNSMutableSet];
     }]];
    
    [commands addObject:[CommandEntry commandWithName:@"testNSOrderSet"
                    accessoryType:UITableViewCellAccessoryNone
                            block:^(__unused UIViewController* controller)
     {
         [self.crashToHanlder testNSOrderSet];
     }]];
    
    [commands addObject:[CommandEntry commandWithName:@"testUIViewBgThread"
                                        accessoryType:UITableViewCellAccessoryNone
                                                block:^(__unused UIViewController* controller)
                         {
                             [self.crashToHanlder testUIViewBgThread];
                         }]];
    
    [commands addObject:[CommandEntry commandWithName:@"testNullMessage"
                                        accessoryType:UITableViewCellAccessoryNone
                                                block:^(__unused UIViewController* controller)
                         {
                             [self.crashToHanlder testNullMessage];
                         }]];
    
    [commands addObject:[CommandEntry commandWithName:@"testTimer"
                                        accessoryType:UITableViewCellAccessoryNone
                                                block:^(__unused UIViewController* controller)
                         {
                             [self.crashToHanlder testTimer];
                         }]];
    
    [commands addObject:[CommandEntry commandWithName:@"testNaviPushPush"
                                        accessoryType:UITableViewCellAccessoryNone
                                                block:^(__unused UIViewController* controller)
                         {
                             [self.crashToHanlder testNaviPushPush];
                         }]];
    
    return commands;
}


- (NSArray*) crashCommands
{
    NSMutableArray* commands = [NSMutableArray array];
    __block AppDelegate* blockSelf = self;
    
    [commands addObject:
     [CommandEntry commandWithName:@"NSException"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher throwUncaughtNSException];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"C++ Exception"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher throwUncaughtCPPException];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Bad Pointer"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher dereferenceBadPointer];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Null Pointer"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher dereferenceNullPointer];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Corrupt Object"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher useCorruptObject];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Spin Run Loop"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher spinRunloop];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Stack Overflow"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher causeStackOverflow];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Abort"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher doAbort];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Divide By Zero"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher doDiv0];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Illegal Instruction"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher doIllegalInstruction];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Deallocated Object"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher accessDeallocatedObject];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Deallocated Proxy"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher accessDeallocatedPtrProxy];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Corrupt Memory"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher corruptMemory];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Zombie NSException"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher zombieNSException];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Crash in Handler"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          blockSelf.crashInHandler = YES;
          [self.crasher dereferenceBadPointer];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Deadlock main queue"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher deadlock];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Deadlock pthread"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher pthreadAPICrash];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"User Defined (soft) Crash"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher userDefinedCrash];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"FOOM"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher FOOM];
      }]];
    
    [commands addObject:
     [CommandEntry commandWithName:@"Block Main Queue"
                     accessoryType:UITableViewCellAccessoryNone
                             block:^(__unused UIViewController* controller)
      {
          [self.crasher blockMainQueue];
      }]];
    
    
    return commands;
}

#define NEW_CRASH(TEXT, CLASS) \
[commands addObject: \
[CommandEntry commandWithName:TEXT \
accessoryType:UITableViewCellAccessoryNone \
block:^(__unused UIViewController* controller) \
{ \
[[CLASS new] crash]; \
}]]


- (NSArray*) crash2Commands
{
    NSMutableArray* commands = [NSMutableArray array];
    
    NEW_CRASH(@"Async Safe Thread", CRLCrashAsyncSafeThread);
    NEW_CRASH(@"CXX Exception", CRLCrashCXXException);
    NEW_CRASH(@"ObjC Exception", CRLCrashObjCException);
    NEW_CRASH(@"NSLog", CRLCrashNSLog);
    NEW_CRASH(@"ObjC Msg Send", CRLCrashObjCMsgSend);
    NEW_CRASH(@"Released Object", CRLCrashReleasedObject);
    NEW_CRASH(@"RO Page", CRLCrashROPage);
    NEW_CRASH(@"Privileged Instruction", CRLCrashPrivInst);
    NEW_CRASH(@"Undefined Instruction", CRLCrashUndefInst);
    NEW_CRASH(@"NULL", CRLCrashNULL);
    NEW_CRASH(@"Garbage", CRLCrashGarbage);
    NEW_CRASH(@"NX Page", CRLCrashNXPage);
    NEW_CRASH(@"Stack Guard", CRLCrashStackGuard);
    NEW_CRASH(@"Trap", CRLCrashTrap);
    NEW_CRASH(@"Abort", CRLCrashAbort);
    NEW_CRASH(@"Corrupt Malloc", CRLCrashCorruptMalloc);
    NEW_CRASH(@"Corrupt ObjC", CRLCrashCorruptObjC);
    NEW_CRASH(@"Overwrite Link Register", CRLCrashOverwriteLinkRegister);
    NEW_CRASH(@"Smash Stack Bottom", CRLCrashSmashStackBottom);
    NEW_CRASH(@"Smash Stack Top", CRLCrashSmashStackTop);
    NEW_CRASH(@"Frameless Dwarf", CRLFramelessDWARF);

    return commands;
}

@end
