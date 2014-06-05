//
//  YabaConnection.m
//  yaba
//
//  Created by TwoPi on 2/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaConnection.h"

#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

#define HTTP_OK             200
#define HTTP_FORBIDDEN      403

static NSString * const kGoogleClientId = @"686846857890-9qcfffctjp7lavjg2h1sferucp0s0k48.apps.googleusercontent.com";
static NSString * const kFacebookClientId = @"1439153039661620";

static NSString * const baseUrl = @"http://192.168.1.6:8000";

@import Accounts;

#pragma mark YabaGoogleSignInDelegate

@interface YabaGoogleSignInDelegate : NSObject <GPPSignInDelegate>

- (instancetype)init:(id<YabaConnectionGPPSignInDelegate>)delegate withHandler:(handlerBlock)completionHandler;

@end

@interface YabaGoogleSignInDelegate ()
@property (nonatomic) id<YabaConnectionGPPSignInDelegate> delegate;
@property (nonatomic,weak) handlerBlock completionHandler;
@end

@implementation YabaGoogleSignInDelegate

- (instancetype)init:(id<YabaConnectionGPPSignInDelegate>)delegate withHandler:(handlerBlock)completionHandler
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _completionHandler = completionHandler;
    }
    
    return self;
}

- (instancetype)init
{
    return [self init:nil withHandler:nil];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (self.delegate) {
        [self.delegate finishedWithAuth:auth error:error withHandler:self.completionHandler];
    }
}
@end

#pragma mark -
#pragma mark YabaConnection

@interface YabaConnection () <YabaConnectionGPPSignInDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic,copy) NSString * csrfToken;
@property (nonatomic) BOOL loggedIn;
@property (nonatomic,assign) YabaSignInProviderType loginProvider;

- (void)loginWithFacebook:(handlerBlock)completionHandler;
- (void)loginWithGoogle:(handlerBlock)completionHandler;

@end

@implementation YabaConnection
{
    GPPSignIn * _glSignIn;
    NSURLSessionDataTask *_dataTask;
}

- (instancetype)initWithDelegate:(id<YabaConnectionDelegate>)delegate
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        _loggedIn = NO;
        _glSignIn = [GPPSignIn sharedInstance];
        _delegate = delegate;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithDelegate:nil];
}

- (void)login:(YabaSignInProviderType)provider withHandler:(handlerBlock)completionHandler
{
    if (provider == YabaSignInProviderFacebook) {
        [self loginWithFacebook:completionHandler];
    } else if (provider == YabaSignInProviderGoogle) {
        [self loginWithGoogle:completionHandler];
    }
}

- (void)loginWithFacebook:(handlerBlock)completionHandler
{
    if (!self.loggedIn) {
        ACAccountStore *store = [[ACAccountStore alloc] init];
            
        ACAccountType *fbAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            
        NSDictionary *options = @{ ACFacebookAppIdKey: kFacebookClientId,
                                   ACFacebookPermissionsKey: @[@"email", @"user_about_me"],
                                   ACFacebookAudienceKey: ACFacebookAudienceOnlyMe};
        
        [store requestAccessToAccountsWithType:fbAccountType options:options completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray * accounts = [store accountsWithAccountType:fbAccountType];
                ACAccount * fbAccount = [accounts lastObject];
                ACAccountCredential *creds = [fbAccount credential];
                NSString * accessToken = [creds oauthToken];
                
                NSURLRequest * req;
                NSString * url = [NSString stringWithFormat:@"%@/accounts/facebook/login/token/",baseUrl];
                NSString * postData = [NSString stringWithFormat:@"access_token=%@&next=/.json",accessToken];
                req = [self makePostRequestForLogin:url withPostData:postData];
                [self fetchBms:req forProvider:YabaSignInProviderFacebook withHandler:completionHandler];
            } else {
                NSLog(@"Access not granted");
                self.loggedIn = NO;
                
                if (completionHandler) {
                    completionHandler(nil, nil, error, NO);
                } else if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
                        [self.delegate loginError:YabaSignInProviderFacebook withError:error];
                    }
                }
            }
        }];
    } else {
        [self getData:completionHandler];
    }
}

- (void)loginWithGoogle:(handlerBlock)completionHandler
{
    GTMOAuth2Authentication * auth = [_glSignIn authentication];
    
    if (!auth) {
        YabaGoogleSignInDelegate *glSignInDelegate = [[YabaGoogleSignInDelegate alloc] init:self withHandler:completionHandler];
        
        _glSignIn.shouldFetchGooglePlusUser = YES;
        _glSignIn.clientID = kGoogleClientId;
        _glSignIn.scopes = @[ kGTLAuthScopePlusLogin ];
        _glSignIn.delegate = glSignInDelegate;
        
        [_glSignIn authenticate];
    } else {
        NSLog(@"Google already logged in");
        if (self.loggedIn) {
            [self getData:completionHandler];
        } else {
            NSString * url = [NSString stringWithFormat:@"%@/allauthext/accounts/google/login/token/",baseUrl];
            NSString * postData = [NSString stringWithFormat:@"access_token=%@&next=/.json",[auth accessToken]];
            NSURLRequest * req = [self makePostRequestForLogin:url withPostData:postData];
            [self fetchBms:req forProvider:YabaSignInProviderGoogle withHandler:completionHandler];
        }
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
                   withHandler:(handlerBlock)completionHandler
{
    if (error) {
        self.loggedIn = NO;
        
        NSLog(@"Received error %@ and auth object %@",error, auth);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
                [self.delegate loginError:YabaSignInProviderGoogle withError:error];
            }
        }
    } else {
        NSLog(@"Google+ successfully authenticated");
        NSString * url = [NSString stringWithFormat:@"%@/allauthext/accounts/google/login/token/",baseUrl];
        NSString * postData = [NSString stringWithFormat:@"access_token=%@&next=/.json",[auth accessToken]];
        NSURLRequest * req = [self makePostRequestForLogin:url withPostData:postData];
        [self fetchBms:req forProvider:YabaSignInProviderGoogle withHandler:completionHandler];
    }
}

- (void)logout
{
    self.loggedIn = NO;
    
    NSString * url = [NSString stringWithFormat:@"%@/api-auth/logout/?next=/.json",baseUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req];
    [dataTask resume];
}

- (void)completeSignup:(NSURL *)url withProvider:(YabaSignInProviderType)provider
              withData:(NSString *)data withHandler:(handlerBlock)completionHandler
{
    NSString * postData=[NSString stringWithFormat:@"email=%@&next=/.json",[self urlencode:data]];
    [self fetchBms:[self makePostRequestForLogin:url.absoluteString withPostData:postData]
       forProvider:provider withHandler:completionHandler];
}

- (NSURLRequest *)makePostRequestForLogin:(NSString*)urlString withPostData:(NSString*)postDataString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *postData = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (self.csrfToken) {
        [req setValue:self.csrfToken forHTTPHeaderField:@"X-CSRFToken"];
    }
    [req setHTTPBody:postData];
    
    return req;
}

- (void)fetchBms:(NSURLRequest *)req forProvider:(YabaSignInProviderType)provider withHandler:(handlerBlock)completionHandler
{
    NSURLSessionDataTask *dataTask =
    //_dataTask =
        [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (completionHandler) {
                BOOL dataAvailable = NO;
                if (error ||
                    httpResponse.statusCode == HTTP_FORBIDDEN ||
                    [[httpResponse.URL path] rangeOfString:@"signup"].location != NSNotFound) {
                    self.loggedIn = NO;
                } else {
                    self.loggedIn = YES;
                    self.loginProvider = provider;
                    dataAvailable = YES;
                    [self readCsrfToken:req];
                }
                completionHandler(httpResponse,data,error,dataAvailable);
            } else if (self.delegate) {
                if (error) {
                    self.loggedIn = NO;
                    if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
                        [self.delegate loginError:provider withError:error];
                    }
                } else {
                    NSInteger statusCode = httpResponse.statusCode;
                    if (statusCode == HTTP_FORBIDDEN) {
                        self.loggedIn = NO;
                        if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
                            NSError *err = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:nil];
                            [self.delegate loginError:provider withError:err];
                        }
                    } else if (statusCode == HTTP_OK) {
                        [self readCsrfToken:req];
                        
                        NSLog(@"response url=%@",httpResponse.URL.absoluteString);
                        
                        if ([[httpResponse.URL path] rangeOfString:@"signup"].location == NSNotFound) {
                            self.loggedIn = YES;
                            self.loginProvider = provider;
                            NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if (jsonObject && [jsonObject count]) {
                                [self.delegate loginCompleted:provider withJSONData:jsonObject];
                            }
                        } else {
                            self.loggedIn = NO;
                            if ([self.delegate respondsToSelector:@selector(signupNeedsCompletion:withProvider:withData:)]) {
                                NSString * dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                //NSLog(@"dataStr=%@",dataStr);
                            
                                NSError *err = NULL;
                                NSRegularExpression *emailRegex =
                                [NSRegularExpression
                                    regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:&err];
                                NSString *emailAddr=nil;
                                NSRange rangeOfFirstMatch =
                                    [emailRegex rangeOfFirstMatchInString:dataStr options:0 range:NSMakeRange(0, [dataStr length])];
                                if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                                    emailAddr = [dataStr substringWithRange:rangeOfFirstMatch];
                                    NSLog(@"email=%@",emailAddr);
                                }
                                
                                [self.delegate signupNeedsCompletion:httpResponse.URL withProvider:provider withData:emailAddr];
                            }
                        }
                    }
                    
                }
            }
        }];
    [dataTask resume];
}

- (void)readCsrfToken:(NSURLRequest *) req
{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:req.URL];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"csrftoken"]) {
            self.csrfToken = [cookie value];
            break;
        }
    }
    //NSLog(@"csrftoken=%@",self.csrfToken);
}

- (void) getData:(handlerBlock)completionHandler
{
    NSString * url = [NSString stringWithFormat:@"%@/.json",baseUrl];
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self fetchBms:req forProvider:self.loginProvider withHandler:completionHandler];
}

- (NSString *)urlencode:(NSString *)unencodedString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)unencodedString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

- (void) finishWithError:(handlerBlock)completionHandler
{
    NSError *err = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:HTTP_FORBIDDEN userInfo:nil];
    
    if (completionHandler) {
        completionHandler(nil,nil,err,NO);
    } else if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
            [self.delegate loginError:YabaSignInProviderNone withError:err];
        }
    }
}

- (void)refreshData:(handlerBlock)completionHandler
{
    if (!self.loggedIn) {
        [self finishWithError:completionHandler];
    } else {
        [self getData:completionHandler];
    }
}

- (void)updateData:(YabaBookmark *)bm isDelete:(BOOL)isDelete withHandler:(handlerBlock)completionHandler
{
    if (!self.loggedIn) {
        [self finishWithError:completionHandler];
    } else {
        NSString * url = [NSString stringWithFormat:@"%@/%@/.json",baseUrl,bm.oid];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [req setValue:self.csrfToken forHTTPHeaderField:@"X-CSRFToken"];
        
        if (isDelete) {
            [req setHTTPMethod:@"DELETE"];
        } else {
            [req setHTTPMethod:@"PUT"];
            NSError *err = NULL;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:bm options:0 error:&err];
            NSLog(@"jsonData=%@",jsonData);
            [req setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
            [req setValue:@"application/json charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [req setHTTPBody:jsonData];
        }
        
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == HTTP_FORBIDDEN) {
                self.loggedIn = NO;
                [self finishWithError:completionHandler];
            } else if (error) {
                self.loggedIn = NO;
                if (completionHandler) {
                    completionHandler(httpResponse,data,error,NO);
                } else if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(loginError:withError:)]) {
                        [self.delegate loginError:YabaSignInProviderNone withError:error];
                    }
                }
            } else {
                if (completionHandler) {
                    completionHandler(httpResponse,data,error,NO);
                }
            }
        }];
        
        [dataTask resume];
    }
}

@end