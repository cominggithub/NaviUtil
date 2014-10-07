//
//  CarPanel4View.m
//  NaviUtil
//
//  Created by Coming on 10/7/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel4View.h"
#import "CarPanelSwitchView.h"
#import "CarPanelBatteryView.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@interface CarPanel4View()
{
    CarPanelSwitchView* networkStatusView;
    CarPanelSwitchView* gpsStatusView;
    CarPanelBatteryView* batteryView;
    
}
@end

@implementation CarPanel4View

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
    xOffset                     = ([SystemManager lanscapeScreenRect].size.width - 480)/4;
    batteryView                     = [[CarPanelBatteryView alloc] initWithFrame:CGRectMake(20+xOffset, 275, 39, 16)];
    batteryView.batteryLifeRect     = CGRectMake(0, 0, 39, 16);

    networkStatusView               = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(75+xOffset, 270, 31, 31)];
    networkStatusView.onImageName   = @"cp3_3g_on";
    networkStatusView.offImageName  = @"cp3_3g_off";
    [networkStatusView off];
    
    gpsStatusView                   = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(120+xOffset, 273, 21, 21)];
    gpsStatusView.onImageName       = @"cp3_gps_on";
    gpsStatusView.offImageName      = @"cp3_gps_off";
    [gpsStatusView off];
    
    
    [self addSubview:batteryView];
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
    batteryView.color               = self.color;
    networkStatusView.color         = self.color;
    gpsStatusView.color             = self.color;

}

-(void)setSpeed:(double)speed
{
    _speed              = speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph                         = isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{

}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);

}

#pragma -- operation
-(void)active
{

}

-(void)inactive
{

}

@end
