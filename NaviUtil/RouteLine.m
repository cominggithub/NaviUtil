//
//  RouteLine.m
//  NaviUtil
//
//  Created by Coming on 13/4/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteLine.h"

@implementation RouteLine

@synthesize startLocation=_startLocation;
@synthesize endLocation=_endLocation;
@synthesize slope=_slope;
@synthesize isSlopeUndefined=_isSlopeUndefined;
@synthesize xOffset=_xOffset;
@synthesize angle=_angle;
@synthesize distance=_distance;
@synthesize stepNo=_stepNo;
@synthesize routeLineNo=_routeLineNo;
@synthesize unitVector=_unitVector;

+(RouteLine*) getRouteLineWithStartLocation:(CLLocationCoordinate2D) startLocation
                                EndLocation:(CLLocationCoordinate2D) endLocation
                                     stepNo:(int) stepNo
                                routeLineNo:(int) routeLineNo
{
    RouteLine *rl = [[RouteLine alloc] initWithStartLocation:startLocation EndLocation:endLocation stepNo:stepNo routeLineNo:routeLineNo];
    return rl;
}

-(id) initWithStartLocation:(CLLocationCoordinate2D) startLocation
                  EndLocation:(CLLocationCoordinate2D) endLocation
                     stepNo:(int) stepNo
                     routeLineNo:(int) routeLineNo
{
    self = [super init];
    if(self)
    {
        self.startLocation      = startLocation;
        self.endLocation        = endLocation;
        self.stepNo             = stepNo;
        self.routeLineNo        = routeLineNo;
        self.slope              = 0.0;
        self.isSlopeUndefined   = false;
        [self calculateLineEquation];
    }
    
    return self;
}
                     

-(void) calculateLineEquation
{
    
    CLLocationCoordinate2D tmpLocation = CLLocationCoordinate2DMake(self.startLocation.latitude+1, self.startLocation.longitude);

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
    
    if(tmpLocation.longitude > self.endLocation.longitude)
    {
        self.angle *= -1;
    }
    
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
#if 0
    double length = [GeoUtil getLengthFromLocation:location ToLocation:self.startLocation];
    
    double angle = [self getAngleToStartLocation:location];
    double distance = [GeoUtil getLengthFromLocation:location ToLocation:self.startLocation] * sin([self getAngleToStartLocation:location]);
#endif
//    mlogfns(ROUTELINE, "length: %f, angle: %f, distance: %f", length, angle, distance);
    return [GeoUtil getGeoDistanceFromLocation:location ToLocation:self.startLocation] * sin([self getAngleToStartLocation:location]);
}

-(double) getAngleToStartLocation:(CLLocationCoordinate2D) location
{

    return [GeoUtil getAngleByLocation1:location Location2:self.startLocation  Location3:self.endLocation ];
 
}

-(double) getAngleToEndLocation:(CLLocationCoordinate2D) location
{
    
    return [GeoUtil getAngleByLocation1:location Location2:self.endLocation Location3:self.startLocation];
    
}

-(double) getAngleToRouteLine:(RouteLine*) routeLine
{
    return acos(self.unitVector.x*routeLine.unitVector.x + self.unitVector.y*routeLine.unitVector.y);
}

-(NSString*) description
{
    
    if( self.isSlopeUndefined )
    {
        return [NSString stringWithFormat:@"Step:%2d, Line:%3d, angle:%4.0f, slope:    Undefine, x:%13.7f, (%11.7f, %11.7f) -> (%11.7f, %11.7f)",
                self.stepNo,
                self.routeLineNo,
                TO_ANGLE(self.angle),
                self.xOffset,
                self.startLocation.latitude,
                self.startLocation.longitude,
                self.endLocation.latitude,
                self.endLocation.longitude
                ];
    }
    
    return [NSString stringWithFormat:@"Step:%2d, Line:%3d, angle:%4.0f, slope:%12.7f, x:%13.7f, (%11.7f, %11.7f) -> (%11.7f, %11.7f)",
        self.stepNo,
        self.routeLineNo,
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
