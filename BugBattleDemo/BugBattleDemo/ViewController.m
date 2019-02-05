//
//  ViewController.m
//  BugBattleDemo
//
//  Created by Lukas on 26.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "ViewController.h"
#import <BugBattle/BugBattle.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [BugBattle trackStepWithType: BugBattleStepTypeView andData: @"DemoView"];
    
    [BugBattle attachCustomData: @{
                                   @"test": @"Penis"
                                   }];
}


@end
