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
#import "CarPanel4SpeedView.h"
#import "CarPanel4HeadingView.h"
#import "CarPanel3CumulativeDistanceView.h"
#import "CarPanelTimeView.h"
#import "GeoUtil.h"


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
    CarPanel4SpeedView* speedView;
    CarPanel4HeadingView* headingView;
    CarPanelTimeView* timeView;
    CarPanelTimeView* cumTimeView;
    CarPanel3CumulativeDistanceView* cumulativeDistanceView;
    
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
    xOffset                         = ([SystemManager lanscapeScreenRect].size.width - 568)/4;
    batteryView                     = [[CarPanelBatteryView alloc] initWithFrame:CGRectMake(410+xOffset, 275, 39, 16)];
    batteryView.batteryLifeRect     = CGRectMake(0, 0, 39, 16);

    networkStatusView               = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(465+xOffset, 270, 31, 31)];
    networkStatusView.onImageName   = @"cp3_3g_on";
    networkStatusView.offImageName  = @"cp3_3g_off";
    networkStatusView.enabled       = NO;
    
    gpsStatusView                   = [[CarPanelSwitchView alloc] initWithFrame:CGRectMake(510+xOffset, 273, 21, 21)];
    gpsStatusView.onImageName       = @"cp3_gps_on";
    gpsStatusView.offImageName      = @"cp3_gps_off";
    gpsStatusView.enabled           = NO;

    headingView                     = [[CarPanel4HeadingView alloc] initWithFrame:CGRectMake(120, 20, 291, 285)];
    speedView                       = [[CarPanel4SpeedView alloc] initWithFrame:CGRectMake(10, 120, 21, 21)];
    speedView.speed                 = 164;

    
    timeView                        = [[CarPanelTimeView alloc] initWithFrame:CGRectMake(375+xOffset, 28, 187, 44)];
    timeView.numberBlockWidth       = 27;
    timeView.numberBlockHeight      = 44;
    timeView.numberGapPadding       = 6;
    timeView.noonTopOffset          = 26;
    timeView.noonLeftOffset         = 150;
    timeView.colonWidth             = 12;
    timeView.colonHeight            = 26;
    timeView.colonTopOffset         = 15;
    timeView.hideNoon               = NO;
    timeView.imagePrefix            = @"cp4_time_";
    timeView.cumulativeTime         = FALSE;
    
    cumTimeView                     = [[CarPanelTimeView alloc] initWithFrame:CGRectMake(435+xOffset, 120, 100, 32)];
    cumTimeView.numberBlockWidth    = 22;
    cumTimeView.numberBlockHeight   = 32;
    cumTimeView.numberGapPadding    = 4;
    cumTimeView.colonWidth          = 8;
    cumTimeView.colonHeight         = 18;
    cumTimeView.colonTopOffset      = 8;
    cumTimeView.hideNoon            = YES;
    cumTimeView.imagePrefix         = @"cp4_cum_";
    cumTimeView.cumulativeTime      = TRUE;
    
    cumulativeDistanceView          = [[CarPanel3CumulativeDistanceView alloc] initWithFrame:CGRectMake(435+xOffset, 164, 100, 32)];

    cumulativeDistanceView.floatNumberImagePrefix   = @"cp4_cum_";
    cumulativeDistanceView.unitImagePrefix          = @"cp4_cum_";
    
    self.heading = 0;
    [self addSubview:batteryView];
    [self addSubview:networkStatusView];
    [self addSubview:gpsStatusView];
    [self addSubview:headingView];
    [self addSubview:speedView];
    [self addSubview:timeView];
    [self addSubview:cumTimeView];
    [self addSubview:cumulativeDistanceView];
    
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
    headingView.color               = self.color;
    
    timeView.color                  = self.color;
    cumTimeView.color               = self.color;
    cumulativeDistanceView.color    = self.color;

}

-(void)setSecondaryColor:(UIColor *)secondaryColor
{
    _secondaryColor = secondaryColor;
    speedView.color = self.secondaryColor;
}
-(void)setSpeed:(double)speed
{
    _speed              = speed;
    speedView.speed     = self.speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph                         = isSpeedUnitMph;
    cumulativeDistanceView.isSpeedUnitMph   = self.isSpeedUnitMph;
    speedView.isSpeedUnitMph                = self.isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{
    _heading = heading + TO_RADIUS(10);
    headingView.heading = self.heading;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    cumulativeDistanceView.location = self.location;

}

-(void)setBatteryLife:(float)batteryLife
{
    _batteryLife = batteryLife;
    batteryView.batteryPercentage = self.batteryLife * 100;
}

-(void)setNetworkEnabled:(BOOL)networkEnabled
{
    _networkEnabled = networkEnabled;
    networkStatusView.enabled = self.networkEnabled;
}

-(void)setGpsEnabled:(BOOL)gpsEnabled
{
    _gpsEnabled = gpsEnabled;
    gpsStatusView.enabled = self.gpsEnabled;
}

#pragma -- operation
-(void)active
{
    [cumTimeView active];
    [timeView active];
}

-(void)inactive
{
    [cumTimeView inactive];
    [timeView inactive];
}

@end
