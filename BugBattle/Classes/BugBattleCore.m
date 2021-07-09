//
//  BugBattle.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleCore.h"
#import "BugBattleImageEditorViewController.h"
#import "BugBattleReplayHelper.h"
#import "BugBattleHttpTrafficRecorder.h"
#import "BugBattleLogHelper.h"
#import <sys/utsname.h>

@interface BugBattle ()

@property (strong, nonatomic) UIImage *screenshot;
@property (retain, nonatomic) NSDate *sessionStart;
@property (retain, nonatomic) NSMutableArray *consoleLog;
@property (retain, nonatomic) NSMutableArray *callstack;
@property (retain, nonatomic) NSMutableArray *stepsToReproduce;
@property (retain, nonatomic) NSMutableDictionary *customData;
@property (retain, nonatomic) NSMutableDictionary *customActions;
@property (retain, nonatomic) NSPipe *inputPipe;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BugBattle

/*
 Returns a shared instance (singleton).
 */
+ (instancetype)sharedInstance
{
    static BugBattle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BugBattle alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

/*
 Init helper.
 */
- (void)initHelper {
    self.lastScreenName = @"";
    self.token = @"";
    self.logoUrl = @"";
    self.customerEmail = @"";
    self.privacyPolicyUrl = @"";
    self.privacyPolicyEnabled = NO;
    self.enablePoweredBy = YES;
    self.apiUrl = @"https://api.bugbattle.io";
    self.activationMethods = [[NSArray alloc] init];
    self.applicationType = NATIVE;
    self.screenshot = nil;
    self.data = [[NSMutableDictionary alloc] init];
    self.sessionStart = [[NSDate alloc] init];
    self.consoleLog = [[NSMutableArray alloc] init];
    self.callstack = [[NSMutableArray alloc] init];
    self.stepsToReproduce = [[NSMutableArray alloc] init];
    self.customData = [[NSMutableDictionary alloc] init];
    self.navigationTint = [UIColor systemBlueColor];
    self.language = [[NSLocale preferredLanguages] firstObject];
}

+ (void)afterBugReportCleanup {
    if ([BugBattle sharedInstance].replaysEnabled) {
        [[BugBattleReplayHelper sharedInstance] start];
    }
}

+ (void)setLanguage: (NSString *)language {
    [BugBattle sharedInstance].language = language;
}

+ (void)disableConsoleLog {
    [BugBattle sharedInstance].consoleLogDisabled = true;
}

+ (void)enableReplays: (BOOL)enable {
    [BugBattle sharedInstance].replaysEnabled = enable;
    
    if ([BugBattle sharedInstance].replaysEnabled) {
        // Starts the replay helper.
        [[BugBattleReplayHelper sharedInstance] start];
    } else {
        [[BugBattleReplayHelper sharedInstance] stop];
    }
}

+ (void)startNetworkRecording {
    [[BugBattleHttpTrafficRecorder sharedRecorder] startRecording];
}

+ (void)startNetworkRecordingForSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    [[BugBattleHttpTrafficRecorder sharedRecorder] startRecordingForSessionConfiguration: configuration];
}

+ (void)stopNetworkRecording {
    [[BugBattleHttpTrafficRecorder sharedRecorder] stopRecording];
}

+ (void)setMaxNetworkLogs: (int)maxNetworkLogs {
    [[BugBattleHttpTrafficRecorder sharedRecorder] setMaxRequests: maxNetworkLogs];
}

+ (void)logEvent: (NSString *)name {
    [[BugBattleLogHelper sharedInstance] logEvent: name];
}

+ (void)logEvent: (NSString *)name withData: (NSDictionary *)data {
    [[BugBattleLogHelper sharedInstance] logEvent: name withData: data];
}

- (NSString *)getTopMostViewControllerName {
    NSString *currentViewControllerName = @"NotSet";
    UIViewController *topViewController = [self getTopMostViewController];
    if (topViewController != nil) {
        if (topViewController.title != nil) {
            currentViewControllerName = topViewController.title;
        } else {
            currentViewControllerName = NSStringFromClass([topViewController class]);
        }
    }
    return currentViewControllerName;
}

/*
 Returns the top most view controller.
 */
- (UIViewController *)getTopMostViewController {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    return [self topViewControllerWith: keyWindow.rootViewController];
}

/*
 Returns the top most view controller.
 */
- (UIViewController *)topViewControllerWith:(UIViewController *)rootViewController {
    if (rootViewController == nil) {
        return nil;
    }
    
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    if (presentedViewController == nil) {
        if ([rootViewController isKindOfClass: [UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)rootViewController;
            return [self topViewControllerWith: navController.viewControllers.lastObject];
        }
        
        if ([rootViewController isKindOfClass: [UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)rootViewController;
            return [self topViewControllerWith: tabBarController.selectedViewController];
        }
        
        return rootViewController;
    }
    return [self topViewControllerWith: presentedViewController];
}

- (void)setSDKToken:(NSString *)token {
    self.token = token;
    
    if (self.consoleLogDisabled != YES) {
        [self openConsoleLog];
    }
}

/*
 Costom initialize method
 */
+ (void)initWithToken: (NSString *)token andActivationMethod: (BugBattleActivationMethod)activationMethod {
    BugBattle* instance = [BugBattle sharedInstance];
    [instance setSDKToken: token];
    instance.activationMethods = @[@(activationMethod)];
    [instance performActivationMethodInit];
}

/*
 Costom initialize method
 */
+ (void)initWithToken: (NSString *)token andActivationMethods: (NSArray *)activationMethods {
    BugBattle* instance = [BugBattle sharedInstance];
    [instance setSDKToken: token];
    instance.activationMethods = activationMethods;
    [instance performActivationMethodInit];
}

/*
 Autoconfigure with token
 */
+ (void)autoConfigureWithToken: (NSString *)token {
    BugBattle* instance = [BugBattle sharedInstance];
    [instance setSDKToken: token];
    [self autoConfigure];
}

+ (void)autoConfigure {
    NSString *widgetConfigURL = [NSString stringWithFormat: @"https://widget.bugbattle.io/appwidget/%@/config?s=ios", BugBattle.sharedInstance.token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL: [NSURL URLWithString: widgetConfigURL]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        if (error == nil) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *e = nil;
            NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *configData = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
            if (e == nil && configData != nil) {
                [BugBattle.sharedInstance configureBugBattleWithConfig: configData];
                return;
            }
        }
        
        NSLog(@"Bugbattle: Auto-configuration failed. Please check your API key and internet connection.");
    }] resume];
}

- (void)configureBugBattleWithConfig: (NSDictionary *)config {
    if ([config objectForKey: @"color"] != nil) {
        UIColor * color = [self colorFromHexString: [config objectForKey: @"color"]];
        [BugBattle setColor: color];
    }
    if ([config objectForKey: @"enableNetworkLogs"] != nil && [[config objectForKey: @"enableNetworkLogs"] boolValue] == YES) {
        [BugBattle startNetworkRecording];
    }
    if ([config objectForKey: @"enableReplays"] != nil) {
        [BugBattle enableReplays: [[config objectForKey: @"enableReplays"] boolValue]];
    }
    if ([config objectForKey: @"logo"] != nil) {
        [BugBattle setLogoUrl: [config objectForKey: @"logo"]];
    }
    if ([config objectForKey: @"hideBugBattleLogo"] != nil && [[config objectForKey: @"hideBugBattleLogo"] boolValue] == YES) {
        [BugBattle enablePoweredByBugbattle: NO];
    } else {
        [BugBattle enablePoweredByBugbattle: YES];
    }
    
    NSMutableArray * activationMethods = [[NSMutableArray alloc] init];
    if ([config objectForKey: @"activationMethodShake"] != nil && [[config objectForKey: @"activationMethodShake"] boolValue] == YES) {
        [activationMethods addObject: @(SHAKE)];
    }
    if ([config objectForKey: @"activationMethodScreenshotGesture"] != nil && [[config objectForKey: @"activationMethodScreenshotGesture"] boolValue] == YES) {
        [activationMethods addObject: @(SCREENSHOT)];
    }
    if ([config objectForKey: @"activationMethodThreeFingerDoubleTab"] != nil && [[config objectForKey: @"activationMethodThreeFingerDoubleTab"] boolValue] == YES) {
        [activationMethods addObject: @(THREE_FINGER_DOUBLE_TAB)];
    }
    
    if (activationMethods.count > 0) {
        _activationMethods = activationMethods;
        [self performActivationMethodInit];
    }
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/**
 Check if activation method exists
 */
- (BOOL)isActivationMethodActive: (BugBattleActivationMethod)activationMethod {
    for (int i = 0; i < self.activationMethods.count; i++) {
        BugBattleActivationMethod currentActivationMethod = [[self.activationMethods objectAtIndex: i] intValue];
        if (currentActivationMethod == activationMethod) {
            return true;
        }
    }
    return false;
}

/**
    Performs initial checks for activation methods.
 */
- (void)performActivationMethodInit {
    if ([self isActivationMethodActive: THREE_FINGER_DOUBLE_TAB]) {
        [self initializeGestureRecognizer];
    }
    
    if ([self isActivationMethodActive: SCREENSHOT]) {
        [self initializeScreenshotRecognizer];
    }
}

- (void)initializeScreenshotRecognizer {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                    [BugBattle startBugReporting];
                                                  }];
}

- (void)initializeGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapGestureActivation:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    tapGestureRecognizer.numberOfTouchesRequired = 3;
    tapGestureRecognizer.cancelsTouchesInView = false;
    
    [[[[UIApplication sharedApplication] delegate] window] addGestureRecognizer: tapGestureRecognizer];
}

- (void)handleTapGestureActivation: (UITapGestureRecognizer *)recognizer
{
    [BugBattle startBugReporting];
}

+ (void)setApiUrl: (NSString *)apiUrl {
    BugBattle.sharedInstance.apiUrl = apiUrl;
}

+ (void)setPrivacyPolicyUrl: (NSString *)privacyPolicyUrl {
    BugBattle.sharedInstance.privacyPolicyUrl = privacyPolicyUrl;
}

+ (void)enablePrivacyPolicy:(BOOL)enable {
    BugBattle.sharedInstance.privacyPolicyEnabled = enable;
}

/**
 Sets the customer's email address.
 */
+ (void)setCustomerEmail: (NSString *)email {
    BugBattle.sharedInstance.customerEmail = email;
}

+ (void)setNavigationTint: (UIColor *)color {
    BugBattle.sharedInstance.navigationTint = color;
}

+ (void)setNavigationBarTint:(UIColor *)color __deprecated {
    
}

+ (void)setNavigationBarTitleColor:(UIColor *)color __deprecated {
    
}

+ (void)setColor:(UIColor *)color {
    BugBattle.sharedInstance.navigationTint = color;
}

/*
 Get's the framework's NSBundle.
 */
+ (NSBundle *)frameworkBundle {
    return [NSBundle bundleForClass: [BugBattle class]];
}

/*
 Starts the bug reporting flow, when a SDK key has been assigned.
 */
+ (void)startBugReporting {
    UIImage * screenshot = [BugBattle.sharedInstance captureScreen];
    [self startBugReportingWithScreenshot: screenshot];
}

/*
 Starts a silent bug reporting flow, when a SDK key has been assigned.
 */
+ (void)sendSilentBugReportWith:(NSString *)email andDescription:(NSString *)description andPriority:(BugBattleBugPriority)priority {
    NSMutableDictionary *dataToAppend = [[NSMutableDictionary alloc] init];
    
    NSString *bugReportPriority = @"LOW";
    if (priority == MEDIUM) {
        bugReportPriority = @"MEDIUM";
    }
    if (priority == HIGH) {
        bugReportPriority = @"HIGH";
    }
    
    [dataToAppend setValue: email forKey: @"reportedBy"];
    [dataToAppend setValue: description forKey: @"description"];
    [dataToAppend setValue: bugReportPriority forKey: @"priority"];
    
    [BugBattle attachData: dataToAppend];
    
    UIImage * screenshot = [BugBattle.sharedInstance captureScreen];
    [self startBugReportingWithScreenshot: screenshot andUI: false];
}

/*
 Starts the bug reporting flow, when a SDK key has been assigned.
 */
+ (void)startBugReportingWithScreenshot:(UIImage *)screenshot {
    [self startBugReportingWithScreenshot: screenshot andUI: true];
}

+ (void)startBugReportingWithScreenshot:(UIImage *)screenshot andUI:(BOOL)ui {
    if (BugBattle.sharedInstance.token.length == 0) {
        NSLog(@"WARN: Please provide a valid BugBattle project TOKEN!");
        return;
    }
    
    if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(bugWillBeSent)]) {
        [BugBattle.sharedInstance.delegate bugWillBeSent];
    }
    
    // Update last screen name
    [BugBattle.sharedInstance updateLastScreenName];
    
    // Stop replays
    [[BugBattleReplayHelper sharedInstance] stop];
    [BugBattle attachScreenshot: screenshot];
    
    if (ui) {
        // UI flow
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"BugBattleStoryboard" bundle: [BugBattle frameworkBundle]];
        BugBattleImageEditorViewController *bugBattleImageEditor = [storyboard instantiateViewControllerWithIdentifier: @"BugBattleImageEditorViewController"];
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController: bugBattleImageEditor];
        navController.navigationBar.barStyle = UIBarStyleBlack;
        [navController.navigationBar setTranslucent: NO];
        [navController.navigationBar setTintColor: BugBattle.sharedInstance.navigationTint];
        [navController.navigationBar setBarTintColor: [UIColor whiteColor]];
        [navController.navigationBar setTitleTextAttributes:
           @{NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        // Show on top of all viewcontrollers.
        [[BugBattle.sharedInstance getTopMostViewController] presentViewController: navController animated: true completion:^{
            [bugBattleImageEditor setScreenshot: screenshot];
        }];
    } else {
        // No UI flow
        [BugBattle.sharedInstance sendReport:^(bool success) {
            if (success) {
                if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(bugSent)]) {
                    [BugBattle.sharedInstance.delegate bugSent];
                }
            } else {
                if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(bugSendingFailed)]) {
                    [BugBattle.sharedInstance.delegate bugSendingFailed];
                }
            }
            [BugBattle afterBugReportCleanup];
        }];
    }
}

/*
 Invoked when a shake gesture is beeing performed.
 */
+ (void)shakeInvocation {
    if ([[BugBattle sharedInstance] isActivationMethodActive: SHAKE]) {
        [BugBattle startBugReporting];
    }
}

/*
 Attaches custom data, which can be viewed in the BugBattle dashboard. New data will be merged with existing custom data.
 */
+ (void)attachCustomData: (NSDictionary *)customData {
    [[BugBattle sharedInstance].customData addEntriesFromDictionary: customData];
}

/*
 Clears all custom data.
 */
+ (void)clearCustomData {
    [[BugBattle sharedInstance].customData removeAllObjects];
}

/**
 * Attach one key value pair to existing custom data.
 */
+ (void)setCustomData: (NSString *)value forKey: (NSString *)key {
    [[BugBattle sharedInstance].customData setObject: value forKey: key];
}

/**
 * Removes one key from existing custom data.
 */
+ (void)removeCustomDataForKey: (NSString *)key {
    [[BugBattle sharedInstance].customData removeObjectForKey: key];
}

/*
 Attaches a screenshot.
 */
+ (void)attachScreenshot: (UIImage *)screenshot {
    [BugBattle sharedInstance].screenshot = screenshot;
}

/*
 Returns the attacked screenshot.
 */
+ (UIImage *)getAttachedScreenshot {
    return [BugBattle sharedInstance].screenshot;
}

/*
 Attaches custom data to a report.
 */
+ (void)attachData: (NSDictionary *)data {
    [BugBattle.sharedInstance.data addEntriesFromDictionary: data];
}

/**
 Sets the application type.
 */
+ (void)setApplicationType: (BugBattleApplicationType)applicationType {
    BugBattle.sharedInstance.applicationType = applicationType;
}

+ (void)enablePoweredByBugbattle: (BOOL)enable {
    BugBattle.sharedInstance.enablePoweredBy = enable;
}

+ (void)setLogoUrl: (NSString *)logoUrl {
    BugBattle.sharedInstance.logoUrl = logoUrl;
}

/*
 Captures the current screen as UIImage.
 */
- (UIImage *)captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (self.applicationType == FLUTTER) {
        UIGraphicsBeginImageContextWithOptions([keyWindow bounds].size, false, [UIScreen mainScreen].scale);
        NSArray *views = [keyWindow subviews];
        for (int i = 0; i < views.count; i++) {
            UIView *view = [views objectAtIndex: i];
            [view drawViewHierarchyInRect: view.bounds afterScreenUpdates: true];
        }
    } else {
        UIGraphicsBeginImageContextWithOptions([keyWindow bounds].size, false, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext: context];
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
 Sends a bugreport to our backend.
 */
- (void)sendReport: (void (^)(bool success))completion {
    if (self.replaysEnabled) {
        [[BugBattle sharedInstance] uploadStepImages: [BugBattleReplayHelper sharedInstance].replaySteps andCompletion:^(bool success, NSArray * _Nonnull fileUrls) {
            if (success) {
                // Attach replay
                [BugBattle attachData: @{ @"replay": @{
                                                  @"interval": @1000,
                                                  @"frames": fileUrls
                } }];
            }
            
            [self uploadScreenshotAndSendBugReport:^(bool success) {
                completion(success);
            }];
        }];
    } else {
        [self uploadScreenshotAndSendBugReport:^(bool success) {
            completion(success);
        }];
    }
}

- (void)updateLastScreenName {
    _lastScreenName = [self getTopMostViewControllerName];
}

- (void)uploadScreenshotAndSendBugReport: (void (^)(bool success))completion {
    // Process with image upload
    [self uploadImage: self.screenshot andCompletion:^(bool success, NSString *fileUrl) {
        if (!success) {
            return completion(false);
        }
        
        // Set screenshot url.
        NSMutableDictionary *dataToAppend = [[NSMutableDictionary alloc] init];
        [dataToAppend setValue: fileUrl forKey: @"screenshotUrl"];
        [BugBattle attachData: dataToAppend];
        
        // Fetch additional metadata.
        [BugBattle attachData: @{ @"metaData": [self getMetaData] }];
        
        // Attach console log.
        [BugBattle attachData: @{ @"consoleLog": self->_consoleLog }];
        
        // Attach steps to reproduce.
        [BugBattle attachData: @{ @"actionLog": self->_stepsToReproduce }];
        
        // Attach custom data.
        [BugBattle attachData: @{ @"customData": [self customData] }];
        
        // Attach custom event log.
        [BugBattle attachData: @{ @"customEventLog": [[BugBattleLogHelper sharedInstance] getLogs] }];
        
        // Attach custom data.
        if ([[[BugBattleHttpTrafficRecorder sharedRecorder] networkLogs] count] > 0) {
            [BugBattle attachData: @{ @"networkLogs": [[BugBattleHttpTrafficRecorder sharedRecorder] networkLogs] }];
        }
        
        // Sending report to server.
        [self sendReportToServer:^(bool success) {
            completion(success);
        }];
    }];
}

/*
 Sends a bugreport to our backend.
 */
- (void)sendReportToServer: (void (^)(bool success))completion {
    if (_token == NULL || [_token isEqualToString: @""]) {
        return completion(false);
    }
    
    NSError *error;
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject: _data options:kNilOptions error: &error];
    
    // Check for parsing error.
    if (error != nil) {
        return completion(false);
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@/bugs", _apiUrl]]];
    [request setValue: _token forHTTPHeaderField: @"Api-Token"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
    [request setHTTPBody: jsonBodyData];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (error != nil) {
                                                    return completion(false);
                                                }
                                                return completion(true);
                                            }];
    [task resume];
}

/*
 Upload file
 */
- (void)uploadFile: (NSData *)fileData andFileName: (NSString*)filename andContentType: (NSString*)contentType andCompletion: (void (^)(bool success, NSString *fileUrl))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@/uploads/sdk", _apiUrl]]];
    [request setValue: _token forHTTPHeaderField: @"Api-Token"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    // Build multipart/form-data
    NSString *boundary = @"BBBOUNDARY";
    NSString *headerContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue: headerContentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    // Add file data
    if (fileData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", @"file", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat: @"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: fileData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // Set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != NULL) {
            return completion(false, nil);
        }
        
        NSError *parseError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData: data options: 0 error:&parseError];
        if (!parseError) {
            NSString* fileUrl = [responseDict objectForKey: @"fileUrl"];
            return completion(true, fileUrl);
        } else {
            return completion(false, nil);
        }
    }];
    [task resume];
}

/*
 Upload image
 */
- (void)uploadImage: (UIImage *)image andCompletion: (void (^)(bool success, NSString *fileUrl))completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *contentType = @"image/jpeg";
    [self uploadFile: imageData andFileName: @"screenshot.jpeg" andContentType: contentType andCompletion: completion];
}

/*
 Upload files
 */
- (void)uploadStepImages: (NSArray *)steps andCompletion: (void (^)(bool success, NSArray *fileUrls))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@/uploads/sdksteps", self->_apiUrl]]];
        [request setValue: self->_token forHTTPHeaderField: @"Api-Token"];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        
        // Build multipart/form-data
        NSString *boundary = @"BBBOUNDARY";
        NSString *headerContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue: headerContentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        
        for (int i = 0; i < steps.count; i++) {
            NSDictionary *currentStep = [steps objectAtIndex: i];
            UIImage *currentImage = [currentStep objectForKey: @"image"];
            
            // Resize screenshot
            CGSize size = CGSizeMake(currentImage.size.width * 0.5, currentImage.size.height * 0.5);
            UIGraphicsBeginImageContext(size);
            [currentImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *imageData = UIImageJPEGRepresentation(destImage, 0.9);
            NSString *filename = [NSString stringWithFormat: @"step_%i", i];
            if (imageData) {
                NSString *contentType = @"image/jpeg";
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", @"file", filename] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat: @"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData: imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != NULL) {
                return completion(false, nil);
            }
            
            NSError *parseError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData: data options: 0 error:&parseError];
            if (!parseError) {
                NSArray* fileUrls = [responseDict objectForKey: @"fileUrls"];
                NSMutableArray *replayArray = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < steps.count; i++) {
                    NSMutableDictionary *currentStep = [[steps objectAtIndex: i] mutableCopy];
                    NSString *currentImageUrl = [fileUrls objectAtIndex: i];
                    [currentStep setObject: currentImageUrl forKey: @"url"];
                    [currentStep removeObjectForKey: @"image"];
                    [replayArray addObject: currentStep];
                }
                
                return completion(true, replayArray);
            } else {
                return completion(false, nil);
            }
        }];
        [task resume];
    });
}

/*
 Returns the session's duration.
 */
- (double)sessionDuration {
    return [_sessionStart timeIntervalSinceNow] * -1.0;
}

/**
    Returns the device model name;
 */
- (NSString*)getDeviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *)getApplicationTypeAsString {
    NSString *applicationType = @"Native";
    if (self.applicationType == FLUTTER) {
        applicationType = @"Flutter";
    } else if (self.applicationType == REACTNATIVE) {
        applicationType = @"ReactNative";
    }
    return applicationType;
}

/*
 Returns all meta data as an NSDictionary.
 */
- (NSDictionary *)getMetaData {
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceName = currentDevice.name;
    NSString *deviceModel = [self getDeviceModelName];
    NSString *systemName = currentDevice.systemName;
    NSString *systemVersion = currentDevice.systemVersion;
    NSString *deviceIdentifier = [[currentDevice identifierForVendor] UUIDString];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *releaseVersionNumber = [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleShortVersionString"];
    NSString *buildVersionNumber = [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleVersion"];
    NSNumber *sessionDuration = [NSNumber numberWithDouble: [self sessionDuration]];
    NSString *preferredUserLocale = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    
    return @{
        @"deviceName": deviceName,
        @"deviceModel": deviceModel,
        @"deviceIdentifier": deviceIdentifier,
        @"bundleID": bundleId,
        @"systemName": systemName,
        @"systemVersion": systemVersion,
        @"buildVersionNumber": buildVersionNumber,
        @"releaseVersionNumber": releaseVersionNumber,
        @"sessionDuration": sessionDuration,
        @"applicationType": [self getApplicationTypeAsString],
        @"lastScreenName": _lastScreenName,
        @"preferredUserLocale": preferredUserLocale
    };
}

- (NSString *)getJSStringForNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [dateFormatter stringFromDate: date];
}

- (NSString *)getCurrentJSDate {
    return [self getJSStringForNSDate: [[NSDate alloc] init]];
}

/*
 Starts reading the console output.
 */
- (void)openConsoleLog {
    if (isatty(STDERR_FILENO)) {
        NSLog(@"[BugBattle] Console logs are captured only when the debugger is not attached.");
        return;
    }
    
    _inputPipe = [[NSPipe alloc] init];
    
    dup2([[_inputPipe fileHandleForWriting] fileDescriptor], STDERR_FILENO);
    
    [NSNotificationCenter.defaultCenter addObserver: self selector: @selector(receiveLogNotification:)  name: NSFileHandleReadCompletionNotification object: _inputPipe.fileHandleForReading];
    
    [_inputPipe.fileHandleForReading readInBackgroundAndNotify];
}

/*
 This callback receives all console output notifications and saves them for further use.
 */
- (void)receiveLogNotification:(NSNotification *) notification
{
    [_inputPipe.fileHandleForReading readInBackgroundAndNotify];
    NSData *data = notification.userInfo[NSFileHandleNotificationDataItem];
    
    NSString *consoleLogLines = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if (consoleLogLines != NULL) {
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+\\d+ .+\\[.+:.+\\] " options:NSRegularExpressionCaseInsensitive error:&error];
        consoleLogLines = [regex stringByReplacingMatchesInString: consoleLogLines options: 0 range:NSMakeRange(0, [consoleLogLines length]) withTemplate:@"#BBNL#"];
        
        NSArray *lines = [consoleLogLines componentsSeparatedByString: @"#BBNL#"];
        for (int i = 0; i < lines.count; i++) {
            NSString *line = [lines objectAtIndex: i];
            if (line != NULL && ![line isEqualToString: @""]) {
                NSString *dateString = [self getJSStringForNSDate: [[NSDate alloc] init]];
                NSDictionary *log = @{ @"date": dateString, @"log": line, @"priority": @"INFO" };
                if (_consoleLog.count > 1000) {
                    [_consoleLog removeObjectAtIndex: 0];
                }
                [_consoleLog addObject: log];
            }
        }
    }
}

@end
