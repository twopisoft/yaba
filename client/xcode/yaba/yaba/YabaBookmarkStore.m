//
//  YabaBookmarkStore.m
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkStore.h"
#import "YabaBookmark.h"

@interface YabaBookmarkStore ()

@property (nonatomic) NSMutableArray *internalBmList;

@end

@implementation YabaBookmarkStore

+ (instancetype)bmStore
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
        _internalBmList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray*) allBms
{
    return self.internalBmList;
}

- (YabaBookmark *)createBm
{
    YabaBookmark *bm = [YabaBookmark randomBm];
    
    //NSLog(@"Bm=%@",bm);
    [self.internalBmList addObject:bm];
    return bm;
}

- (void)removeBm:(YabaBookmark *)bm
{
    [self.internalBmList removeObjectIdenticalTo:bm];
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


@end
