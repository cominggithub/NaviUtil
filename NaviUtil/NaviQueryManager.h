//
//  NaviQuery.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "Place.h"
#import "DownloadRequest.h"
#import "Speech.h"
#import "NSDictionary+category.h"


#define GG_DIRECTION_URL            @"https://maps.googleapis.com/maps/api/directions"
#define GG_PLACE_TEXT_SEARCH_URL    @"https://maps.googleapis.com/maps/api/place/textsearch"
#define GG_TEXT_TO_SPEECH_URL       @"http://translate.google.com/translate_tts?ie=UTF-8&"
#define S_LANGUAGE                  @"language"
#define S_ORIGIN                    @"origin"
#define S_DESTINATION               @"destination"
#define S_SENSOR                    @"sensor"
#define S_LOCATION                  @"location"
#define S_RADIUS                    @"radius"
#define S_MODE                      @"mode"
#define S_WAYPOINTS                 @"waypoints"
#define S_ALTERNATIVES              @"alternatives"
#define S_XML                       @"xml"
#define S_JSON                      @"json"
#define S_TRANSLATION_TO            @"tl"
#define S_SPEECH_QUERY              @"Q"
#define S_FALSE                     @"false"
#define S_TRUE                      @"true"
#define S_INPUT                     @"input"
#define S_QUERY                     @"query"
#define S_GOOGLE_API_KEY            @"key"
#define S_IE                        @"ie"
#define S_UTF8                      @"UTF-8"
#define S_Q                         @"q"
#define S_TL                        @"tl"



typedef enum DownloadFileFormat {
    GOOGLE_JSON,
    GOOGLE_XML,
    GOOGLE_SPEECH
}DownloadFileFormat;

@interface NaviQueryManager : NSObject

+(Route*) getRoute;
+(Route*) getRouteStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation;
+(NSArray*) getPlace:(NSString*) location;
+(NSString*) getSpeechFile:text;
+(NSString*) getFileNameParameters:(NSDictionary*) param downloadFileFormat:(DownloadFileFormat)downloadFileFormat;

+(NSString*) getRouteFilePathStartLocation:(CLLocationCoordinate2D) startLocation endLocation:(CLLocationCoordinate2D) endLocation;
+(NSString*) getPlaceFilePath:(NSString*) locationName;
+(NSString*) getSpeechFilePath:(NSString*) text;


+(NSString*) getQueryBaseUrl:(NSString*)url parameters:(NSDictionary*) params downloadFileFormat:(DownloadFileFormat)downloadFileFormat;
+(NSString*) getPlaceQuery:(NSString*) location;
+(NSString*) getSpeechQuery:(NSString*) text;

+(void) planRouteStartLocationText:(NSString*) startLocationText EndLocationText:(NSString*) endLocationText;
+(void) planRouteStartLocation:(CLLocationCoordinate2D) start EndLocation:(CLLocationCoordinate2D) end;
+(void) startNavigation;
+(void) stopNavigation;
+(void) startDownloadSpeech;

+(void) init;

+(void) downloadRequestStatusChange:(DownloadRequest*) downloadRequest;
+(DownloadRequest*) getPlaceDownloadRequest:(NSString*) place;
+(DownloadRequest*) getNearPlaceDownloadRequest:(NSString*) locationName locaiton:(CLLocationCoordinate2D) location radius:(int) radius;
+(DownloadRequest*) getRouteDownloadRequestFrom:(CLLocationCoordinate2D) start To:(CLLocationCoordinate2D) end;
+(void) download:(DownloadRequest*) dr;
+(void) downloadSpeech:(Route*) route;
@end


