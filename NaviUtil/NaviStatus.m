//
//  NaviStatus.m
//  NaviUtil
//
//  Created by Coming on 6/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "NaviStatus.h"
#import "CoordinateTranslator.h"

@implementation NaviStatus

- (void)setCarCoordinate:(CLLocationCoordinate2D)carCoordinate
{
    _carCoordinate  = carCoordinate;
    _carDrawPoint   = [CoordinateTranslator projectCoordinate:carCoordinate];
}


@end
