//
//  CarPanel3View.m
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3View.h"
#import "CarPanel3SpeedView.h"
#import "CarPanel3SpeedView2.h"
#import "CarPanel3HeadingView.h"
#import "SystemManager.h"
#import "CarPanelSwitchView.h"
#import "CarPanel3CumulativeDistanceView.h"
#import "CarPanelTimeView.h"
#import "CarPanelBatteryView.h"


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
    CarPanel3HeadingView* headingView;
    CarPanelSwitchView* networkStatusView;
    CarPanelSwitchView* gpsStatusView;
    CarPanel3SpeedView2* speedView2;
    CarPanel3CumulativeDistanceView* cumulativeDistanceView;
    CarPanelTimeView* timeView;
    CarPanelTimeView* cumTimeView;
    CarPanelBatteryView* batteryView;

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
    xOffset                     = ([SystemManager lanscapeScreenRect].size.width - 480)/4;
    speedView2                  = [[CarPanel3SpeedView2 alloc] initWithFrame:CGRectMake(295+xOffset, 118, 140, 120)];

    headingView                 = [[CarPanel3HeadingView alloc] initWithFrame:CGRectMake(218+xOffset, 20, 291, 285)];
    headingView.imageName       = @"cp3_heading";
    
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
    
    timeView                        = [[CarPanelTimeView alloc] initWithFrame:CGRectMake(16+xOffset, 28, 187, 44)];
    timeView.numberBlockWidth       = 27;
    timeView.numberBlockHeight      = 44;
    timeView.numberGapPadding       = 6;
    timeView.noonTopOffset          = 19;
    timeView.noonLeftOffset         = 150;
    timeView.colonWidth             = 6;
    timeView.colonHeight            = 22;
    timeView.colonTopOffset         = 12;
    timeView.hideNoon               = NO;
    timeView.imagePrefix            = @"cp3_time_";
    timeView.cumulativeTime         = FALSE;
    
    cumTimeView                     = [[CarPanelTimeView alloc] initWithFrame:CGRectMake(20+xOffset, 102, 100, 32)];
    cumTimeView.numberBlockWidth    = 20;
    cumTimeView.numberBlockHeight   = 32;
    cumTimeView.numberGapPadding    = 4;
    cumTimeView.colonWidth          = 5;
    cumTimeView.colonHeight         = 17;
    cumTimeView.colonTopOffset      = 8;
    cumTimeView.hideNoon            = YES;
    cumTimeView.imagePrefix         = @"cp3_cum_";
    cumTimeView.cumulativeTime      = TRUE;
    
    cumulativeDistanceView          = [[CarPanel3CumulativeDistanceView alloc] initWithFrame:CGRectMake(20+xOffset, 164, 100, 32)];

    [self addSubview:speedView2];
    
    [self addSubview:headingView];
    [self addSubview:batteryView];
    [self addSubview:networkStatusView];
    [self addSubview:gpsStatusView];
    [self addSubview:cumulativeDistanceView];
    [self addSubview:timeView];
    [self addSubview:cumTimeView];
    
    
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
    headingView.color               = self.color;
    batteryView.color               = self.color;
    networkStatusView.color         = self.color;
    gpsStatusView.color             = self.color;
    speedView2.color                = self.color;
    cumulativeDistanceView.color    = self.color;
    timeView.color                  = self.color;
    cumTimeView.color               = self.color;
    
}

-(void)setSpeed:(double)speed
{
    _speed              = speed;
    speedView2.speed    = self.speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph                         = isSpeedUnitMph;
    speedView2.isSpeedUnitMph                = self.isSpeedUnitMph;
    cumulativeDistanceView.isSpeedUnitMph   = self.isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{
    headingView.heading = heading;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    cumulativeDistanceView.location = self.location;
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
    [timeView active];
}

@end
