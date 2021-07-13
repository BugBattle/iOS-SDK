//
//  BugBattleImageEditorViewController.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleImageEditorViewController.h"
#import "BugBattleTouchDrawImageView.h"
#import "BugBattleCore.h"
#import "BugBattleReplayHelper.h"
#import "BugBattleTranslationHelper.h"
#import <SafariServices/SafariServices.h>
#import <math.h>

@interface BugBattleImageEditorViewController ()
@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet BugBattleTouchDrawImageView *screenshotImageView;
@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIView *colorSelectionView;
@property (weak, nonatomic) IBOutlet UIView *mainToolsView;
@property (weak, nonatomic) IBOutlet UIButton *colorPreview1;
@property (weak, nonatomic) IBOutlet UIButton *colorPreview2;
@property (weak, nonatomic) IBOutlet UIButton *colorPreview3;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *blurButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotWidthContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotHeightContraint;
@property (copy, nonatomic) NSArray *colorViews;
@property (copy, nonatomic) NSArray *previewColorViews;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *reportSent;
@property (weak, nonatomic) IBOutlet UILabel *labelSent;
@property (weak, nonatomic) IBOutlet UILabel *labelLoading;
@property (weak, nonatomic) IBOutlet UIImageView *sentImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (nonatomic, assign) bool sending;
@property (nonatomic, assign) bool lastStepWasScreenshotEditor;
@property (nonatomic, assign) bool screenshotEditorIsFirstStep;

@end

@implementation BugBattleImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lastStepWasScreenshotEditor = NO;
    _screenshotEditorIsFirstStep = NO;
    [_loadingView setHidden: YES];
    [_reportSent setHidden: YES];
    
    _sentImageView.tintColor = BugBattle.sharedInstance.navigationTint;
    _sentImageView.image = [_sentImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    _loadingActivityView.color = BugBattle.sharedInstance.navigationTint;
    _labelSent.text = [BugBattleTranslationHelper localizedString: @"report_sent"];
    _labelLoading.text = [BugBattleTranslationHelper localizedString: @"preparing_feedback"];
    
    self.navigationItem.title = @"";
    [self showCancelButton];
    
    [self createWebView];
    [self initializeScreenshotEditor];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (void)showBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: [BugBattleTranslationHelper localizedString: @"report_back"] style: UIBarButtonItemStylePlain target: self action: @selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)showCancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: [BugBattleTranslationHelper localizedString: @"report_cancel"] style: UIBarButtonItemStylePlain target: self action: @selector(closeReporting:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)closeReporting:(id)sender {
    [self dismissViewControllerAnimated: YES completion:^{
        [self onDismissCleanup];
    }];
}

- (void)showNextButton {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle: [BugBattleTranslationHelper localizedString: @"report_next"] style: UIBarButtonItemStyleDone target: self action: @selector(showNextStep:)];
    self.navigationItem.rightBarButtonItem = nextButton;
}

- (void)showEditorView {
    _lastStepWasScreenshotEditor = NO;
    [_webView setHidden: YES];
    self.navigationItem.title = [BugBattleTranslationHelper localizedString: @"mark_the_bug"];
    [self showNextButton];
    if (_screenshotEditorIsFirstStep) {
        [self showCancelButton];
    }
}

- (void)backAction:(id)sender {
    if (self.lastStepWasScreenshotEditor) {
        [self showEditorView];
        return;
    }
    
    self.navigationItem.title = @"";
    [_webView reload];
    if (_webView.isHidden) {
        [_webView setHidden: NO];
        [self showCancelButton];
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self showCancelButton];
    }
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
    
    if ([message.name isEqualToString: @"selectedMenuOption"]) {
        [self showBackButton];
    }
    
    if ([message.name isEqualToString: @"openScreenshotEditor"]) {
        if ([message.body objectForKey: @"screenshotEditorIsFirstStep"] != nil && [[message.body objectForKey: @"screenshotEditorIsFirstStep"] boolValue] == YES) {
            _screenshotEditorIsFirstStep = YES;
        }
        [self showEditorView];
    }
    
    if ([message.name isEqualToString: @"sendFeedback"]) {
        [_webView setHidden: YES];
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
    webConfig.userContentController = userController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration: webConfig];
    if (@available(iOS 13.0, *)) {
        self.webView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        // Fallback on earlier versions
        self.webView.backgroundColor = UIColor.whiteColor;
    }
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view insertSubview: self.webView belowSubview: self.loadingView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    NSURL * url = [NSURL URLWithString: [NSString stringWithFormat: @"https://widget.bugbattle.io/appwidget/%@?email=%@&lang=%@&enableprivacypolicy=%@&privacyplicyurl=%@&color=%@&logourl=%@&showpoweredby=%@", BugBattle.sharedInstance.token, [BugBattle.sharedInstance.customerEmail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [BugBattle.sharedInstance.language stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], BugBattle.sharedInstance.privacyPolicyEnabled ? @"true" : @"false", [BugBattle.sharedInstance.privacyPolicyUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [self hexStringForColor: BugBattle.sharedInstance.navigationTint], [BugBattle.sharedInstance.logoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], BugBattle.sharedInstance.enablePoweredBy ? @"true" : @"false"]];
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

- (void)showNextStep:(id)sender {
    [_webView setHidden: false];
    if (self.screenshotImageView.image) {
        [BugBattle attachScreenshot: self.screenshotImageView.image];
    }
    self.navigationItem.title = @"";
    self.lastStepWasScreenshotEditor = YES;
    self.navigationItem.rightBarButtonItem = nil;
    [self showBackButton];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateScreenshotConstraints];
    });
}

- (void)initializeScreenshotEditor {
    _colorViews = @[_color1, _color2, _color3];
    _previewColorViews = @[_colorPreview1, _colorPreview2, _colorPreview3];
    
    UIColor *defaultColor = UIColor.blackColor;
    if (@available(iOS 13, *)) {
        defaultColor = UIColor.labelColor;
    }
    
    _screenshotImageView.clipsToBounds = YES;
    _screenshotImageView.layer.masksToBounds = NO;
    _screenshotImageView.layer.cornerRadius = 5.0;
    _screenshotImageView.layer.shadowColor = defaultColor.CGColor;
    _screenshotImageView.layer.shadowOpacity = 0.2;
    _screenshotImageView.layer.shadowOffset = CGSizeZero;
    _screenshotImageView.layer.shadowRadius = 6;
    
    // Setup color selection
    for (int i = 0; i < _colorViews.count; i++) {
        UIButton *button = [_colorViews objectAtIndex: i];
        UIButton *previewButton = [_previewColorViews objectAtIndex: i];
        button.layer.cornerRadius = 20.0;
        previewButton.layer.cornerRadius = 12.0;
        previewButton.backgroundColor = button.backgroundColor;
        
        [self addEffectToColorSelectionButton: button withDistance: 4.0];
        [self addEffectToColorSelectionButton: previewButton withDistance: 2.0];
    }
    
    [self setColorForButton: _color1];
    [self enableColorSelection: NO];
}

- (void)sendBugReport {
    self.navigationItem.leftBarButtonItem = false;
    self.navigationItem.rightBarButtonItem = false;
    
    _labelLoading.text = [BugBattleTranslationHelper localizedString: @"report_sending"];
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

- (void)addEffectToColorSelectionButton:(UIButton *)button withDistance:(double)distance {
    UIView *holderView = [[UIView alloc] initWithFrame: CGRectMake(distance, distance, button.frame.size.width - (distance * 2), button.frame.size.height - (distance * 2))];
    holderView.layer.cornerRadius = holderView.frame.size.height / 2.0;
    if (@available(iOS 13.0, *)) {
        holderView.layer.borderColor = UIColor.systemBackgroundColor.CGColor;
    } else {
        // Fallback on earlier versions
        holderView.layer.borderColor = UIColor.blackColor.CGColor;
    }
    holderView.clipsToBounds = YES;
    holderView.backgroundColor = button.backgroundColor;
    button.clipsToBounds = YES;
    [holderView setUserInteractionEnabled: NO];
    [button addSubview: holderView];
}

- (void)enableColorSelection:(BOOL)show {
    [_colorSelectionView setHidden: !show];
    [_mainToolsView setHidden: show];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateScreenshotConstraints];
}

- (void)updateScreenshotConstraints {
    if (_screenshotImageView.image == nil) {
        return;
    }
    
    float paddingHorizontal = 20;
    float paddingVertical = 100;
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    viewWidth = viewWidth - (paddingHorizontal * 2);
    viewHeight = viewHeight - (paddingVertical * 2);
    float imageWidth = _screenshotImageView.image.size.width;
    float imageHeight = _screenshotImageView.image.size.height;
    float aspectRatio = fmin(viewWidth / imageWidth, viewHeight / imageHeight);
    
    _screenshotWidthContraint.constant = round(imageWidth * aspectRatio);
    _screenshotHeightContraint.constant = round(imageHeight * aspectRatio);
    [self.view setNeedsLayout];
}

- (void)resetBorder {
    [_blurButton setSelected: NO];
    for (int i = 0; i < _colorViews.count; i++) {
        UIButton *button = [_colorViews objectAtIndex: i];
        UIButton *previewButton = [_previewColorViews objectAtIndex: i];
        [[button subviews] objectAtIndex: 0].layer.borderWidth = 0.0;
        [[previewButton subviews] objectAtIndex: 0].layer.borderWidth = 0.0;
    }
}

- (void)setColorForButton:(UIButton *)button {
    [self resetBorder];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [button.backgroundColor getRed: &red green: &green blue: &blue alpha: &alpha];
    _screenshotImageView.red = red;
    _screenshotImageView.green = green;
    _screenshotImageView.blue = blue;
    _screenshotImageView.paintWidth = 4.0;
    [[button subviews] objectAtIndex: 0].layer.borderWidth = 2.0;
    [[[_previewColorViews objectAtIndex: [_colorViews indexOfObject: button]] subviews] objectAtIndex: 0].layer.borderWidth = 1.0;
    [self enableColorSelection: NO];
}

- (IBAction)lastStep:(id)sender {
    [_screenshotImageView stepBack];
}

- (IBAction)showColorSelection:(id)sender {
    [self enableColorSelection: YES];
}

- (IBAction)hideColorSelection:(id)sender {
    [self enableColorSelection: NO];
}

- (IBAction)activateBlurMode:(id)sender {
    [self resetBorder];
    [_blurButton setSelected: YES];
    _screenshotImageView.red = 0.0;
    _screenshotImageView.green = 0.0;
    _screenshotImageView.blue = 0.0;
    _screenshotImageView.paintWidth = 20.0;
}

- (IBAction)setColor:(id)sender {
    [self setColorForButton: sender];
}

- (void)setScreenshot:(UIImage *)image {
    self.screenshotImageView.image = image;
    [self updateScreenshotConstraints];
}

- (void)onDismissCleanup {
    [BugBattle afterBugReportCleanup];
}

@end
