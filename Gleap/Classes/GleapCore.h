//
//  Gleap.h
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 Gleap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum activationMethodTypes { NONE, SHAKE, THREE_FINGER_DOUBLE_TAB, SCREENSHOT } GleapActivationMethod;
typedef enum bugPriorityTypes { LOW, MEDIUM, HIGH } GleapBugPriority;
typedef enum applicationType { NATIVE, REACTNATIVE, FLUTTER } GleapApplicationType;

@protocol GleapDelegate <NSObject>
@optional
- (void) bugWillBeSent;
- (void) bugSent;
- (void) bugSendingFailed;
- (void) customActionCalled: (NSString *)customAction;
@required
@end

@interface Gleap : NSObject

/**
 * Returns a new shared instance of Gleap.
 * @author Gleap
 *
 * @return A new shared instance of Gleap.
 */
+ (instancetype)sharedInstance;

/**
 * Initializes the Gleap SDK.
 * @author Gleap
 *
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 * @param activationMethod Activation method, which triggers a new bug report.
 */
+ (void)initWithToken: (NSString *)token andActivationMethod: (GleapActivationMethod)activationMethod;

/**
 * Initializes the Gleap SDK.
 * @author Gleap
 *
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 * @param activationMethods Array of GleapActivationMethod. Activation methods, which triggers a new bug report.
 */
+ (void)initWithToken: (NSString *)token andActivationMethods: (NSArray *)activationMethods;

/**
 * Auto-configures the Gleap SDK from the remote config.
 * @author Gleap
 *
 * @param token The SDK key, which can be found on dashboard.bugbattle.io
 */
+ (void)autoConfigureWithToken: (NSString *)token;

/**
 * Manually start the bug reporting workflow. This is used, when you use the activation method "NONE".
 * @author Gleap
 *
 */
+ (void)startBugReporting;

/**
 * Manually start a silent bug reporting workflow.
 * @author Gleap
 *
 */
+ (void)sendSilentBugReportWith:(NSString *)email andDescription:(NSString *)description andPriority:(GleapBugPriority)priority;

/**
 * Enables replays
 * @author Gleap
 *
 */
+ (void)enableReplays: (BOOL)enable;

/**
 * Attaches custom data, which can be viewed in the Gleap dashboard. New data will be merged with existing custom data.
 * @author Gleap
 *
 * @param customData The data to attach to a bug report.
 */
+ (void)attachCustomData: (NSDictionary *)customData;

/**
 * Attach one key value pair to existing custom data.
 * @author Gleap
 *
 * @param value The value you want to add
 * @param key The key of the attribute
 */
+ (void)setCustomData: (NSString *)value forKey: (NSString *)key;

/**
 * Removes one key from existing custom data.
 * @author Gleap
 *
 * @param key The key of the attribute
 */
+ (void)removeCustomDataForKey: (NSString *)key;

/**
 * Clears all custom data.
 * @author Gleap
 */
+ (void)clearCustomData;

/**
 * Set a custom navigation bar tint color.
 * @author Gleap
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationBarTint:(UIColor *)color __deprecated;

/**
 * Set a custom navigation title color.
 * @author Gleap
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationBarTitleColor:(UIColor *)color __deprecated;

/**
 * Set a custom navigation tint color.
 * @author Gleap
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setNavigationTint:(UIColor *)color __deprecated;

/**
 * Sets a custom accent color
 * @author Gleap
 *
 * @param color The  color of the navigation action items.
 */
+ (void)setColor:(UIColor *)color;

/**
 * Sets a custom api url.
 * @author Gleap
 *
 * @param apiUrl The custom api url.
 */
+ (void)setApiUrl: (NSString *)apiUrl;

/**
 * Enables the privacy policy check.
 * @author Gleap
 *
 * @param enable Enable the privacy policy.
 */
+ (void)enablePrivacyPolicy: (BOOL)enable;

/**
 * Enables or disables the powered by Bugbattle logo.
 * @author Gleap
 *
 * @param enable Enablesor disable the powered by Bugbattle logo.
 */
+ (void)enablePoweredByBugbattle: (BOOL)enable;

/**
 * Sets the main logo url.
 * @author Gleap
 *
 * @param logoUrl The main logo url.
 */
+ (void)setLogoUrl: (NSString *)logoUrl;

/**
 * Disables the console logging. This must be called BEFORE initializing the SDK.
 * @author Gleap
 *
 */
+ (void)disableConsoleLog;

/**
 * Sets a custom privacy policy url.
 * @author Gleap
 *
 * @param privacyPolicyUrl The URL pointing to your privacy policy.
 */
+ (void)setPrivacyPolicyUrl: (NSString *)privacyPolicyUrl;

/**
 * Set maximum amount of network logs in queue
 * @author Gleap
 *
 * @param maxNetworkLogs Sets the maximum amount of network logs.
 */
+ (void)setMaxNetworkLogs: (int)maxNetworkLogs;

/**
 * Sets the customer's name.
 * @author Gleap
 *
 * @param name The customer's name.
 */
+ (void)setCustomerName:(NSString *)name;

/**
 * Sets the customer's email address.
 * @author Gleap
 *
 * @param email The customer's email address.
 */
+ (void)setCustomerEmail: (NSString *)email;

/**
 * Set's the current userinterface language.
 * @author Gleap
 *
 * @param language The 2 digit ISO code language to set
 */
+ (void)setLanguage: (NSString *)language;

/**
 * Logs a custom event
 * @author Gleap
 *
 * @param name Name of the event
 *
 */
+ (void)logEvent: (NSString *)name;

/**
 * Logs a custom event with data
 * @author Gleap
 *
 * @param name Name of the event
 * @param data Data passed with the event.
 *
 */
+ (void)logEvent: (NSString *)name withData: (NSDictionary *)data;

/**
 * Starts network recording.
 * @author Gleap
 *
 */
+ (void)startNetworkRecording;

/**
 * Starts network recording with a session configuration.
 * @author Gleap
 *
 * @param configuration the NSURLSessionConfiguration which should be logged
 *
 */
+ (void)startNetworkRecordingForSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * Stops network recording.
 * @author Gleap
 *
 */
+ (void)stopNetworkRecording;

+ (void)setApplicationType: (GleapApplicationType)applicationType;
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
@property (nonatomic, assign) GleapApplicationType applicationType;
@property (nonatomic, weak) id <GleapDelegate> delegate;
@property (retain, nonatomic) NSString *lastScreenName;
@property (retain, nonatomic) NSString *customerEmail;
@property (retain, nonatomic) NSString *customerName;
@property (retain, nonatomic) UIColor *navigationTint;
@property (nonatomic, assign) bool currentlyOpened;

extern NSString *const GleapStepTypeView;
extern NSString *const GleapStepTypeButton;
extern NSString *const GleapStepTypeInput;

@end

NS_ASSUME_NONNULL_END
