//
//  YabaBookmarkTag.h
//  yaba
//
//  Created by TwoPi on 11/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YabaBookmark;

@interface YabaBookmarkTag : NSManagedObject

@property (nonatomic, retain) NSString * tagValue;
@property (nonatomic, strong) NSNumber * syncStatus;
@property (nonatomic, retain) NSSet *bookmarks;
@end

@interface YabaBookmarkTag (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(YabaBookmark *)value;
- (void)removeBookmarksObject:(YabaBookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

@end
