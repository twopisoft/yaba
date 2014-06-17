//
//  YabaImageTransformer.m
//  yaba
//
//  Created by TwoPi on 9/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaImageTransformer.h"

@implementation YabaImageTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}
@end
