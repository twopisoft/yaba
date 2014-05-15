//
//  YabaBookmarkDetailsViewController.m
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkDetailsViewController.h"
#import "YabaBookmark.h"
#import "YabaUtil.h"
#import "YabaDatePickerViewController.h"

#define NOTIFY_DATE_FIELD_TAG 99

@interface YabaBookmarkDetailsViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bmImageView;
@property (weak, nonatomic) IBOutlet UITextView *bmSynopsisView;
@property (weak, nonatomic) IBOutlet UITextField *bmTagsField;
@property (weak, nonatomic) IBOutlet UITextField *bmNameField;
@property (weak, nonatomic) IBOutlet UITextField *bmUrlField;
@property (weak, nonatomic) IBOutlet UITextField *bmNotifyDateField;

@end

@implementation YabaBookmarkDetailsViewController

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Details";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                            target:self action:@selector(saveBm:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                   target:self action:@selector(shareBm:)];
    
    navItem.rightBarButtonItems = @[shareButton,saveButton];
    
    YabaBookmark * bm = self.bm;
    
    self.bmImageView.image = bm.thumbnail;
    self.bmNameField.text = bm.name;
    self.bmUrlField.text = bm.url;
    self.bmSynopsisView.text = bm.synopsis;
    self.bmTagsField.text = [bm.tags componentsJoinedByString:@","];
    
    if (bm.hasNotify) {
        self.bmNotifyDateField.text = [YabaUtil formatDate:[bm notifyOn]];
    } else {
        self.bmNotifyDateField.text = @"Not Set";
    }
}

-(IBAction)saveBm:(id)sender
{
    YabaBookmark * bm = self.bm;
    
    bm.name = [self.bmNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    bm.url = [self.bmUrlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    bm.synopsis = [self.bmSynopsisView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    bm.tags = [self.bmTagsField.text componentsSeparatedByString:@","];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)shareBm:(id)sender
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.frame.origin.y > 300) {
        [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.frame.origin.y > 300) {
        [self animateTextField:textField up:NO];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag != NOTIFY_DATE_FIELD_TAG) {
        return YES;
    }
    
    YabaDatePickerViewController *datePicker = [[YabaDatePickerViewController alloc] init];
    datePicker.bm = self.bm;
    
    [self.navigationController pushViewController:datePicker animated:YES];
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextView:textView up:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextView:textView up:NO];
}

- (void)animateTextView:(UITextView*)textView up:(BOOL)up
{
    [self animateArea:up];
}

- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    [self animateArea:up];
}

- (void)animateArea:(BOOL)up
{
    const int movementDistance = 160;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
