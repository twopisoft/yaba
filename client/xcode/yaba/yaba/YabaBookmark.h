//
//  YabaBookmark.h
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YabaBookmark : NSObject

@property (nonatomic, copy) NSString *oid;
@property (nonatomic, copy) NSString *added;
@property (nonatomic, copy) NSString *updated;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *synopsis;
@property (nonatomic, assign) BOOL hasNotify;
@property (nonatomic) NSArray *tags;
@property (nonatomic) NSString *notifyOn;
@property (nonatomic) NSString *user;

@property (nonatomic, strong) UIImage *thumbnail;

- (instancetype)initWithName:(NSString *)name withUrl:(NSString *)url;
+ (instancetype)randomBm;

-(void)addTag:(NSString*)tag;
-(void)removeTag:(NSString*)tag;

-(void)setThumbnailFromImage:(UIImage *)image withRect:(CGRect)rect;

@end
