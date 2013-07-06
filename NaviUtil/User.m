//
//  User.m
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "User.h"
#import "TestFlight.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation User

static NSString*        _name;
static NSString*        _email;
static NSMutableArray*  _homePlaces;
static NSMutableArray*  _officePlaces;
static NSMutableArray*  _favorPlaces;
static NSMutableArray*  _searchedPlaceText;
static NSMutableArray*  _searchedPlaces;

+(NSString*) name
{
    return _name;
}

+(NSString*) email
{
    return _email;
}

+(NSArray*) homePlaces
{
    
    return _homePlaces;
}

+(NSArray*) officePlaces
{
    
    return _officePlaces;
}

+(NSArray*) favorPlaces
{
    return _favorPlaces;
}

+(NSArray*) searchedPlaceText
{
    
    return _searchedPlaceText;
}

+(NSArray*) _searchedPlaces
{
    
    return _searchedPlaces;
}

+(NSString*) getSearchPlaceTextByIndex:(int) index
{
    if(index < _searchedPlaceText.count)
    {
        return [_searchedPlaceText objectAtIndex:index];
    }

    return nil;
}

+(Place*) getHomePlaceByIndex:(int) index
{
    if(index < _homePlaces.count)
    {
        return [_homePlaces objectAtIndex:index];
    }
    
    return nil;
}

+(Place*) getOfficePlaceByIndex:(int) index
{
    if(index < _officePlaces.count)
    {
        return [_officePlaces objectAtIndex:index];
    }
    
    return nil;
}

+(Place*) getFavorPlaceByIndex:(int) index
{
    if(index < _favorPlaces.count)
    {
        return [_favorPlaces objectAtIndex:index];
    }
    
    return nil;
}

+(Place*) getSearchedPlaceByIndex:(int) index
{
    if(index < _searchedPlaces.count)
    {
        return [_searchedPlaces objectAtIndex:index];
    }
    
    return nil;
}

+(int) getSectionCount:(SectionMode) sectionMode
{
    int sectionCount = 0;

    if (_homePlaces.count > 0)
        sectionCount++;
    
    if (_officePlaces.count > 0)
        sectionCount++;
    
    if (_favorPlaces.count > 0)
        sectionCount++;
    
    if (kSectionMode_Home_Office_Favor_Searched == sectionMode)
    {
        if (_searchedPlaces.count > 0)
            sectionCount++;
    }
    else
    {
        if (_searchedPlaceText.count > 0)
            sectionCount++;
    }
    
    
    return sectionCount;
    
}



+(int) getPlaceCountBySectionMode:(SectionMode) sectionMode Section:(int) section
{
    int placeType;
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode Section:section];

    switch(placeType)
    {
        case kPlaceType_Home:
            return _homePlaces.count;
        case kPlaceType_Office:
            return _officePlaces.count;
        case kPlaceType_Favor:
            return _favorPlaces.count;
        case kPlaceType_SearchedPlace:
            return _searchedPlaces.count;
        case kPlaceType_SearchedPlaceText:
            return _searchedPlaceText.count;
    }
    
    return 0;
}

+(Place*) getPlaceBySectionMode:(SectionMode) sectionMode Section:(int) section Index:(int) index
{
    int placeType;
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode Section:section];
    
    switch(placeType)
    {
        case kPlaceType_Home:
            return [self getHomePlaceByIndex:index];
        case kPlaceType_Office:
            return [self getOfficePlaceByIndex:index];
        case kPlaceType_Favor:
            return [self getFavorPlaceByIndex:index];
        case kPlaceType_SearchedPlace:
            return [self getSearchedPlaceByIndex:index];
        case kPlaceType_SearchedPlaceText:
        {
            Place *p = [[Place alloc] init];
            p.placeType = kPlaceType_SearchedPlaceText;
            p.name = [NSString stringWithString:[self getSearchPlaceTextByIndex:index]];
            return p;
        }
    }
    
    return nil;
}

+(void) addHomePlace:(Place*) p
{
    mlogAssertNotNil(p);
    
    p.placeType = kPlaceType_Home;
    [_homePlaces addObject:p];
}

+(void) addOfficePlace:(Place*) p
{
    mlogAssertNotNil(p);
    
    p.placeType = kPlaceType_Office;
    [_officePlaces addObject:p];
}

+(void) addFavorPlace:(Place*) p
{
    mlogAssertNotNil(p);
    
    p.placeType = kPlaceType_Favor;
    [_favorPlaces addObject:p];
}

+(void) addSearchedPlace:(Place*) p
{
    mlogAssertNotNil(p);
    
    p.placeType = kPlaceType_SearchedPlace;
    [_searchedPlaces addObject:p];
    
}

+(void) addSearchedPlaceText:(NSString*) placeText
{
    int i=0;
    
    mlogAssertStrNotEmpty(placeText);
    
    NSString* newPlace = [NSString stringWithString:placeText];
    for(i=0; i<_searchedPlaceText.count; i++)
    {
        if ([placeText isEqualToString:[_searchedPlaceText objectAtIndex:i]])
        {
            [_searchedPlaceText removeObjectAtIndex:i];
            i--;
        }
    }
    
    [_searchedPlaceText insertObject:newPlace atIndex:0];
    
}

+(void) addPlaceBySectionMode:(SectionMode) sectionMode Section:(int) section Place:(Place*) p
{
    int placeType;
    
    mlogAssertNotNil(p);
    
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode Section:section];
    
    switch(placeType)
    {
        case kPlaceType_Home:
            [self addHomePlace:p];
        case kPlaceType_Office:
            [self addOfficePlace:p];
        case kPlaceType_Favor:
            [self addFavorPlace:p];
        case kPlaceType_SearchedPlace:
            [self addSearchedPlace:p];
        case kPlaceType_SearchedPlaceText:
            [self addSearchedPlaceText:p.name];
    }
}

+(void) removeHomePlaceAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _homePlaces.count-1);
    [_homePlaces removeObjectAtIndex:index];

}

+(void) removeOfficeLocationAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _officePlaces.count-1);
    [_officePlaces removeObjectAtIndex:index];

}

+(void) removeFavorLocationAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _favorPlaces.count-1);
    [_favorPlaces removeObjectAtIndex:index];

}

+(void) setPlaceSearchResult:(NSArray*) placeSearchResult
{
    mlogAssertNotNil(placeSearchResult);
    _searchedPlaces = [NSMutableArray arrayWithArray: placeSearchResult];
}

+(int) translatSectionIndexIntoPlaceType:(SectionMode) sectionMode Section:(int) section
{

    if (kSectionMode_Home == sectionMode)
        return kPlaceType_Home;
    
    if (kSectionMode_Office == sectionMode)
        return kPlaceType_Office;
    
    if (kSectionMode_Favor == sectionMode)
        return kPlaceType_Favor;
    
    if (section < 0)
        return kPlaceRouteType_None;

    if (_homePlaces.count > 0 && --section == -1)
        return kPlaceType_Home;
    
    if (_officePlaces.count > 0 && --section == -1)
        return kPlaceType_Office;
    
    if (_favorPlaces.count > 0 && --section == -1)
        return kPlaceType_Favor;
    
    if (kSectionMode_Home_Office_Favor_Searched == sectionMode)
    {
        if (_searchedPlaces.count > 0 && --section == -1)
            return kPlaceType_SearchedPlace;
    }
    else
    {
        if (_searchedPlaceText.count > 0 && --section == -1)
            return kPlaceType_SearchedPlace;
    }
    
    return kPlaceType_None;
}

+(void) updateHomePlaceAtIndex:(int) index Location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _homePlaces.count-1);
    
    Place *oldPlace = (Place*) [_homePlaces objectAtIndex:index];
    [place copyTo:oldPlace];

}

+(void) updateOfficeLocationAtIndex:(int) index Location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _officePlaces.count-1);
    
    Place *oldPlace = (Place*) [_officePlaces objectAtIndex:index];
    [place copyTo:oldPlace];
    
}

+(void) updateFavorLocationAtIndex:(int) index Location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _favorPlaces.count-1);
    
    Place *oldPlace = (Place*) [_favorPlaces objectAtIndex:index];
    [place copyTo:oldPlace];
}

+(void) removeHomePlace:(Place*) place
{
    int i;
    
    mlogAssertNotNil(place);
    
    for(i=0; i<_homePlaces.count; i++)
    {
        if ([place isEqual:[_homePlaces objectAtIndex:i]])
        {
            [_homePlaces removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) removeOfficePlace:(Place*) place
{
    int i;
    
    mlogAssertNotNil(place);
    
    for(i=0; i<_officePlaces.count; i++)
    {
        if ([place isEqual:[_officePlaces objectAtIndex:i]])
        {
            [_officePlaces removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) removeSearchedPlaces:(NSString*) place
{
    int i=0;
    
    mlogAssertStrNotEmpty(place);
    
    for(i=0; i<_searchedPlaceText.count; i++)
    {
        if ([place isEqualToString:[_searchedPlaceText objectAtIndex:i]])
        {
            [_searchedPlaceText removeObjectAtIndex:i];
            i--;
        }
    }
}

+(void) init
{
    mlogCheckPoint(@"User Init");
    if(false == [User parseJson:[SystemManager userFilePath]])
    {
        Place *p                = [[Place alloc] init];
        _name                   = @"Coming";
        _email                  = @"misscoming@gmail.com";
        _homePlaces          = [[NSMutableArray alloc] initWithCapacity:0];
        _officePlaces        = [[NSMutableArray alloc] initWithCapacity:0];
        _favorPlaces         = [[NSMutableArray alloc] initWithCapacity:0];
        _searchedPlaceText      = [[NSMutableArray alloc] initWithCapacity:0];

        p               = [[Place alloc] init];
        p.name          = @"永安租房";
        p.address       = @"台南市永康區永安路103巷20號4F-2";
        p.coordinate    = CLLocationCoordinate2DMake(23.042724,120.245876);
        [self addHomePlace:p];
        
        p               = [[Place alloc] init];
        p.name          = @"宜蘭冬山";
        p.address       = @"宜蘭縣冬山鄉保安二路131巷19號";
        p.coordinate    = CLLocationCoordinate2DMake(24.641790,121.798983);
        [self addHomePlace:p];

        p               = [[Place alloc] init];
        p.name          = @"南科智邦";
        p.address       = @"台南市新市區南科3路3號3樓";
        p.coordinate    = CLLocationCoordinate2DMake(23.099313,120.284371);
        [self addOfficePlace:p];

        p               = [[Place alloc] init];
        p.name          = @"成大";
        p.address       = @"台南市東區大學路1號";
        p.coordinate    = CLLocationCoordinate2DMake(22.9967080, 120.2198480);
        [self addFavorPlace:p];
        
        [self addSearchedPlaceText:@"成大"];
        [self addSearchedPlaceText:@"宜蘭高中"];
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
        
        _name            = [user objectForKey:@"Name"];
        _email           = [user objectForKey:@"Email"];
        _searchedPlaceText  = [NSMutableArray arrayWithArray:[user objectForKey:@"SearchedPlaces"]];
        
        _homePlaces      = [[NSMutableArray alloc] initWithCapacity:0];
        _officePlaces    = [[NSMutableArray alloc] initWithCapacity:0];
        _favorPlaces     = [[NSMutableArray alloc] initWithCapacity:0];
        
        
        tmpArray = [NSMutableArray arrayWithArray:[user objectForKey:@"Homes"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addHomePlace:p];
        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:@"Offices"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addOfficePlace:p];
        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:@"Favors"]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addFavorPlace:p];
        }
    }
    @catch (NSException *exception) {
        return false;
    }
    @finally {

    }

    return true;
}

+(NSDictionary*) toDictionary
{
    NSDictionary *result;
    NSMutableDictionary *userDic            = [[NSMutableDictionary alloc] init];
    NSMutableArray* homePlacesArray      = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* officePlacesArray    = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* favorPlacesArray     = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* SearchedPlacesArray  = [[NSMutableArray alloc] initWithCapacity:0];

    for(Place *p in self.homePlaces)
    {
        [homePlacesArray addObject:[p toDictionary]];
    }
    
    for(Place *p in self.officePlaces)
    {
        [officePlacesArray addObject:[p toDictionary]];
    }

    for(Place *p in self.favorPlaces)
    {
        [favorPlacesArray addObject:[p toDictionary]];
    }

    for(NSString *place in self.searchedPlaceText)
    {
        [SearchedPlacesArray addObject:place];
    }
    
    [userDic setObject:self.name forKey:@"Name"];
    [userDic setObject:self.email forKey:@"Email"];
    
    [userDic setObject:homePlacesArray forKey:@"Homes"];
    [userDic setObject:officePlacesArray forKey:@"Offices"];
    [userDic setObject:favorPlacesArray forKey:@"Favors"];
    [userDic setObject:SearchedPlacesArray forKey:@"SearchedPlaces"];
    
    result = [NSDictionary dictionaryWithObjectsAndKeys:userDic, @"User", nil];
    return result;
}

+(void) save
{
    [TestFlight passCheckpoint:@"User Saved Start"];
    NSError* error;
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.toDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:[SystemManager userFilePath] atomically:true];
    [TestFlight passCheckpoint:@"User Saved"];
}
@end
