//
//  SystemStatusView.m
//  NaviUtil
//
//  Created by Coming on 8/17/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "SystemStatusView.h"
#import "ClockView.h"
#import "SystemManager.h"
#import "NSString+category.h"
#import "UIFont+category.h"
#import "BatteryLifeView.h"
#import "UIImageView+category.h"
#import "UIColor+category.h"

#define FILE_DEBUG TRUE
#include "Log.h"

@implementation SystemStatusView
{
    BatteryLifeView* _batteryLifeView;
    UIImageView *_threeGImage;
    UIImageView *_gpsImage;

    
}
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    [self addUIComponents];
    self.batteryLife    = [SystemManager getBatteryLife];
    self.networkStatus  = [SystemManager getNetworkStatus];
    [SystemManager addDelegate:self];
    [self update];
}

-(void) active
{

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SystemManager addDelegate:self];

    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UIDeviceBatteryLevelDidChangeNotification
     object:self];
    

    [self update];
}

-(void) deactive
{
    [SystemManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];

}
-(void) addUIComponents
{
    
    _batteryLifeView        = [[BatteryLifeView alloc] initWithFrame:CGRectMake(18, 8, 49, 28)];
    _threeGImage            = [[UIImageView alloc] initWithFrame:CGRectMake(86, 8, 43, 28)];
    _gpsImage               = [[UIImageView alloc] initWithFrame:CGRectMake(150, 8, 27, 27)];
    
    _threeGImage.image  = [UIImage imageNamed:@"3g.png"];
    _gpsImage.image     = [UIImage imageNamed:@"gps.png"];
    
    
    [self addSubview:_batteryLifeView];
    [self addSubview:_threeGImage];
    [self addSubview:_gpsImage];
}

-(void) update
{
    _gpsEnabled = [SystemManager getGpsStatus] > 0;
    
    if (NO == _gpsEnabled)
    {
        [_gpsImage setImageTintColor:[_color getColorByAlpha:0.4]];
    }
    else
    {
        [_gpsImage setImageTintColor:_color];
    }

    
    if (0 >= _networkStatus)
    {
        _threeGImage.hidden = !_threeGImage.hidden;
    }
    else
    {
        _threeGImage.hidden = NO;
    }
    
    self.batteryLife    = [SystemManager getBatteryLife];
    self.networkStatus  = [SystemManager getNetworkStatus];
}

-(void) setColor:(UIColor *)color
{
    _color                  = color;
    _batteryLifeView.color  = _color;

    [_gpsImage          setImageTintColor:_color];
    [_threeGImage       setImageTintColor:_color];

}

#pragma mark - System Monitor
-(void) networkStatusChangeWifi:(float) wifiStatus threeG:(float) threeGStatus
{
    self.networkStatus = wifiStatus + threeGStatus;
}


-(void) batteryStatusChange:(float) status
{
    self.batteryLife = status;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
