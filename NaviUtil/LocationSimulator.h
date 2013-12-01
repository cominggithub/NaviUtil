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
#import "NSValue+category.h"

typedef enum
{
    kLocationSimulator_ManualRoute,
    kLocationSimulator_Line,
    kLocationSimulator_File
}LocationSimulator_Type;

@interface LocationSimulator : NSObject
{
    NSTimer *_timer;

    int _nextLocationIndex;
    CLLocation *_currentLocation;
    CLLocation *_nextLocation;
}
@property (nonatomic, weak) id<CLLocationManagerDelegate> delegate;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSArray *locationPoints;
@property (readonly) bool isStart;
@property (nonatomic) LocationSimulator_Type type;

-(void) start;
-(void) stop;
-(void) triggerLocationUpdate;
-(void) setRoute:(Route*) route;
@end
