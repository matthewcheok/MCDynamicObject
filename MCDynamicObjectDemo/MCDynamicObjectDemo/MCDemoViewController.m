//
//  MCDemoViewController.m
//  MCDynamicObjectDemo
//
//  Created by Matthew Cheok on 31/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCDemoViewController.h"
#import "MCTestingKeychain.h"

@interface MCDemoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation MCDemoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textField.text = [MCTestingKeychain sharedInstance].name;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [MCTestingKeychain sharedInstance].name = textField.text;
}

@end
