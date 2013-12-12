//
//  User.m
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "User.h"
#import "TestFlight.h"
#import "NSString+category.h"


#define FILE_DEBUG FALSE
#include "Log.h"

#define USERJSON_VERSION                @"Version"
#define USERJSON_USER                   @"Usuer"
#define USERJSON_NAME                   @"Name"
#define USERJSON_EMAIL                  @"Email"
#define USERJSON_HOMES                  @"Homes"
#define USERJSON_OFFICES                @"Offices"
#define USERJSON_FAVORS                 @"Favors"
#define USERJSON_SEARCHED_PLACE_TEXT    @"SearchedPlaceText"
#define USERJSON_SEARCHED_PLACES        @"SearchedPlaces"
#define USERJSON_RECENT_PLACES          @"RecentPlaces"

#define USER_SEARCHED_PLACE_TEXT_MAX 20
#define USER_RECENT_PLACE_MAX 20

#define USERJSON_VERSION_NUM 1

@implementation User

static int              _versionNum;
static NSString*        _name;
static NSString*        _email;
static NSMutableArray*  _homePlaces;
static NSMutableArray*  _officePlaces;
static NSMutableArray*  _favorPlaces;
static NSMutableArray*  _searchedPlaceText;
static NSMutableArray*  _searchedPlaces;
static NSMutableArray*  _recentPlaces;


#pragma mark -- property
+(int) versionNum
{
    return _versionNum;
}

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

+(NSArray*) searchedPlaces
{
    
    return _searchedPlaces;
}

+(NSArray*) recentPlaces
{
    return _recentPlaces;
}

+(int) placeCount
{
    int count = 0;
    
    if (nil != _homePlaces )
        count += _homePlaces.count;
    
    if (nil != _officePlaces)
        count += _officePlaces.count;
    
    if (nil != _favorPlaces)
        count += _favorPlaces.count;

    if (nil != _searchedPlaces)
        count += _searchedPlaces.count;
    
    return count;
}

#pragma mark -- place

+(void) addFavorPlace:(Place*) p
{
    mlogAssertNotNil(p);
    p.placeType = kPlaceType_Favor;
    [_favorPlaces addObject:p];
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

+(void) addPlaceSearchResult:(NSArray*) placeSearchResult
{
    mlogAssertNotNil(placeSearchResult);
    if (placeSearchResult.count > 0)
    {
        [_searchedPlaces addObjectsFromArray:placeSearchResult];
    }
}

+(void) addRecentPlace:(Place*) p
{
    int i;
    Place* tmpP;

    mlogAssertNotNil(p);
    
    /* remove the same place */
    for (i=0; i<_recentPlaces.count; i++)
    {
        tmpP = [_recentPlaces objectAtIndex:i];
        if ([tmpP isCoordinateEqualTo:p])
        {
            [_recentPlaces removeObjectAtIndex:i--];
        }
    }
    
    /* remove last place if there are more then 20 places */
    if (_recentPlaces.count > USER_RECENT_PLACE_MAX)
        [_recentPlaces removeLastObject];
    
    [_recentPlaces insertObject:p atIndex:0];
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
    NSString* newPlaceText;
    
    mlogAssertStrNotEmpty(placeText);
    
    if (_searchedPlaceText.count >= USER_SEARCHED_PLACE_TEXT_MAX)
    {
        NSIndexSet *range = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, USER_SEARCHED_PLACE_TEXT_MAX-1)];
        _searchedPlaceText = [NSMutableArray arrayWithArray:[_searchedPlaceText objectsAtIndexes:range]];
    }
    
    newPlaceText = [NSString stringWithString:placeText];
    for(i=0; i<_searchedPlaceText.count; i++)
    {
        if ([newPlaceText isEqualToString:[_searchedPlaceText objectAtIndex:i]])
        {
            [_searchedPlaceText removeObjectAtIndex:i];
            i--;
        }
    }
    
    [_searchedPlaceText insertObject:newPlaceText atIndex:0];
    
}

+(Place*) getFavorPlaceByIndex:(int) index
{
    if(index < _favorPlaces.count)
    {
        return [_favorPlaces objectAtIndex:index];
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

+(int) getPlaceCountBySectionMode:(SectionMode) sectionMode section:(int) section
{
    int placeType;
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode section:section];
    
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
        case kPlaceType_None:
            return 0;
    }
    
    mlogError(@"unknown place type %d at SectionMode:%d section:%d\n", placeType, sectionMode, section);
    return 0;
}

+(NSString*) getSearchedPlaceTextByIndex:(int) index
{
    if(index < _searchedPlaceText.count)
    {
        return [_searchedPlaceText objectAtIndex:index];
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

/* Mode 1: kSectionMode_Home_Office_Favor_Searched
      home
      office
      favor
      searched place
   Mode 2:
      home
      office
      favor
      searched place text
 */

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
        // for searched places
        if (_searchedPlaces.count > 0)
            sectionCount++;
    }
    else if (kSectionMode_Home_Office_Favor_SearchedText == sectionMode)
    {
        // for searched places text
        if (_searchedPlaceText.count > 0)
            sectionCount++;
    }

    return sectionCount;
    
}

+(Place*) getPlaceBySectionMode:(SectionMode) sectionMode section:(int) section index:(int) index
{
    int placeType;
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode section:section];
    
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
            p.name = [NSString stringWithString:[self getSearchedPlaceTextByIndex:index]];
            return p;
        }
    }
    
    mlogError(@"unknown place type %d at SectionMode:%d section:%d\n", placeType, sectionMode, section);
    return nil;
}

+(void) removeAllSearchedPlaces
{
    [_searchedPlaces removeAllObjects];
    _searchedPlaces = [[NSMutableArray alloc] initWithCapacity:0];
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
            break;
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
            break;
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
            break;
        }
    }
}

+(void) removeHomePlaceAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _homePlaces.count-1);
    [_homePlaces removeObjectAtIndex:index];

}

+(void) removeOfficePlaceAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _officePlaces.count-1);
    [_officePlaces removeObjectAtIndex:index];

}

+(void) removeFavorPlaceAtIndex:(int) index
{
    mlogAssertInRange(index, 0, _favorPlaces.count-1);
    [_favorPlaces removeObjectAtIndex:index];

}

+(void) removePlaceBySectionMode:(SectionMode) sectionMode section:(int) section index:(int) index
{
    int placeType;
    
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode section:section];
    
    switch(placeType)
    {
        case kPlaceType_Home:
            [self removeHomePlaceAtIndex:index];
            break;
        case kPlaceType_Office:
            [self removeOfficePlaceAtIndex:index];
            break;
        case kPlaceType_Favor:
            [self removeFavorPlaceAtIndex:index];
            break;
        default:
            mlogError(@"unknown place type:%d, sectionMode:%d, Section: %d\n", placeType, sectionMode, section);
            break;
    }
}
    



+(void) updateHomePlaceAtIndex:(int) index location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _homePlaces.count-1);
    
    Place *oldPlace = (Place*) [_homePlaces objectAtIndex:index];
    [place copyTo:oldPlace];

}

+(void) updateOfficeLocationAtIndex:(int) index location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _officePlaces.count-1);
    
    Place *oldPlace = (Place*) [_officePlaces objectAtIndex:index];
    [place copyTo:oldPlace];
    
}

+(void) updateFavorLocationAtIndex:(int) index location:(Place*) place
{
    mlogAssertNotNil(place);
    mlogAssertInRange(index, 0, _favorPlaces.count-1);
    
    Place *oldPlace = (Place*) [_favorPlaces objectAtIndex:index];
    [place copyTo:oldPlace];
}



#pragma mark -- table view section
+(void) addPlaceBySectionMode:(SectionMode) sectionMode section:(int) section place:(Place*) p
{
    int placeType;
    
    mlogAssertNotNil(p);
    
    placeType = [self translatSectionIndexIntoPlaceType:sectionMode section:section];
    
    switch(placeType)
    {
        case kPlaceType_Home:
            [self addHomePlace:p];
            [self addRecentPlace:p];
            break;
        case kPlaceType_Office:
            [self addOfficePlace:p];
            [self addRecentPlace:p];
            break;
        case kPlaceType_Favor:
            [self addFavorPlace:p];
            [self addRecentPlace:p];
            break;
        case kPlaceType_SearchedPlace:
            [self addSearchedPlace:p];
            [self addRecentPlace:p];
            break;
        case kPlaceType_SearchedPlaceText:
            [self addSearchedPlaceText:p.name];
            break;
        default:
            mlogError(@"unknown place type:%d, sectionMode:%d, Section: %d\n", placeType, sectionMode, section);
            break;
    }
}
/* section start from 0 */
+(PlaceType) translatSectionIndexIntoPlaceType:(SectionMode) sectionMode section:(int) section
{
    int tmpSection;
    
    if (section < 0)
    {
        mlogError(@"unkonwn place type, sectionMode: %d, section: %d\n", sectionMode, section);
        return kPlaceType_None;
    }
    
    tmpSection = section;
    
    if (kSectionMode_Home == sectionMode)
        return kPlaceType_Home;
    
    if (kSectionMode_Office == sectionMode)
        return kPlaceType_Office;
    
    if (kSectionMode_Favor == sectionMode)
        return kPlaceType_Favor;
    
    /* mode: kSectionMode_Home_Office_Favor_Searched
     * section number dependes on the place count of home, office, favor and searched place
     * when the tmpSection is 0, the it means we got the desire place type now
     */
    
    if (_homePlaces.count > 0 && tmpSection-- == 0)
        return kPlaceType_Home;
    
    if (_officePlaces.count > 0 && tmpSection-- == 0)
        return kPlaceType_Office;
    
    if (_favorPlaces.count > 0 && tmpSection-- == 0)
        return kPlaceType_Favor;
    
    /* kSectionMode_Home_Office_Favor_Searched */
    if (kSectionMode_Home_Office_Favor_Searched == sectionMode)
    {
        if (_searchedPlaces.count > 0 && tmpSection-- == 0)
            return kPlaceType_SearchedPlace;
    }
    /* kSectionMode_Home_Office_Favor_SearchedText */
    else
    {
        if (_searchedPlaceText.count > 0 && tmpSection-- == 0)
            return kPlaceType_SearchedPlace;
    }
    
    mlogError(@"unkonwn place type, sectionMode: %d, section: %d\n", sectionMode, section);
    return kPlaceType_None;
}

#pragma mark -- operation


+(void) clearConfig
{
    _versionNum             = USERJSON_VERSION_NUM;
    _name                   = @"";
    _email                  = @"";
    _homePlaces             = [[NSMutableArray alloc] initWithCapacity:0];
    _officePlaces           = [[NSMutableArray alloc] initWithCapacity:0];
    _favorPlaces            = [[NSMutableArray alloc] initWithCapacity:0];
    _searchedPlaceText      = [[NSMutableArray alloc] initWithCapacity:0];
    _searchedPlaces         = [[NSMutableArray alloc] initWithCapacity:0];
    _recentPlaces           = [[NSMutableArray alloc] initWithCapacity:20];
}

+(void) createDebugConfig
{
    mlogInfo(@"Create new user profile");
    Place *p                = [[Place alloc] init];
    _name                   = @"Coming";
    _email                  = @"misscoming@gmail.com";
    _homePlaces             = [[NSMutableArray alloc] initWithCapacity:0];
    _officePlaces           = [[NSMutableArray alloc] initWithCapacity:0];
    _favorPlaces            = [[NSMutableArray alloc] initWithCapacity:0];
    _searchedPlaceText      = [[NSMutableArray alloc] initWithCapacity:0];
    _searchedPlaces         = [[NSMutableArray alloc] initWithCapacity:0];
    _recentPlaces           = [[NSMutableArray alloc] initWithCapacity:20];

    
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

+(void) init
{
    mlogInfo(@"User Init");
    if(false == [User parseJson:[SystemManager getPath:kSystemManager_Path_User]])
    {
        mlogInfo(@"Create new user profile");
        [self clearConfig];
    }

}


+(bool) parseJson:(NSString*) fileName
{
    NSError* error;
    NSDictionary *user;
    NSDictionary* root;
    NSData *data;
    NSArray *tmpArray;
    
    mlogInfo(@"Parse user.json %@", fileName);
    
    @try
    {
        data = [[NSFileManager defaultManager] contentsAtPath:fileName];

        if(nil == data)
        {
            mlogInfo(@"cannot open: %@", fileName);
            return false;
        }
        
        root = [NSJSONSerialization
                JSONObjectWithData:data //1
                options:kNilOptions
                error:&error];
        
        if(nil == root)
        {
            mlogError(@"cannot get root of %@", fileName);
            return false;
        }
        
        user = [root objectForKey:USERJSON_USER];
        
        if(nil == user)
        {
            mlogError(@"cannot get user of %@", fileName);
            return false;
        }
        
        _versionNum         = [[user objectForKey:USERJSON_VERSION] intValue];
        _name               = [user objectForKey:USERJSON_NAME];
        _email              = [user objectForKey:USERJSON_EMAIL];
        _searchedPlaceText  = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_SEARCHED_PLACE_TEXT]];
        
        _homePlaces         = [[NSMutableArray alloc] initWithCapacity:0];
        _officePlaces       = [[NSMutableArray alloc] initWithCapacity:0];
        _favorPlaces        = [[NSMutableArray alloc] initWithCapacity:0];
        _searchedPlaces     = [[NSMutableArray alloc] initWithCapacity:0];
        _recentPlaces       = [[NSMutableArray alloc] initWithCapacity:0];
        
        if (nil == _name)
        {
            _name = @"";
        }
        
        if (nil == _email)
        {
            _email = @"";
        }
        
        tmpArray = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_HOMES]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addHomePlace:p];

        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_OFFICES]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addOfficePlace:p];

        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_FAVORS]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addFavorPlace:p];
        }

        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_SEARCHED_PLACES]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addSearchedPlace:p];
        }
        
        tmpArray     = [NSMutableArray arrayWithArray:[user objectForKey:USERJSON_RECENT_PLACES]];
        for(NSDictionary *d in tmpArray)
        {
            Place* p = [Place parseDictionary:d];
            [self addRecentPlace:p];
        }

    }
    @catch (NSException *exception)
    {
        mlogError(@"Parse user json fail\n");
        mlogError(@"CRASH: %@", exception);
        mlogError(@"Stack Trace: %@", [exception callStackSymbols]);
        return false;
    }

    return true;
}

+(NSDictionary*) toDictionary
{
    NSDictionary *result;
    NSMutableDictionary *userDic            = [[NSMutableDictionary alloc] init];
    NSMutableArray* homePlacesArray         = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* officePlacesArray       = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* favorPlacesArray        = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* searchedPlaceTextArray  = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* recentPlacesArray        = [[NSMutableArray alloc] initWithCapacity:0];

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

    for(Place *p in self.recentPlaces)
    {
        [recentPlacesArray addObject:[p toDictionary]];
    }
    
    for(NSString *place in self.searchedPlaceText)
    {
        [searchedPlaceTextArray addObject:place];
    }

    [userDic setObject:[NSString stringFromInt:self.version] forKey:USERJSON_VERSION];
    [userDic setObject:self.name forKey:USERJSON_NAME];
    [userDic setObject:self.email forKey:USERJSON_EMAIL];
    
    [userDic setObject:homePlacesArray forKey:USERJSON_HOMES];
    [userDic setObject:officePlacesArray forKey:USERJSON_OFFICES];
    [userDic setObject:favorPlacesArray forKey:USERJSON_FAVORS];
    [userDic setObject:searchedPlaceTextArray forKey:USERJSON_SEARCHED_PLACE_TEXT];
    [userDic setObject:recentPlacesArray forKey:USERJSON_RECENT_PLACES];

    
    result = [NSDictionary dictionaryWithObjectsAndKeys:userDic, USERJSON_USER, nil];
    return result;
}

+(void) save
{
    mlogInfo(@"Save user.json %@", [SystemManager getPath:kSystemManager_Path_User]);
    NSError* error;
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.toDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:[SystemManager getPath:kSystemManager_Path_User] atomically:true];
}


@end
