//
//  YabaUtil.h
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YabaDefines.h"

@interface YabaUtil : NSObject

+ (NSString*) formatDate:(NSDate*)date;
+ (NSString*) dateToUTCDateString:(NSDate *)date;
+ (NSDate*) dateFromUTCString:(NSString *)dateStr;
+ (NSDate*) addDays:(NSDate*)date withDays:(NSInteger)days;
+ (id) NullToNil:(id)obj;

+ (void)saveLastUserChosenLoginProvider:(YabaSignInProviderType)provider;
+ (void)saveLastSuccessfulLoginProvider:(YabaSignInProviderType)provider;
+ (YabaSignInProviderType)readLastUserChosenLoginProvider;
+ (YabaSignInProviderType)readLastSuccessfulLoginProvider;
@end

