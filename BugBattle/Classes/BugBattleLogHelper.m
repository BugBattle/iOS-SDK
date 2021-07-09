//
//  BugBattleReplayHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "BugBattleLogHelper.h"
#import "BugBattleCore.h"

@implementation BugBattleLogHelper

/*
 Returns a shared instance (singleton).
 */
+ (instancetype)sharedInstance
{
    static BugBattleLogHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BugBattleLogHelper alloc] init];
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
    self.log = [[NSMutableArray alloc] init];
}

- (NSArray *)getLogs {
    return self.log;
}

- (void)checkLogSize {
    if (self.log.count >= 1000) {
        [self.log removeObjectAtIndex: 0];
    }
}

- (void)logEvent: (NSString *)name {
    [self checkLogSize];
    [self.log addObject: @{
        @"name": name,
        @"date": [[BugBattle sharedInstance] getCurrentJSDate]
    }];
}

- (void)logEvent: (NSString *)name withData: (NSDictionary *)data {
    [self checkLogSize];
    [self.log addObject: @{
        @"name": name,
        @"data": data,
        @"date": [[BugBattle sharedInstance] getCurrentJSDate]
    }];
}

- (void)clear {
    self.log = [[NSMutableArray alloc] init];
}

@end
