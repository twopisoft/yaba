//
//  YabaBookmark.h
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YabaBookmark : NSObject

@property (nonatomic) NSDate *added;
@property (nonatomic) NSDate *updated;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *synopsis;
@property (nonatomic) BOOL hasNotify;
@property (nonatomic) NSArray *tags;
@property (nonatomic) NSDate *notifyOn;
@property (nonatomic) NSString *user;

@property (nonatomic, strong) UIImage *thumbnail;

- (instancetype)initWithName:(NSString *)name withUrl:(NSString *)url;
+ (instancetype)randomBm;

-(void)addTag:(NSString*)tag;
-(void)removeTag:(NSString*)tag;

-(void)setThumbnailFromImage:(UIImage *)image withRect:(CGRect)rect;

@end
