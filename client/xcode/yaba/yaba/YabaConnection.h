//
//  YabaConnection.h
//  yaba
//
//  Created by TwoPi on 2/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YabaDefines.h"

#import <GoogleOpenSource/GoogleOpenSource.h>
#import "YabaBookmark.h"


@class YabaConnection;

@protocol YabaConnectionDelegate <NSObject>

- (void)loginCompleted:(YabaSignInProviderType)provider withJSONData:(NSDictionary *)jsonData;

@optional
- (void)loginError:(YabaSignInProviderType)provider withError:(NSError*)error;
- (void)signupNeedsCompletion:(NSURL*)url withProvider:(YabaSignInProviderType)provider withData:(NSString*)data;

@end

@protocol  YabaConnectionGPPSignInDelegate <NSObject>

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
             withHandler:(handlerBlock)completionHandler;

@end

@interface YabaConnection : NSObject 

@property (nonatomic) id<YabaConnectionDelegate> delegate;

- (void)login:(YabaSignInProviderType)provider
                withHandler:(handlerBlock)completionHandler;

- (void)logout;

- (void)completeSignup:(NSURL *)url withProvider:(YabaSignInProviderType)provider
              withData:(NSString *)data withHandler:(handlerBlock)completionHandler;

- (void)refreshData:(handlerBlock)completionHandler;

- (instancetype)initWithDelegate:(id<YabaConnectionDelegate>)delegate;

- (void)updateData:(YabaBookmark *)oid isDelete:(BOOL)isDelete withHandler:(handlerBlock)completionHandler;

@end
