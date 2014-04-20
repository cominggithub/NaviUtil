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

#include "Log.h"
@implementation SpeedView
{
    UILabel *_speedLabel;
    UILabel *_speedUnitLabel;
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
    
    [self addUIComponent];
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
    
    [self updateUIByLanguage];

}

-(void) updateUIByLanguage
{
    NSString* language = [SystemManager getSystemLanguage];
    
    if ([language isEqualToString:@"zh-Hant"] || [language isEqualToString:@"zh-Hans"])
    {
        _speedUnitLabel.font = [_speedUnitLabel.font newFontsize:12];
    }
}

-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    if (YES == _isSpeedUnitMph)
    {
        self.speed = MS_TO_MPH(speed);
    }
    else
    {
        self.speed = MS_TO_KMH(speed);
    }
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
    [self updateUIByLanguage];
    [LocationManager addDelegate:self];

}

-(void) inactive
{
    [LocationManager removeDelegate:self];
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
