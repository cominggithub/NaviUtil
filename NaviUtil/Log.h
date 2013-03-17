//
//  Log.h
//  NaviUtil
//
//  Created by Coming on 13/3/4.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemManager.h"
#import <objc/objc-runtime.h>


#define logfn() printf("%s(%d)\n", __FUNCTION__, __LINE__)
#define logfns(args...) do{printf("%s(%d): ", __FUNCTION__, __LINE__); printf(args);}while(0)
#define logso(o) printf("%s: %s\n",#o, [o UTF8String])
#define logos(o, args...) do{printf("%s", #o); printf(args);}while(0)
#define logi(o) printf("%s: %d\n",#o, o)

#define getObjectName(oo) #oo
#define logClass(o) printf("%s: %s\n", getObjectName(o), (char*)class_getName([o class]))


typedef enum
{
    kLogDebug,
    kLogInfo,
    kLogWarning,
    kLogError,
}LogLevel;

void logWarning(id formatString, ...);
void logError(id formatString, ...);
void logInfo(id formatString, ...);
void logDebug(id formatString, ...);



