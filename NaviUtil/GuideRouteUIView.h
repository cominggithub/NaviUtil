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
    GR_EVENT_GPS_NO_SIGNAL,
    GR_EVENT_NETWORK_NO_SIGNAL,
    GR_EVENT_LOCATION_LOST,
    GR_EVENT_GPS_READY,
    GR_EVENT_NETWORK_READY,
    GR_EVENT_ALL_READY,
    GR_EVENT_ROUTE_DESTINATION_ERROR,
    GR_EVENT_START_NAVIGATION,
    GR_EVENT_ACTIVE,
    GR_EVENT_INACTIVE,
    GR_EVENT_ARRIVAL
}GR_EVENT;

typedef enum
{
    GR_STATE_ROUTE_PLANNING,
    GR_STATE_ROUTE_REPLANNING,
    GR_STATE_ROUTE_DESTINATION_ERROR,
    GR_STATE_NAVIGATION,
    GR_STATE_GPS_NO_SIGNAL,
    GR_STATE_NETWORK_NO_SIGNAL,
    GR_STATE_LOOKUP,
    GR_STATE_ARRIVAL,
    GR_STATE_INIT
    
}GR_STATE;


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
    RouteLine *currentRouteLine;
    NSTimer *rotateTimer;

    double angleRotateStep;
    double rotateInterval;
    CLLocationCoordinate2D currentCarLocation;
    CLLocationCoordinate2D lastCarLocation;
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
@property (nonatomic) BOOL isNetwork;
@property (nonatomic) BOOL isGps;
@property (nonatomic) GR_STATE state;


-(void) autoSimulatorLocationUpdateStart;
-(void) autoSimulatorLocationUpdateStop;
-(void) initSelf;
-(void) generateRoutePoints;
-(UIImage*) getCarImage;
-(PointD) getDrawPoint:(PointD) location;
-(BOOL) startRouteNavigationFrom:(Place*) s To:(Place*) e;
-(void) triggerLocationUpdate;
-(void) updateCarLocation:(CLLocationCoordinate2D)  newCarLocation;
/* LocationManager delegate */
-(void) locationManager:(LocationManager*) locationManager update:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading;

-(void) active;
-(void) inactive;
-(void) update;
@end
