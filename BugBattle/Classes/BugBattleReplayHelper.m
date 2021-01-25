//
//  BugBattleReplayHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "BugBattleReplayHelper.h"
#import "BugBattleCore.h"
#import "BugBattleTouchHelper.h"

@implementation BugBattleReplayHelper

/*
 Returns a shared instance (singleton).
 */
+ (instancetype)sharedInstance
{
    static BugBattleReplayHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BugBattleReplayHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)initHelper {
    self.replaySteps = [[NSMutableArray alloc] init];
    self.running = false;
}

- (void)start {
    if (self.running) {
        return;
    }
    self.running = true;
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                         target: self
                                       selector: @selector(addReplayStep)
                                       userInfo: nil
                                        repeats: YES];
}

- (void)stop {
    if (self.replayTimer) {
        [self.replayTimer invalidate];
    }
    self.running = false;
}

- (void)clear {
    self.replaySteps = [[NSMutableArray alloc] init];
}

- (void)addReplayStep {
    if (self.replaySteps.count >= 60) {
        [self.replaySteps removeObjectAtIndex: 0];
    }
    
    UIImage *screenshot = [[BugBattle sharedInstance] captureLowResScreen];
    NSString *currentViewControllerName = @"NotSet";
    UIViewController *topViewController = [[BugBattle sharedInstance] getTopMostViewController];
    if (topViewController != nil) {
        currentViewControllerName = NSStringFromClass([topViewController class]);
    }
    
    [self.replaySteps addObject: @{
        @"screenname": currentViewControllerName,
        @"image": screenshot,
        @"interactions": [BugBattleTouchHelper getAndClearTouchEvents],
        @"date": [[BugBattle sharedInstance] getJSStringForNSDate: [[NSDate alloc] init]]
    }];
}

@end
