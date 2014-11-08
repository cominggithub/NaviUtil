//
//  CarPanel2SpeedView.m
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2SpeedView.h"
#import "UIImage+category.h"
#import "GeoUtil.h"

#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@implementation CarPanel2SpeedView
{
    UILabel *speedLabel;
    UILabel *speedLabelUint;
    UIView *speedLabelMask;
    UIImageView *arrow;
    UIImage *arrowImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    speedLabel.text     = @"120";
    self.isSpeedUnitMph = YES;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)addUIComponents
{
    speedLabel                      = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 250, 300)];
    speedLabel.font                 = [UIFont fontWithName:@"CordiaUPC" size:200];
    speedLabel.textAlignment        = UITextAlignmentCenter;

    speedLabelUint                  = [[UILabel alloc] initWithFrame:CGRectMake(5, -30, 250, 300)];
    speedLabelUint.font             = [UIFont fontWithName:@"IrisUPC" size:50];
    speedLabelUint.textAlignment    = UITextAlignmentCenter;
    
    speedLabelMask                  = [[UIView alloc] initWithFrame:CGRectMake(-5, 135, 270, 130)];
    speedLabelMask.backgroundColor  = [UIColor blackColor];
    
    arrow                           = [[UIImageView alloc] initWithFrame:CGRectMake(118, 55, 25, 28) ];
    arrowImage                      = [UIImage imageNamed:@"cp2_arrow"];
    arrow.image                     = arrowImage;
    

    [self addSubview:speedLabelMask];
    [self addSubview:arrow];
    [self addSubview:speedLabel];
    [self addSubview:speedLabelUint];
}


#pragma mark -- Property

-(void)setColor:(UIColor *)color
{
    _color = color;
    speedLabel.textColor        = [UIColor colorWithCGColor:[color CGColor]];
    speedLabelUint.textColor    = [UIColor colorWithCGColor:[color CGColor]];
    arrow.image                 = [arrowImage imageTintedWithColor:self.color];
}

-(void)setSpeed:(double)speed
{
    _speed = speed;
    speedLabel.text = [NSString stringWithFormat:@"%.0f", self.speed];
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph = isSpeedUnitMph;
    if (YES == self.isSpeedUnitMph)
    {
        speedLabelUint.text = [SystemManager getLanguageString:@"mph"];
    }
    else
    {
        speedLabelUint.text = @"km/h";
    }
}

@end
