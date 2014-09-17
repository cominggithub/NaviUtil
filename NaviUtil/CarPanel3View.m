//
//  CarPanel3View.m
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3View.h"
#import "CarPanel3SpeedView.h"
#import "CarPanel3HeadingView.h"
#import "SystemManager.h"
#import "CarPanelSwitchView.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@interface CarPanel3View()
{
    CarPanel3SpeedView* speedView;
    CarPanel3HeadingView* headingView;
    CarPanelSwitchView* networkStatusView;
    CarPanelSwitchView* gpsStatusView;

}
@end

@implementation CarPanel3View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    [self addUIComponents];
}

#pragma mark -- UI Component
-(void) addUIComponents
{
    int xOffset;
    xOffset                     = ([SystemManager lanscapeScreenRect].size.width - 480)/2;
//    clockView                   = [[CarPanel2ClockView alloc] initWithFrame:CGRectMake(0, 70, 180, 50)];
//    elapsedTimeView             = [[CarPanel2ElapsedTimeView alloc] initWithFrame:CGRectMake(-5, 145, 180, 50)];
//    systemStatusView            = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
//    cumulativeDistanceView      = [[CarPanel2CumulativeDistanceView alloc] initWithFrame:CGRectMake(13, 210, 180, 50)];
    speedView                   = [[CarPanel3SpeedView alloc] initWithFrame:CGRectMake(210+xOffset, 50, 291, 285)];
    headingView                 = [[CarPanel3HeadingView alloc] initWithFrame:CGRectMake(210+xOffset, 50, 291, 285)];
    headingView.imageName       = @"cp3_heading";
    
    networkStatusView               = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(50+xOffset, 280, 31, 31)];
    networkStatusView.onImageName   = @"cp3_3g";
    networkStatusView.offImageName  = @"cp3_3g";
    [networkStatusView on];

    gpsStatusView                   = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(95+xOffset, 280, 21, 21)];
    gpsStatusView.onImageName       = @"cp3_gps";
    gpsStatusView.offImageName      = @"cp3_gps";
    [gpsStatusView on];
    
//
//    [self addSubview:systemStatusView];
//    [self addSubview:clockView];
//    [self addSubview:elapsedTimeView];
//    [self addSubview:cumulativeDistanceView];
    [self addSubview:headingView];
    [self addSubview:speedView];
    [self addSubview:networkStatusView];
    [self addSubview:gpsStatusView];
    
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -- Property

-(void)setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    
    if(TRUE == _isHud)
    {
        self.transform = CGAffineTransformMakeScale(1,-1);
    }
    else
    {
        self.transform = CGAffineTransformMakeScale(1,1);
    }
}

-(void)setColor:(UIColor *)color
{
    
    _color                          = color;
//    systemStatusView.color          = self.color;
    speedView.color                 = self.color;
    headingView.color               = self.color;
//    clockView.color                 = self.color;
//    elapsedTimeView.color           = self.color;
//    cumulativeDistanceView.color    = self.color;
    networkStatusView.color         = self.color;
    gpsStatusView.color             = self.color;
}

-(void)setSpeed:(double)speed
{
    _speed          = speed;
    speedView.speed = self.speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph                         = isSpeedUnitMph;
    speedView.isSpeedUnitMph                = self.isSpeedUnitMph;
//    cumulativeDistanceView.isSpeedUnitMph   = self.isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{
    headingView.heading = heading;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
//    cumulativeDistanceView.location = self.location;
}

#pragma -- operation
-(void)active
{
//    [systemStatusView active];
//    [clockView active];
//    [elapsedTimeView active];
//    [cumulativeDistanceView active];
}

-(void)inactive
{
//    [systemStatusView inactive];
//    [clockView inactive];
//    [elapsedTimeView inactive];
//    [cumulativeDistanceView inactive];
}

@end
