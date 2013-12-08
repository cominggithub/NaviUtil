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

#define logfn() printf("%s(%d)\n", __FUNCTION__, __LINE__)
#define logfns(args...) do{printf("%s(%d): ", __FUNCTION__, __LINE__); printf(args);}while(0)
#define logO(o) printf("%s: %s(0x%X)\n",#o, [[o description] UTF8String], (int)o)
#define logObjNoName(o) printf("%s\n",[[o description] UTF8String])
#define logOS(o, args...) do{printf("%s", #o); printf(args);}while(0)
#define logI(o) printf("%s(%d), %s: %d\n", __FUNCTION__, __LINE__, #o, o)
#define logF(o) printf("%s(%d), %s: %f\n", __FUNCTION__, __LINE__, #o, o)
#define logS(o) printf("%s(%d), %s: %s\n", __FUNCTION__, __LINE__, #o, o)
#define logCoor(o) printf("%s(%d), %s: (%f, %f)\n", __FUNCTION__, __LINE__, #o, o.latitude, o.longitude)
#define logPoint(o) printf("%s(%d), %s: (%f, %f)\n", __FUNCTION__, __LINE__, #o, o.x, o.y)
#define logNS(o) printf("%s(%d), %s: %s\n", __FUNCTION__, __LINE__, #o, [o UTF8String])
#define logBool(o) do{printf("%s(%d), %s: %s\n", __FUNCTION__, __LINE__, #o, o == TRUE ? "TRUE":"FALSE");}while(0)
#define getObjectName(oo) #oo
#define logClass(o) printf("%s(%d), %s: %s\n", __FUNCTION__, __LINE__, getObjectName(o), (char*)class_getName([o class]))
#define logRect(o) printf("%s(%d), %s: (%.1f, %.1f, %.1f, %.1f)\n", __FUNCTION__, __LINE__, #o, o.origin.x, o.origin.y, o.size.width, o.size.height)

#define mlogInfo(args...)     do{logOut(kLogInfo, __FUNCTION__, __LINE__, args);}while(0)
#define mlogWarning(args...)  do{logOut(kLogWarning, __FUNCTION__, __LINE__, args);}while(0)
#define mlogError(args...)    do{logOut(kLogError, __FUNCTION__, __LINE__, args);}while(0)
#define mlogCheckPoint(args...)    do{logOut(kLogCheckPoint, __FUNCTION__, __LINE__, args);}while(0)
#define mlogStackTrace(reason)        do{mlogError(@"%@\n%@", reason, [NSThread callStackSymbols]);}while(0)
#define mlogException(e)              do{mlogError(@"CRASH:%@\n Stack Trace: %@", e, [e callStackSymbols]);}while(0)


#define mlogAssertNotNil(o)      do{if(nil == o || NULL == o){mlogError(@"%s is nil", #o); mlogStackTrace(@""); return;}}while(0)
#define mlogAssertNotNilR(o, r)     do{if(nil == o || NULL == o){mlogError(@"%s is nil", #o); mlogStackTrace(@""); return r;}}while(0)

#define mlogAssertStrNotEmpty(o)      do{if(nil == o  || NULL == o || [o length] < 1){mlogError(@"%s is nil or empty", #o); return;}}while(0)
#define mlogAssertStrNotEmptyR(o, r)     do{if(nil == o  || NULL == o || [o length] < 1){mlogError(@"%s is nil or empty", #o); return r;}}while(0)


#define mlogAssertInRange(o, min, max)      do{if(min > o || max < o){mlogError(@"%s is out of range", #o); return;}}while(0)
#define mlogAssertInRangeR(o, min, max, r)      do{if(min > o || max < o){mlogError(@"%s is out of range", #o); return r;}}while(0)


#if (FILE_DEBUG == TRUE)
#define mlogDebug(args...)    do{logOut(kLogDebug, __FUNCTION__, __LINE__, args);}while(0)
#else
#define mlogDebug(args...)
#endif



typedef enum
{
    kLogCheckPoint = 0,
    kLogError,
    kLogInfo,
    kLogWarning,
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

void logOut(int level, const char* func_name, int lineNo, id formatString, ...);
#endif

