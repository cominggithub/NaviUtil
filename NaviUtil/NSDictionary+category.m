//
//  NSDictionary+category.m
//  NaviUtil
//
//  Created by Coming on 13/3/9.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NSDictionary+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation NSDictionary (category)

-(TextValue*) textValue
{
    TextValue* result = [[TextValue alloc] init];
    result.text = [self objectForKey:@"text"];
    result.value = [[self objectForKey:@"value"] intValue];
    
    return result;
}

-(void) dump
{
    printf("dump dic:\n");
    for(NSString *key in self) {
        printf("%s:%s\n", [key UTF8String], [[[self objectForKey:key] description] UTF8String]);

    }
}

+(NSDictionary*) getLatLngDic:(CLLocationCoordinate2D) coordinate
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            
                                [NSString stringWithFormat:@"%.7f", coordinate.latitude], @"lat",
                                [NSString stringWithFormat:@"%.7f", coordinate.longitude], @"lng",
                                nil];

    return result;
}

-(CLLocationCoordinate2D) getCLLocationCoordinate2D
{
    if(nil == self)
        return CLLocationCoordinate2DMake(0, 0);
    CLLocationCoordinate2D cl = CLLocationCoordinate2DMake(
                                                           [[self objectForKey:@"lat"] doubleValue],
                                                           [[self objectForKey:@"lan"] doubleValue]);
    
    return cl;
}
@end
