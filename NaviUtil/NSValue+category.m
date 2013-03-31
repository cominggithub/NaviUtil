//
//  NSValue+NSValue_category.m
//  GoogleDirection
//
//  Created by Coming on 13/2/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NSValue+category.h"

@implementation NSValue (NSValue_category)

+ (id)valueWithPointD:(PointD)v
{
    return [NSValue value:&v withObjCType:@encode(PointD)];
}

+ (id)valueWithCLLocationCoordinate2D:(CLLocationCoordinate2D)v
{
    return [NSValue value:&v withObjCType:@encode(CLLocationCoordinate2D)];
}

- (PointD)PointDValue
{
    PointD v;
    [self getValue:&v];
    return v;
}

- (CLLocationCoordinate2D)CLLocationCoordinate2DValue
{
    CLLocationCoordinate2D v;
    [self getValue:&v];
    return v;
}
@end
