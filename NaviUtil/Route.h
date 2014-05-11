//
//  Route.h
//  GoogleDirection
//
//  Created by Coming on 13/1/8.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+category.h"
#import "NSValue+category.h"
#import "GeoUtil.h"
#import "TextValue.h"
#import "Speech.h"
#import "RouteLine.h"
#import "GoogleJson.h"


typedef enum
{
    kRouteStatusCodeOk,
    kRouteStatusCodeFail,
}RouteStatusCode;

@interface Route : NSObject
{
    NSArray* steps;
    NSArray* polyLines;
    NSMutableArray *speech;
    NSArray *legs;
    
    NSMutableArray *tmpRouteLines;
    int routeLineCount;
    
    CLLocationCoordinate2D routeLineStartLocation;
    CLLocationCoordinate2D routeLineEndLocation;
}


@property (nonatomic) RouteStatusCode status;

@property (nonatomic) int distanceValue;
@property (nonatomic) int durationValue;
@property (nonatomic) int numOfStep;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, strong) NSDictionary *root;
@property (nonatomic, strong) NSArray *routeLines;





+(Route*) parseJson:(NSString*) fileName;

-(id) initWithJsonRouteFile: (NSString*) fileName;
-(long) getStepCount;
-(NSArray*) getRoutePolyLineCLLocationCoordinate2D;
-(NSArray*) getRoutePolyLineCLLocation;
-(NSArray*) getRoutePolyLinePointD;
-(NSArray*) getStepPolyLine:(int) stepIndex;
-(NSString*) getStepInstruction: (int) stepIndex;
-(NSString*) getStepDurationString: (int) stepIndex;
-(NSString*) getStepDistanceString: (int) stepIndex;
-(NSString*) getDocumentDirectory;
-(NSArray*) getSpeech;
-(NSString*) getStartAddress;
-(NSString*) getEndAddress;
-(NSString*) getDurationString;
-(NSString*) getDistanceString;
-(RouteLine*) findClosestRouteLineByLocation:(CLLocationCoordinate2D) location LastRouteLine:(RouteLine*)lastRouteLine distance:(double*) outDistance;
-(CLLocationCoordinate2D) getStartLocation;
-(CLLocationCoordinate2D) getEndLocation;
-(RouteLine*) getNextStepFirstRouteLineByRouteLine:(RouteLine*) currentRouteLine carLocation:(CLLocationCoordinate2D) carLocation speed:(double)speed distanceToNextStep:(double*)distanceToNextStep timeToNextStep:(double*)timeToNextStep;
-(double) getAngleFromCLLocationCoordinate2D:(CLLocationCoordinate2D) location routeLineNo:(int) routeLineNo withInDistance:(double) distance;
-(double) getCorrectedTargetAngle:(int) routeLineNo distance:(int) distance;

@end
