//
//  UIWindow+BugBattleTouchRecognizer.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "UIWindow+BugBattleTouchRecognizer.h"
#import "BugBattleTouchHelper.h"
#import "BugBattleReplayHelper.h"

@implementation UIWindow (BugBattleTouchRecognizer)

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([BugBattleReplayHelper sharedInstance].running) {
        UITouch *touch = touches.allObjects.firstObject;
        CGPoint point = [touch locationInView: self];
        float x = point.x / self.frame.size.width;
        float y = point.y / self.frame.size.height;
        [BugBattleTouchHelper addX: x andY: y andType: @"TU"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([BugBattleReplayHelper sharedInstance].running) {
        UITouch *touch = touches.allObjects.firstObject;
        CGPoint point = [touch locationInView: self];
        float x = point.x / self.frame.size.width;
        float y = point.y / self.frame.size.height;
        [BugBattleTouchHelper addX: x andY: y andType: @"TD"];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([BugBattleReplayHelper sharedInstance].running) {
        UITouch *touch = touches.allObjects.firstObject;
        CGPoint point = [touch locationInView: self];
        float x = point.x / self.frame.size.width;
        float y = point.y / self.frame.size.height;
        [BugBattleTouchHelper addX: x andY: y andType: @"TM"];
    }
}

@end
