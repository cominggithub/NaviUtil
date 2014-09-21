//
//  CumulativeDistanceCaculator.h
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CumulativeDistanceCalculator : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, readonly) double cumulativeDistance;
@end
