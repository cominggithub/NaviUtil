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





@interface GuideRouteUIView : UIView<LocationManagerDelegate, DownloadRequestDelegate>
{

    NSMutableArray *routePoints;
    NSMutableArray *carFootPrint;
    bool isDrawCarFootPrint;
    double margin;
    double ratio;
    double fitRatio;
    int locationIndex;
    PointD carPoint;
    PointD carDrawPoint;
    PointD carCenterPoint;
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
@property (nonatomic) bool isHUD;
@property (strong, nonatomic) UIColor *color;


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
-(void) setHUD;
/* LocationManager delegate */
-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;

@end
