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
static Place*           _homeLocation;
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

+(Place*) homeLocation
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
    int i=0;
    NSString* newPlace = [NSString stringWithString:place];
    for(i=0; i<_searchedPlaces.count; i++)
    {
        if ([place isEqualToString:[_searchedPlaces objectAtIndex:i]])
        {
            [_searchedPlaces removeObjectAtIndex:i];
            i--;
        }
    }
    
    [_searchedPlaces insertObject:newPlace atIndex:0];
    
}

+(void) init
{
    if(false == [User parseJson:[SystemManager userFilePath]])
    {
        _name                   = @"Coming";
        _email                  = @"misscoming@gmail.com";
        _officeLocations        = [[NSMutableArray alloc] initWithCapacity:0];
        _favorLocations         = [[NSMutableArray alloc] initWithCapacity:0];
        _searchedPlaces         = [[NSMutableArray alloc] initWithCapacity:0];
        _homeLocation           = [[Place alloc] init];
        _homeLocation.name      = @"家";
        _homeLocation.address   = @"宜蘭縣冬山鄉保安二路131巷19號";
        [self addSearchedPlace:@"成大"];
        [self addSearchedPlace:@"宜蘭高中"];
    }

}

+(bool) parseJson:(NSString*) fileName
{
    NSError* error;
    NSDictionary *user;
    NSDictionary* root;
    NSData *data;
    
    data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    if(nil == data)
        return false;
    
    root = [NSJSONSerialization
                      JSONObjectWithData:data //1
                      options:kNilOptions
                      error:&error];

    if(nil == root)
        return false;
    
    user = [root objectForKey:@"User"];

    if(nil == user)
        return false;
    
    _name               = [user objectForKey:@"Name"];
    _email              = [user objectForKey:@"Email"];
    _homeLocation       = [Place parseDictionary:[user objectForKey:@"Home"]];
    _officeLocations    = [NSMutableArray arrayWithArray:[user objectForKey:@"Offices"]];
    _favorLocations     = [NSMutableArray arrayWithArray:[user objectForKey:@"Favors"]];
    _searchedPlaces     = [NSMutableArray arrayWithArray:[user objectForKey:@"SearchedPlaces"]];
   
    return true;
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
