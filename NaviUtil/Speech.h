//
//  Speech.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SystemManager.h"

@interface Speech : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString* filePath;
@property (nonatomic, strong) NSString* text;
@end
