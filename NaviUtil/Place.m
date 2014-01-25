//
//  Place.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Place.h"
#import "NSString+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation Place


#define CLOSE_THRESHOLD 5
@synthesize name=_name;
@synthesize coordinate=_coordinate;
@synthesize address=_address;


- (id)initWithName:(NSString*) name address:(NSString*) address coordinate:(CLLocationCoordinate2D) coordinate
{
    self = [super init];
    if(self)
    {
        self.placeType      = kPlaceType_None;
        self.name           = [NSString stringWithString:name];
        self.address        = [NSString stringWithString:address];
        self.coordinate     = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    }
    
    return self;
}

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
        mlogWarning(@"parse json file fail: %@", fileName);
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
          printf("[%d]: %s\n", i, [[[array objectAtIndex:i] description] UTF8String]);
    }
}


+(Place*) parseDictionary:(NSDictionary*) dic
{
    double lat, lng;
    Place* p        = [[Place alloc] init];
    
    p.name          = [dic objectForKey:@"name"];
    p.address       = [dic objectForKey:@"address"];
    p.placeType     = [[dic objectForKey:@"placeType"] intValue];
    lat             = [[dic objectForKey:@"lat"] doubleValue];
    lng             = [[dic objectForKey:@"lng"] doubleValue];
    p.coordinate    = CLLocationCoordinate2DMake(lat, lng);
    
    return p;
}

+(Place*) newPlace:(NSString*) name Address:(NSString*) address Location:(CLLocationCoordinate2D) location
{
    Place* p        = [[Place alloc] init];
    p.name          = [NSString stringWithString:name];
    p.address       = [NSString stringWithString:address];
    p.coordinate    = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    p.placeType     = kPlaceType_None;
    
    return p;
    
}

-(void) copyTo:(Place*) p;
{
    if (nil == p)
        return;
    
    p.name          = [NSString stringWithString:self.name];
    p.address       = [NSString stringWithString:self.address];
    p.placeType     = self.placeType;
    p.coordinate    = CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude);
    
}

-(NSString*) description
{
    
    return [NSString stringWithFormat:@"%@, %@, %@, (%.7f, %.7f)", self.getPlaceTypeString, self.name, self.address, self.coordinate.latitude, self.coordinate.longitude];
    
}

-(NSString*) getPlaceTypeString
{
    
    switch (self.placeType)
    {
        case kPlaceType_None:
            return @"None";
        case kPlaceType_Home:
            return @"Home";
        case kPlaceType_Office:
            return @"Office";
        case kPlaceType_Favor:
            return @"Favor";
        case kPlaceType_SearchedPlace:
            return @"Searched Place";
        case kPlaceType_SearchedPlaceText:
            return @"Searched Place Text";
        case kPlaceType_CurrentPlace:
            return @"Current Place";
        default:
            return @"unknown type";
    }
}

-(BOOL) isNullPlace
{
    return self.coordinate.latitude == 0 && self.coordinate.longitude == 0;
}

-(BOOL) isPlaceMatched:(NSString*) name
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
    mlogDebug(@"matchedRate: (%@ - %@) = %.0f\%", self.name, name, matchedRate*100);
    
    return matchedRate > 0.6;
    
}

-(BOOL) isCoordinateEqualTo:(Place*) p
{
    if (nil == self || nil == p)
        return false;
    return [GeoUtil isCLLocationCoordinate2DEqual:self.coordinate To:p.coordinate];
}
-(BOOL) isCloseTo:(Place*) p
{
    mlogAssertNotNilR(p, FALSE);

    return [GeoUtil getGeoDistanceFromLocation:self.coordinate ToLocation:p.coordinate] <= CLOSE_THRESHOLD;
}

-(NSDictionary*) toDictionary
{
    
    NSMutableDictionary* result;
    result = [[NSMutableDictionary alloc] init];

    [result setObject:self.name forKey:@"name"];
    [result setObject:self.address forKey:@"address"];
    [result setObject:[NSString stringFromInt:self.placeType] forKey:@"placeType"];
    [result setObject:[NSString stringWithFormat:@"%.7f", self.coordinate.latitude] forKey:@"lat"];
    [result setObject:[NSString stringWithFormat:@"%.7f", self.coordinate.longitude] forKey:@"lng"];
   
    
    
    return result;
}


@end
