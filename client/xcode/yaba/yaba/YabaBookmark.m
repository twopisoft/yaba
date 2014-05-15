//
//  YabaBookmark.m
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmark.h"

#define StringFromBoolean(value) (value ? @"YES" : @"NO")

@interface YabaBookmark ()

@property (nonatomic) NSMutableSet *tagSet;


@end

@implementation YabaBookmark

-(instancetype)initWithName:(NSString *)name withUrl:(NSString *)url
{
    self = [super init];
    
    if (self) {
        _name = name;
        _url = url;
        _imageUrl = @"";
        _synopsis = @"";
        _added = [[NSDate alloc] init];
        _updated = nil;
        _hasNotify = NO;
        _notifyOn = nil;
        _tagSet = [[NSMutableSet alloc] init];
        _user = @"";
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithName:@"BM" withUrl:@""];
}

- (NSArray*) tags
{
    return [self.tagSet allObjects];
}

-(void)addTag:(NSString *)tag
{
    [self.tagSet addObject:tag];
}

-(void)removeTag:(NSString*)tag
{
    [self.tagSet removeObject:tag];
}

+ (instancetype)randomBm
{
    NSArray * nameList = @[@"Violence against women in politics rising in Pakistan, India: study",
                           @"Increased loadshedding worries prime minister",
                           @"PM arrives in Karachi to review operation",
                           @"Anand - Kahin Door Jab Din Dhal Jaaye Saanj"];
    NSArray * urlList = @[@"http://www.dawn.com/news/1103511/violence-against-women-in-politics-rising-in-pakistan-india-study",
                          @"http://www.dawn.com/news/1102953/increased-loadshedding-worries-prime-minister",
                          @"http://www.dawn.com/news/1106255/pm-arrives-in-karachi-to-review-operation",
                          @"http://www.youtube.com/watch?v=BmYT79bYIQw"];
    NSArray * imageUrlList = @[@"http://i.dawn.com/medium/2014/05/53620b3008e5c.jpg?r=859066511",
                               @"http://i.dawn.com/thumbnail/2014/04/535f05b3a8d61.jpg?r=1172350925",
                               @"http://i.dawn.com/medium/2014/05/537325d9da72b.jpg?r=660420117",
                               @"http://i1.ytimg.com/vi/BmYT79bYIQw/maxresdefault.jpg"];
    
    NSArray * descList =
        @[@"In the study, more than one in every three respondents in Pakistan (36 per cent) maintained that keeping \"politics as a "
           "male domain\" is a key reason for VAWIP. All respondents in KP (Pakistan) quoted purdah as one of the main impediments to "
           "women participating in politics",
          @"ISLAMABAD: With temperature still below 40 degree Celsius, ghosts of loadshedding have already started haunting the length "
           "and breadth of the country. With demonstrations being held over loadshedding in the interior of Sindh, where mercury in "
           "some districts has crossed 40C, and Punjab subjected to increasing outages, the government appears to have bent its mind "
           "to addressing the problem.",
          @"Sharif chaired a meeting over the city's law and order situation which was also attended by former president Zardari.",
          @"Movie : Anand Music Director : Salil Choudhury Singer : Mukesh Director : Hrishikesh Mukherjee Enjoy this super hit song from the 1971 "
           "movie Anand starring R..."];
    
    NSArray * tagsList = @[@"article", @"DAWN.com", @"Women", @"Load Shedding", @"Pakistan", @"Karachi", @"YouTube", @"Mukesh"];
    NSArray * hasNotify = @[@YES, @NO];
    
    NSInteger nameIndex = arc4random() % [nameList count];
    NSInteger numTags = arc4random() % [tagsList count];
    NSInteger notifyDays = arc4random() % 20;
    NSInteger hasNotifyIndex = arc4random() % [hasNotify count];
    NSInteger updateDays = arc4random() % 5;
    
    YabaBookmark *newBm = [[YabaBookmark alloc] init];
    newBm.name = [nameList objectAtIndex:nameIndex];
    newBm.url = [urlList objectAtIndex:nameIndex];
    newBm.imageUrl = [imageUrlList objectAtIndex:nameIndex];
    newBm.synopsis = [descList objectAtIndex:nameIndex];
    newBm.hasNotify = (BOOL) [hasNotify objectAtIndex:hasNotifyIndex];
    if (newBm.hasNotify) {
        newBm.notifyOn = [YabaBookmark randomDate:[NSDate date] addDays:notifyDays];
    }
    newBm.updated = [YabaBookmark randomDate:[NSDate date] addDays:updateDays];
    
    for (int i=0; i<numTags; i++) {
        [newBm addTag:[tagsList objectAtIndex:i]];
    }
    
    return newBm;
}

+ (NSDate*)randomDate:(NSDate*)date addDays:(NSInteger) days
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    if (!date) {
        date = [NSDate date];
    }
    
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setDay:days];
    return [cal dateByAddingComponents:comps toDate:date options:0];
}

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

-(NSString *)description
{
    NSMutableString* desc =
    [[NSMutableString alloc] initWithFormat:@"Bookmark:\n\tName=%@\n\tUrl=%@\n\tImage Url=%@\n\tDescription=%@\n\tTags=%@\n\tAdded=%@\n\tUpdated=%@\n\tHas Notify=%@\n\t",
     self.name,
     self.url,
     self.imageUrl,
     self.synopsis,
     [self.tags componentsJoinedByString:@","],
     self.added,
     self.updated,
     StringFromBoolean(self.hasNotify)];
    
    if (self.hasNotify) {
        [desc appendString:[[NSString alloc] initWithFormat:@"Notify On=%@\n",self.notifyOn]];
    }
    
    return desc;
}
@end
