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
}


@property (readonly) RouteStatusCode status;
@property (nonatomic, strong) TextValue *distance;
@property (nonatomic, strong) TextValue *duration;
@property (nonatomic, strong) NSString *endAddress;
@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic) int distanceValue;
@property (nonatomic) int durationValue;
@property (nonatomic) CLLocationCoordinate2D startLocation;
@property (nonatomic) CLLocationCoordinate2D endLocation;
@property (nonatomic) int numOfStep;
@property (nonatomic, strong) NSDictionary *root;


-(id) initWithJsonRouteFile: (NSString*) fileName;
-(int) getStepCount;
-(void) parseJson:(NSString*) fileName;
-(NSArray*) getRoutePolyLine;
-(NSArray*) getRoutePolyLinePointD;
-(NSArray*) getStepPolyLine:(int) stepIndex;
-(NSString*) getStepInstruction: (int) stepIndex;
-(NSString*) getStepDurationString: (int) stepIndex;
-(NSString*) getStepDistanceString: (int) stepIndex;
-(NSString*) getDocumentFilePath:(NSString*) fileName;
-(NSString*) getDocumentDirectory;
-(NSArray*) getSpeech;
-(NSString*) getStartAddress;
-(NSString*) getEndAddress;
-(CLLocationCoordinate2D) getStartLocation;
-(CLLocationCoordinate2D) getEndLocation;
-(void) dump;

@end
