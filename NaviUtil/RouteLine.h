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
@property (nonatomic, readonly) CGPoint startProjectedPoint;     // projected point
@property (nonatomic, readonly) CGPoint endProjectedPoint;       // projected point
@property double slope;
@property bool isSlopeUndefined;
@property double xOffset;
@property double angle;
@property double distance;
@property double cumulativeDistance;
@property double mathDistance;
@property int stepNo;
@property int no;
@property PointD unitVector;
@property BOOL startRouteLine;

+(RouteLine*) getRouteLineWithStartLocation:(CLLocationCoordinate2D) startLocation
                            EndLocation:(CLLocationCoordinate2D) endLocation
                                 stepNo:(int) stepNo
                            routeLineNo:(int) routeLineNo
                             startRouteLine:(BOOL) startRouteLine;

-(double) getGeoDistanceToLocation:(CLLocationCoordinate2D) location;
-(double) getAngleToStartLocation:(CLLocationCoordinate2D) location;
-(double) getAngleToEndLocation:(CLLocationCoordinate2D) location;
-(double) getTurnAngle:(RouteLine*) routeLine;

@end
