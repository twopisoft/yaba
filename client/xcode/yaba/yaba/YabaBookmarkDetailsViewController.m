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


#import <GoogleOpenSource/GoogleOpenSource.h>
#import <Social/Social.h>

#define NOTIFY_DATE_FIELD_TAG 99

#define FACEBOOK_BUTTON_INDEX   0
#define GOOGLE_BUTTON_INDEX     1
#define TWITTER_BUTTON_INDEX    2

static NSString * const kClientId = @"686846857890-9qcfffctjp7lavjg2h1sferucp0s0k48.apps.googleusercontent.com";

@interface YabaBookmarkDetailsViewController () <UITextFieldDelegate, UITextViewDelegate,
                                                 UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bmImageView;
@property (weak, nonatomic) IBOutlet UITextView *bmSynopsisView;
@property (weak, nonatomic) IBOutlet UITextField *bmTagsField;
@property (weak, nonatomic) IBOutlet UITextField *bmNameField;
@property (weak, nonatomic) IBOutlet UITextField *bmUrlField;
@property (weak, nonatomic) IBOutlet UITextField *bmNotifyDateField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIControl *contentView;

@property (weak, nonatomic) UIView *activeField;
@property (weak, nonatomic) NSLayoutConstraint * heightConstraint;
@end


@implementation YabaBookmarkDetailsViewController

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat multiplier = 1.3;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        
        multiplier = 2.5;
    }
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.scrollView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:multiplier
                                                                         constant:0];
    self.heightConstraint = heightConstraint;
    
    [self.view addConstraint:self.heightConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat multiplier = 1.3;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        multiplier = 2.5;
    }
    
    [self.view removeConstraint:self.heightConstraint];
    
    NSLayoutConstraint * newHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.scrollView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:multiplier
                                                                             constant:0];
    self.heightConstraint = newHeightConstraint;
    
    [self.view addConstraint:self.heightConstraint];
    
    [self.contentView setNeedsUpdateConstraints];
        
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

#pragma mark - Share

-(IBAction)shareBm:(id)sender
{
    UIBarButtonItem * bbi = (UIBarButtonItem *)sender;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                            initWithTitle:@"Share On"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:@"Facebook",@"Google+",@"Twitter", nil];
    
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showFromBarButtonItem:bbi animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Button at index=%d clicked",buttonIndex);
    if (buttonIndex == FACEBOOK_BUTTON_INDEX) {
        [self shareOnFaceBook:self.bm];
    } else if (buttonIndex == GOOGLE_BUTTON_INDEX) {
        [self shareOnGoogle:self.bm];
    } else if (buttonIndex == TWITTER_BUTTON_INDEX) {
        [self shareOnTwitter:self.bm];
    }
}

- (void)shareOnFaceBook:(YabaBookmark*)bm
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPost =
        [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [fbPost setInitialText:@"Posted from YABA..."];
        [fbPost addURL:[NSURL URLWithString:bm.url]];
        [self presentViewController:fbPost animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                                initWithTitle:@"Facebook App Not Installed"
                                message:@"Please install Facebook App and setup Facebook account"
                                delegate:self
                                cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)shareOnGoogle:(YabaBookmark *)bm
{
    //NSLog(@"shareOnGoogle");
    
    if (![[GPPSignIn sharedInstance] authentication]) {
        [self authenticateGoogle];
    } else {
    
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
        [shareBuilder setURLToShare:[NSURL URLWithString:bm.url]];
        [shareBuilder open];
    }
}

- (void)shareOnTwitter:(YabaBookmark*)bm
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet =
            [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:bm.url];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Twitter App Not Installed"
                              message:@"Please install Twitter App and setup Twitter account"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)authenticateGoogle
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.delegate = self;
    
    GPPSignInButton *signInButton = [[GPPSignInButton alloc] init];
    [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark GPPSignInDelegate

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        NSLog(@"Received error %@ and auth object %@",error, auth);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Unable to Login to Google+"
                              message:@"Please check your Google+ setup and try again"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        
        [alert show];

    } else {
        NSLog(@"Google+ successfully authenticated");
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        [shareBuilder setURLToShare:[NSURL URLWithString:self.bm.url]];
        [shareBuilder open];
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController
{
    NSLog(@"presentSignInViewController");
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
}

#pragma mark - UITextFieldDelegate/UITextViewDelegate

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)textViewDidBeginEditing:(UITextView *)textView
{
    //[self animateTextView:textView up:YES];
    self.activeField = textView;
}

- (IBAction)textViewDidEndEditing:(UITextView *)textView
{
    self.activeField = nil;
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

- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


@end
