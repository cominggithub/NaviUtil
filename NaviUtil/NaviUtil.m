//
//  NaviUtil.m
//  NaviUtil
//
//  Created by Coming on 13/2/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NaviUtil.h"

@implementation NaviUtil

static bool _isInit = false;
static NSString* _googleAPIKey=@"";
static NSString* _googlePlaceAPIKey=@"";

+(void) setGoogleAPIKey:(NSString*) key
{
    _googleAPIKey=key;
}

+(void) setGooglePlaceAPIKey:(NSString*) key
{
    _googlePlaceAPIKey=key;
}

+(NSString*) getGoogleAPIKey
{
    return _googleAPIKey;
}

+(NSString*) getGooglePlaceAPIKey
{
    return _googlePlaceAPIKey;
}

+(void) init
{
    [SystemManager init];
    [SystemConfig init];
    [NaviQueryManager init];
    [User init];
    [LocationManager init];
    
    _isInit = true;
}

+(void) close
{
    [User save];
}
@end

