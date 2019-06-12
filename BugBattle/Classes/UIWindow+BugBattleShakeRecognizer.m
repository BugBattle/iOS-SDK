//
//  UIWindow+BugBattleShakeRecognizer.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "UIWindow+BugBattleShakeRecognizer.h"
#import "BugBattleCore.h"

@implementation UIWindow (BugBattleShakeRecognizer)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [BugBattle shakeInvocation];
    }
}

@end
