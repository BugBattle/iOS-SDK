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

typedef enum activationMethodTypes { NONE, SHAKE, THREE_FINGER_DOUBLE_TAB, SCREENSHOT } BugBattleActivationMethod;
typedef enum applicationType { NATIVE, REACTNATIVE, FLUTTER } BugBattleApplicationType;

@interface BugBattle : NSObject

/**
 * Returns a new shared instance of BugBattle.
 * @author BugBattle
 *
 * @return A new shared instance of BugBattle.
 */
+ (instancetype)sharedInstance;

/**
 * Initializes the BugBattle SDK.
 * @author BugBattle
 *
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 * @param activationMethod Activation method, which triggers a new bug report.
 */
+ (void)initWithToken: (NSString *)token andActivationMethod: (BugBattleActivationMethod)activationMethod;

/**
 * Manually start the bug reporting workflow. This is used, when you use the activation method "NONE".
 * @author BugBattle
 *
 */
+ (void)startBugReporting;

/**
 * Manually start the bug reporting workflow, using a custom screenshot (rather than
 * automatically capturing one). This is used, when you use the activation method "NONE".
 * @author BugBattle
 *
 */
+ (void)startBugReportingWithScreenshot: (UIImage *)screenshot;

/**
 * Attach custom data, which can be view in the BugBattle dashboard.
 * @author BugBattle
 *
 * @param customData The data to attach to a bug report.
 */
+ (void)attachCustomData: (NSDictionary *)customData;

/**
 * Set a custom navigationbar tint color.
 * @author BugBattle
 *
 * @param color The background color of the navigationbar.
 */
+ (void)setNavigationBarTint: (UIColor *)color;

/**
 * Set a custom navigation tint color.
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationTint:(UIColor *)color;

/**
 * Set a custom navigationbar title color.
 * @author BugBattle
 *
 * @param color The  color of the navigationbar title.
 */
+ (void)setNavigationBarTitleColor:(UIColor *)color;

/**
 * Sets a custom api url.
 * @author BugBattle
 *
 * @param apiUrl The custom api url.
 */
+ (void)setApiUrl: (NSString *)apiUrl;

/**
 * Enables the privacy policy check.
 * @author BugBattle
 *
 * @param enable Enable the privacy policy.
 */
+ (void)enablePrivacyPolicy: (BOOL)enable;

/**
 * Sets a custom privacy policy url.
 * @author BugBattle
 *
 * @param privacyPolicyUrl The URL pointing to your privacy policy.
 */
+ (void)setPrivacyPolicyUrl: (NSString *)privacyPolicyUrl;

/**
 * Sets the customer's email address.
 * @author BugBattle
 *
 * @param email The customer's email address.
 */
+ (void)setCustomerEmail: (NSString *)email;

/**
 * Add a 'step to reproduce' step.
 * @author BugBattle
 *
 * @param type Type of the step. (Use any custom string or one of the predefined constants - BugBattleStepTypeView, Button, Input)
 * @param data Custom data associated with the step.
 */
+ (void)trackStepWithType: (NSString *)type andData: (NSString *)data;

+ (void)attachData: (NSDictionary *)data;
+ (NSBundle *)frameworkBundle;
+ (void)shakeInvocation;
+ (void)attachScreenshot: (UIImage *)screenshot;
+ (UIImage *)getAttachedScreenshot;

- (void)sendReport: (void (^)(bool success))completion;

@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* apiUrl;
@property (nonatomic, retain) NSString* privacyPolicyUrl;
@property (nonatomic, assign) bool privacyPolicyEnabled;
@property (nonatomic, assign) BugBattleActivationMethod activationMethod;
@property (nonatomic, assign) BugBattleApplicationType applicationType;
@property (nonatomic, retain) NSMutableDictionary* data;

extern NSString *const BugBattleStepTypeView;
extern NSString *const BugBattleStepTypeButton;
extern NSString *const BugBattleStepTypeInput;

@end

NS_ASSUME_NONNULL_END
