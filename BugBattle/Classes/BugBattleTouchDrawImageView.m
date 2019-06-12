//
//  BugBattleTouchDrawImageView.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleTouchDrawImageView.h"

@interface BugBattleTouchDrawImageView ()

@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation BugBattleTouchDrawImageView

@synthesize red, green, blue;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.allObjects.firstObject;
    if (touch == NULL) {
        return;
    }
    
    _lastPoint = [touch previousLocationInView: self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.allObjects.firstObject;
    if (touch == NULL) {
        return;
    }
    
    CGPoint previousPoint2 = _lastPoint;
    _lastPoint = [touch previousLocationInView: self];
    CGPoint currentPoint = [touch locationInView: self];
    
    CGPoint mid1 = [self midPointBetween: _lastPoint and: previousPoint2];
    CGPoint mid2 = [self midPointBetween: currentPoint and: _lastPoint];
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorSpace(context, CGColorSpaceCreateDeviceRGB());
    
    UIImage* image = self.image;
    
    if (image == NULL || context == NULL) {
        return;
    }
    
    [image drawInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    CGContextAddLineToPoint(context, mid2.x, mid2.y);
    
    CGFloat colorComponents[4] = { red, green, blue, 1.0f };
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColor(context, colorComponents);
    CGContextStrokePath(context);
    
    UIImage* imageFromContext = UIGraphicsGetImageFromCurrentImageContext();
    if (imageFromContext != NULL) {
        self.image = imageFromContext;
    }
    
    UIGraphicsEndImageContext();
}

- (CGPoint)midPointBetween:(CGPoint)p1 and:(CGPoint)p2 {
    return CGPointMake((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);
}

@end
