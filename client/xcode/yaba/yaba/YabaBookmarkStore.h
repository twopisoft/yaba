//
//  YabaBookmarkStore.h
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YabaBookmark;

@interface YabaBookmarkStore : NSObject

@property (nonatomic, readonly) NSArray * allBms;

+ (instancetype)bmStore;
- (YabaBookmark *) createBm;
- (void) removeBm:(YabaBookmark*)bm;
- (void) moveBmAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
