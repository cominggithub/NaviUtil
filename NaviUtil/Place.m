//
//  Place.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize name=_name;
@synthesize coordinate=_coordinate;


-(id) init
{
    self = [super init];
    if(self)
    {
        self.placeType = kPlaceType_None;
    }
    
    return self;
}


+(NSArray*) parseJson:(NSString*) fileName
{
    int i;
    NSArray *array;
    NSDictionary *dic;
    NSDictionary *location;
    NSError* error;
    NSMutableArray *result;
    NSData *data;
    
    
    NSDictionary* root;
    
    if ( [GoogleJson getStatus:fileName] != kGoogleJsonStatus_Ok )
    {
        return nil;
    }
    
    @try
    {
        result  = [[NSMutableArray alloc] initWithCapacity:0];
        data    = [[NSFileManager defaultManager] contentsAtPath:fileName];
        root    = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
        array = [root objectForKey:@"results"];
        dic = [array objectAtIndex:0];

        for(i=0; i<array.count; i++)
        {
            Place *p = [[Place alloc] init];
            dic = [array objectAtIndex:i];
            location = [dic objectForKey:@"geometry"];
            location = [location objectForKey:@"location"];
            p.name = [NSString stringWithString:[dic objectForKey:@"name"]];
            p.address = [NSString stringWithString:[dic objectForKey:@"formatted_address"]];
            p.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location objectForKey:@"lng"] doubleValue]);
            [result addObject:p];
        }

        return result;
    
    }
    @catch (NSException *exception)
    {
        mlogWarning(PLACE, @"parse json file fail: %@", fileName);
    }
    @finally
    {
        mlogWarning(PLACE, @"parse json file fail: %@", fileName);            
    }
    
    return nil;
}

+(void) printDictionaryKeys:(NSDictionary*) dic
{
    printf("dump keys\n");
    for(NSString *aKey in dic) {
        printf("%s\n", [aKey UTF8String]);
        //        NSLog(@"%@", [[dic valueForKey:aKey] description]); //made up method
    }
}

+(void) printArray:(NSArray*) array
{
    int i=0;
    printf("dump array\n");
    for(i=0; i<[array count]; i++)
    {
//        printf("[%d]\n", i, [[array objectAtIndex:i] UTF8String]);
          printf("[%d]: %s\n", i, [[[array objectAtIndex:i] description] UTF8String]);
    }
}


+(Place*) parseDictionary:(NSDictionary*) dic
{
    double lat, lng;
    Place* p        = [[Place alloc] init];
    
    p.name          = [dic objectForKey:@"name"];
    p.address       = [dic objectForKey:@"address"];
    lat             = [[dic objectForKey:@"lat"] doubleValue];
    lng             = [[dic objectForKey:@"lng"] doubleValue];
    p.coordinate    = CLLocationCoordinate2DMake(lat, lng);
    
    return p;
}

-(NSDictionary*) toDictionary
{
    
    NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.name, @"name",
                            self.address, @"address",
                            self.coordinate.latitude, @"lat",
                            self.coordinate.longitude, @"lng",
                            nil];
    
    
    return result;
}

-(NSString*) description
{
    
    return [NSString stringWithFormat:@"%@, %@, (%.7f, %.7f)", self.name, self.address, self.coordinate.latitude, self.coordinate.longitude];
    
}

-(bool) isPlaceMatched:(NSString*) name
{

    if (nil == name || name.length < 1)
        return true;
    
    int location, length, matchedCount, i;
    float matchedRate = 0;
    location = [self.name rangeOfString:name].location;
    length = [self.name rangeOfString:name].length;

    matchedCount = 0;
    
    for(i=0; i<name.length; i++)
    {
        if([self.name rangeOfString:[name substringWithRange:NSMakeRange(i, 1)]].location != NSNotFound)
        {
            matchedCount++;
        }
    }
    
    matchedRate = matchedCount/name.length;
    mlogDebug(PLACE, @"matchedRate: (%@ - %@) = %.0f\%", self.name, name, matchedRate*100);
    
    return matchedRate > 0.6;
    
}

-(bool) isCoordinateEqualTo:(Place*) p
{
    if (nil == self || nil == p)
        return false;
    return [GeoUtil isCLLocationCoordinate2DEqual:self.coordinate To:p.coordinate];
}
@end
