//
//  Route.m
//  GoogleDirection
//
//  Created by Coming on 13/1/8.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Route.h"
#import "SystemConfig.h"

#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"

#define DISTANCE_FROM_ROUTE_LINE_THRESHOLD  10
#define DISTANCE_FROM_START_POINT_THRESHOLD 10

@implementation Route
{
    double _cumulativeDistance;
}

@synthesize status = _status;
@synthesize routeLines = _routeLines;

-(id) init
{
    self = [super init];
    if(self)
    {
        routeLineCount = -1;
    }
    
    _status = kRouteStatusCodeFail;
    return self;
}

-(id) initWithJsonRouteFile: (NSString*) fileName
{

    return self;
}

-(bool) parseJson:(NSString*) fileName
{

    int i = 0;
    NSArray *array;
    NSDictionary *location;
    NSDictionary *dic;
    NSError* error;
    NSData *data;
    NSDictionary* root;
    BOOL startRouteLine;
    
    if ( [GoogleJson getStatus:fileName] != kGoogleJsonStatus_Ok )
    {
        return nil;
    }
    
    @try
    {
        
        data  = [[NSFileManager defaultManager] contentsAtPath:fileName];
        root  = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        array = [root objectForKey:@"results"];
        dic = [array objectAtIndex:0];
    
        legs    = [[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
        steps   = [[[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
        speech = [[NSMutableArray alloc] initWithCapacity:steps.count];
        [self initRouteLines];

        dic = [[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0];
 
        /* add Start Location */
        [self addLocationToRouteLinesWithStepNo:i Location:[self getStartLocation] startRouteLine:FALSE];


        for(i=0; i<steps.count; i++)
        {

            startRouteLine = TRUE;
            Speech* s = [[Speech alloc] init];
            dic = [steps objectAtIndex:i];
            s.text = [[NSString stringWithString:[dic objectForKey:@"html_instructions"]] stripHTML];
            s.coordinate  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                   [[location objectForKey:@"lng"] doubleValue]);
            [speech addObject:s];
            NSArray *stepPolyLine = [self getStepPolyLine:i];
            /* add points in PolyLie */
            for(CLLocation *location in stepPolyLine)
            {

                if ([self addLocationToRouteLinesWithStepNo:i Location:location.coordinate startRouteLine:startRouteLine])
                {
                    startRouteLine = FALSE;
                }
            }


        }
    
        self.status = kRouteStatusCodeOk;
        [self addLocationToRouteLinesWithStepNo:i-1 Location:[self getEndLocation] startRouteLine:FALSE];

        [self saveRouteLines];
        [self saveToKMLFileName:[self getName] filePath:[NSString stringWithFormat:@"%@/%@.kml", [SystemManager getPath:kSystemManager_Path_Route], [self getName]]];
     
        [self dumpRouteLines];
    }
    @catch (NSException *exception)
    {
        mlogWarning(@"parse json file fail: %@, reason: %@\n%@", fileName, [exception reason], exception );
        return FALSE;
    }
    
    return TRUE;
}

+(Route*) parseJson:(NSString*) fileName
{
    Route* r = [[Route alloc] init];
    if(![r parseJson:fileName])
        return nil;
    return r;
    
}
-(void) initRouteLines
{
    tmpRouteLines       = [[NSMutableArray alloc] initWithCapacity:0];
    routeLineCount      = -1;
    _cumulativeDistance = 0;
}

-(BOOL) addLocationToRouteLinesWithStepNo:(int) stepNo Location:(CLLocationCoordinate2D) location startRouteLine:(BOOL) startRouteLine
{
    BOOL added;
    

    mlogDebug(@"AddLocationToRouteLinesWithStepNo: %3d, Line: %3d, (%12.7f, %12.7f)", stepNo, routeLineCount, location.latitude, location.longitude);
    
    routeLineEndLocation    = location;
    added                   = TRUE;
    
    if(routeLineCount == -1)
    {
        routeLineStartLocation = routeLineEndLocation;
        routeLineCount++;
    }
    
    if( !(routeLineStartLocation.longitude == routeLineEndLocation.longitude &&
          routeLineStartLocation.latitude == routeLineEndLocation.latitude))
    {
        RouteLine *routeLine = [RouteLine getRouteLineWithStartLocation: routeLineStartLocation
                                                            EndLocation: routeLineEndLocation
                                                                 stepNo: stepNo
                                                            routeLineNo:routeLineCount
                                                         startRouteLine:startRouteLine];
        routeLine.distance = [GeoUtil getGeoDistanceFromLocation:routeLineStartLocation ToLocation:routeLineEndLocation];
        routeLine.cumulativeDistance = _cumulativeDistance;
        
        _cumulativeDistance += routeLine.distance;
        [tmpRouteLines addObject:routeLine];
        routeLineCount++;
    }
    else
    {
        mlogDebug(@"    Skip");
        added = FALSE;
    }

    routeLineStartLocation = routeLineEndLocation;
    
    return added;
}

-(void) saveRouteLines
{
    self.routeLines = [NSArray arrayWithArray:tmpRouteLines];
}

-(long) getStepCount
{
    return [steps count];
}

-(NSArray*) getSubRouteStartPoints
{
    int i = 0;
    int max = 100;
    int cnt = 0;
    PointD p;
    PointD prev;
    p.x = -1;
    prev.x = -2;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count] && cnt < max ; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];

        for(CLLocation *location in stepPolyLine)
        {
            p.x = location.coordinate.longitude;
            p.y = location.coordinate.latitude;
            
            if(!(prev.x == p.x && prev.y == prev.y))
                [routePolyLine addObject:[NSValue valueWithPointD:p]];
            
            cnt++;
            prev.x = p.x;
            prev.y = p.y;
            
            if(cnt > max)
                break;
        }
    }
    
    return routePolyLine;

}

-(NSArray*) getRoutePolyLineCLLocationCoordinate2D
{

    int i = 0;
    CLLocationCoordinate2D p;
    CLLocationCoordinate2D prev;
    prev = CLLocationCoordinate2DMake(0, 0);
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count]; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        for(CLLocation *location in stepPolyLine)
        {
            p = location.coordinate;
            if(!(prev.latitude == p.latitude && prev.longitude == prev.longitude))
                [routePolyLine addObject:[NSValue valueWithCLLocationCoordinate2D:p]];
            prev = p;
        }
    }
    
    return routePolyLine;
}

-(NSArray*) getRoutePolyLinePointD
{
    int i = 0;
    int max = 100000;
    int cnt = 0;
    PointD p;
    PointD prev;
    p.x = -1;
    prev.x = -2;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    
    /* add start location */
    p = [GeoUtil makePointDFromCLLocationCoordinate2D:[self getStartLocation]];
    prev.x  = p.x;
    prev.y  = p.y;
    [routePolyLine addObject:[NSValue valueWithPointD:p]];
    
    for(i=0; i<[steps count] && cnt < max ; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        
        /* add points in poly line */
        for(CLLocation *location in stepPolyLine)
        {
            p.x = location.coordinate.longitude;
            p.y = location.coordinate.latitude;
            
            if(!(prev.x == p.x && prev.y == p.y))
                [routePolyLine addObject:[NSValue valueWithPointD:p]];
            
            cnt++;
            prev.x = p.x;
            prev.y = p.y;
            
            if(cnt > max)
                break;
        }


    }
    
    /* add end location */
    p = [GeoUtil makePointDFromCLLocationCoordinate2D:[self getEndLocation]];
    
    [routePolyLine addObject:[NSValue valueWithPointD:p]];
    
    return routePolyLine;
}

-(NSArray*) getRoutePolyLineCLLocation
{
    int i = 0;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count]; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        
        for(CLLocation *location in stepPolyLine)
        {
            [routePolyLine addObject:location];
        }
    }
    
    return routePolyLine;
}


-(NSArray*) getStepPolyLine:(int) index
{
    NSArray *polyLine = [[[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"polyline"] objectForKey:@"points"] decodePolyLine];
    return polyLine;

}

-(NSString* ) getStepInstruction: (int) index
{
    if (index == steps.count)
    {
        mlogError(@"index >= steps.count");
        return @"";
    }
    
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"html_instructions"] stripHTML];
}

-(NSString* ) getStepDurationString: (int) index
{
    if (index >= steps.count)
    {
        mlogError(@"index >= steps.count");
        return @"";
    }
    
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"duration"] objectForKey:@"text"];
}

-(NSString* ) getStepDistanceString: (int) index
{
    if (index >= steps.count)
    {
        mlogError(@"index >= steps.count");
        return @"";
    }
    
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"distance"] objectForKey:@"text"];
}

-(void) saveToKMLFileName:(NSString*)name filePath: (NSString*)filePath
{
    
    NSMutableString *content = [[NSMutableString alloc] init];
    NSMutableString *coordinates = [[NSMutableString alloc] init];
    NSArray* routePolyLine = self.getRoutePolyLineCLLocation;

    for(CLLocation* cl in routePolyLine)
    {
        [coordinates appendFormat:@"%f,%f,0 \n", cl.coordinate.longitude, cl.coordinate.latitude];
    }
    
    [content appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [content appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"];
    [content appendString:@"<Document>\n"];
    [content appendFormat:@"<name>%@</name>\n", name];
    [content appendString:@"<Placemark>\n"];
    [content appendString:@"<Style>\n"];
    [content appendString:@"<LineStyle>\n"];
    [content appendString:@"<color>FF00FF00</color>\n"];
    [content appendString:@"<width>10</width>\n"];
    [content appendString:@"</LineStyle>\n"];
    [content appendString:@"</Style>\n"];
    [content appendString:@"<MultiGeometry>\n"];
    [content appendString:@"<LineString>\n"];
    [content appendString:@"<tessellate>1</tessellate>\n"];
    [content appendString:@"<altitudeMode>clampToGround</altitudeMode>\n"];
    [content appendString:@"<coordinates>\n"];
    [content appendString:coordinates];
    
    [content appendString:@"</coordinates>\n"];
    [content appendString:@"</LineString>\n"];
    [content appendString:@"</MultiGeometry>\n"];
    [content appendString:@"</Placemark>\n"];
    [content appendString:@"</Document>\n"];
    [content appendString:@"</kml>"];
    
    NSError *err;
    mlogDebug(@"kml path:%@\n", filePath);
    
    BOOL ok = [content writeToFile:filePath atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
    if (!ok)
    {
        mlogWarning(@"cannot write: %@\n", filePath);
    }
    
}



-(NSString*) getDocumentDirectory
{
    NSFileManager *filemanager;
    NSString *currentPath;
    
    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}

-(NSArray*) getSpeech
{
    return speech;
}

-(NSString*) getStartAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"start_address"];
}

-(NSString*) getEndAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"end_address"];
}

-(NSString*) getDurationString
{
    return [[[legs objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"];
}

-(NSString*) getDistanceString
{
    return [[[legs objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"text"];
}

-(CLLocationCoordinate2D) getStartLocation
{
    NSDictionary *location = [[legs objectAtIndex:0] objectForKey:@"start_location"];
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(
                                        [[location objectForKey:@"lat"] doubleValue],
                                        [[location objectForKey:@"lng"] doubleValue]);
    
    return result;
}

-(CLLocationCoordinate2D) getEndLocation
{
    NSDictionary *location = [[legs objectAtIndex:0] objectForKey:@"end_location"];
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(
                                                               [[location objectForKey:@"lat"] doubleValue],
                                                               [[location objectForKey:@"lng"] doubleValue]);
    
    return result;
}

-(NSString *) getName
{
    return [NSString stringWithFormat:@"%@_to_%@",
            [self getStartAddress],
            [self getEndAddress]
            ];
    
}

-(NSString *) getNameWithCoordinate
{
    CLLocationCoordinate2D startLocation = [self getStartLocation];
    CLLocationCoordinate2D endLocation = [self getStartLocation];
    
    return [NSString stringWithFormat:@"%@_to_%@((%.7f,%.7f)_To_(%.7f,%.7f))",
            [self getStartAddress],
            [self getEndAddress],
            startLocation.latitude,
            startLocation.longitude,
            endLocation.latitude,
            endLocation.longitude
            ];
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"%@ to %@ (%.7f,%.7f) -> (%.7f,%.7f), Step:%d, RouteLines:%d",
            [self getStartAddress],
            [self getEndAddress],
            [self getStartLocation].latitude,
            [self getStartLocation].longitude,
            [self getEndLocation].latitude,
            [self getEndLocation].longitude,
            steps.count,
            self.routeLines.count
            ];
}

-(RouteLine*) crossRouteLineByLocation:(CLLocationCoordinate2D) location
{
    int i;
    double angleStart; // angle from start point
    double angleEnd;   // angle from end point
    double tmpDistance;
    double tmpStartDistance;
    double distanceFromStart;
    RouteLine* candidateRouteLine;
    
    distanceFromStart = DISTANCE_FROM_START_POINT_THRESHOLD;
    
    for(i=0; i<routeLineCount; i++)
    {
        
        RouteLine *rl = [self.routeLines objectAtIndex:i];
        [self calculateDistanceFromLocation:location
                              fromRouteLine:rl
                                 angleStart:&angleStart
                                   angleEnd:&angleEnd
                                   distance:&tmpDistance
                          distanceFromStart:&tmpStartDistance];

        /* find acute triangle */
        if(angleStart <= 90 && angleEnd <= 90)
        {
            return rl;
        }

        /* check the distance from start point
         * choose the route line whose start point is cloeset to the car location
         */
        if(tmpStartDistance < distanceFromStart)
        {
            distanceFromStart   = tmpStartDistance;
            candidateRouteLine  = rl;
        }
    }
    
    return nil;
    
}

-(RouteLine*) findClosestRouteLineByLocation:(CLLocationCoordinate2D) location LastRouteLine:(RouteLine*)lastRouteLine
{
    int i=0;
    int radius = 20;
    int searchCount = 0;
    NSDate* startTime;
    NSDate* endTime;
    NSTimeInterval duration;
    
    RouteLine* matchedRouteLine             = nil;
    RouteLine* matchedRouteLineWithEndPoint = nil;
//    RouteLine* carCurrentRouteLine          = nil;
    double distance                         = DISTANCE_FROM_ROUTE_LINE_THRESHOLD;
    double distanceFromStartPoint           = DISTANCE_FROM_START_POINT_THRESHOLD;
    double tmpDistance                      = 0.0;
    double tmpStartDistance                 = 0.0;
    double angleStart                       = 0.0;
    double angleEnd                         = 0.0;

    startTime = [NSDate date];
    NSString *matchFlag;

    if(lastRouteLine == nil)
        i = 0;
    else
        i = lastRouteLine.no;
    
    /* look forward */
    for(; i<lastRouteLine.no+radius && i<routeLineCount; i++)
    {

        RouteLine *rl = [self.routeLines objectAtIndex:i];
        [self calculateDistanceFromLocation:location
                              fromRouteLine:rl
                                 angleStart:&angleStart
                                   angleEnd:&angleEnd
                                   distance:&tmpDistance
                          distanceFromStart:&tmpStartDistance];
            matchFlag = @"";
            if(angleStart <= 90 && angleEnd <= 90)
            {
                matchFlag = @"acute";
            }
            
            if((tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {
                
                matchedRouteLine = rl;
                distance = tmpDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"*"];
            }
            
            if(tmpStartDistance < distanceFromStartPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromStartPoint = tmpStartDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"E"];
            }

            mlogDebug(@"rlno:%3d (%12.8f, %12.8f) ag:%3.0f agS:%3.0f agE:%3.0f d:%3.0f dS:%3.0f %@",
                      rl.no,
                      rl.startLocation.latitude,
                      rl.startLocation.longitude,
                      angleStart + angleEnd,
                      angleStart,
                      angleEnd,
                      tmpDistance,
                      tmpStartDistance,
                      matchFlag
                      );

            searchCount++;
        }
        
        /* look backward */
        if(lastRouteLine == nil)
            i = -1;
        for(i=lastRouteLine.no-1; i>=0 && i>=lastRouteLine.no-radius && i<routeLineCount; i--)
        {
            RouteLine *rl = [self.routeLines objectAtIndex:i];
            [self calculateDistanceFromLocation:location
                                  fromRouteLine:rl
                                     angleStart:&angleStart
                                       angleEnd:&angleEnd
                                       distance:&tmpDistance
                              distanceFromStart:&tmpStartDistance];
            matchFlag = @"";   
            if(angleStart <= 90 && angleEnd <= 90)
            {
                matchFlag = @"acute";
            }
            if((tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {
                
                matchedRouteLine = rl;
                distance = tmpDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"*"];
            }
            if(tmpStartDistance < distanceFromStartPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromStartPoint = tmpStartDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"E"];
            }
            
            mlogDebug(@"rlno:%3d (%12.8f, %12.8f) ag:%3.0f agS:%3.0f agE:%3.0f d:%3.0f dS:%3.0f %@",
                      rl.no,
                      rl.startLocation.latitude,
                      rl.startLocation.longitude,
                      angleStart + angleEnd,
                      angleStart,
                      angleEnd,
                      tmpDistance,
                      tmpStartDistance,
                      matchFlag
                      );
            
            searchCount++;
        }

    if(distance >= DISTANCE_FROM_ROUTE_LINE_THRESHOLD && nil != matchedRouteLineWithEndPoint)
    {
        
        matchedRouteLine = matchedRouteLineWithEndPoint;
        matchFlag = @"E*";
        mlogDebug(@"rlno:%3d (%12.8f, %12.8f) ag:%3.0f agS:%3.0f agE:%3.0f d:%3.0f dS:%3.0f %@",
                  matchedRouteLine.no,
                  matchedRouteLine.startLocation.latitude,
                  matchedRouteLine.startLocation.longitude,
                  angleStart + angleEnd,
                  angleStart,
                  angleEnd,
                  tmpDistance,
                  tmpStartDistance,
                  matchFlag
                  );
        
    }
    

    endTime = [NSDate date];
    
    duration = [endTime timeIntervalSinceDate:startTime];

    
    mlogDebug(@"Matched: %d(%.1f), RouteLine %d searched, in %f seconds",
             matchedRouteLine != nil ? matchedRouteLine.no : -1,
             distance,
             searchCount,
             duration
             );

    return matchedRouteLine;
        
}

-(void) calculateDistanceFromLocation:(CLLocationCoordinate2D) location fromRouteLine:(RouteLine*) rl
               angleStart:(double*) angleStart angleEnd:(double*) angleEnd distance:(double*) distance distanceFromStart:(double*) distanceFromStart
{
    *distance           = [rl getGeoDistanceToLocation:location];
    *angleStart         = TO_ANGLE([rl getAngleToStartLocation:location]);
    *angleEnd           = TO_ANGLE([rl getAngleToEndLocation:location]);
    *distance           = [rl getGeoDistanceToLocation:location];
    *distanceFromStart  = [GeoUtil getGeoDistanceFromLocation:rl.startLocation ToLocation:location];
}

/* within 30s or 30 meters */
-(RouteLine*) getNextStepFirstRouteLineByRouteLine:(RouteLine*) currentRouteLine carLocation:(CLLocationCoordinate2D) carLocation speed:(double)speed distanceToNextStep:(double*)distanceToNextStep timeToNextStep:(double*)timeToNextStep
{
    mlogAssertNotNilR(currentRouteLine, nil);
    double minDistance;
    double minTime;
    RouteLine *nextStepRouteLine;
    
    minDistance             = [SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_BEFORE_DISTANCE];
    minTime                 = [SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_BEFORE_TIME];
    *distanceToNextStep     = [GeoUtil getGeoDistanceFromLocation:carLocation ToLocation:currentRouteLine.endLocation];
    nextStepRouteLine       = nil;
    
    for(RouteLine* rl in self.routeLines)
    {
        /* accumulate each subsequential route line */
        if (rl.stepNo == currentRouteLine.stepNo && rl.no > currentRouteLine.no)
        {
            *distanceToNextStep += rl.distance;
        }
        else if(rl.stepNo == currentRouteLine.stepNo+1)
        {
            nextStepRouteLine = rl;
            if (speed > 0)
            {
                *timeToNextStep = *distanceToNextStep/speed;
            }
            else
            {
                *timeToNextStep = minTime+1;
            }
        }
    }
    
    /* if car is not approaching the route line of next step, then just return nil */
    if (*distanceToNextStep > minDistance && *timeToNextStep > minTime)
    {
        nextStepRouteLine = nil;
    }
    
    
    return nextStepRouteLine;
}


-(void) dumpRouteLines
{
    
    for(RouteLine *rl in self.routeLines)
    {
        logObjNoName(rl);
    }
}

-(void) dumpRouteLineAndPolyLine
{
    int i=0;
    NSArray* polyLine = [self getRoutePolyLinePointD];
    for(i=0; i<polyLine.count && i<self.routeLines.count;i++)
    {
        NSValue *v = [polyLine objectAtIndex:i];
        RouteLine *rl = [self.routeLines objectAtIndex:i];
        PointD p = [v PointDValue];
        if(p.y == rl.startLocation.latitude && p.x == rl.startLocation.longitude)
        {
            printf(" ");
        }
        else
        {
            printf("!");
        }
        printf("step:%4d, line: %4d, (%12.7f, %12.7f), (%12.7f, %12.7f)\n",
               rl.stepNo, rl.no,
               p.y, rl.startLocation.latitude,
               p.x, rl.startLocation.longitude);
    }
    
}


-(double) getAngleFromCLLocationCoordinate2D:(CLLocationCoordinate2D) location routeLineNo:(int) routeLineNo withInDistance:(double) distance;
{
    int i;

    double cumulativeDistance           = 0;
    double startAngleCumulativeDistance = 0;
    double endAngleCumulativeDistance   = 0;
    double startAngle                   = 0;
    double endAngle                     = 0;
    double turnAngle                    = 0;
    double distanceToNextRouteLine      = 0;
    bool isStartAngleUndfined           = TRUE;
    RouteLine *r;
    
    if (routeLineNo < 0 || routeLineNo > self.routeLines.count)
        return 0;

    r = (RouteLine*) [self.routeLines objectAtIndex:routeLineNo];
    distanceToNextRouteLine = [GeoUtil getGeoDistanceFromLocation:location ToLocation:r.endLocation];
    
    // look backward to decide start angle
    for (i=routeLineNo; i >= 0 && cumulativeDistance < distance; i--)
    {
        r = (RouteLine*) [self.routeLines objectAtIndex:routeLineNo];
        if (r.distance > 1)
        {
            startAngle                      = r.angle;
            endAngle                        = r.angle;
            startAngleCumulativeDistance    += r.distance;
            endAngleCumulativeDistance      += r.distance;
            cumulativeDistance  += [GeoUtil getGeoDistanceFromLocation:location ToLocation:r.endLocation];
            isStartAngleUndfined = FALSE;
//            mlogDebug(@"Start Angle: %.2f at r:%d, cdistance: %.2f", startAngle, r.no, cumulativeDistance);
            break;
        }

    }
    
    
    // look forward to decide end angle
    for (i=routeLineNo+1; i<self.routeLines.count && cumulativeDistance < distance; i++)
    {
        r = [self.routeLines objectAtIndex:i];

        if (r.distance > 3)
        {
            if (TRUE == isStartAngleUndfined)
            {
                startAngle                      = r.angle;
                startAngleCumulativeDistance    += r.distance;
    //            mlogDebug(@"Start Angle: %.2f at r:%d, cdistance: %.2f", startAngle, r.no, cumulativeDistance);
                isStartAngleUndfined = FALSE;
            }
            endAngle                    = r.angle;
            endAngleCumulativeDistance  += r.distance;
            
            cumulativeDistance          += r.no == routeLineNo ? distanceToNextRouteLine : r.distance;
            
            /* if we get an angle that is greater than 90 degress, then break the loop */
            if (fabs([GeoUtil getTurnAngleFrom:startAngle toAngle:endAngle]) >= M_PI_4 + 0.1)
            {
                break;
            }
        }
//        mlogDebug(@"End Angle: %.2f at r:%d, cdistance: %.2f", endAngle, r.no, cumulativeDistance);
    }
    
    turnAngle = [GeoUtil getTurnAngleFrom:startAngle toAngle:endAngle];
    
//    mlogDebug(@"StartAngle: %.0f, EndAngle: %.0f, turnAngle: %.0f, cdistance: %.2f",
//              TO_ANGLE(startAngle),
//              TO_ANGLE(endAngle),
//              TO_ANGLE(turnAngle),
//              cumulativeDistance);
    
    return turnAngle;
    
}

-(double) getCorrectedTargetAngle:(int) routeLineNo distance:(int) distance
{
    int i;
    
    double cumulativeDistance   = 0;

    RouteLine *r;
    
    if (routeLineNo < 0 || routeLineNo > self.routeLines.count)
        return 0;
    
    // look backward
    for (i=routeLineNo; i >= 0 && cumulativeDistance < distance; i--)
    {
        r = (RouteLine*) [self.routeLines objectAtIndex:routeLineNo];
        if (r.distance > 2)
        {
            return r.angle;
        }
    }
    
    // look forward
    for (i=routeLineNo; i<self.routeLines.count && cumulativeDistance < distance; i++)
    {
        r = [self.routeLines objectAtIndex:i];
        
        if (r.distance > 2)
        {
            return r.angle;
        }
    }
    
    return 0;
}

/* the the distance from car location to the target route line by following the route */
-(double) getDistanceFromLocation:(CLLocationCoordinate2D) location routeLineNo:routeLineNo toRouteLineNo:toLRouteLineNo
{
    return 10;
}
@end
