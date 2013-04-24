//
//  GuideRouteUIView.h
//  GoogleDirection
//
//  Created by Coming on 13/1/12.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "GeoUtil.h"
#import "NSValue+category.h"
#import "Log.h"
#import "LocationManager.h"
#import "NaviQueryManager.h"





@interface GuideRouteUIView : UIView<LocationManagerDelegate>
{
    Route* route;
    NSMutableArray *routePoints;
    double margin;
    double ratio;
    double fitRatio;
    int locationIndex;
    PointD carPoint;
    PointD carDrawPoint;
    PointD carCenterPoint;
    PointD screenOffsetPoint;
    PointD startPoint;
    
    PointD leftMost, rightMost, topMost, bottomMost;
    PointD currentLocation;
    PointD startLocation;
    PointD toScreenOffset;
    CGSize screenSize;
    double distanceWidth;
    double distanceHeight;

    CGRect routeDisplayBound;
    NSTimer *timer;
    double directionAngle;
    UIImage *carImage;
    

    double routeLineM;
    bool isRouteLineMUndefind;
    double routeLineB;

    PointD routeStartPoint;
    PointD routeEndPoint;
    PointD directionStep;
    double oneStep;
    PointD routeUnitVector;
    double routeDistance;
    
    CGRect msgRect;
    int currentStep;
}

-(void) initSelf;
-(void) generateRoutePoints;
-(PointD) getDrawPoint:(PointD) location;
-(void) timerTimeout;
-(void) updateCarLocation:(CLLocationCoordinate2D) newCarLocationCoordinate2D;
-(UIImage*) getCarImage;


@end
