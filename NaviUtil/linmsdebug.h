//
//  linmsdebug.h
//  NavUtil
//
//  Created by Coming on 13/2/16.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#ifndef NavUtil_linmsdebug_h
#define NavUtil_linmsdebug_h

#define linmsfn() printf("%s(%d)\n", __FUNCTION__, __LINE__)
#define linmsfns(args...) do{printf("%s(%d): ", __FUNCTION__, __LINE__); printf(args);}while(0)
#define linmso(o) printf("%s: %s\n",#o, [o UTF8String])
#define linmsos(o, args...) do{printf("%s", #o); printf(args);}while(0)

#endif
