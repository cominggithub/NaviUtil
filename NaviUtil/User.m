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
static NSMutableArray*  _searchedPlaces;

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

+(NSArray*) searchedPlaces
{
    
    return _searchedPlaces;
}

+(NSString*) getSearchPlaceByIndex:(int) index
{
    if(index < _searchedPlaces.count)
    {
        return [_searchedPlaces objectAtIndex:index];
    }
    
    return nil;
}


+(void) addSearchedPlace:(NSString*) place
{
    [_searchedPlaces addObject:place];
}

+(void) init
{
    _name               = @"";
    _email              = @"";
    _homeLocation       = [[Location alloc] init];
    _officeLocations    = [[NSMutableArray alloc] initWithCapacity:0];
    _favorLocations     = [[NSMutableArray alloc] initWithCapacity:0];
    _searchedPlaces     = [[NSMutableArray alloc] initWithCapacity:0];
    _homeLocation.coordinate = CLLocationCoordinate2DMake(24.641790,121.798983);
                       
}

+(void) parseJson:(NSString*) fileName
{
    NSError* error;
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];

    
    NSDictionary* root = [NSJSONSerialization
                      JSONObjectWithData:data //1
                      options:kNilOptions
                      error:&error];
    _name               = [root objectForKey:@"Name"];
    _email              = [root objectForKey:@"Email"];
    _officeLocations    = [root objectForKey:@"Offices"];
    _favorLocations     = [root objectForKey:@"Favors"];
    _searchedPlaces     = [root objectForKey:@"SearchedPlaces"];
    
    int i=0;
    for(i=0; i<_searchedPlaces.count; i++)
    {
        logo([_searchedPlaces objectAtIndex:i]);
    }
}

+(NSDictionary*) toDictionary
{
    NSDictionary *result;
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
    NSMutableArray* officeLocationArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* favorLocationArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* searchedPlaceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(Location *location in self.officeLocations)
    {
        [officeLocationArray addObject:[location toDictionary]];
    }

    for(Location *location in self.favorLocations)
    {
        [favorLocationArray addObject:[location toDictionary]];
    }

    for(NSString *place in self.searchedPlaces)
    {
        [searchedPlaceArray addObject:place];
    }
    
    [userDic setObject:self.name forKey:@"Name"];
    [userDic setObject:self.email forKey:@"Email"];
    [userDic setObject:[self.homeLocation toDictionary] forKey:@"Home"];
    

    [userDic setObject:officeLocationArray forKey:@"Offices"];
    [userDic setObject:favorLocationArray forKey:@"Favors"];
    [userDic setObject:searchedPlaceArray forKey:@"SearchedPlaces"];
    
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
