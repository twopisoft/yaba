//
//  YabaUtil.m
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaUtil.h"

@implementation YabaUtil

+ (NSString*) formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*) dateFromUTCString:(NSString *)dateStr
{
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [df dateFromString:dateStr];
}

+ (NSDate*)addDays:(NSDate *)date withDays:(NSInteger)days
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    if (!date) {
        date = [NSDate date];
    }
    
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setDay:days];
    return [cal dateByAddingComponents:comps toDate:date options:0];
}

@end
