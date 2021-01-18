//
//  BugBattleReplayHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "BugBattleReplayHelper.h"
#import "BugBattleCore.h"

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
    self.replayImages = [[NSMutableArray alloc] init];
    self.replaySteps = [[NSMutableArray alloc] init];
}

- (void)start {
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                         target: self
                                       selector: @selector(addReplayStep)
                                       userInfo: nil
                                        repeats: YES];
}

- (void)stop {
    if (self.replayTimer) {
        [self.replayTimer invalidate];
    }
}

- (void)clear {
    self.replayImages = [[NSMutableArray alloc] init];
    self.replaySteps = [[NSMutableArray alloc] init];
}

- (void)addReplayStep {
    if (self.replayImages.count >= 60) {
        [self.replayImages removeObjectAtIndex: 0];
    }
    UIImage *screenshot = [[BugBattle sharedInstance] captureLowResScreen];
    [self.replayImages addObject: screenshot];
}

@end
