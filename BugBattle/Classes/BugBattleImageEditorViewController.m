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
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;
@property (weak, nonatomic) IBOutlet UIButton *color6;
@property (weak, nonatomic) IBOutlet UIButton *color7;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotWidthContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotHeightContraint;

@end

@implementation BugBattleImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    _screenshotImageView.clipsToBounds = true;
    _screenshotImageView.layer.masksToBounds = false;
    _screenshotImageView.layer.cornerRadius = 5.0;
    _screenshotImageView.layer.shadowColor = defaultColor.CGColor;
    _screenshotImageView.layer.shadowOpacity = 0.3;
    _screenshotImageView.layer.shadowOffset = CGSizeZero;
    _screenshotImageView.layer.shadowRadius = 10;
    
    _color1.layer.cornerRadius = 16.0;
    _color1.layer.borderColor = UIColor.blackColor.CGColor;
    _color1.clipsToBounds = true;
    _color2.layer.cornerRadius = 16.0;
    _color2.layer.borderColor = UIColor.blackColor.CGColor;
    _color2.clipsToBounds = true;
    _color3.layer.cornerRadius = 16.0;
    _color3.layer.borderColor = UIColor.blackColor.CGColor;
    _color3.clipsToBounds = true;
    _color4.layer.cornerRadius = 16.0;
    _color4.layer.borderColor = UIColor.blackColor.CGColor;
    _color4.clipsToBounds = true;
    _color5.layer.cornerRadius = 16.0;
    _color5.layer.borderColor = UIColor.blackColor.CGColor;
    _color5.clipsToBounds = true;
    _color6.layer.cornerRadius = 16.0;
    _color6.layer.borderColor = UIColor.blackColor.CGColor;
    _color6.clipsToBounds = true;
    _color7.layer.cornerRadius = 16.0;
    _color7.layer.borderColor = UIColor.blackColor.CGColor;
    _color7.clipsToBounds = true;
    
    [self setColorForButton: _color1];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    _screenshotWidthContraint.constant = round(self.view.frame.size.width * 0.68);
    _screenshotHeightContraint.constant = round(self.view.frame.size.height * 0.68);
}

- (void)resetBorder {
    _color1.layer.borderWidth = 0.0;
    _color2.layer.borderWidth = 0.0;
    _color3.layer.borderWidth = 0.0;
    _color4.layer.borderWidth = 0.0;
    _color5.layer.borderWidth = 0.0;
    _color6.layer.borderWidth = 0.0;
    _color7.layer.borderWidth = 0.0;
}

- (void)setColorForButton:(UIButton *)button {
    [self resetBorder];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [button.backgroundColor getRed: &red green: &green blue: &blue alpha: &alpha];
    self.screenshotImageView.red = red;
    self.screenshotImageView.green = green;
    self.screenshotImageView.blue = blue;
    button.layer.borderWidth = 2.0;
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
        [self.navigationController pushViewController: bugBattleBugDetails animated: true];
    }
}

- (IBAction)closeReporting:(id)sender {
    [self dismissViewControllerAnimated: true completion:^{
        
    }];
}

@end
