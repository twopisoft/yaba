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
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    [df setLocale:[NSLocale currentLocale]];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    return [df stringFromDate:date];
}

+ (NSString*) dateToUTCDateString:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [df stringFromDate:date];
}

+ (NSDate*) dateFromUTCString:(NSString *)dateStr
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
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

+ (id)NullToNil:(id)obj
{
    return (obj==[NSNull null]?nil:obj);
}

@end
