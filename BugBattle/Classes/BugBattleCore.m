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
@property (retain, nonatomic) NSDate *sessionStart;
@property (retain, nonatomic) NSMutableArray *consoleLog;
@property (retain, nonatomic) NSMutableArray *callstack;
@property (retain, nonatomic) NSMutableArray *stepsToReproduce;
@property (retain, nonatomic) NSDictionary *customData;
@property (retain, nonatomic) NSPipe *inputPipe;
@property (retain, nonatomic) NSPipe *outputPipe;
@property (retain, nonatomic) NSTimer *stepsToReproduceTimer;

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
    self.activationMethod = NONE;
    self.data = [[NSMutableDictionary alloc] init];
    self.sessionStart = [[NSDate alloc] init];
    self.consoleLog = [[NSMutableArray alloc] init];
    self.callstack = [[NSMutableArray alloc] init];
    self.stepsToReproduce = [[NSMutableArray alloc] init];
    self.customData = [[NSDictionary alloc] init];
    self.navigationBarTint = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 1.0];
    
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
 Get's the framework's NSBundle.
 */
+ (NSBundle *)frameworkBundle {
    return [NSBundle bundleForClass: [BugBattle class]];
}

/*
 Starts the bug reporting flow, when a SDK key has been assigned.
 */
+ (void)startBugReporting {
    if (BugBattle.sharedInstance.token.length > 0) {
        // Stop screen capturung
        [BugBattle.sharedInstance.stepsToReproduceTimer invalidate];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"BugBattleStoryboard" bundle: [BugBattle frameworkBundle]];
        BugBattleImageEditorViewController *bugBattleImageEditor = [storyboard instantiateViewControllerWithIdentifier: @"BugBattleImageEditorViewController"];
        
        UIImage * screenshot = [BugBattle.sharedInstance captureScreen];
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController: bugBattleImageEditor];
        navController.navigationBar.barStyle = UIBarStyleBlack;
        [navController.navigationBar setTranslucent: NO];
        [navController.navigationBar setBarTintColor: BugBattle.sharedInstance.navigationBarTint];
        [navController.navigationBar setTintColor: [UIColor whiteColor]];
        navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        // Show on top of all viewcontrollers.
        [[BugBattle.sharedInstance getTopMostViewController] presentViewController: navController animated: true completion:^{
            [bugBattleImageEditor setScreenshot: screenshot];
        }];
    } else {
        NSLog(@"WARN: Please provide a valid BugBattle project TOKEN!");
    }
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
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
 Sends a bugreport to our backend.
 */
- (void)sendReport: (void (^)(bool success))completion {
    [self getPresignedURL:^(NSDictionary *data) {
        if (data != nil) {
            // Upload screenshot.
            NSString *url = [data objectForKey: @"url"];
            NSString *finalUrl = [data objectForKey: @"path"];
            [self uploadImage: self.screenshot toAWSWithUrl: url andCompletion:^(bool success) {
                if (!success) {
                    return completion(false);
                }
                
                // Set screenshot url.
                NSMutableDictionary *dataToAppend = [[NSMutableDictionary alloc] init];
                [dataToAppend setValue: finalUrl forKey: @"screenshot"];
                [BugBattle attachData: dataToAppend];
                
                // Fetch additional metadata.
                [BugBattle attachData: @{ @"meta": [self getMetaData] }];
                
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
        } else {
            completion(false);
        }
    }];
}

/*
 Sends a bugreport to our backend.
 */
- (void)sendReportToServer: (void (^)(bool success))completion {
    if (_token == NULL || [_token isEqualToString: @""]) {
        return completion(false);
    }
    
    NSString *urlString = [NSString stringWithFormat: @"https://webhooks.mongodb-stitch.com/api/client/v2.0/app/bugbattle-xfblb/service/reportBug/incoming_webhook/reportBugWebhook?token=%@", _token];
    
    NSError *error;
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject: _data options:kNilOptions error: &error];
    
    // Check for parsing error.
    if (error != nil) {
        return completion(false);
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL: [NSURL URLWithString: urlString]];
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
 Prepares a signed URL for uploading images to S3.
 */
- (void)getPresignedURL: (void (^)(NSDictionary* response))completion {
    NSString *urlString = @"https://ii5xbrdd27.execute-api.eu-central-1.amazonaws.com/default/getSignedBugBattleUploadUrl";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject: BugBattle.sharedInstance.token forKey: @"apiKey"];
    
    NSError *error;
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject: dict options:kNilOptions error: &error];
    if (error) {
        return completion(nil);
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL: [NSURL URLWithString: urlString]];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
    [request setHTTPBody: jsonBodyData];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != NULL) {
            return completion(nil);
        }
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        return completion(responseData);
    }];
    [task resume];
}

/*
 Uploads an image to S3.
 */
- (void)uploadImage: (UIImage *)image toAWSWithUrl: (NSString *)presignedURL andCompletion: (void (^)(bool success))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"PUT";
    [request setURL: [NSURL URLWithString: presignedURL]];
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [request setHTTPBody: data];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != NULL) {
            return completion(false);
        }
        return completion(true);
    }];
    [task resume];
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
                [_consoleLog addObject: log];
            }
        }
    }
}

@end
