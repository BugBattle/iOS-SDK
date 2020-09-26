//
//  BugBattleImageEditorViewController.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleImageEditorViewController.h"
#import "BugBattleTouchDrawImageView.h"
#import "BugBattleBugDetailsViewController.h"
#import "BugBattleCore.h"

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

@end

@implementation BugBattleImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _colorViews = @[_color1, _color2, _color3];
    _previewColorViews = @[_colorPreview1, _colorPreview2, _colorPreview3];
    
    [[NSUserDefaults standardUserDefaults] setValue: @"" forKey: @"BugBattle_SavedDescription"];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle: @"Next" style: UIBarButtonItemStyleDone target: self action: @selector(showNextStep:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(closeReporting:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.navigationItem.title = @"Report a bug";
    
    UIColor *defaultColor = UIColor.blackColor;
    if (@available(iOS 13, *)) {
        defaultColor = UIColor.labelColor;
    }
    
    _screenshotImageView.clipsToBounds = YES;
    _screenshotImageView.layer.masksToBounds = NO;
    _screenshotImageView.layer.cornerRadius = 5.0;
    _screenshotImageView.layer.shadowColor = defaultColor.CGColor;
    _screenshotImageView.layer.shadowOpacity = 0.3;
    _screenshotImageView.layer.shadowOffset = CGSizeZero;
    _screenshotImageView.layer.shadowRadius = 10;
    
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

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    _screenshotWidthContraint.constant = round([[UIScreen mainScreen] bounds].size.width * 0.66);
    _screenshotHeightContraint.constant = round([[UIScreen mainScreen] bounds].size.height * 0.66);
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
    _screenshotImageView.paintWidth = 10.0;
}

- (IBAction)setColor:(id)sender {
    [self setColorForButton: sender];
}

- (void)setScreenshot:(UIImage *)image {
    self.screenshotImageView.image = image;
}

- (IBAction)showNextStep:(id)sender {
    if (self.screenshotImageView.image) {
        [BugBattle attachScreenshot: self.screenshotImageView.image];
        
        // Push finalization screen.
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"BugBattleStoryboard" bundle: [BugBattle frameworkBundle]];
        BugBattleBugDetailsViewController *bugBattleBugDetails = [storyboard instantiateViewControllerWithIdentifier: @"BugBattleBugDetailsViewController"];
        [self.navigationController pushViewController: bugBattleBugDetails animated: YES];
    }
}

- (IBAction)closeReporting:(id)sender {
    [self dismissViewControllerAnimated: YES completion:^{
        
    }];
}

@end
