//
//  BugBattleTouchHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "BugBattleTouchHelper.h"

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

+ (void)addTouch:(CGPoint)touch {
    [[self sharedInstance] addTouchEvent: touch];
}

- (void)addTouchEvent:(CGPoint)touch {
    NSDictionary *point = @{
        @"x": @(touch.x),
        @"y": @(touch.y),
        @"date": [NSDate date]
    };
    [self.touchEvents addObject: point];
}

@end

