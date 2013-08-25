//
//  SpeedView.h
//  NaviUtil
//
//  Created by Coming on 8/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface SpeedView : UIView<LocationManagerDelegate>
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) double speed;
@property (nonatomic) BOOL isSpeedUnitMph;

-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading;
-(void) active;
-(void) inactive;

@end
