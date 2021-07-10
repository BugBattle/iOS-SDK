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

- (void)customActionCalled:(NSString *)customAction {
    NSLog(@"%@", customAction);
}

- (void)bugWillBeSent {
    NSLog(@"SENT BUG");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Home";
    
    BugBattle.sharedInstance.delegate = self;
    
    [BugBattle attachCustomData: @{ @"key" : @"value", @"key2" : @"value2"}];
    
    [BugBattle removeCustomDataForKey: @"email"];
    
    [BugBattle setCustomData: @"lukas@bugbattle.io" forKey: @"email"];

    NSLog(@"Started Bugbattle-Demo.");
    
    for (int i = 0; i < 5; i++) {
        NSLog(@"Lorum logsum %i", i);
    }
    
    [BugBattle setCustomerEmail: @"isabella@bugbattle.io"];
    
    [BugBattle enableReplays: true];
    
    [BugBattle logEvent: @"User signed in"];
    
    [BugBattle logEvent: @"User signed in" withData: @{
        @"userId": @"1242",
        @"name": @"Isabella",
        @"skillLevel": @"🤩"
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
