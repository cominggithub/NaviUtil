//
//  Route.m
//  GoogleDirection
//
//  Created by Coming on 13/1/8.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Route.h"

@implementation Route

@synthesize status=_status;
-(id) init
{
    self = [super init];
    if(self)
    {
        
    }
    
    _status = RouteStatusCodeOK;
    return self;
}

-(id) initWithJsonRouteFile: (NSString*) fileName
{
    
    self = [self init];
    NSError* error;
    NSFileManager *filemanager;
    NSString *currentPath;
    
    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *jsonFile = [NSString stringWithFormat:@"%@/%@", docsDir, fileName];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:jsonFile];
    
    
    NSDictionary* root = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];

    legs    = [[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
    steps   = [[[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];

    [self saveToKMLFile:[self getName] fileName:[NSString stringWithFormat:@"%@.xml", [self getName]]];
    
    return self;
}

-(void) parseJson:(NSString*) fileName
{

    int i;
    NSArray *array;
    NSDictionary *dic;
    NSError* error;
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSDictionary* root = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
    
    array = [root objectForKey:@"results"];
    dic = [array objectAtIndex:0];
    
    legs    = [[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
    steps   = [[[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];

    speech = [[NSMutableArray alloc] initWithCapacity:steps.count];
    for(i=0; i<steps.count; i++)
    {
        Speech* s = [[Speech alloc] init];
        dic = [steps objectAtIndex:i];
        NSDictionary *location = [dic objectForKey:@"start_location"];
        
        s.text = [NSString stringWithString:[dic objectForKey:@"html_instructions"]];
        s.coordinate  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                   [[location objectForKey:@"lng"] doubleValue]);
        [speech addObject:s];
    }
    
    [self saveToKMLFile:[self getName] fileName:[NSString stringWithFormat:@"%@.xml", [self getName]]];
    
}
-(void) printDictionaryKeys:(NSDictionary*) dic
{
    
    for(NSString *aKey in dic) {
        NSLog(@"%@", aKey);
        //        NSLog(@"%@", [[dic valueForKey:aKey] description]); //made up method
    }
}

-(void) printArray:(NSArray*) array
{
    int i=0;
    for(i=0; i<[array count]; i++)
    {
        NSLog(@"v: %@", [array objectAtIndex:i]);
    }
}


-(int) getStepCount
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
    
    NSLog(@"routePolyLine: %d", [routePolyLine count]);
    return routePolyLine;

}

-(NSArray*) getRoutePolyLinePointD
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
    
    NSLog(@"routePolyLine: %d", [routePolyLine count]);
    return routePolyLine;
}

-(NSArray*) getRoutePolyLine
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
    
    NSLog(@"routePolyLine: %d", [routePolyLine count]);
    return routePolyLine;
}

-(NSArray*) getStepPolyLine:(int) index
{
    NSArray *polyLine = [[[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"polyline"] objectForKey:@"points"] decodePolyLine];
    return polyLine;

}

-(NSString* ) getStepInstruction: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"html_instructions"] stringByStrippingHTML];
}

-(NSString* ) getStepDurationString: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"duration"] objectForKey:@"text"];
}

-(NSString* ) getStepDistanceString: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"distance"] objectForKey:@"text"];
}

-(void) saveToKMLFile:(NSString*)name fileName: (NSString*)fName
{
    
    NSMutableString *content = [[NSMutableString alloc] init];
    NSMutableString *coordinates = [[NSMutableString alloc] init];
    NSArray* routePolyLine = self.getRoutePolyLine;

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
    
    NSString* filepath = [[NSString alloc] init];
    NSError *err;
    
    filepath = [self getDocumentFilePath:fName];
    
    BOOL ok = [content writeToFile:filepath atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
    if (!ok) {
        NSLog(@"Error writing file at %@\n%@",
              filepath, [err localizedFailureReason]);
    }
    
}

-(NSString*) getDocumentFilePath:(NSString*) fileName
{
    return [self.getDocumentDirectory stringByAppendingPathComponent:fileName];
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

-(NSArray*) getSpeechText
{
    NSMutableArray* result;
    
    return result;
}

-(NSString*) getStartAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"start_address"];
}

-(NSString*) getEndAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"end_address"];
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
    CLLocationCoordinate2D startLocation = [self getStartLocation];
    CLLocationCoordinate2D endLocation = [self getStartLocation];
    
    return [NSString stringWithFormat:@"%@ To %@ (%.7f,%.7f) -> (%.7f,%.7f)",
            [self getStartAddress],
            [self getEndAddress],
            startLocation.latitude,
            startLocation.longitude,
            endLocation.latitude,
            endLocation.longitude
            ];
}

@end
