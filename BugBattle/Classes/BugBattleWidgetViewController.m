//
//  BugBattleWidgetViewController.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleWidgetViewController.h"
#import "BugBattleTouchDrawImageView.h"
#import "BugBattleCore.h"
#import "BugBattleReplayHelper.h"
#import "BugBattleTranslationHelper.h"
#import "BugBattleImageEditorViewController.h"
#import <SafariServices/SafariServices.h>
#import <math.h>

@interface BugBattleWidgetViewController ()
@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotWidthContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotHeightContraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *reportSent;
@property (weak, nonatomic) IBOutlet UILabel *labelSent;
@property (weak, nonatomic) IBOutlet UIImageView *sentImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (nonatomic, assign) UIImage *screenshotImage;
@property (nonatomic, assign) bool sending;
@property (nonatomic, assign) bool screenshotEditorIsFirstStep;

@end

@implementation BugBattleWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenshotEditorIsFirstStep = NO;
    [_loadingView setHidden: YES];
    [_reportSent setHidden: YES];
    
    self.view.backgroundColor = UIColor.clearColor;
    
    _sentImageView.tintColor = BugBattle.sharedInstance.navigationTint;
    _sentImageView.image = [_sentImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    _loadingActivityView.color = BugBattle.sharedInstance.navigationTint;
    _labelSent.text = [BugBattleTranslationHelper localizedString: @"report_sent"];
    
    [self createWebView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (void)closeReporting:(id)sender {
    [self dismissViewControllerAnimated: YES completion:^{
        [self onDismissCleanup];
    }];
}

- (void)showEditorView {
    self.navigationItem.title = [BugBattleTranslationHelper localizedString: @"mark_the_bug"];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"BugBattleStoryboard" bundle: [BugBattle frameworkBundle]];
    BugBattleImageEditorViewController *bugBattleImageEditor = [storyboard instantiateViewControllerWithIdentifier: @"BugBattleImageEditorViewController"];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController: bugBattleImageEditor];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    [navController.navigationBar setTranslucent: NO];
    [navController.navigationBar setTintColor: BugBattle.sharedInstance.navigationTint];
    [navController.navigationBar setBarTintColor: [UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:
       @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController: navController animated: YES completion:^{
        [bugBattleImageEditor setScreenshot: self.screenshotImage];
    }];
}

- (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message
{
    if ([message.name isEqualToString: @"customActionCalled"]) {
        if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(customActionCalled:)]) {
            [BugBattle.sharedInstance.delegate customActionCalled: [message.body objectForKey: @"name"]];
        }
        [self closeReporting: nil];
    }
    
    if ([message.name isEqualToString: @"openExternalURL"]) {
        UIViewController *presentingViewController = self.presentingViewController;
        [self dismissViewControllerAnimated: YES completion:^{
            [self onDismissCleanup];
            [self openURLExternally: [NSURL URLWithString: [message.body objectForKey: @"url"]] fromViewController: presentingViewController];
        }];
    }
    
    if ([message.name isEqualToString: @"closeBugBattle"]) {
        [self closeReporting: nil];
    }
    
    if ([message.name isEqualToString: @"selectedMenuOption"]) {
        // [self showBackButton];
    }
    
    if ([message.name isEqualToString: @"sendFeedback"]) {
        NSDictionary *formData = [message.body objectForKey: @"formData"];
        NSString *feedbackType = [message.body objectForKey: @"type"];
        
        NSMutableDictionary *dataToAppend = [[NSMutableDictionary alloc] init];
        
        [dataToAppend setValue: @"MEDIUM" forKey: @"priority"];
        [dataToAppend setValue: formData forKey: @"formData"];
        [dataToAppend setValue: feedbackType forKey: @"type"];
        [BugBattle attachData: dataToAppend];
        
        [self sendBugReport];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURL *url = navigationAction.request.URL;
    [self openURLExternally: url fromViewController: self];
    return nil;
}

- (void)createWebView {
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController* userController = [[WKUserContentController alloc] init];
    [userController addScriptMessageHandler: self name: @"sendFeedback"];
    [userController addScriptMessageHandler: self name: @"openScreenshotEditor"];
    [userController addScriptMessageHandler: self name: @"selectedMenuOption"];
    [userController addScriptMessageHandler: self name: @"customActionCalled"];
    [userController addScriptMessageHandler: self name: @"openExternalURL"];
    [userController addScriptMessageHandler: self name: @"closeBugBattle"];
    webConfig.userContentController = userController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration: webConfig];
    self.webView.opaque = false;
    self.webView.backgroundColor = UIColor.clearColor;
    self.webView.scrollView.backgroundColor = UIColor.clearColor;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view insertSubview: self.webView belowSubview: self.loadingView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    NSURL * url = [NSURL URLWithString: [NSString stringWithFormat: @"http://192.168.1.132:9002/appwidgetv5/%@?email=%@&lang=%@&enableprivacypolicy=%@&privacyplicyurl=%@&color=%@&logourl=%@&showpoweredby=%@", BugBattle.sharedInstance.token, [BugBattle.sharedInstance.customerEmail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [BugBattle.sharedInstance.language stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], BugBattle.sharedInstance.privacyPolicyEnabled ? @"true" : @"false", [BugBattle.sharedInstance.privacyPolicyUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [self hexStringForColor: BugBattle.sharedInstance.navigationTint], [BugBattle.sharedInstance.logoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], BugBattle.sharedInstance.enablePoweredBy ? @"true" : @"false"]];
    NSURLRequest * request = [NSURLRequest requestWithURL: url];
    [self.webView loadRequest: request];
}

- (NSString *)hexStringForColor:(UIColor *)color {
      const CGFloat *components = CGColorGetComponents(color.CGColor);
      CGFloat r = components[0];
      CGFloat g = components[1];
      CGFloat b = components[2];
      NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
      return hexString;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [_loadingView setHidden: false];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self->_loadingView setHidden: true];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self loadingFailed: error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self loadingFailed: error];
}

- (void)loadingFailed:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: error.localizedDescription
                                                                             message: nil
                                                                      preferredStyle: UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated: YES completion:^{
            
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)openURLExternally:(NSURL *)url fromViewController:(UIViewController *)presentingViewController {
    if ([SFSafariViewController class]) {
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL: url];
        viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [presentingViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL: url]) {
            [[UIApplication sharedApplication] openURL: url];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURL *url = navigationAction.request.URL;
        if ([url.absoluteString hasPrefix: @"mailto:"]) {
            if ([[UIApplication sharedApplication] canOpenURL: url]) {
                [[UIApplication sharedApplication] openURL: url];
            }
        } else {
            [self openURLExternally: url fromViewController: self];
        }
        return decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    return decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)sendBugReport {
    self.navigationItem.leftBarButtonItem = false;
    self.navigationItem.rightBarButtonItem = false;
    
    [_loadingView setHidden: false];
    [BugBattle.sharedInstance sendReport:^(bool success) {
        if (success) {
            [self->_loadingView setHidden: true];
            [self->_reportSent setHidden: false];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                self.sending = NO;
                [self dismissViewControllerAnimated: true completion:^{
                    [self onDismissCleanup];
                }];
            });
            
            if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(bugSent)]) {
                [BugBattle.sharedInstance.delegate bugSent];
            }
        } else {
            self.sending = NO;
            [[self navigationController] setNavigationBarHidden: NO animated: NO];
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle: [BugBattleTranslationHelper localizedString: @"report_failed_title"]
                                         message: [BugBattleTranslationHelper localizedString: @"report_failed"]
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle: [BugBattleTranslationHelper localizedString: @"ok"]
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [self dismissViewControllerAnimated: true completion:^{
                                                [self onDismissCleanup];
                                            }];
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
            
            if (BugBattle.sharedInstance.delegate && [BugBattle.sharedInstance.delegate respondsToSelector: @selector(bugSendingFailed)]) {
                [BugBattle.sharedInstance.delegate bugSendingFailed];
            }
        }
    }];
}

- (void)setScreenshot:(UIImage *)image {
    self.screenshotImage = image;
}

- (void)onDismissCleanup {
    [BugBattle afterBugReportCleanup];
}

@end
