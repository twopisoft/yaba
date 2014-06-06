//
//  YabaBookmarkStore.m
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkStore.h"
#import "YabaBookmark.h"
#import "YabaConnection.h"

#define HTTP_FORBIDDEN      403

@interface YabaBookmarkStore ()

@property (nonatomic) NSMutableArray *internalBmList;
@property (nonatomic,strong) YabaConnection *connection;
@end

@implementation YabaBookmarkStore

+ (instancetype)sharedStore
{
    static YabaBookmarkStore *bmStore = nil;
    
    if (!bmStore) {
        bmStore = [[self alloc] initPrivate];
    }
    
    return bmStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[YabaBookmarkStore bmStore]" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _internalBmList = [[NSMutableArray alloc] init];;
        _connection = [[YabaConnection alloc] init];
    }
    
    return self;
}

- (NSArray*) allBookmarks
{
    return self.internalBmList;
}

- (void)refreshBookmarks:(handlerBlock)completionHandler
{
    [_connection refreshData:[self wrappedCompletionHandler:completionHandler]];
}

- (void) loginWithFacebookAndRefreshBookmarks:(handlerBlock)completionHandler
{
    [_connection login:YabaSignInProviderFacebook withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void) loginWithGoogleAndRefreshBookmarks:(handlerBlock)completionHandler
{
    [_connection login:YabaSignInProviderGoogle withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void)completeSignup:(NSURL *)url withProvider:(NSString *)provider
              withData:(NSString *)data withHandler:(handlerBlock)completionHandler
{
    YabaSignInProviderType prov = YabaSignInProviderFacebook;
    
    if ([provider isEqualToString:@"Google"]) {
        prov = YabaSignInProviderGoogle;
    }
    
    [_connection completeSignup:url
                   withProvider:prov
                       withData:data
                    withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void)logout
{
    [_connection logout];
    _internalBmList = [[NSMutableArray alloc] init];
}

- (YabaBookmark *)createBm
{
    YabaBookmark *bm = [YabaBookmark randomBm];
    
    //NSLog(@"Bm=%@",bm);
    [self.internalBmList addObject:bm];
    return bm;
}

- (void)removeBm:(YabaBookmark *)bm withHandler:(handlerBlock)completionHandler
{
    [_connection updateData:bm isDelete:YES
                withHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error, BOOL dataAvailable) {
                    
                    if (!error && [response statusCode] != HTTP_FORBIDDEN) {
                        [self.internalBmList removeObjectIdenticalTo:bm];
                    }
                    if (completionHandler) {
                        completionHandler(response,data,error,dataAvailable);
                    }
                }];
}

- (void)updateBm:(YabaBookmark *)bm atIndex:(NSInteger)index withHandler:(handlerBlock)completionHandler
{
    [_connection updateData:bm isDelete:NO
                withHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error, BOOL dataAvailable) {
                    
                    if (!error && [response statusCode] != HTTP_FORBIDDEN) {
                        self.internalBmList[index] = bm;
                    }
                    if (completionHandler) {
                        completionHandler(response,data,error,dataAvailable);
                    }
                }];
}

- (void)moveBmAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    
    YabaBookmark * bm = [self.internalBmList objectAtIndex:fromIndex];
    [self.internalBmList removeObjectAtIndex:fromIndex];
    [self.internalBmList insertObject:bm atIndex:toIndex];
}

- (handlerBlock)wrappedCompletionHandler:(handlerBlock)completionHandler
{
    handlerBlock block = ^void(NSHTTPURLResponse* response, NSData* data, NSError* error, BOOL dataAvailable) {
        if (dataAvailable) {
            NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self populateBookmarkList:jsonObject[@"results"]];
        }
        
        if (completionHandler) {
            completionHandler(response,data,error,dataAvailable);
        }
    };
    
    return block;
}

- (void) populateBookmarkList:(NSArray *)jsonData
{
    self.internalBmList = [[NSMutableArray alloc] init];
    
    if (jsonData && [jsonData count]) {
        for (NSDictionary *jsonBm in jsonData) {
            YabaBookmark *bm = [[YabaBookmark alloc] init];
            bm.oid = [NSString stringWithFormat:@"%@",jsonBm[@"id"]];
            bm.name = jsonBm[@"name"];
            bm.url = jsonBm[@"url"];
            bm.imageUrl = jsonBm[@"image_url"];
            bm.synopsis = jsonBm[@"description"];
            bm.added = jsonBm[@"added"];
            bm.updated = jsonBm[@"updated"];
            bm.hasNotify = [jsonBm[@"has_notify"] boolValue];
            bm.notifyOn = jsonBm[@"notify_on"];
            bm.user = jsonBm[@"user"];
            NSString * tags = jsonBm[@"tags"];
            NSArray * tagsList = [tags componentsSeparatedByString:@","];
            for (int j=0; j<[tagsList count]; j++) {
                [bm addTag:tagsList[j]];
            }
            [self.internalBmList addObject:bm];
        }
    }
}


@end
