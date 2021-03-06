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

    CGSize screenSize;

    CGRect routeDisplayBound;

    UIImage *carImage;
    
    CGPoint routeStartProjectedPoint;
    CGPoint routeEndProjectedPoint;
    
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
-(UIImage*) getCarImage;
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
