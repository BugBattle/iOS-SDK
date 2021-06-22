//
//  BBViewController.m
//  BugBattle
//
//  Created by Lukas Böhler on 06/12/2019.
//  Copyright (c) 2019 Lukas Böhler. All rights reserved.
//

#import "BBViewController.h"
#import "BBAFURLSessionManager.h"

@interface BBViewController ()

@end

@implementation BBViewController

- (void)bugWillBeSent {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Home";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary: @{ @"key" : @"value", @"key2" : @"value2"}];
    [BugBattle attachCustomData: dict];
    [BugBattle enableReplays: true];
    
    [BugBattle enablePrivacyPolicy: true];
    
    BugBattle.sharedInstance.delegate = self;
    
    NSLog(@"Started Bugbattle-Demo.");
    
    for (int i = 0; i < 5; i++) {
        NSLog(@"Lorum logsum %i", i);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
