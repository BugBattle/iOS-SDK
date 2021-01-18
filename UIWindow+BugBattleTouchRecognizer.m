//
//  UIWindow+BugBattleTouchRecognizer.m
//  BugBattle
//
//  Created by Lukas Boehler on 15.01.21.
//

#import "UIWindow+BugBattleTouchRecognizer.h"
#import "BugBattleTouchHelper.h"

@implementation UIWindow (BugBattleTouchRecognizer)

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.allObjects.firstObject;
    CGPoint point = [touch locationInView: self];
    [BugBattleTouchHelper addTouch: point];
}

@end
