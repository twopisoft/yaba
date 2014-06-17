//
//  com_twopiViewController.m
//  yaba
//
//  Created by TwoPi on 5/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkListViewController.h"
#import "YabaBookmarkDetailsViewController.h"
#import "YabaBookmark.h"
#import "YabaBookmarkStore.h"
#import "YabaBookmarkCell.h"
#import "YabaDefines.h"
#import "YabaUtil.h"
#import "YabaWebViewController.h"

#import <Social/Social.h>

#import <SDCAlertView.h>
#import <SDCAutoLayout/UIView+SDCAutoLayout.h>

#define EMAIL_FIELD_TAG     1010


@interface YabaBookmarkListViewController ()
@property (nonatomic,strong) YabaBookmarkStore *store;
@property (nonatomic) SDCAlertView *loginView;
@property (nonatomic) SDCAlertView *signupView;
@property (nonatomic,strong) handlerBlock completionHandler;

- (void)refreshBookmarks;
@end

@implementation YabaBookmarkListViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _store = [YabaBookmarkStore sharedStore];
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"YABA";
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithTitle:@"Settings" style:UIBarButtonItemStylePlain
                                target:self action:@selector(configure:)];
        
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
        
        [self _createLoginMenu];
        [self _createSignupView];
        [self _setCompletionHandler];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

-(IBAction)configure:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    //UINib *nib = [UINib nibWithNibName:@"YabaBookmarkCell" bundle:nil];
    
    //[self.tableView registerNib:nib forCellReuseIdentifier:@"YabaBookmarkCell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshBookmarks) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self refreshBookmarks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = [[self.store allBookmarks] count];
    if (!numRows) {
        self.navigationItem.leftBarButtonItem = nil;
        return 1;
    } else {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    //YabaBookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YabaBookmarkCell" forIndexPath:indexPath];
    
    NSArray *bms = [self.store allBookmarks];
    
    /*if ([bms count]) {
        YabaBookmark *bm = bms[indexPath.row];
        
        cell.bmNameLabel.text = [bm name];
        cell.bmNameLabel.textAlignment = NSTextAlignmentLeft;
        cell.bmImage.image = nil;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[bm imageUrl]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            [bm setThumbnailFromImage:[UIImage imageWithData:data] withRect:CGRectMake(0, 0, 134, 75)];
            cell.bmImage.image = bm.thumbnail;
            cell.bmImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.bmImage.clipsToBounds = YES;
            
        }];
    } else {
        if (indexPath.row == 0) {
            cell.bmNameLabel.text = @"No Bookmarks Found. Pull Down to refresh and see if there are any...";
            cell.bmNameLabel.textAlignment = NSTextAlignmentCenter;
            cell.bmImage.image = nil;
        }
    }*/
    
    if ([bms count]) {
        YabaBookmark *bm = bms[indexPath.row];
        
        cell.textLabel.text = bm.name;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.imageView.image = [UIImage imageNamed:@"spacer"];
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        if ([cell.contentView subviews]) {
            for (UIView *subview in [cell.contentView subviews]) {
                [subview removeFromSuperview];
            }
        }
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:(CGRect){.size={70, tableView.rowHeight}}];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.center = CGPointMake(iv.center.x+5,cell.contentView.bounds.size.height/2);
        
        if (!bm.thumbnail) {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[bm imageUrl]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                UIImage *thumbnail = [UIImage imageWithData:data];
                [bm setThumbnailFromImage:thumbnail withRect:CGRectMake(0, 0, 134, 75)];
                iv.image = bm.thumbnail;
                
                [cell.contentView addSubview:iv];
                
            }];
        } else {
            iv.image = bm.thumbnail;
            [cell.contentView addSubview:iv];
        }
        
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"Pull down to login/refresh";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray * bms = [self.store allBookmarks];
        YabaBookmark * bm = [bms objectAtIndex:indexPath.row];
        [self.store removeBm:bm withHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error, BOOL dataAvailable) {
            if (!error && [response statusCode] != HTTP_FORBIDDEN) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *bms = [self.store allBookmarks];
                    if ([bms count]) {
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    } else {
                        [tableView setEditing:NO animated:YES];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                });
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/*- (void)tableView:(UITableView *)tableView
                    moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[YabaBookmarkStore bmStore] moveBmAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}*/

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Accessory button tapped for row=%d",indexPath.row);
    
    YabaBookmarkDetailsViewController *detailViewController = [[YabaBookmarkDetailsViewController alloc] init];
    
    NSArray * bms = [self.store allBookmarks];
    //NSLog(@"count=%d",[bms count]);
    YabaBookmark * selectedBm = [bms objectAtIndex:indexPath.row];
    
    detailViewController.bm = selectedBm;
    detailViewController.bmIndex = indexPath.row;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * bms = [self.store allBookmarks];
    YabaBookmark * bm = [bms objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:bm.url];
    
    YabaWebViewController *webViewController = [[YabaWebViewController alloc] init];
    webViewController.title = bm.name;
    webViewController.url = url;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}


- (void)refreshBookmarks
{
    [self.store refreshBookmarks:self.completionHandler];
}

- (void)loginWithFacebook
{
    [self.loginView dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
    
        [YabaUtil saveLastUserChosenLoginProvider:YabaSignInProviderFacebook];
        [self.store loginWithFacebookAndRefreshBookmarks:self.completionHandler];
    } else {
        SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Facebook not setup on this device"
                                                          message:@"Please setup Facebook app and Facebook account"
                                                         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)loginWithGoogle
{
    [self.loginView dismissWithClickedButtonIndex:0 animated:YES];
    
    [YabaUtil saveLastUserChosenLoginProvider:YabaSignInProviderGoogle];
    [self.store loginWithGoogleAndRefreshBookmarks:self.completionHandler];
}

- (void) logout
{
    [YabaUtil saveLastSuccessfulLoginProvider:YabaSignInProviderNone];
    [YabaUtil saveLastUserChosenLoginProvider:YabaSignInProviderNone];
    [self.store logout];
    [self.tableView reloadData];
}

- (void)_setCompletionHandler
{
    __weak typeof(self) weakSelf = self;
    
    _completionHandler = ^void(NSHTTPURLResponse* response, NSData* data, NSError* error, BOOL dataAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.refreshControl endRefreshing];
            
            if (error) {
                if (error.code == HTTP_FORBIDDEN) {
                    //NSLog(@"error=%@",error);
                    [YabaUtil saveLastSuccessfulLoginProvider:YabaSignInProviderNone];
                    [weakSelf.loginView show];
                } else {
                    [YabaUtil saveLastSuccessfulLoginProvider:YabaSignInProviderNone];
                    
                    NSString *title = nil;
                    NSString * message = nil;
                    
                    if (error.code == FB_ACCESS_NOT_GRANTED) {
                        title = @"Facebook Login Error";
                        message = @"Problem while getting permission to access your Facebook account. Please check your Facebook account setup in Settings";
                    } else if (response.statusCode != HTTP_FORBIDDEN) {
                        title = @"Communication Problem";
                        message = @"Unable to Connect to YABA server. Please try again later.";
                    }
                    SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:title
                                                                      message:message
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];
                    [alert show];
                }
            } else if (response.statusCode == HTTP_FORBIDDEN) {
                
                switch ([YabaUtil readLastSuccessfulLoginProvider]) {
                    case YabaSignInProviderFacebook :
                        [weakSelf loginWithFacebook];
                        break;
                    
                    case YabaSignInProviderGoogle:
                        [weakSelf loginWithGoogle];
                        break;
                        
                    default:
                        [weakSelf.loginView show];
                        
                }
            } else if ([weakSelf isSignupResponse:response]) {
                [weakSelf processSignup:response.URL provider:[weakSelf extractProvider:response] email:[weakSelf extractEmail:data]];
            } else {
                [YabaUtil saveLastSuccessfulLoginProvider:[YabaUtil readLastUserChosenLoginProvider]];
                [weakSelf.tableView reloadData];
            }
        });
    };
}

- (void)processSignup:(NSURL*)responseUrl provider:(NSString*)provider email:(NSString*)email
{
    _signupView.message = [_signupView.message stringByReplacingOccurrencesOfString:@"provider"
                                                                         withString:provider];
    
    UITextField *emailField = (UITextField*)[_signupView.contentView viewWithTag:EMAIL_FIELD_TAG];
    if ([email length] > 0) {
        emailField.text = email;
    }
    
    [_signupView showWithDismissHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logout];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"Signup Cancelled"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                [alert show];
            });
        } else if (buttonIndex == 1) {
            NSString *newEmail = [emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([newEmail length] > 0) {
                [self.store completeSignup:responseUrl withProvider:provider withData:newEmail withHandler:self.completionHandler];
            }
        }
    }];
    
}

- (BOOL)isSignupResponse:(NSHTTPURLResponse*)response
{
    return [[response.URL path] rangeOfString:@"signup"].location != NSNotFound;
}

- (NSString *)extractProvider:(NSHTTPURLResponse *)response
{
    NSString * provider = nil;
    if ([[response.URL path] rangeOfString:@"facebook"].location != NSNotFound) {
        provider = @"Facebook";
    } else if ([[response.URL path] rangeOfString:@"google"].location != NSNotFound) {
        provider = @"Google";
    }
    
    return provider;
}

- (NSString *)extractEmail:(NSData *)data
{
    NSString * dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"dataStr=%@",dataStr);
    
    NSError *error = NULL;
    NSRegularExpression *emailRegex =
    [NSRegularExpression
     regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
     options:NSRegularExpressionCaseInsensitive
     error:&error];
    NSString *emailAddr=nil;
    NSRange rangeOfFirstMatch = [emailRegex rangeOfFirstMatchInString:dataStr options:0 range:NSMakeRange(0, [dataStr length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        emailAddr = [dataStr substringWithRange:rangeOfFirstMatch];
        NSLog(@"email=%@",emailAddr);
    }
    return emailAddr;
}

- (void)_createLoginMenu
{
    _loginView = [[SDCAlertView alloc] initWithTitle:@"Signup or Login with:"
                                             message:nil
                                            delegate:nil
                                   cancelButtonTitle:@"Later..."
                                   otherButtonTitles:nil,nil];
    
    
    UIButton *glButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *glNormalImage = [UIImage imageNamed:@"GoogleNormal"];
    UIImage *glPressedImage = [UIImage imageNamed:@"GooglePressed"];
    
    [glButton setImage:glNormalImage forState:UIControlStateNormal];
    [glButton setImage:glPressedImage forState:UIControlStateSelected];
    [glButton addTarget:self action:@selector(loginWithGoogle) forControlEvents:UIControlEventTouchUpInside];
    
    [glButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *fbNormalImage = [UIImage imageNamed:@"FacebookNormal"];
    UIImage *fbPressedImage = [UIImage imageNamed:@"FacebookPressed"];
    
    [fbButton setImage:fbNormalImage forState:UIControlStateNormal];
    [fbButton setImage:fbPressedImage forState:UIControlStateSelected];
    [fbButton addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    [fbButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_loginView.contentView addSubview:fbButton];
    [_loginView.contentView addSubview:glButton];
    
    NSDictionary *map = @{@"fbButton" : fbButton,
                          @"glButton" : glButton};
    
    NSArray * hc = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[fbButton]-8-[glButton]-25-|"
                                                           options:0
                                                           metrics:nil
                                                             views:map];
    
    [_loginView.contentView addConstraints:hc];
    
    [glButton sdc_verticallyCenterInSuperviewWithOffset:SDCAutoLayoutStandardSiblingDistance];
    [fbButton sdc_verticallyCenterInSuperviewWithOffset:SDCAutoLayoutStandardSiblingDistance];
}

- (void)_createSignupView
{
    _signupView = [[SDCAlertView alloc] initWithTitle:@"Complete Signup"
                                              message:@"The email address from your provider account is already in use. Please use a different email address"
                                             delegate:nil
                                    cancelButtonTitle:@"Later..."
                                    otherButtonTitles:@"OK",nil];
    
    UITextField *emailField = [[UITextField alloc] init];
    [emailField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [emailField setTag:EMAIL_FIELD_TAG];
    
    [_signupView.contentView addSubview:emailField];
    
    NSDictionary *map = @{@"emailField" : emailField};
    
    NSArray * hc = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[emailField]-8-|"
                                                           options:0
                                                           metrics:nil
                                                             views:map];
    
    [_signupView.contentView addConstraints:hc];
    [emailField sdc_verticallyCenterInSuperview];
}



@end
