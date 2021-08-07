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
@property (weak, nonatomic) IBOutlet UIView *screenshotEditorView;

@end

@implementation BugBattleImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
    [self showCancelButton];
    
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

- (void)backAction:(id)sender {
    
}

- (NSString *)hexStringForColor:(UIColor *)color {
      const CGFloat *components = CGColorGetComponents(color.CGColor);
      CGFloat r = components[0];
      CGFloat g = components[1];
      CGFloat b = components[2];
      NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
      return hexString;
}

- (void)showNextStep:(id)sender {
    if (self.screenshotImageView.image) {
        [BugBattle attachScreenshot: self.screenshotImageView.image];
    }
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = nil;
    [self showBackButton];
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
