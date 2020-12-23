//
//  BugBattle.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleCore.h"
#import "BugBattleImageEditorViewController.h"

@interface BugBattle ()

@property (weak, nonatomic) UIImage *screenshot;
@property (retain, nonatomic) UIColor *navigationBarTint;
@property (retain, nonatomic) UIColor *navigationTint;
@property (retain, nonatomic) UIColor *navigationBarTitleColor;
@property (retain, nonatomic) NSDate *sessionStart;
@property (retain, nonatomic) NSMutableArray *consoleLog;
@property (retain, nonatomic) NSMutableArray *callstack;
@property (retain, nonatomic) NSMutableArray *stepsToReproduce;
@property (retain, nonatomic) NSDictionary *customData;
@property (retain, nonatomic) NSPipe *inputPipe;
@property (retain, nonatomic) NSPipe *outputPipe;
@property (retain, nonatomic) NSTimer *stepsToReproduceTimer;
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
    self.token = @"";
    self.apiUrl = @"https://api.bugbattle.io";
    self.privacyPolicyEnabled = false;
    self.privacyPolicyUrl = @"https://www.bugbattle.io/privacy-policy/";
    self.activationMethod = NONE;
    self.data = [[NSMutableDictionary alloc] init];
    self.sessionStart = [[NSDate alloc] init];
    self.consoleLog = [[NSMutableArray alloc] init];
    self.callstack = [[NSMutableArray alloc] init];
    self.stepsToReproduce = [[NSMutableArray alloc] init];
    self.customData = [[NSDictionary alloc] init];
    self.navigationTint = [UIColor systemBlueColor];
    self.navigationBarTint = [UIColor whiteColor];
    self.navigationBarTitleColor = [UIColor blackColor];
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationBarTint = [UIColor systemBackgroundColor];
            self.navigationBarTitleColor = [UIColor whiteColor];
        }
    }
    
    // Open console log.
    [self openConsoleLog];
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

/*
 Costom initialize method
 */
+ (void)initWithToken: (NSString *)token andActivationMethod: (BugBattleActivationMethod)activationMethod {
    BugBattle* instance = [BugBattle sharedInstance];
    instance.token = token;
    instance.activationMethod = activationMethod;
    
    if (activationMethod == THREE_FINGER_DOUBLE_TAB) {
        [instance initializeGestureRecognizer];
    }
    
    if (activationMethod == SCREENSHOT) {
        [instance initializeScreenshotRecognizer];
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
    [[NSUserDefaults standardUserDefaults] setValue: email forKey: @"BugBattle_SenderEmail"];
}

/*
 Sets the navigationbar tint color.
 */
+ (void)setNavigationBarTint: (UIColor *)color {
    BugBattle.sharedInstance.navigationBarTint = color;
}

/*
 Sets the navigation tint color.
 */
+ (void)setNavigationTint: (UIColor *)color {
    BugBattle.sharedInstance.navigationTint = color;
}

/*
 Sets the navigationbar title color.
 */
+ (void)setNavigationBarTitleColor: (UIColor *)color {
    BugBattle.sharedInstance.navigationBarTitleColor = color;
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
 Starts the bug reporting flow, when a SDK key has been assigned.
 */
+ (void)startBugReportingWithScreenshot:(UIImage *)screenshot {
    if (BugBattle.sharedInstance.token.length == 0) {
        NSLog(@"WARN: Please provide a valid BugBattle project TOKEN!");
        return;
    }
    
    // Stop screen capturung
    [BugBattle.sharedInstance.stepsToReproduceTimer invalidate];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"BugBattleStoryboard" bundle: [BugBattle frameworkBundle]];
    BugBattleImageEditorViewController *bugBattleImageEditor = [storyboard instantiateViewControllerWithIdentifier: @"BugBattleImageEditorViewController"];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController: bugBattleImageEditor];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    [navController.navigationBar setTranslucent: NO];
    [navController.navigationBar setBarTintColor: BugBattle.sharedInstance.navigationBarTint];
    [navController.navigationBar setTintColor: BugBattle.sharedInstance.navigationTint];
    navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: BugBattle.sharedInstance.navigationBarTitleColor};
    
    // Show on top of all viewcontrollers.
    [[BugBattle.sharedInstance getTopMostViewController] presentViewController: navController animated: true completion:^{
        [bugBattleImageEditor setScreenshot: screenshot];
    }];
}

/*
 Invoked when a shake gesture is beeing performed.
 */
+ (void)shakeInvocation {
    if ([BugBattle sharedInstance].activationMethod == SHAKE) {
        [BugBattle startBugReporting];
    }
}

/*
 Attaches custom data.
 */
+ (void)attachCustomData: (NSDictionary *)customData {
    [BugBattle sharedInstance].customData = customData;
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

/*
 Tracks a new step.
 */
+ (void)trackStepWithType: (NSString *)type andData: (NSString *)data {
    [BugBattle.sharedInstance.stepsToReproduce addObject: @{
        @"type": type,
        @"data": data,
        @"date": [BugBattle.sharedInstance getJSStringForNSDate: [[NSDate alloc] init]]
    }];
}

/*
 Captures the current screen as UIImage.
 */
- (UIImage *) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext: context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
 Sends a bugreport to our backend.
 */
- (void)sendReport: (void (^)(bool success))completion {
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
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *contentType = @"image/jpeg";
    [self uploadFile: imageData andFileName: @"screenshot.jpeg" andContentType: contentType andCompletion: completion];
}

/*
 Returns the session's duration.
 */
- (double)sessionDuration {
    return [_sessionStart timeIntervalSinceNow] * -1.0;
}

/*
 Returns all meta data as an NSDictionary.
 */
- (NSDictionary *)getMetaData {
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceName = currentDevice.name;
    NSString *deviceModel = currentDevice.model;
    NSString *systemName = currentDevice.systemName;
    NSString *systemVersion = currentDevice.systemVersion;
    NSString *deviceIdentifier = [[currentDevice identifierForVendor] UUIDString];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *releaseVersionNumber = [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleShortVersionString"];
    NSString *buildVersionNumber = [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleVersion"];
    NSNumber *sessionDuration = [NSNumber numberWithDouble: [self sessionDuration]];
    
    return @{
        @"deviceName": deviceName,
        @"deviceModel": deviceModel,
        @"deviceIdentifier": deviceIdentifier,
        @"bundleID": bundleId,
        @"systemName": systemName,
        @"systemVersion": systemVersion,
        @"buildVersionNumber": buildVersionNumber,
        @"releaseVersionNumber": releaseVersionNumber,
        @"sessionDuration": sessionDuration
    };
}

- (NSString *)getJSStringForNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [dateFormatter stringFromDate: date];
}

/*
 Starts reading the console output.
 */
- (void)openConsoleLog {
    _inputPipe = [[NSPipe alloc] init];
    _outputPipe = [[NSPipe alloc] init];
    
    dup2(STDOUT_FILENO, _outputPipe.fileHandleForWriting.fileDescriptor);
    dup2(_inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO);
    dup2(_inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO);
    
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
    
    [[_outputPipe fileHandleForWriting] writeData: data];
    
    NSString *consoleLogLines = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if (consoleLogLines != NULL) {
        NSArray *lines = [consoleLogLines componentsSeparatedByString: @"\n"];
        for (int i = 0; i < lines.count; i++) {
            NSString *line = [lines objectAtIndex: i];
            if (line != NULL && ![line isEqualToString: @""]) {
                NSString *dateString = [self getJSStringForNSDate: [[NSDate alloc] init]];
                NSDictionary *log = @{ @"date": dateString, @"log": line };
                if (_consoleLog.count > 1000) {
                    [_consoleLog removeObjectAtIndex: 0];
                }
                [_consoleLog addObject: log];
            }
        }
    }
}

@end
