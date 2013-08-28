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
#import "UIImage+category.h"
#import "UIColor+category.h"

#define FILE_DEBUG TRUE
#include "Log.h"

@implementation SystemStatusView
{
    BatteryLifeView* _batteryLifeView;
    UIImage *_gpsOnImage;
    UIImage *_gpsOffImage;
    UIImage *_threeGOnImage;
    UIImage *_threeGOffImage;
    UIImageView *_threeGImageView;
    UIImageView *_gpsImageView;

    
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

-(void) inactive
{
    [SystemManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];

}
-(void) addUIComponents
{
    
    _batteryLifeView        = [[BatteryLifeView alloc] initWithFrame:CGRectMake(18, 8, 49, 28)];
    _threeGImageView        = [[UIImageView alloc] initWithFrame:CGRectMake(86, 8, 43, 28)];
    _gpsImageView           = [[UIImageView alloc] initWithFrame:CGRectMake(150, 8, 27, 27)];
    
    _threeGOnImage          = [UIImage imageNamed:@"3g.png"];
    _threeGOffImage         = [UIImage imageNamed:@"3g_off.png"];
    _gpsOnImage             = [UIImage imageNamed:@"gps.png"];
    _gpsOffImage            = [UIImage imageNamed:@"gps_off.png"];
    _threeGImageView.image  = _threeGOnImage;
    _gpsImageView.image     = _gpsOnImage;
    
    
    [self addSubview:_batteryLifeView];
    [self addSubview:_threeGImageView];
    [self addSubview:_gpsImageView];
}

-(void) update
{
    self.batteryLife       = [SystemManager getBatteryLife];
    self.networkStatus     = [SystemManager getNetworkStatus];
    self.gpsEnabled        = [SystemManager getGpsStatus] > 0 ? TRUE:FALSE;
}

-(void) setBatteryLife:(float)batteryLife
{
    _batteryLifeView.life = batteryLife;
}

-(void) setGpsEnabled:(BOOL)gpsEnabled
{
    _gpsEnabled = gpsEnabled;
    
    if (NO == _gpsEnabled)
    {
        _gpsImageView.image = [_gpsOffImage imageTintedWithColor:_color];
    }
    else
    {
        _gpsImageView.image = [_gpsOnImage imageTintedWithColor:_color];
    }
}

-(void) setNetworkStatus:(float)networkStatus
{
    _networkStatus = networkStatus;
    if (0 >= _networkStatus)
    {
        _threeGImageView.image = [_threeGOffImage imageTintedWithColor:_color];
    }
    else
    {
        _threeGImageView.image = [_threeGOnImage imageTintedWithColor:_color];
    }
}
-(void) setColor:(UIColor *)color
{
    _color                  = color;
    _batteryLifeView.color  = _color;

    [_gpsImageView          setImageTintColor:_color];
    [_threeGImageView       setImageTintColor:_color];

}

-(void) dealloc
{
    _batteryLifeView    = nil;
    _gpsOnImage         = nil;
    _gpsOffImage        = nil;
    _threeGOnImage      = nil;
    _threeGOffImage     = nil;
    _threeGImageView    = nil;
    _gpsImageView       = nil;
    
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

-(void) gpsStatusChange:(float) status
{
    self.gpsEnabled = status > 0 ? TRUE:FALSE;
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
