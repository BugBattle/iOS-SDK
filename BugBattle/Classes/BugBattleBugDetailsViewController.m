//
//  BugBattleBugDetailsViewController.m
//  AyAyObjectiveCPort
//
//  Created by Lukas on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import "BugBattleBugDetailsViewController.h"
#import "BugBattleCore.h"
#import "BugBattleReplayHelper.h"

@interface BugBattleBugDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *reportSent;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *messageSentIcon;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotPreview;
@property (weak, nonatomic) IBOutlet UIView *editIconView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *severity;
@property (weak, nonatomic) IBOutlet UITextView *privacyPolicyTextView;
@property (weak, nonatomic) IBOutlet UISwitch *privacyPolicyToggle;
@property (weak, nonatomic) IBOutlet UIView *privacyPolicyContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyPolicyHeightConstraint;
@property (nonatomic) UILabel *lbl;
@property (nonatomic) Boolean sending;

@end

@implementation BugBattleBugDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageSentIcon.tintColor = self.navigationController.navigationBar.tintColor;
    
    UIColor *defaultColor = UIColor.blackColor;
    if (@available(iOS 13, *)) {
        defaultColor = UIColor.labelColor;
    }
    
    _sending = NO;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle: @"Send" style: UIBarButtonItemStyleDone target: self action: @selector(send:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    self.navigationItem.title = @"Report a bug";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self.navigationItem hidesBackButton];
    
    _severity.selectedSegmentIndex = 1;
    
    _screenshotPreview.clipsToBounds = true;
    _screenshotPreview.layer.masksToBounds = false;
    _screenshotPreview.layer.cornerRadius = 5.0;
    _screenshotPreview.layer.shadowColor = defaultColor.CGColor;
    _screenshotPreview.layer.shadowOpacity = 0.15;
    _screenshotPreview.layer.shadowOffset = CGSizeZero;
    _screenshotPreview.layer.shadowRadius = 5;
    
    [_editIconView setClipsToBounds: YES];
    _editIconView.layer.cornerRadius = 27.5;
    
    [_loadingView setHidden: true];
    [_reportSent setHidden: true];
    
    [self setupPrivacyPolicy];
    
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey: @"BugBattle_SenderEmail"];
    _emailTextField.text = email;
    NSString *savedDescription = [[NSUserDefaults standardUserDefaults] stringForKey: @"BugBattle_SavedDescription"];
    _descriptionTextView.text = savedDescription;
    [self isSendEnabled];
    
    _lbl = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 0.0, _descriptionTextView.frame.size.width - 10.0, 34.0)];
    [_lbl setText: @"What went wrong?"];
    [_lbl setBackgroundColor: [UIColor clearColor]];
    [_lbl setFont: [UIFont systemFontOfSize: 18.0 weight: UIFontWeightMedium]];
    
    [_lbl setTextColor: [defaultColor colorWithAlphaComponent: 0.3]];
    
    [_descriptionTextView addSubview: _lbl];
    [_descriptionTextView setContentInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    
    if (_descriptionTextView.text.length > 0) {
        _lbl.hidden = YES;
    }
    
    [_emailTextField addTarget: self action: @selector(emailAddressDidChangeValue:) forControlEvents: UIControlEventEditingChanged];
}

- (void)setupPrivacyPolicy {
    if (!BugBattle.sharedInstance.privacyPolicyEnabled) {
        self.privacyPolicyHeightConstraint.constant = 0;
    }
    
    NSMutableAttributedString *privacyPolicyText = [[NSMutableAttributedString alloc] initWithString: @"I have read and agree to the "];
    NSMutableAttributedString *privacyPolicyAppendix = [[NSMutableAttributedString alloc] initWithString: @"."];
    NSMutableAttributedString *privacyPolicyLink = [[NSMutableAttributedString alloc] initWithString:@"privacy policy"
                                                                           attributes:@{ NSLinkAttributeName: [NSURL URLWithString: BugBattle.sharedInstance.privacyPolicyUrl] }];
    [privacyPolicyText appendAttributedString: privacyPolicyLink];
    [privacyPolicyText appendAttributedString: privacyPolicyAppendix];
    [_privacyPolicyTextView setAttributedText: privacyPolicyText];
    
    if (@available(iOS 13.0, *)) {
        [_privacyPolicyTextView setTextColor: UIColor.labelColor];
    }
    [_privacyPolicyTextView setFont:[UIFont systemFontOfSize: 15]];
    [_privacyPolicyTextView setTextContainerInset:UIEdgeInsetsZero];
    _privacyPolicyTextView.textContainer.lineFragmentPadding = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)onDismissCleanup {
    // Starts the replay helper.
    if ([BugBattle sharedInstance].replaysEnabled) {
        [[BugBattleReplayHelper sharedInstance] start];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated: YES completion:^{
        [self onDismissCleanup];
    }];
}

- (IBAction)emailAddressDidChangeValue:(id)sender {
    [self isSendEnabled];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [[NSUserDefaults standardUserDefaults] setValue: _descriptionTextView.text forKey: @"BugBattle_SavedDescription"];
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)isSendEnabled {
    if ([_emailTextField.text isEqualToString: @""]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    _screenshotPreview.image = [BugBattle getAttachedScreenshot];
}

- (void)textViewDidEndEditing:(UITextView *) textView {
    if (![textView hasText]) {
        _lbl.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    if(![textView hasText]) {
        _lbl.hidden = NO;
    } else {
        _lbl.hidden = YES;
    }
}

- (IBAction)showEditScreen:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (NSString *)getCurrentSeverity {
    switch(_severity.selectedSegmentIndex) {
        case 0:
            return @"LOW";
        case 2:
            return @"HIGH";
        default:
            return @"MEDIUM";
    }
}

- (IBAction)send:(id)sender {
    if (BugBattle.sharedInstance.privacyPolicyEnabled && !_privacyPolicyToggle.on) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy policy" message:@"Please read and accept the privacy policy." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (_sending) {
        return;
    }
    
    [[self navigationController] setNavigationBarHidden: YES animated: NO];
    
    _sending = YES;
    [_emailTextField resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
    
    NSMutableDictionary *dataToAppend = [[NSMutableDictionary alloc] init];
    if (_emailTextField.text == NULL || [_emailTextField.text isEqualToString: @""]) {
        _emailTextField.text = @"--";
    }
    if (_descriptionTextView.text == NULL || [_descriptionTextView.text isEqualToString: @""]) {
        _descriptionTextView.text = @"--";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue: _emailTextField.text forKey: @"BugBattle_SenderEmail"];
    [dataToAppend setValue: _emailTextField.text forKey: @"reportedBy"];
    [dataToAppend setValue: _descriptionTextView.text forKey: @"description"];
    [dataToAppend setValue: [self getCurrentSeverity] forKey: @"priority"];
    [BugBattle attachData: dataToAppend];
    
    [_loadingView setHidden: false];
    [BugBattle.sharedInstance sendReport:^(bool success) {
        [self->_loadingView setHidden: true];
        if (success) {
            [self->_reportSent setHidden: false];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                self->_sending = NO;
                [self dismissViewControllerAnimated: true completion:^{
                    [[NSUserDefaults standardUserDefaults] setValue: @"" forKey: @"BugBattle_SavedDescription"];
                    [self onDismissCleanup];
                }];
            });
        } else {
            self->_sending = NO;
            [[self navigationController] setNavigationBarHidden: NO animated: NO];
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Error"
                                         message:@"An error occurred, please try again!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
