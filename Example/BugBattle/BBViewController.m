//
//  BBViewController.m
//  BugBattle
//
//  Created by Lukas Böhler on 06/12/2019.
//  Copyright (c) 2019 Lukas Böhler. All rights reserved.
//

#import "BBViewController.h"
#import <BugBattle/BugBattle.h>

@interface BBViewController ()

@end

@implementation BBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary: @{ @"key" : @"value", @"key2" : @"value2"}];
    [BugBattle attachCustomData: dict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
