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

@property (nonatomic, readonly) float speed;
@property (nonatomic, readonly) CLLocationCoordinate2D location;
@property (nonatomic, readonly) float orientation;

-(void) updateLocation:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading;
-(float) getMoveTimeByDistance:(float) distance;
@end
