//
//  YabaUtil.h
//  yaba
//
//  Created by TwoPi on 15/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YabaUtil : NSObject

+ (NSString*) formatDate:(NSDate*)date;
+ (NSDate*) addDays:(NSDate*)date withDays:(NSInteger)days;

@end

