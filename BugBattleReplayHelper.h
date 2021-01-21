//
//  BugBattleReplayHelper.h
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BugBattleReplayHelper : NSObject

/**
 * Returns a new shared instance of BugBattleReplayHelper.
 * @author BugBattle
 *
 * @return A new shared instance of BugBattleReplayHelper.
 */
+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;
- (void)clear;

@property (nonatomic, retain) NSMutableArray* replaySteps;
@property (nonatomic, retain) NSTimer* replayTimer;
@property (nonatomic, assign) bool running;

@end

NS_ASSUME_NONNULL_END
