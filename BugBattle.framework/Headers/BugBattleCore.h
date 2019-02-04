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

typedef enum activationMethodTypes { NONE, SHAKE } BugBattleActivationMethod;

@interface BugBattle : NSObject

+ (instancetype)sharedInstance;
+ (void)initWithToken: (NSString *)token andActivationMethod: (BugBattleActivationMethod)activationMethod;
+ (void)startBugReporting;
+ (void)shakeInvocation;
+ (void)attachScreenshot: (UIImage *)screenshot;
+ (UIImage *)getAttachedScreenshot;
+ (void)attachData: (NSDictionary *)data;
+ (void)setNavigationBarTint: (UIColor *)color;
+ (void)attachCustomData: (NSDictionary *)customData;
+ (void)enableStepsToReproduce:(BOOL)enable;
+ (void)trackStepWithType: (NSString *)type andData: (NSString *)data;
+ (NSBundle *)frameworkBundle;

- (void)sendReport: (void (^)(bool success))completion;

@property (nonatomic, retain) NSString* token;
@property (nonatomic, assign) BugBattleActivationMethod activationMethod;
@property (nonatomic, retain) NSMutableDictionary* data;

extern NSString *const BugBattleStepTypeView;
extern NSString *const BugBattleStepTypeButton;
extern NSString *const BugBattleStepTypeInput;

@end

NS_ASSUME_NONNULL_END
