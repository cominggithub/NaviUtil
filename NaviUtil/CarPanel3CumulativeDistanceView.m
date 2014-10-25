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
    floatNumberView.floatNumber         = 0.0;
    
    
    unitImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 16, 38, 16)];
    unitImage.contentMode       = UIViewContentModeScaleAspectFit;
    unitImage.image             = kmImage;
    unitImage.backgroundColor   = [UIColor clearColor];
    
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
    cumDisCalculator.location = location;
    if (self.isSpeedUnitMph == YES)
    {
        floatNumberView.floatNumber = M_TO_MILE(cumDisCalculator.cumulativeDistance);
    }
    else
    {
        floatNumberView.floatNumber = cumDisCalculator.cumulativeDistance/1000.0;
    }
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


-(void) setFloatNumberImagePrefix:(NSString *)floatNumberImagePrefix
{
    _floatNumberImagePrefix = floatNumberImagePrefix;
    floatNumberView.imagePrefix = self.floatNumberImagePrefix;
}

-(void) setUnitImagePrefix:(NSString *)unitImagePrefix
{
    _unitImagePrefix = unitImagePrefix;

    kmImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@km", self.unitImagePrefix]];
    mlImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@ml", self.unitImagePrefix]];
    
    self.isSpeedUnitMph = self.isSpeedUnitMph;
}


@end
