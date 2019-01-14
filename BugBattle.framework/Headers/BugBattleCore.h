//
//  BugBattle.h
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum myTypes { NONE, SHAKE } BugBattleActivationMethod;

@interface BugBattle : NSObject

+ (instancetype)sharedInstance;
+ (void)initWithToken: (NSString *)token andActivationMethod: (BugBattleActivationMethod)activationMethod;
+ (void)startBugReporting;
+ (void)shakeInvocation;
+ (void)attachScreenshot: (UIImage *)screenshot;
+ (void)attachData: (NSDictionary *)data;
+ (void)attachCustomData: (NSDictionary *)customData;

- (void)sendReport: (void (^)(bool success))completion;

@property (nonatomic, assign) NSString* token;
@property (nonatomic, assign) BugBattleActivationMethod activationMethod;
@property (nonatomic, retain) NSMutableDictionary* data;

@end

NS_ASSUME_NONNULL_END
