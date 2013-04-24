//
//  RouteLine.m
//  NaviUtil
//
//  Created by Coming on 13/4/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteLine.h"

@implementation RouteLine

-(id) init
{
    self = [super init];
    if(self)
    {
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
        self.slopeUndefined = true;
    }
    // y = mx+b
    else
    {
        self.slope = (self.startLocation.latitude - self.endLocation.latitude)/(self.startLocation.longitude - self.endLocation.longitude);
        self.xOffset = self.endLocation.latitude - self.slope*self.endLocation.longitude;
        self.slopeUndefined = false;
    }
    
    self.angle = [GeoUtil getAngle:self.startLocation Point1:tmpLocation Point2:self.endLocation];
    
    if(tmpLocation.longitude > self.endLocation.longitude)
    {
        self.angle *= -1;
    }
    
    //    directionAngle = 0;
    
    //    printf("angle: %.5f\n", directionAngle*(180.0/M_PI));
    //    printf("route: (%.5f, %.5f) -> (%.5f, %.5f)\n", routeStartPoint.x, routeStartPoint.y, routeEndPoint.x, routeEndPoint.y);
    
    
    /*
     if(isRouteLineMUndefind == true)
     printf("x = %.8f\n", routeStartPoint.x);
     else if(routeLineM == 0)
     printf("y = %.8f\n", routeLineB);
     else
     printf("y = %.8fx + %.8f\n", routeLineM, routeLineB);
     
     */

    
    self.distance = [GeoUtil getLength:self.startLocation ToLocation:self.endLocation];
    unitVector.x = (self.endLocation.longitude - self.startLocation.longitude)/self.distance;
    unitVector.y = (self.endLocation.latitude - self.startLocation.latitude)/self.distance;

    
    //    printf("routeUnitVector: (%.8f, %.8f)\n", routeUnitVector.x, routeUnitVector.y);
    
    //    printf("move distance point: (%.8f, %.8f)\n", routeUnitVector.x*oneStep, routeUnitVector.y*oneStep);
    
}
@end
