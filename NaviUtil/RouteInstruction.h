//
//  RouteInstruction.h
//  GoogleDirection
//
//  Created by Coming on 13/2/6.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoUtil.h"

@interface RouteInstruction : NSObject
{
    int routeId;
    CLLocation *startLocation;
    CLLocation *endLocation;
    NSString *instruction;
}

-(bool) isEnterRoute:(PointD) p;
@end
