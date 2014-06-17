//
//  YabaBookmarkStore.h
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YabaDefines.h"

@class YabaBookmark;

@interface YabaBookmarkStore : NSObject

@property (nonatomic, readonly) NSArray * allBookmarks;
@property (atomic, readonly) BOOL syncInProgress;

+ (instancetype)sharedStore;
//- (YabaBookmark *) createBm;
- (void) removeBm:(YabaBookmark*)bm withHandler:(handlerBlock)completionHandler;
- (void) moveBmAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void) updateBm:(YabaBookmark *)bm atIndex:(NSInteger)index withHandler:(handlerBlock)completionHandler;

- (void) refreshBookmarks:(handlerBlock)completionHandler;
- (void) loginWithFacebookAndRefreshBookmarks:(handlerBlock)completionHandler;
- (void) loginWithGoogleAndRefreshBookmarks:(handlerBlock)completionHandler;
- (void) completeSignup:(NSURL *)url withProvider:(NSString*)provider withData:(NSString *)data
            withHandler:(handlerBlock)completionHandler;
- (void) logout;

- (BOOL) saveChanges;

//- (void) startSync;
@end
