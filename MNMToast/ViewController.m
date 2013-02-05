//
//  ViewController.m
//  toast
//
//  Created by Mario Negro on 31/01/13.
//  Copyright (c) 2013 Mario Negro. All rights reserved.
//

#import "ViewController.h"
#import "MNMToast.h"

@interface ViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UITextView *textView;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *toastButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *hideButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *showSeveralButton;
@property (nonatomic, readwrite, weak) IBOutlet UISwitch *autohidingSwitch;

- (IBAction)buttonTouchedUpInside:(id)sender;
- (IBAction)autohidingSwitchValueChanged:(id)sender;

@end

@implementation ViewController

@synthesize textView = textView_;
@synthesize toastButton = toastButton_;
@synthesize hideButton = hideButton_;
@synthesize showSeveralButton = showSeveralButton_;
@synthesize autohidingSwitch = autohidingSwitch_;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [autohidingSwitch_ setOn:YES];
    [self autohidingSwitchValueChanged:autohidingSwitch_];
    [textView_ setText:@"This is a regular text to be toasted. Push the button!"];
}

- (IBAction)buttonTouchedUpInside:(id)sender {
    
    void(^ToastBlock)(void) = ^{
       
        if (sender == toastButton_) {
            
            [MNMToast showWithText:[textView_ text]
                       autoHidding:[autohidingSwitch_ isOn]
                          priority:MNMToastPriorityNormal
                 completionHandler:^(MNMToastValue *toast) {
                     
                     NSLog(@"Toast did dissapear");
                     
                 } tapHandler:^(MNMToastValue *toast) {
                     
                     [MNMToast hide];
                     [MNMToast showWithText:@"Toast has been tapped"
                          completionHandler:nil
                                 tapHandler:nil];
                 }];
            
        } else if (sender == hideButton_) {
            
            [MNMToast hide];
     
        } else if (sender == showSeveralButton_) {
            
            [MNMToast showWithText:@"Toast #1/3"
                 completionHandler:nil
                        tapHandler:nil];
            
            [MNMToast showWithText:@"Toast #2/3"
                 completionHandler:^(MNMToastValue *value) {
                 
                     NSLog(@"Chain finished.");
                     
                 } tapHandler:nil];
            
            [MNMToast showWithText:@"Toast #3/3 (higher priority than #2)"
                       autoHidding:YES
                          priority:MNMToastPriorityHigh
                 completionHandler:nil
                        tapHandler:nil];
        }
    };
    
    if ([textView_ isFirstResponder]) {
    
        [textView_ resignFirstResponder];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            ToastBlock();
        });
        
    } else {
        
        ToastBlock();
    }
}

- (IBAction)autohidingSwitchValueChanged:(id)sender {

    if ([autohidingSwitch_ isOn]) {
        
        [hideButton_ setTitle:@"Autohiding..." forState:UIControlStateNormal];
        [hideButton_ setEnabled:NO];
        [hideButton_ setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    } else {
        
        [hideButton_ setTitle:@"Hide" forState:UIControlStateNormal];
        [hideButton_ setEnabled:YES];
        [hideButton_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

@end
