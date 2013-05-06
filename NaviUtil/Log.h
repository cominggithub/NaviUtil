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




#define ALL                       (0xFFFFFFFFFFFFFFFF)
#define SYSTEM_MANAGER            (1<<1)
#define DOWNLOAD_MANAGER          (1<<2)
#define ROUTE                     (1<<3)
#define NAVI_QUERY_MANAGER        (1<<4)
#define LOCATION_SIMULATOR        (1<<5)
#define GUIDE_ROUTE_UIVIEW        (1<<6)
#define GEOUTIL                   (1<<7)
#define ROUTELINE                 (1<<8)
#define FILE_DOWNLOADER           (1<<9)
#define NONE                      (1<<16)

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

