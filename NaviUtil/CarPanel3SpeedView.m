//
//  CarPanel3SpeedView.m
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3SpeedView.h"
#import "UIImage+category.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@implementation CarPanel3SpeedView
{
    UILabel *speedLabel;
    UILabel *speedLabelUint;
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
    speedLabelUint.text = @"mph";
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
    speedLabel                      = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
    speedLabel.font                 = [UIFont fontWithName:@"SWIsop3" size:100];
    speedLabel.textAlignment        = UITextAlignmentCenter;

    speedLabelUint                  = [[UILabel alloc] initWithFrame:CGRectMake(50, 80, 250, 300)];
    speedLabelUint.font             = [UIFont fontWithName:@"SWIsop3" size:30];
    speedLabelUint.textAlignment    = UITextAlignmentCenter;
    
    [self addSubview:speedLabel];
    [self addSubview:speedLabelUint];
}


#pragma mark -- Property

-(void)setColor:(UIColor *)color
{
    _color = color;
    speedLabel.textColor        = [UIColor colorWithCGColor:[color CGColor]];
    speedLabelUint.textColor    = [UIColor colorWithCGColor:[color CGColor]];
}

-(void)setSpeed:(double)speed
{
    speedLabel.text = [NSString stringWithFormat:@"%.0f", speed];
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    if (YES == isSpeedUnitMph)
    {
        speedLabelUint.text = [SystemManager getLanguageString:@"mph"];
    }
    else
    {
        speedLabelUint.text = @"km/h";
    }
}

@end
