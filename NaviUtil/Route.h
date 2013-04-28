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


typedef enum
{
    RouteStatusCodeOK,
    RouteStatusCodeFAIL,
}RouteStatusCode;

@interface Route : NSObject
{
    NSArray* steps;
    NSArray* polyLines;
    NSMutableArray *speech;
    NSArray *legs;
    NSArray *routeLines;
    NSMutableArray *tmpRouteLines;
    int routeLineCount;
    
    CLLocationCoordinate2D routeLineStartLocation;
    CLLocationCoordinate2D routeLineEndLocation;
}


@property (readonly) RouteStatusCode status;

@property (nonatomic) int distanceValue;
@property (nonatomic) int durationValue;
@property (nonatomic) CLLocationCoordinate2D startLocation;
@property (nonatomic) CLLocationCoordinate2D endLocation;
@property (nonatomic) int numOfStep;
@property (nonatomic, strong) NSDictionary *root;




-(id) initWithJsonRouteFile: (NSString*) fileName;
-(int) getStepCount;
-(void) parseJson:(NSString*) fileName;
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
-(RouteLine*) findClosestRouteLineByLocation:(CLLocationCoordinate2D) location LastRouteLine:(RouteLine*)lastRouteLine;

-(CLLocationCoordinate2D) getStartLocation;
-(CLLocationCoordinate2D) getEndLocation;
-(void) dump;

@end
