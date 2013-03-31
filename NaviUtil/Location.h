//
//  Location.h
//  NaviUtil
//
//  Created by Coming on 13/3/18.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSDictionary+category.h"

@interface Location : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* address;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(NSDictionary*) toDictionary;
@end
