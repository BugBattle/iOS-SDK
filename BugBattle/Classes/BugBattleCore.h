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
typedef enum bugPriorityTypes { LOW, MEDIUM, HIGH } BugBattleBugPriority;
typedef enum applicationType { NATIVE, REACTNATIVE, FLUTTER } BugBattleApplicationType;

@protocol BugBattleDelegate <NSObject>
@optional
- (void) bugWillBeSent;
- (void) bugSent;
- (void) bugSendingFailed;
- (void) customActionCalled: (NSString *)customAction;
@required
@end

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
 * Initializes the BugBattle SDK.
 * @author BugBattle
 *
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 * @param activationMethods Array of BugBattleActivationMethod. Activation methods, which triggers a new bug report.
 */
+ (void)initWithToken: (NSString *)token andActivationMethods: (NSArray *)activationMethods;

/**
 * Auto-configures the BugBattle SDK from the remote config.
 * @author BugBattle
 *
 */
+ (void)autoconfigure;

/**
 * Manually start the bug reporting workflow. This is used, when you use the activation method "NONE".
 * @author BugBattle
 *
 */
+ (void)startBugReporting;

/**
 * Manually start a silent bug reporting workflow.
 * @author BugBattle
 *
 */
+ (void)sendSilentBugReportWith:(NSString *)email andDescription:(NSString *)description andPriority:(BugBattleBugPriority)priority;

/**
 * Enables replays
 * @author BugBattle
 *
 */
+ (void)enableReplays: (BOOL)enable;

/**
 * Attaches custom data. This will be merged with user attributes.
 * @author BugBattle
 *
 * @param customData The data to attach to a bug report.
 */
+ (void)attachCustomData: (NSDictionary *)customData __deprecated;

/**
 * Attach custom user attributes to your  reports.
 * @author BugBattle
 *
 * @param attributes The data to attach to your reports.
 */
+ (void)attachUserAttributes: (NSDictionary *)attributes;

/**
 * Attach custom data, which can be view in the BugBattle dashboard.
 * @author BugBattle
 *
 * @param key The key of the attribute
 * @param value The value you want to add
 */
+ (void)setUserAttribute: (NSString *)key with: (NSString *)value;

/**
 * Removes one key from the custom data
 * @author BugBattle
 *
 * @param key The key of the attribute
 */
+ (void)removeUserAttribute: (NSString *)key;

/**
 * Clears all user attributes
 * @author BugBattle
 */
+ (void)clearAllUserAttributes;

/**
 * Set a custom navigation tint color.
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationTint:(UIColor *)color;

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
 * Enables or disables the powered by Bugbattle logo.
 * @author BugBattle
 *
 * @param enable Enablesor disable the powered by Bugbattle logo.
 */
+ (void)enablePoweredByBugbattle: (BOOL)enable;

/**
 * Sets the main logo url.
 * @author BugBattle
 *
 * @param logoUrl The main logo url.
 */
+ (void)setLogoUrl: (NSString *)logoUrl;

/**
 * Set maximum amount of network logs in queue
 * @author BugBattle
 *
 * @param maxNetworkLogs Sets the maximum amount of network logs.
 */
+ (void)setMaxNetworkLogs: (int)maxNetworkLogs;

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
 * Set's the current userinterface language.
 * @author BugBattle
 *
 * @param language The 2 digit ISO code language to set
 */
+ (void)setLanguage: (NSString *)language;

/**
 * Starts network recording.
 * @author BugBattle
 *
 */
+ (void)startNetworkRecording;

/**
 * Starts network recording with a session configuration.
 * @author BugBattle
 *
 * @param configuration the NSURLSessionConfiguration which should be logged
 *
 */
+ (void)startNetworkRecordingForSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * Stops network recording.
 * @author BugBattle
 *
 */
+ (void)stopNetworkRecording;

+ (void)setApplicationType: (BugBattleApplicationType)applicationType;
+ (void)attachData: (NSDictionary *)data;
+ (NSBundle *)frameworkBundle;
+ (void)shakeInvocation;
+ (void)attachScreenshot: (UIImage *)screenshot;
+ (UIImage *)getAttachedScreenshot;

- (void)sendReport: (void (^)(bool success))completion;
- (void)uploadStepImages: (NSArray *)steps andCompletion: (void (^)(bool success, NSArray *fileUrls))completion;
- (UIViewController *)getTopMostViewController;
- (NSString *)getTopMostViewControllerName;
- (NSString *)getJSStringForNSDate:(NSDate *)date;
- (UIImage *) captureScreen;
+ (void)afterBugReportCleanup;

@property (nonatomic, retain) NSString* language;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* apiUrl;
@property (nonatomic, retain) NSString* privacyPolicyUrl;
@property (nonatomic, retain) NSArray *activationMethods;
@property (nonatomic, retain) NSArray *logoUrl;
@property (nonatomic, retain) bool enablePoweredBy;
@property (nonatomic, retain) NSMutableDictionary* data;
@property (nonatomic, assign) bool privacyPolicyEnabled;
@property (nonatomic, assign) bool replaysEnabled;
@property (nonatomic, assign) BugBattleApplicationType applicationType;
@property (nonatomic, weak) id <BugBattleDelegate> delegate;

extern NSString *const BugBattleStepTypeView;
extern NSString *const BugBattleStepTypeButton;
extern NSString *const BugBattleStepTypeInput;

@end

NS_ASSUME_NONNULL_END
