//
//  CarStatus.h
//  NaviUtil
//
//  Created by Coming on 4/26/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CarStatus : NSObject

@property (nonatomic, readonly) double speed;
@property (nonatomic, readonly) CLLocationCoordinate2D location;
@property (nonatomic, readonly) double heading;

-(void) updateLocation:(CLLocationCoordinate2D)location speed:(double)speed heading:(double)heading;
-(float) getMoveTimeByDistance:(double) distance;
@end
