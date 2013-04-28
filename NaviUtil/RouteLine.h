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

}

@property CLLocationCoordinate2D startLocation;
@property CLLocationCoordinate2D endLocation;
@property double slope;
@property bool isSlopeUndefined;
@property double xOffset;
@property double angle;
@property double distance;
@property int stepNo;
@property int routeLineNo;
@property PointD unitVector;

+(RouteLine*) getRouteLineWithStartLocation:(CLLocationCoordinate2D) startLocation
                            EndLocation:(CLLocationCoordinate2D) endLocation
                                 stepNo:(int) stepNo
                            routeLineNo:(int) routeLineNo;

-(id) initWithStartLocation:(CLLocationCoordinate2D) startLocation
                  EndLocation:(CLLocationCoordinate2D) endLocation
                       stepNo:(int) stepNo
                  routeLineNo:(int) routeLineNo;

-(double) getDistanceWithLocation:(CLLocationCoordinate2D) location;
-(double) getAngleToStartLocation:(CLLocationCoordinate2D) location;
-(double) getAngleToEndLocation:(CLLocationCoordinate2D) location;
@end
