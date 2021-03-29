//
//  BBAFURLSessionManager.m
//  BugBattle_Example
//
//  Created by Lukas Boehler on 29.03.21.
//  Copyright © 2021 Lukas Böhler. All rights reserved.
//

#import "BBAFURLSessionManager.h"
#import <BugBattle/BugBattle.h>

@implementation BBAFURLSessionManager

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {
    [BugBattle startNetworkRecordingForSessionConfiguration: configuration];
    
    return [super initWithSessionConfiguration:configuration];
}

@end
