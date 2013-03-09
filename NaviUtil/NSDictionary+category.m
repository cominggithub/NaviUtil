//
//  NSDictionary+category.m
//  NaviUtil
//
//  Created by Coming on 13/3/9.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NSDictionary+category.h"

@implementation NSDictionary (category)

-(TextValue*) textValue
{
    TextValue* result = [[TextValue alloc] init];
    result.text = [self objectForKey:@"text"];
    result.value = [[self objectForKey:@"value"] intValue];
    
    return result;
}

@end
