//
//  User.m
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "User.h"

@implementation User

static NSString*        _name;
static NSString*        _email;
static Location*        _homeLocation;
static NSMutableArray*  _officeLocations;
static NSMutableArray*  _favorLocations;

+(NSString*) name
{
    return _name;
}

+(NSString*) email
{
    return _email;
}

+(Location*) homeLocation
{
    
    return _homeLocation;
}

+(NSArray*) officeLocations
{
    
    return _officeLocations;
}

+(NSArray*) favorLocations
{
    
    return _favorLocations;
}

+(void) init
{
    _name               = @"";
    _email              = @"";
    _homeLocation       = [[Location alloc] init];
    _officeLocations    = [[NSMutableArray alloc] initWithCapacity:0];
    _favorLocations     = [[NSMutableArray alloc] initWithCapacity:0];
    _homeLocation.coordinate = CLLocationCoordinate2DMake(24.641790,121.798983);
                       
}

+(void) parseJson:(NSString*) fileName
{
#if 0
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
    
#endif

}

+(NSDictionary*) toDictionary
{
    NSDictionary *result;
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
    NSMutableArray* officeLocationArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* favorLocationArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(Location *location in self.officeLocations)
    {
        [officeLocationArray addObject:[location toDictionary]];
    }

    for(Location *location in self.favorLocations)
    {
        [favorLocationArray addObject:[location toDictionary]];
    }

    [userDic setObject:self.name forKey:@"Name"];
    [userDic setObject:self.email forKey:@"email"];
    [userDic setObject:[self.homeLocation toDictionary] forKey:@"Home"];
    

    [userDic setObject:officeLocationArray forKey:@"Offices"];
    [userDic setObject:favorLocationArray forKey:@"Favors"];
    
    result = [NSDictionary dictionaryWithObjectsAndKeys:userDic, @"User", nil];
    return result;
}

+(void) save
{
    NSError* error;
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.toDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:[SystemManager userFilePath] atomically:true];
    
}
@end
