//
//  CarPanel3CumulativeDistanceView.m
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3CumulativeDistanceView.h"
#import "CarPanelFloatNumberView.h"
#import "UIView+category.h"
#import "UIImageView+category.h"
#import "UIImage+category.h"
#import "SystemManager.h"
#import "GeoUtil.h"
#import "CumulativeDistanceCalculator.h"


#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif


#include "Log.h"

@implementation CarPanel3CumulativeDistanceView
{
    CarPanelFloatNumberView* floatNumberView;
    UIImage* kmImage;
    UIImage* mlImage;
    UIImageView *unitImage;
    CumulativeDistanceCalculator* cumDisCalculator;
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
    
    self.backgroundColor = [UIColor blackColor];
    cumDisCalculator = [[CumulativeDistanceCalculator alloc] init];
    [self addUIComponent];
}

-(void) addUIComponent
{
    floatNumberView                     = [[CarPanelFloatNumberView alloc] initWithFrame:CGRectMake(0, 0, 100, 70)];
    floatNumberView.numberBlockWidth    = 20;
    floatNumberView.numberBlockHeight   = 32;
    floatNumberView.numberGapPadding    = 5;
    floatNumberView.dotWidth            = 5;
    floatNumberView.dotHeight           = 6;
    floatNumberView.imagePrefix         = @"cp3_cum_";
    floatNumberView.floatNumber         = 0.0;
    
    kmImage = [UIImage imageNamed:@"cp3_km"];
    mlImage = [UIImage imageNamed:@"cp3_ml"];
    
    unitImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 16, 25, 16)];
    unitImage.image = kmImage;
    unitImage.backgroundColor = [UIColor blackColor];
    
    [self addSubview:floatNumberView];
    [self addSubview:unitImage];
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    floatNumberView.color = self.color;
    [unitImage setImageTintColor:self.color];
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    logfn();
    cumDisCalculator.location = location;
    logF(cumDisCalculator.cumulativeDistance);
    if (self.isSpeedUnitMph == YES)
    {
        logfn();
        floatNumberView.floatNumber = M_TO_MILE(cumDisCalculator.cumulativeDistance);
    }
    else
    {
        logfn();

        floatNumberView.floatNumber = cumDisCalculator.cumulativeDistance/1000.0;
    }
    
    logF(floatNumberView.number);
}

-(void)setIsSpeedUnitMph:(double)isSpeedUnitMph
{
    _isSpeedUnitMph = isSpeedUnitMph;
    if (YES == isSpeedUnitMph)
    {
        unitImage.image = [mlImage imageTintedWithColor:self.color];
    }
    else
    {
        unitImage.image = [kmImage imageTintedWithColor:self.color];
    }
}

@end
