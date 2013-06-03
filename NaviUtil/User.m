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
static NSMutableArray*  _homeLocations;
static NSMutableArray*  _officeLocations;
static NSMutableArray*  _favorLocations;
static NSMutableArray*  _searchedLocations;

+(NSString*) name
{
    return _name;
}

+(NSString*) email
{
    return _email;
}

+(NSArray*) homeLocations
{
    
    return _homeLocations;
}

+(NSArray*) officeLocations
{
    
    return _officeLocations;
}

+(NSArray*) favorLocations
{
    
    return _favorLocations;
}

+(NSArray*) searchedLocations
{
    
    return _searchedLocations;
}

+(NSString*) getSearchPlaceByIndex:(int) index
{
    if(index < _searchedLocations.count)
    {
        return [_searchedLocations objectAtIndex:index];
    }

    return nil;
}

+(Place*) getHomeLocationByIndex:(int) index
{
    if(index < _homeLocations.count)
    {
        return [_homeLocations objectAtIndex:index];
    }
    
    return nil;
}

+(Place*) getOfficeLocationByIndex:(int) index
{
    if(index < _officeLocations.count)
    {
        return [_officeLocations objectAtIndex:index];
    }
    
    return nil;
}

+(Place*) getFavorLocationByIndex:(int) index
{
    if(index < _favorLocations.count)
    {
        return [_favorLocations objectAtIndex:index];
    }
    
    return nil;
}

+(void) addHomeLocation:(Place*) p
{
    p.placeType = kPlaceType_Home;
    [_homeLocations addObject:p];
}

+(void) addOfficeLocation:(Place*) p
{
    p.placeType = kPlaceType_Office;
    [_officeLocations addObject:p];
}

+(void) addFavorLocation:(Place*) p
{
    p.placeType = kPlaceType_Favor;
    [_favorLocations addObject:p];
}

+(void) addSearchedLocation:(NSString*) place
{
    int i=0;
    NSString* newPlace = [NSString stringWithString:place];
    for(i=0; i<_searchedLocations.count; i++)
    {
        if ([place isEqualToString:[_searchedLocations objectAtIndex:i]])
        {
            [_searchedLocations removeObjectAtIndex:i];
            i--;
        }
    }
    
    [_searchedLocations insertObject:newPlace atIndex:0];
    
}


+(void) removeHomeLocationAtIndex:(int) index
{
    if (index > -1 && index < _homeLocations.count)
    {
        [_homeLocations removeObjectAtIndex:index];
    }
}

+(void) removeOfficeLocationAtIndex:(int) index
{
    if (index > -1 && index < _officeLocations.count)
    {
        [_officeLocations removeObjectAtIndex:index];
    }
}

+(void) removeFavorLocationAtIndex:(int) index
{
    if (index > -1 && index < _favorLocations.count)
    {
        [_favorLocations removeObjectAtIndex:index];
    }
}

+(void) updateHomeLocationAtIndex:(int) index Location:(Place*) place
{
    if (nil == place)
        return;
    
    if (index > -1 && index < _homeLocations.count)
    {
        Place *oldPlace = (Place*) [_homeLocations objectAtIndex:index];
        [place copyTo:oldPlace];
    }
}

+(void) updateOfficeLocationAtIndex:(int) index Location:(Place*) place
{
    if (nil == place)
        return;
    
    if (index > -1 && index < _officeLocations.count)
    {
        Place *oldPlace = (Place*) [_officeLocations objectAtIndex:index];
        [place copyTo:oldPlace];
    }
}

+(void) updateFavorLocationAtIndex:(int) index Location:(Place*) place
{
    if (nil == place)
        return;
    
    if (index > -1 && index < _favorLocations.count)
    {
        Place *oldPlace = (Place*) [_favorLocations objectAtIndex:index];
        [place copyTo:oldPlace];
    }
}

+(void) removeHomePlace:(Place*) place
{
    int i;
    for(i=0; i<_homeLocations.count; i++)
    {
        if ([place isEqual:[_homeLocations objectAtIndex:i]])
        {
            [_homeLocations removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) removeOfficePlace:(Place*) place
{
    int i;
    for(i=0; i<_officeLocations.count; i++)
    {
        if ([place isEqual:[_officeLocations objectAtIndex:i]])
        {
            [_officeLocations removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) removeSearchedLocations:(NSString*) place
{

    int i=0;
    for(i=0; i<_searchedLocations.count; i++)
    {
        if ([place isEqualToString:[_searchedLocations objectAtIndex:i]])
        {
            [_searchedLocations removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) init
{

    if(false == [User parseJson:[SystemManager userFilePath]])
    {
        Place *p                = [[Place alloc] init];
        _name                   = @"Coming";
        _email                  = @"misscoming@gmail.com";
        _homeLocations          = [[NSMutableArray alloc] initWithCapacity:0];
        _officeLocations        = [[NSMutableArray alloc] initWithCapacity:0];
        _favorLocations         = [[NSMutableArray alloc] initWithCapacity:0];
        _searchedLocations      = [[NSMutableArray alloc] initWithCapacity:0];

        p               = [[Place alloc] init];
        p.name          = @"永安租房";
        p.address       = @"台南市永康區永安路103巷20號4F-2";
        p.coordinate    = CLLocationCoordinate2DMake(23.042724,120.245876);
        [self addHomeLocation:p];
        
        p               = [[Place alloc] init];
        p.name          = @"宜蘭冬山";
        p.address       = @"宜蘭縣冬山鄉保安二路131巷19號";
        p.coordinate    = CLLocationCoordinate2DMake(24.641790,121.798983);
        [self addHomeLocation:p];

        p               = [[Place alloc] init];
        p.name          = @"南科智邦";
        p.address       = @"台南市新市區南科3路3號3樓";
        p.coordinate    = CLLocationCoordinate2DMake(23.099313,120.284371);
        [self addOfficeLocation:p];

        p               = [[Place alloc] init];
        p.name          = @"成大";
        p.address       = @"台南市東區大學路1號";
        p.coordinate    = CLLocationCoordinate2DMake(22.9967080, 120.2198480);
        [self addFavorLocation:p];
        
        [self addSearchedLocation:@"成大"];
        [self addSearchedLocation:@"宜蘭高中"];
    }

}

+(bool) parseJson:(NSString*) fileName
{
    NSError* error;
    NSDictionary *user;
    NSDictionary* root;
    NSData *data;
    NSArray *tmpArray;
    
    @try
    {
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
        _searchedLocations  = [NSMutableArray arrayWithArray:[user objectForKey:@"SearchedLocations"]];
        
        _homeLocations      = [[NSMutableArray alloc] initWithCapacity:0];
        _officeLocations    = [[NSMutableArray alloc] initWithCapacity:0];
        _favorLocations     = [[NSMutableArray alloc] initWithCapacity:0];
        
        
        tmpArray = [NSMutableArray arrayWithArray:[user objectForKey:@"Homes"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addHomeLocation:p];
        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:@"Offices"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addOfficeLocation:p];
        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:@"Favors"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addFavorLocation:p];
        }
    }
    @catch (NSException *exception) {
        return false;
    }
    @finally {
        return false;
    }

    return true;
}

+(NSDictionary*) toDictionary
{
    NSDictionary *result;
    NSMutableDictionary *userDic            = [[NSMutableDictionary alloc] init];
    NSMutableArray* homeLocationsArray      = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* officeLocationsArray    = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* favorLocationsArray     = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* searchedLocationsArray  = [[NSMutableArray alloc] initWithCapacity:0];

    for(Place *p in self.homeLocations)
    {
        [homeLocationsArray addObject:[p toDictionary]];
    }
    
    for(Place *p in self.officeLocations)
    {
        [officeLocationsArray addObject:[p toDictionary]];
    }

    for(Place *p in self.favorLocations)
    {
        [favorLocationsArray addObject:[p toDictionary]];
    }

    for(NSString *place in self.searchedLocations)
    {
        [searchedLocationsArray addObject:place];
    }
    
    [userDic setObject:self.name forKey:@"Name"];
    [userDic setObject:self.email forKey:@"Email"];
    
    [userDic setObject:homeLocationsArray forKey:@"Homes"];
    [userDic setObject:officeLocationsArray forKey:@"Offices"];
    [userDic setObject:favorLocationsArray forKey:@"Favors"];
    [userDic setObject:searchedLocationsArray forKey:@"SearchedLocations"];
    
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
