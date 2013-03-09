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


typedef enum
{
    RouteStatusCodeOK,
    RouteStatusCodeFAIL,
}RouteStatusCode;

@interface Route : NSObject
{
    NSArray* steps;
    NSArray* polyLines;
}

@property (readonly) RouteStatusCode status;
-(id) initWithJsonRouteFile: (NSString*) fileName;
-(int) getStepCount;
-(NSArray*) getRoutePolyLine;
-(NSArray*) getRoutePolyLinePointD;
-(NSArray*) getStepPolyLine:(int) stepIndex;
-(NSString*) getStepInstruction: (int) stepIndex;
-(NSString*) getStepDurationString: (int) stepIndex;
-(NSString*) getStepDistanceString: (int) stepIndex;
-(NSString*) getDocumentFilePath:(NSString*) fileName;
-(NSString*) getDocumentDirectory;
@end
