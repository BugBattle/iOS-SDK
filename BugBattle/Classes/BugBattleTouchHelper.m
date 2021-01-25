//
//  BugBattleTouchHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "BugBattleTouchHelper.h"
#import "BugBattleCore.h"

#define MAX_INTERACTIONS 10

@implementation BugBattleTouchHelper

/*
 Returns a shared instance (singleton).
 */
+ (instancetype)sharedInstance
{
    static BugBattleTouchHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BugBattleTouchHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.touchEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)addX:(float)x andY:(float)y andType:(NSString *)type {
    [[self sharedInstance] addX: x andY: y andType: type];
}

+ (NSArray *)getAndClearTouchEvents {
    NSArray *touchEventsCopy = [[[self sharedInstance] touchEvents] copy];
    [[[self sharedInstance] touchEvents] removeAllObjects];
    return touchEventsCopy;
}

- (void)addX:(float)x andY:(float)y andType:(NSString *)type {
    if (self.touchEvents.count >= MAX_INTERACTIONS) {
        return;
    }
    
    NSDictionary *point = @{
        @"x": @(x),
        @"y": @(y),
        @"date": [[BugBattle sharedInstance] getJSStringForNSDate: [[NSDate alloc] init]],
        @"type": type
    };
    [self.touchEvents addObject: point];
}

@end

