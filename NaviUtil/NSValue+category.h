//
//  NSValue+NSValue_category.h
//  GoogleDirection
//
//  Created by Coming on 13/2/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoUtil.h"

@interface NSValue (NSValue_category)

+ (id)valueWithPointD:(PointD)v;
+ (id)valueWithCLLocationCoordinate2D:(CLLocationCoordinate2D)v;
-(PointD) PointDValue;
-(CLLocationCoordinate2D) CLLocationCoordinate2DValue;

@end
