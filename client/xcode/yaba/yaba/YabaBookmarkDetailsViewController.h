//
//  YabaBookmarkDetailsViewController.h
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GooglePlus/GooglePlus.h>

@class YabaBookmark;

@interface YabaBookmarkDetailsViewController : UIViewController <GPPSignInDelegate>

@property (nonatomic, strong) YabaBookmark* bm;
@property (nonatomic, assign) NSInteger bmIndex;

@end
