//
//  LocationSimulator.h
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "log.h"
#import "NSValue+category.h"



@interface LocationSimulator : NSObject
{
    NSTimer *timer;
    bool isStart;
    int nextLocationIndex;
    CLLocation *currentLocation;
    CLLocation *nextLocation;
}
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSArray *locationPoints;


-(CLLocationCoordinate2D) getNextLocation;
-(void) start;
-(void) stop;

@end
