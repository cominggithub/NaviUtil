//
//  GuideRouteUIView.h
//  GoogleDirection
//
//  Created by Coming on 13/1/12.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "Route.h"
#import "GeoUtil.h"
#import "NSValue+category.h"
#import "LocationManager.h"
#import "LocationSimulator.h"
#import "NaviQueryManager.h"
#import "RouteLine.h"




typedef enum
{
    state_route_planning,
    state_reroute_planning,
    state_location_lost,
    state_no_gps,
    state_no_network,
    state_navigateion,
    state_lookup,
    state_unknown
}GuideRouteState_t;

@interface GuideRouteUIView : UIView<LocationManagerDelegate, DownloadRequestDelegate, SystemManagerDelegate>
{

    NSMutableArray *routePoints;
    NSMutableArray *carFootPrint;

    double margin;
    double ratio;
    double fitRatio;
    int locationIndex;
    PointD carPoint;
    PointD carDrawPoint;

    PointD screenOffsetPoint;
    
    PointD leftMost, rightMost, topMost, bottomMost;
    PointD currentLocation;
    PointD startLocation;
    PointD toScreenOffset;
    CGSize screenSize;
    double distanceWidth;
    double distanceHeight;

    CGRect routeDisplayBound;
    NSTimer *timer;
    double targetAngle;
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
    RouteLine *lastRouteLine;
    RouteLine *currentRouteLine;
    NSTimer *rotateTimer;
    double currentDrawAngle;
    double angleRotateStep;
    double rotateInterval;
    CLLocationCoordinate2D currentCarLocation;
    AVAudioPlayer *audioPlayer;
    double xOffset;
    Place *routeStartPlace;
    Place *routeEndPlace;
    

    
}
@property (nonatomic) bool isAutoSimulatorLocationUpdateStarted;

@property (nonatomic) bool isDebugDraw;
@property (nonatomic) bool isDebugNormalLine;
@property (nonatomic) bool isDebugRouteLineAngle;


/* UI Control */
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) BOOL isSpeedUnitMph;

@property (nonatomic) NSString* messageBoxText;
@property (nonatomic) GuideRouteState_t state;
@property (nonatomic) BOOL isNetwork;
@property (nonatomic) BOOL isGps;


-(void) autoSimulatorLocationUpdateStart;
-(void) autoSimulatorLocationUpdateStop;
-(void) initSelf;
-(void) generateRoutePoints;
-(UIImage*) getCarImage;
-(PointD) getDrawPoint:(PointD) location;
-(void) startRouteNavigationFrom:(Place*) s To:(Place*) e;
-(void) timerTimeout;
-(void) triggerLocationUpdate;
-(void) updateCarLocation:(CLLocationCoordinate2D)  newCarLocation;
/* LocationManager delegate */
-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading;
-(void) lostLocationUpdate;

-(void) active;
-(void) inactive;
-(void) update;
@end
