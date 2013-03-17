//
//  User.h
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemManager.h"

@interface User : NSObject
+(void) parseJson:(NSString*) fileName;
+(void) save;
@end
