//
//  RouteLine.m
//  NaviUtil
//
//  Created by Coming on 13/4/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteLine.h"
#import "CoordinateTranslator.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation RouteLine

@synthesize startLocation=_startLocation;
@synthesize endLocation=_endLocation;
@synthesize slope=_slope;
@synthesize isSlopeUndefined=_isSlopeUndefined;
@synthesize xOffset=_xOffset;
@synthesize angle=_angle;
@synthesize distance=_distance;
@synthesize stepNo=_stepNo;
@synthesize no=_no;
@synthesize unitVector=_unitVector;

+(RouteLine*) getRouteLineWithStartLocation:(CLLocationCoordinate2D) startLocation
                                EndLocation:(CLLocationCoordinate2D) endLocation
                                     stepNo:(int) stepNo
                                routeLineNo:(int) routeLineNo
                             startRouteLine:(BOOL) startRouteLine
{
    RouteLine *rl = [[RouteLine alloc] initWithStartLocation:startLocation EndLocation:endLocation stepNo:stepNo routeLineNo:routeLineNo startRouteLine:startRouteLine];
    

    return rl;
}

-(id) initWithStartLocation:(CLLocationCoordinate2D) startLocation
                  EndLocation:(CLLocationCoordinate2D) endLocation
                     stepNo:(int) stepNo
                     routeLineNo:(int) no
             startRouteLine:(BOOL) startRouteLine
{
    self = [super init];
    if(self)
    {
        self.startLocation      = startLocation;
        self.endLocation        = endLocation;
        self.stepNo             = stepNo;
        self.no                 = no;
        self.slope              = 0.0;
        self.isSlopeUndefined   = false;
        self.distance           = 0;
        self.cumulativeDistance = 0;
        self.startRouteLine     = startRouteLine;
     
        _startProjectedPoint             = [CoordinateTranslator projectCoordinate:startLocation];
        _endProjectedPoint               = [CoordinateTranslator projectCoordinate:endLocation];
        
        [self calculateLineEquation];

    }
    
    return self;
}
                     

-(void) calculateLineEquation
{
    
    CLLocationCoordinate2D tmpLocation = CLLocationCoordinate2DMake(self.startLocation.latitude+0.00001, self.startLocation.longitude);

    // x = ??
    if((self.startLocation.longitude - self.endLocation.longitude) == 0)
    {
        self.slope = 0;
        self.isSlopeUndefined = true;
    }
    // y = mx+b
    else
    {
        self.slope = (self.startLocation.latitude - self.endLocation.latitude)/(self.startLocation.longitude - self.endLocation.longitude);
        self.xOffset = self.endLocation.latitude - self.slope*self.endLocation.longitude;
        self.isSlopeUndefined = false;
    }
    
    self.angle = [GeoUtil getAngleByLocation1:tmpLocation Location2:self.startLocation Location3:self.endLocation];

#if 1
    if(tmpLocation.longitude > self.endLocation.longitude)
    {
        self.angle *= -1;
    }
#else

    if(tmpLocation.longitude > self.endLocation.longitude)
    {
        self.angle = 2*M_PI - self.angle;
    }
#endif
    
    self.distance   = [GeoUtil getLengthFromLocation:self.startLocation ToLocation:self.endLocation];
    self.mathDistance = [GeoUtil getMathLengthFromLocation:self.startLocation ToLocation:self.endLocation];
    self.unitVector = [GeoUtil makePointDFromX:(self.endLocation.longitude - self.startLocation.longitude)/self.distance
                                             Y:(self.endLocation.latitude  - self.startLocation.latitude )/self.distance];
 
}

-(double) getGeoDistanceToLocation:(CLLocationCoordinate2D) location;
{
    /* distance from a point x to a line
     * distance from x to start location * sin(angle(x->startLocation->EndLocation))
     */

    double angle;
    double distanceToStartLocation;
    double distanceToEndLocation;
    angle                   = [self getAngleToStartLocation:location];
    distanceToStartLocation = [GeoUtil getGeoDistanceFromLocation:location ToLocation:self.startLocation];
    distanceToEndLocation   = [GeoUtil getGeoDistanceFromLocation:location ToLocation:self.endLocation];
    
    if (angle != 0)
    {
        return distanceToStartLocation * sin(angle);
    }
    else
    {
        // location -> start -> end
        if (distanceToEndLocation > self.distance)
        {
            logfn();
            return distanceToStartLocation;
        }
        // start -> location -> end
        else
        {
            logfn();
            return 0;
        }
    }
}

-(double) getAngleToStartLocation:(CLLocationCoordinate2D) location
{

    return [GeoUtil getAngleByLocation1:location Location2:self.startLocation  Location3:self.endLocation ];
 
}

-(double) getAngleToEndLocation:(CLLocationCoordinate2D) location
{
    
    return [GeoUtil getAngleByLocation1:location Location2:self.endLocation Location3:self.startLocation];
    
}

-(double) getTurnAngle:(RouteLine*) routeLine
{
    bool reverseDirection = false;
    double angleOffset = fabs(self.angle - routeLine.angle);
    double turnAngle;
    
    /* if angle offset > 180 || angle offset < -180
     then turn right + becomes turn left - and
     turn left - becomes turn right +
     */
    reverseDirection = angleOffset > (M_PI) ? true:false;
    
    /* should be turn right + */
    if(self.angle < routeLine.angle)
    {
        turnAngle = angleOffset;
        /* become turn left - */
        if (true == reverseDirection)
        {
            turnAngle = (-1) * (2*M_PI - turnAngle);
        }
    }
    /* should be turn left - */
    else
    {
        turnAngle = (-1) * angleOffset;
        /* becomes turn right + */
        if (true == reverseDirection)
        {
            turnAngle = 2*M_PI + turnAngle;
        }
    }
    
    return turnAngle;
}

-(NSString*) description
{
    
    if( self.isSlopeUndefined )
    {
        return [NSString stringWithFormat:@"Step:%2d, Line:%3d%@, distance: %.2f, angle:%4.0f, slope:    Undefine, x:%13.7f, (%11.7f, %11.7f) -> (%11.7f, %11.7f)",
                self.stepNo,
                self.no,
                self.startRouteLine ? @"*":@"-",
                self.distance,
                TO_ANGLE(self.angle),
                self.xOffset,
                self.startLocation.latitude,
                self.startLocation.longitude,
                self.endLocation.latitude,
                self.endLocation.longitude

                ];
    }
    
    return [NSString stringWithFormat:@"Step:%2d, Line:%3d%@, distance: %.2f, angle:%4.0f, slope:%12.7f, x:%13.7f, (%11.7f, %11.7f) -> (%11.7f, %11.7f)",
        self.stepNo,
        self.no,
        self.startRouteLine ? @"*":@"-",
        self.distance,            
        TO_ANGLE(self.angle),
        self.slope,
        self.xOffset,
        self.startLocation.latitude,
        self.startLocation.longitude,
        self.endLocation.latitude,
        self.endLocation.longitude
        ];

}
@end
