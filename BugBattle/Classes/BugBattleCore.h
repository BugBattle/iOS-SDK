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
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 */
+ (void)autoConfigureWithToken: (NSString *)token;

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
 * Attaches custom data, which can be viewed in the BugBattle dashboard. New data will be merged with existing custom data.
 * @author BugBattle
 *
 * @param customData The data to attach to a bug report.
 */
+ (void)attachCustomData: (NSDictionary *)customData;

/**
 * Attach one key value pair to existing custom data.
 * @author BugBattle
 *
 * @param value The value you want to add
 * @param key The key of the attribute
 */
+ (void)setCustomData: (NSString *)value forKey: (NSString *)key;

/**
 * Removes one key from existing custom data.
 * @author BugBattle
 *
 * @param key The key of the attribute
 */
+ (void)removeCustomDataForKey: (NSString *)key;

/**
 * Clears all custom data.
 * @author BugBattle
 */
+ (void)clearCustomData;

/**
 * Set a custom navigation bar tint color.
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationBarTint:(UIColor *)color __deprecated;

/**
 * Set a custom navigation title color.
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationBarTitleColor:(UIColor *)color __deprecated;

/**
 * Set a custom navigation tint color.
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationTint:(UIColor *)color __deprecated;

/**
 * Sets a custom accent color
 * @author BugBattle
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setColor:(UIColor *)color;

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
 * Disables the console logging. This must be called BEFORE initializing the SDK.
 * @author BugBattle
 *
 */
+ (void)disableConsoleLog;

/**
 * Sets a custom privacy policy url.
 * @author BugBattle
 *
 * @param privacyPolicyUrl The URL pointing to your privacy policy.
 */
+ (void)setPrivacyPolicyUrl: (NSString *)privacyPolicyUrl;

/**
 * Set maximum amount of network logs in queue
 * @author BugBattle
 *
 * @param maxNetworkLogs Sets the maximum amount of network logs.
 */
+ (void)setMaxNetworkLogs: (int)maxNetworkLogs;

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
 * Logs a custom event
 * @author BugBattle
 *
 * @param name Name of the event
 *
 */
+ (void)logEvent: (NSString *)name;

/**
 * Logs a custom event with data
 * @author BugBattle
 *
 * @param name Name of the event
 * @param data Data passed with the event.
 *
 */
+ (void)logEvent: (NSString *)name withData: (NSDictionary *)data;

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
- (UIImage *)captureScreen;
- (NSString *)getCurrentJSDate;
+ (void)afterBugReportCleanup;

@property (nonatomic, retain) NSString* language;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* apiUrl;
@property (nonatomic, retain) NSString* privacyPolicyUrl;
@property (nonatomic, retain) NSArray *activationMethods;
@property (nonatomic, retain) NSString *logoUrl;
@property (nonatomic, retain) NSMutableDictionary* data;
@property (nonatomic, assign) bool enablePoweredBy;
@property (nonatomic, assign) bool privacyPolicyEnabled;
@property (nonatomic, assign) bool replaysEnabled;
@property (nonatomic, assign) bool consoleLogDisabled;
@property (nonatomic, assign) BugBattleApplicationType applicationType;
@property (nonatomic, weak) id <BugBattleDelegate> delegate;
@property (retain, nonatomic) NSString *lastScreenName;
@property (retain, nonatomic) NSString *customerEmail;
@property (retain, nonatomic) UIColor *navigationTint;

extern NSString *const BugBattleStepTypeView;
extern NSString *const BugBattleStepTypeButton;
extern NSString *const BugBattleStepTypeInput;

@end

NS_ASSUME_NONNULL_END
