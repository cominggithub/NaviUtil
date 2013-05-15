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
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    
    NSDictionary* root = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
    
    array = [root objectForKey:@"results"];
    dic = [array objectAtIndex:0];

    for(i=0; i<array.count; i++)
    {
        Place *p = [[Place alloc] init];
        dic = [array objectAtIndex:i];
        location = [dic objectForKey:@"geometry"];
        location = [location objectForKey:@"location"];
        p.name = [NSString stringWithString:[dic objectForKey:@"name"]];
        p.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location objectForKey:@"lng"] doubleValue]);
        [result addObject:p];
    }

    return result;
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

@end
