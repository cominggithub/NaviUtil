//
//  NaviUtil.m
//  NaviUtil
//
//  Created by Coming on 13/2/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NaviUtil.h"

@implementation NaviUtil

static bool isInit = false;
static NSString* googleAPIKey=@"";

+(void) setGoogleAPIKey:(NSString*) key
{
    googleAPIKey=key;
}

+(NSString*) getGoogleAPIKey
{
    return googleAPIKey;
}

+(void) init
{
    [SystemManager init];
    [NaviQueryManager init];
    
    isInit = true;
}
@end

