//
//  NaviQuery.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NaviQueryManager.h"
#import "NaviUtil.h"

@implementation NaviQueryManager


static bool _isInit = false;
static int _requestId = 1;
static DownloadManager *_downloadManager = nil;
static Route* _currentRoute = nil;
static DownloadRequest *_currentRouteDownloadRequest = nil;
static DownloadRequest *_startLocationDownloadRequest = nil;
static DownloadRequest *_endLocationDownloadRequest = nil;
static bool _isGetStartLocation = false;
static bool _isGetEndLocation = false;
static CLLocationCoordinate2D _startLocation;
static CLLocationCoordinate2D _endLocation;


+(void) init
{
    if( false == _isInit)
    {
        _downloadManager = [[DownloadManager alloc] init];
    }
    _isInit = true;
}

+(void) planRouteStartLocationText:(NSString*) startLocationText EndLocationText:(NSString*) endLocationText
{
    _isGetStartLocation = false;
    _isGetEndLocation = false;
    _startLocationDownloadRequest = [self getPlaceDownloadRequest:startLocationText];
    _endLocationDownloadRequest = [self getPlaceDownloadRequest:endLocationText];
    [_downloadManager download:_startLocationDownloadRequest];
    [_downloadManager download:_endLocationDownloadRequest];
    
    
}
+(void) planRouteStartLocation:(CLLocationCoordinate2D) start EndLocation:(CLLocationCoordinate2D) end
{
    _currentRouteDownloadRequest = [self getRouteDownloadRequest:start EndLocation:end];
    [_downloadManager download:_currentRouteDownloadRequest];

}

+(void) startNavigation;
{

    DownloadRequest *downloadRequest;
    _currentRoute = [[Route alloc] init];
    [_currentRoute parseJson:_currentRouteDownloadRequest.filePath];

    mlogDebug(NAVI_QUERY_MANAGER, @"Num of speech %d\n", [_currentRoute getSpeech].count);
    
    for(Speech *speech in [_currentRoute getSpeech])
    {
        downloadRequest = [self getSpeechDownloadRequest:speech.text];
        
        mlogDebug(NAVI_QUERY_MANAGER, @"%@\n", speech.text);
        
        [_downloadManager download:downloadRequest];
    }

}

+(void) stopNavigation
{
    
}

+(void) startDownloadPlaces
{
    
}

+(void) startDownloadSpeech
{
    
}

+(void) downloadRequestStatusChange:(DownloadRequest*) downloadRequest
{
    if(downloadRequest == _currentRouteDownloadRequest)
    {

        [self startNavigation];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAN_ROUTE_DONE object:self];
    }
    else if(downloadRequest == _startLocationDownloadRequest)
    {
        NSArray *places = [Place parseJson:[downloadRequest filePath]];
        if (places.count > 0)
        {
            _startLocation = ((Place*)[places objectAtIndex:0]).coordinate;
            _isGetStartLocation = true;
        }
    }
    else if(downloadRequest == _endLocationDownloadRequest)
    {
        NSArray *places = [Place parseJson:[downloadRequest filePath]];
        if (places.count > 0)
        {
            _endLocation = ((Place*)[places objectAtIndex:0]).coordinate;
            _isGetEndLocation = true;
        }
    }
    
    if ( true == _isGetStartLocation && true == _isGetEndLocation)
    {
        [self planRouteStartLocation:_startLocation EndLocation:_endLocation];
        _isGetStartLocation = false;
        _isGetEndLocation = false;
        
    }
        
}
+(DownloadRequest*) getRouteDownloadRequest:(CLLocationCoordinate2D) start EndLocation:(CLLocationCoordinate2D) end
{
    DownloadRequest* downloadRequest = [[DownloadRequest alloc] init];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.filePath    = [self getRouteFilePathStartLocation:start endLocation:end];
    downloadRequest.url         = [self getRouteQueryStartLocation:start endLocation:end];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.status      = kDownloadStatus_Pending;

    return downloadRequest;
}

+(DownloadRequest*) getPlaceDownloadRequest:(NSString*) locationName
{
    DownloadRequest* downloadRequest = [[DownloadRequest alloc] init];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.filePath    = [self getPlaceFilePath:locationName];
    downloadRequest.url         = [self getPlaceQuery:locationName];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.status      = kDownloadStatus_Pending;
    
    return downloadRequest;
}

+(DownloadRequest*) getSpeechDownloadRequest:(NSString*) text
{
    DownloadRequest* downloadRequest = [[DownloadRequest alloc] init];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.filePath    = [self getSpeechFilePath:text];
    downloadRequest.url         = [self getSpeechQuery:text];
    downloadRequest.requestId   = [self getNextRequestId];
    downloadRequest.status      = kDownloadStatus_Pending;
    
    return downloadRequest;
}



+(NSString*) getQueryBaseUrl:(NSString*)url parameters:(NSDictionary*) param downloadFileFormat:(DownloadFileFormat)downloadFileFormat
{
    bool isFirstParam = true;
    NSMutableString *result= [[NSMutableString alloc] init];
    
    [result appendString:url];
    if(param.count > 0)
    {
        if(downloadFileFormat == GOOGLE_JSON)
        {
            [result appendString:[NSString stringWithFormat:@"/%@?", S_JSON]];
        }
        else if(downloadFileFormat == GOOGLE_XML)
        {
            [result appendString:[NSString stringWithFormat:@"/%@?", S_XML]];
        }
    }
    
    for(id o in param.allKeys)
    {
        id v = [param objectForKey:o];
        if (isFirstParam == true)
        {
            [result appendString:[NSString stringWithFormat:@"%@=%@", o, v]];
        }
        else
        {
            [result appendString:[NSString stringWithFormat:@"&%@=%@", o, v]];
        }

        
        isFirstParam = false;
        
    }

    return result;
}

+(NSDictionary*) getRouteQueryParamStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation
{
    NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys:
     
     [GeoUtil getLatLngStr:startLocation], S_ORIGIN,
     [GeoUtil getLatLngStr:endLocation], S_DESTINATION,
     S_FALSE, S_SENSOR,
     [SystemManager getSupportLanguage], S_LANGUAGE,
     nil
     ];
    return param;
}

+(NSDictionary*) getPlaceQueryParam:(NSString*) locationName
{
    NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys:
                           locationName, S_QUERY,
                           [NaviUtil getGooglePlaceAPIKey], S_GOOGLE_API_KEY,
                           S_FALSE, S_SENSOR,
                           [SystemManager getSupportLanguage], S_LANGUAGE,
                           nil
                           ];
    
    return param;
}

+(NSDictionary*) getSpeechQueryParam:(NSString*) text
{
    
    /*
     * ie=UTF-8, tl=zh-TW, q=<text>
     * http://translate.google.com/translate_tts?ie=UTF-8&tl=zh-TW&q=ohoh
     */
    NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys:
                           text, S_Q,
                           [SystemManager getSupportLanguage], S_TL,
                           nil
                           ];
    return param;
}

+(NSString*) getRouteFilePathStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation;
{
    /*
     * origin, destination, sensor
     */
    NSDictionary* param = [self getRouteQueryParamStartLocation:startLocation endLocation:endLocation];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [SystemManager routeFilePath], [self getFileNameParameters:param downloadFileFormat:GOOGLE_JSON]];
    
    return filePath;
}


+(NSString*) getPlaceFilePath:(NSString*) locationName
{
    NSDictionary* param = [self getPlaceQueryParam:locationName];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [SystemManager placeFilePath], [self getFileNameParameters:param downloadFileFormat:GOOGLE_JSON]];
    
    return filePath;
}

+(NSString*) getSpeechFilePath:(NSString*) text
{
//    NSDictionary* param = [self getSpeechQueryParam:text];
    
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [SystemManager speechFilePath], [self getFileNameParameters:param downloadFileFormat:GOOGLE_SPEECH]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", [SystemManager speechFilePath], text];
    
    return filePath;
}

+(NSString*) getRouteQueryStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation;
{
    /*
     * origin, destination, sensor
     */
    NSDictionary* param = [self getRouteQueryParamStartLocation:startLocation endLocation:endLocation];
    return [NaviQueryManager getQueryBaseUrl:GG_DIRECTION_URL parameters:param downloadFileFormat:GOOGLE_JSON];
}

+(NSString*) getPlaceQuery:(NSString*) locationName
{

    /*
     * query, language, key, sensor
     */
    NSDictionary* param = [self getPlaceQueryParam:locationName];
    return [NaviQueryManager getQueryBaseUrl:GG_PLACE_TEXT_SEARCH_URL parameters:param downloadFileFormat:GOOGLE_JSON];
}

+(NSString*) getSpeechQuery:(NSString*) text
{
    
    /*
     * ie=UTF-8, tl=zh-TW, q=<text>
     * http://translate.google.com/translate_tts?ie=UTF-8&tl=zh-TW&q=ohoh
     */
    NSDictionary* param = [self getSpeechQueryParam:text];
    return [NaviQueryManager getQueryBaseUrl:GG_TEXT_TO_SPEECH_URL parameters:param downloadFileFormat:GOOGLE_SPEECH];
}


+(Route*) getRoute
{
    return _currentRoute;
}

+(Route*) getRouteStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation
{
    Route *result = nil;
    NSString *filePath = [self getRouteFilePathStartLocation:startLocation endLocation:endLocation];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        result = [[Route alloc] initWithJsonRouteFile:filePath];
    }
    
    return result;
}

+(NSArray*) getPlace:(NSString*) locationName
{
    NSArray* result = nil;
    NSString *filePath = [self getPlaceFilePath:locationName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        result = [Place parseJson:filePath];
    }
    
    return result;
    
}

+(NSString*) getSpeechFile:text
{
    NSString *filePath = [self getSpeechFilePath:text];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == false)
    {
        filePath = nil;
    }
    
    return filePath;
}

+(NSString*) getFileNameParameters:(NSDictionary*) param downloadFileFormat:(DownloadFileFormat)downloadFileFormat
{
    NSMutableString *result = [[NSMutableString alloc] init];
    bool isFirstParam=true;
    
    for(id o in param.allKeys)
    {
        id v = [param objectForKey:o];
        if (isFirstParam == true)
        {
            [result appendString:[NSString stringWithFormat:@"%@=%@", o, v]];
        }
        else
        {
            [result appendString:[NSString stringWithFormat:@"_%@=%@", o, v]];
        }
        
        
        isFirstParam = false;
        
    }
    
    switch(downloadFileFormat)
    {
        case GOOGLE_JSON:
            [result appendString:@".json"];
            break;
        case GOOGLE_XML:
            [result appendString:@".xml"];
            break;
        case GOOGLE_SPEECH:
            [result appendString:@".mp3"];
            break;
    }
    
    return result;
}

+(int) getNextRequestId
{
    return _requestId++;
}



@end
