//
//  LocationUpdateEvent.h
//  NaviUtil
//
//  Created by Coming on 9/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationUpdateEvent : NSObject


@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) double speed;
@property (nonatomic) int distance;
@property (nonatomic) double heading;

-(id) initWitchCLLocationCoordinate2D:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading;
@end
