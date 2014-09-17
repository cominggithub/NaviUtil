//
//  CarPanel2CumulativeDistanceView.m
//  NaviUtil
//
//  Created by Coming on 8/2/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2CumulativeDistanceView.h"
#import "SystemManager.h"
#import "GeoUtil.h"


#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif


#include "Log.h"


@implementation CarPanel2CumulativeDistanceView
{
    UILabel *distanceLabel;
    UILabel *distanceUnitLabel;
    
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

-(void)initSelf
{
    distanceLabel       = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
    distanceUnitLabel   = [[UILabel alloc] initWithFrame:CGRectMake(95, 22, 40, 60)];
    
    
    [distanceLabel      setFont:[UIFont fontWithName:@"CordiaUPC" size:70]];
    [distanceUnitLabel  setFont:[UIFont fontWithName:@"CordiaUPC" size:30]];
    
    
    distanceLabel.textAlignment = UITextAlignmentLeft;
    
    [self addSubview:distanceLabel];
    [self addSubview:distanceUnitLabel];
    
    self.isSpeedUnitMph = TRUE;
    [self addDistance:22.8/0.000621371];
    [self setLocation:CLLocationCoordinate2DMake(0.0, 0.0)];

    
}

-(void)active
{
    self.location = CLLocationCoordinate2DMake(0.0, 0.0);
    self.cumulativeDistance = 0;
}

-(void)inactive
{

}


-(void)addDistance:(double)distance
{
    self.cumulativeDistance = self.cumulativeDistance + distance;
}

-(void)setColor:(UIColor *)color
{
    _color                          = color;
    distanceLabel.textColor         = [UIColor colorWithCGColor:[color CGColor]];
    distanceUnitLabel.textColor     = [UIColor colorWithCGColor:[color CGColor]];
}

-(void)setLocation:(CLLocationCoordinate2D)location
{

    double distance;
    // skip init location
    
    if ((self.location.latitude == 0 && self.location.latitude == 0) || (location.latitude == 0 && location.longitude == 0))
    {
        _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        return;
    }
    
    distance = [GeoUtil getGeoDistanceFromLocation:self.location ToLocation:location];
    logF(distance);
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [self addDistance:distance];
    
}
-(void)setCumulativeDistance:(double)cumulativeDistance
{
    double distanceToShow = 0;
    _cumulativeDistance = cumulativeDistance;

    logF(_cumulativeDistance);
    if (self.isSpeedUnitMph == YES)
    {
        distanceToShow = M_TO_MILE(_cumulativeDistance);
    }
    else
    {
        distanceToShow = _cumulativeDistance/1000.0;
    }

    logF(distanceToShow);
    
    if (distanceToShow < 9.9999)
    {
        distanceLabel.text = [NSString stringWithFormat:@"%.2f", distanceToShow];
    }
    else if (distanceToShow < 99.9999)
    {
        distanceLabel.text = [NSString stringWithFormat:@"%.1f", distanceToShow];
    }
    else
    {
        distanceLabel.text = [NSString stringWithFormat:@"%.0f", distanceToShow];
    }
}
-(void)setIsSpeedUnitMph:(double)isSpeedUnitMph
{
    _isSpeedUnitMph = isSpeedUnitMph;
    if (YES == isSpeedUnitMph)
    {
        distanceUnitLabel.text = [SystemManager getLanguageString:@"mile"];
    }
    else
    {
        distanceUnitLabel.text = [SystemManager getLanguageString:@"km"];
    }
}


@end
