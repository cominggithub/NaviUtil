//
//  NSDictionary+category.h
//  NaviUtil
//
//  Created by Coming on 13/3/9.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TextValue.h"

@interface NSDictionary (category)
-(TextValue*) textValue;
-(void) dump;
+(NSDictionary*) getLatLngDic:(CLLocationCoordinate2D) coordinate;
-(CLLocationCoordinate2D) getCLLocationCoordinate2D;


@end
