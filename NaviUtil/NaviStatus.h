//
//  NaviStatus.h
//  NaviUtil
//
//  Created by Coming on 6/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface NaviStatus : NSObject

@property (nonatomic) CLLocationCoordinate2D carCoordinate;
@property (nonatomic, readonly) CGPoint carDrawPoint;
@end
