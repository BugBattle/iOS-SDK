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
    
    BugBattle.sharedInstance.delegate = self;
    
    NSLog(@"Started Bugbattle-Demo.");
    
    for (int i = 0; i < 5; i++) {
        NSLog(@"Lorum logsum %i", i);
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    BBAFURLSessionManager *manager = [[BBAFURLSessionManager alloc] initWithSessionConfiguration: configuration];
    
    [manager GET: @"https://run.mocky.io/v3/28703249-3fdd-43e6-a30a-9cc436d75941" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
