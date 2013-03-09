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


+(void) init
{
    if( false == _isInit)
    {
        _downloadManager = [[DownloadManager alloc] init];
    }
    _isInit = true;
}

+(void) planRouteStartLocation:(CLLocationCoordinate2D) start EndLocation:(CLLocationCoordinate2D) end
{
    _currentRouteDownloadRequest = [self getRouteDownloadRequest:start EndLocation:end];
    [_downloadManager download:_currentRouteDownloadRequest];

}

+(void) startNavigation;
{
    _currentRoute = [[Route alloc] init];
    [_currentRoute parseJson:_currentRouteDownloadRequest.filePath];
    for(Speech *speech in [_currentRoute getSpeechText])
    {
        DownloadRequest *downloadRequest = [self getSpeechDownloadRequest:speech.text];
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
    }
}
+(DownloadRequest*) getRouteDownloadRequest:(CLLocationCoordinate2D) start EndLocation:(CLLocationCoordinate2D) end
{
    DownloadRequest* downloadRequest = [[DownloadRequest alloc] init];
    downloadRequest.requestId = [self getNextRequestId];

    return downloadRequest;
}

+(DownloadRequest*) getPlaceDownloadRequest:(NSString*) locationName
{
    DownloadRequest* downloadRequest;
    downloadRequest.requestId = [self getNextRequestId];
    
    return downloadRequest;
}

+(DownloadRequest*) getSpeechDownloadRequest:(NSString*) text
{
    DownloadRequest* downloadRequest;
    downloadRequest.requestId = [self getNextRequestId];
    
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
    return [result stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
}

+(NSDictionary*) getRouteQueryParamStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation
{
    NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys:
     
     [GeoUtil getLatLngStr:startLocation], S_ORIGIN,
     [GeoUtil getLatLngStr:endLocation], S_DESTINATION,
     S_FALSE, S_SENSOR,
     nil
     ];
    return param;
}

+(NSDictionary*) getPlaceQueryParam:(NSString*) locationName
{
    NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys:
                           locationName, S_QUERY,
                           [SystemManager getSystemLanguage], S_LANGUAGE,
                           [NaviUtil getGoogleAPIKey], S_GOOGLE_API_KEY,
                           S_FALSE, S_SENSOR,
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
                           [SystemManager getSystemLanguage], S_TL,
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
    NSDictionary* param = [self getSpeechQueryParam:text];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [SystemManager speechFilePath], [self getFileNameParameters:param downloadFileFormat:GOOGLE_SPEECH]];
    
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
    return [NaviQueryManager getQueryBaseUrl:GG_PLACE_TEXT_SEARCH_URL parameters:param downloadFileFormat:GOOGLE_SPEECH];
}


+(Route*) getRoute:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation
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
