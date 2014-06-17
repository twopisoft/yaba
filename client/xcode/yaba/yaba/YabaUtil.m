//
//  YabaUtil.m
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaUtil.h"

NSString * const kYabaUserChosenLoginProvider = @"YabaUserChosenLoginProvider";
NSString * const kYabaLastSuccessfulLoginProvider = @"kYabaLastSuccessfulLoginProvider";

@implementation YabaUtil

+ (NSString*) formatDate:(NSDate *)date
{
    if (date) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
        [df setLocale:[NSLocale currentLocale]];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        return [df stringFromDate:date];
    }
    return @"";
}

+ (NSString*) dateToUTCDateString:(NSDate *)date
{
    if (date) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        return [df stringFromDate:date];
    }
    return @"";
}

+ (NSDate*) dateFromUTCString:(NSString *)dateStr
{
    if (dateStr && [dateStr length]) {
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setLocale:[NSLocale currentLocale]];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *ret = [df dateFromString:dateStr];
        if (!ret) {
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            ret = [df dateFromString:dateStr];
        }
        return ret;
    }
    
    return nil;
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

+ (void)saveLastUserChosenLoginProvider:(YabaSignInProviderType)provider
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:provider] forKey:kYabaUserChosenLoginProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveLastSuccessfulLoginProvider:(YabaSignInProviderType)provider
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:provider] forKey:kYabaLastSuccessfulLoginProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (YabaSignInProviderType)readLastUserChosenLoginProvider
{
    NSNumber * val = [[NSUserDefaults standardUserDefaults] valueForKey:kYabaUserChosenLoginProvider];
    if (val) {
        return (YabaSignInProviderType)[val intValue];
    }
    return YabaSignInProviderNone;
}

+ (YabaSignInProviderType)readLastSuccessfulLoginProvider
{
    NSNumber * val = [[NSUserDefaults standardUserDefaults] valueForKey:kYabaLastSuccessfulLoginProvider];
    if (val) {
        return (YabaSignInProviderType)[val intValue];
    }
    return YabaSignInProviderNone;
}

@end
