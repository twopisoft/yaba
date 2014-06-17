//
//  YabaBookmark.m
//  yaba
//
//  Created by TwoPi on 9/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmark.h"

@implementation YabaBookmark

@dynamic oid;
@dynamic added;
@dynamic updated;
@dynamic name;
@dynamic url;
@dynamic imageUrl;
@dynamic synopsis;
@dynamic hasNotify;
@dynamic notifyOn;
@dynamic user;
@dynamic thumbnail;
@dynamic syncStatus;
@dynamic tags;


-(void)setThumbnailFromImage:(UIImage *)image withRect:(CGRect)rect
{
    CGSize origImageSize = image.size;
    
    float ratio = MAX(rect.size.width/origImageSize.width,
                      rect.size.height/origImageSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.0];
    
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (rect.size.width - projectRect.size.width)/2.0;
    projectRect.origin.y = (rect.size.height - projectRect.size.height)/2.0;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;
    
    UIGraphicsEndImageContext();
}

@end
