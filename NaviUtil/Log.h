//
//  Log.h
//  NaviUtil
//
//  Created by Coming on 13/3/4.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#ifndef LOG_H
#define LOG_H
#import <Foundation/Foundation.h>
#import "SystemManager.h"

#import <objc/runtime.h>
#import <objc/message.h>




#define ALL                         (0xFFFFFFFFFFFFFFFFULL)
#define SYSTEM_MANAGER              (1ULL<<1)
#define DOWNLOAD_MANAGER            (1ULL<<2)
#define ROUTE                       (1ULL<<3)
#define NAVI_QUERY_MANAGER          (1ULL<<4)
#define LOCATION_SIMULATOR          (1ULL<<5)
#define GUIDE_ROUTE_UIVIEW          (1ULL<<6)
#define GEOUTIL                     (1ULL<<7)
#define ROUTELINE                   (1ULL<<8)
#define FILE_DOWNLOADER             (1ULL<<9)
#define PLACE                       (1ULL<<10)
#define GOOGLE_MAP_UIVIEWCONTROLLER (1ULL<<10)
#define NONE                        (1ULL<<63)

#define logfn() printf("%s(%d)\n", __FUNCTION__, __LINE__)
#define logfns(args...) do{printf("%s(%d): ", __FUNCTION__, __LINE__); printf(args);}while(0)
#define logo(o) printf("%s: %s\n",#o, [[o description] UTF8String])
#define logObjNoName(o) printf("%s\n",[[o description] UTF8String])
#define logos(o, args...) do{printf("%s", #o); printf(args);}while(0)
#define logi(o) printf("%s: %d\n",#o, o)
#define logf(o) printf("%s: %f\n",#o, o)
#define logs(o) printf("%s: %s\n",#o, o)
#define loglc(o) printf("%s: (%f, %f)\n",#o, o.latitude, o.longitude)
#define logpd(o) printf("%s: (%f, %f)\n",#o, o.x, o.y)
#define logns(o) printf("%s: %s\n",#o, [o UTF8String])

#define getObjectName(oo) #oo
#define logClass(o) printf("%s: %s\n", getObjectName(o), (char*)class_getName([o class]))

#define mlogInfo(module, args...)     do{logInfo(#module, args);}while(0)
#define mlogWarning(module, args...)  do{logWarning(#module, args);}while(0)
#define mlogError(module, args...)    do{logError(#module, args);}while(0)
#define mlogDebug(module, args...)    do{if (isLogModule(module)) {logDebug(#module, args);}}while(0)
#define mlogfn(module)                do{if (isLogModule(module)) {printf("[DEBUG] %s ", #module); logfn();printf("\n");}}while(0)
#define mlogfns(module, args...)      do{if(isLogModule(module) && isDebug()) {printf("[DEBUG] %s: %s(%d): ", #module, __FUNCTION__, __LINE__); printf(args);printf("\n");}}while(0)


typedef enum
{
    kLogError,
    kLogWarning,
    kLogInfo,
    kLogDebug,
    kLogAll,
}LogLevel;

int isLogModule(unsigned long long module);
void addLogModule(unsigned long long moudle);
void removeLogModule(unsigned long long module);
void logWarning(const char* moduleName, id formatString, ...);
void logError(const char* moduleName, id formatString, ...);
void logInfo(const char* moduleName, id formatString, ...);
void logDebug(const char* moduleName, id formatString, ...);
bool isDebug();

#endif

