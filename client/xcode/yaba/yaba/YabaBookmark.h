//
//  YabaBookmark.h
//  yaba
//
//  Created by TwoPi on 9/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "YabaBookmarkTag.h"


@interface YabaBookmark : NSManagedObject

@property (nonatomic, strong) NSString * oid;
@property (nonatomic, strong) NSDate * added;
@property (nonatomic, strong) NSDate * updated;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * synopsis;
@property (nonatomic) BOOL hasNotify;
@property (nonatomic, strong) NSDate * notifyOn;
@property (nonatomic, strong) NSString * user;
@property (nonatomic, strong) UIImage * thumbnail;
@property (nonatomic, strong) NSNumber * syncStatus;
@property (nonatomic, strong) NSSet *tags;
@end

@interface YabaBookmark (CoreDataGeneratedAccessors)

- (void)addTagsObject:(YabaBookmarkTag *)value;
- (void)removeTagsObject:(YabaBookmarkTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;
- (void)setThumbnailFromImage:(UIImage *)image withRect:(CGRect)rect;
@end
