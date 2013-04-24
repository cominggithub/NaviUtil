//
//  RouteLine.h
//  NaviUtil
//
//  Created by Coming on 13/4/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoUtil.h"


@interface RouteLine : NSObject
{
    PointD unitVector;
}

@property CLLocationCoordinate2D startLocation;
@property CLLocationCoordinate2D endLocation;
@property double slope;
@property bool slopeUndefined;
@property double xOffset;
@property double angle;
@property double distance;

@end
