//
//  SpeedView.m
//  NaviUtil
//
//  Created by Coming on 8/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "SpeedView.h"
#import "SystemManager.h"
#import "SystemConfig.h"
#import "GeoUtil.h"
#import "LocationManager.h"
#import "UIFont+category.h"
#import "UIColor+category.h"
#import "LocationUpdateEvent.h"

#include "Log.h"
@implementation SpeedView
{
    UILabel *_speedLabel;
    UILabel *_speedUnitLabel;
    double zeroSpeedCount;
    double rawSpeed;
}
- (id)initWithFrame:(CGRect)frame
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
    zeroSpeedCount  = 0;
    rawSpeed        = 0;
    [self addUIComponent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocationUpdateEvent:)
                                                 name:LOCATION_MANAGER_LOCATION_UPDATE_EVENT
                                               object:nil];
    
}

-(void) addUIComponent
{
    _speedLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 80)];
    _speedUnitLabel     = [[UILabel alloc] initWithFrame:CGRectMake(175, 60, 80, 30)];

    
    [_speedLabel        setFont:[UIFont fontWithName:@"JasmineUPC" size:120]];
    [_speedUnitLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:30]];
    
    _speedLabel.textAlignment           = NSTextAlignmentCenter;
    _speedUnitLabel.textAlignment       = NSTextAlignmentLeft;
    _speedLabel.backgroundColor         = [UIColor clearColor];
    _speedUnitLabel.backgroundColor     = [UIColor clearColor];
    self.backgroundColor                = [UIColor clearColor];

    self.speed          = 0;
    self.isSpeedUnitMph = FALSE;

    [self addSubview:_speedLabel];
    [self addSubview:_speedUnitLabel];
    
}


-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    double filteredSpeed;
    filteredSpeed = [self filterSpeed:speed];
    
    if (YES == _isSpeedUnitMph)
    {
        self.speed = MS_TO_MPH(filteredSpeed);
    }
    else
    {
        self.speed = MS_TO_KMH(filteredSpeed);
    }
}

-(double)filterSpeed:(double)speed
{
    if (speed == 0)
    {
        zeroSpeedCount++;
        if (zeroSpeedCount >= 2)
        {
            rawSpeed = 0;
            return 0;
        }
        else
        {
            return rawSpeed;
        }
    }
    
    zeroSpeedCount  = 0;
    rawSpeed        = speed;
    
    return rawSpeed;
}

-(void) setColor:(UIColor *)color
{
    _color                      = color;
    _speedLabel.textColor       = _color;
    _speedUnitLabel.textColor   = _color;
    
}

-(void) setSpeed:(double)speed
{
    if (speed < 0)
        speed = 0;
    
    if (speed > 999)
        speed = 999;
    
    if (isnan(speed))
        speed = 0;

    _speed = speed;
    _speedLabel.text = [NSString stringWithFormat:@"%.0f", _speed];


}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    
    _isSpeedUnitMph = isSpeedUnitMph;
    
    if (YES == _isSpeedUnitMph)
    {
        _speedUnitLabel.text = [SystemManager getLanguageString:@"mph"];
    }
    else
    {
        _speedUnitLabel.text = [SystemManager getLanguageString:@"kmh"];
    }
}

-(void) active
{
    self.speed          = 0;


}

-(void) inactive
{

}

- (void)receiveLocationUpdateEvent:(NSNotification *)notification
{
    LocationUpdateEvent *event;
    event = [notification.userInfo objectForKey:@"data"];
    [self locationManager:NULL update:event.location speed:event.speed distance:event.distance heading:event.heading];
}

@end
