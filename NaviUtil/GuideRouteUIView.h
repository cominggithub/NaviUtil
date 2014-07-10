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
#import "NaviState.h"
#import "CarStatus.h"


@interface GuideRouteUIView : UIView<LocationManagerDelegate, DownloadRequestDelegate, SystemManagerDelegate, NaviStateDelegate>
{

    NSMutableArray *routePoints;
    NSMutableArray *carFootPrint;

    double margin;
    double ratio;
    double fitRatio;
    int locationIndex;


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

    PointD routeStartPoint; // old
    PointD routeEndPoint;   // old
    CGPoint routeStartProjectedPoint;
    CGPoint routeEndProjectedPoint;
    PointD directionStep;
    double oneStep;
    PointD routeUnitVector;
    double routeDistance;
    
    CGRect msgRect;
    int currentStep;
    RouteLine *currentRouteLine;


    double angleRotateStep;
    double rotateInterval;

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



-(void) autoSimulatorLocationUpdateStart;
-(void) autoSimulatorLocationUpdateStop;
-(void) initSelf;
-(void) generateRoutePoints;
-(UIImage*) getCarImage;
-(PointD) getDrawPoint:(PointD) location;
-(BOOL) startRouteNavigationFrom:(Place*) s To:(Place*) e;
-(void) triggerLocationUpdate;
-(void) updateCarLocation:(CLLocationCoordinate2D) location speed:(double)speed heading:(double)heading;

/* DownloadRequest delegate */
-(void) downloadRequest:(DownloadRequest*) downloadRequest status:(DownloadStatus) status;

/* LocationManager delegate */
-(void) locationManager:(LocationManager*) locationManager update:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading;

-(void) active;
-(void) inactive;
-(void) update;
@end
