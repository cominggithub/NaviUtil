//
//  CarPanel3SpeedView2.m
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3SpeedView2.h"
#import "CarPanelNumberView.h"
#import "UIView+category.h"
#import "UIImage+category.h"
#import "UIImageView+category.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@implementation CarPanel3SpeedView2
{
    CarPanelNumberView *numberView;
    UIImageView *speedUnitView;
    UIImage *mphImage;
    UIImage *kmhImage;
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
    [self addUIComponent];
    self.isSpeedUnitMph = YES;
    self.backgroundColor = [UIColor blackColor];
}

-(void)addUIComponent
{
    numberView = [[CarPanelNumberView alloc] initWithFrame:CGRectMake(0, 0, 40*3+30, 80)];
    numberView.numberBlockWidth     = 40;
    numberView.numberBlockHeight    = 64;
    numberView.numberGapPadding     = 10;
    numberView.imagePrefix          = @"cp3_speed_num_";
    numberView.number               = 0;
    
    kmhImage = [UIImage imageNamed:@"cp3_kmh"];
    mphImage = [UIImage imageNamed:@"cp3_mph"];
    
    speedUnitView = [[UIImageView alloc] initWithFrame:
                     CGRectMake((self.frame.size.width - kmhImage.size.width)/2, 80, kmhImage.size.width, kmhImage.size.height)];
    
    [self addSubview:numberView];
    [self addSubview:speedUnitView];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setSpeed:(double)speed
{
    numberView.number = (int)speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    if (isSpeedUnitMph)
    {
        speedUnitView.image= [mphImage imageTintedWithColor:self.color];
    }
    else
    {
        speedUnitView.image= [kmhImage imageTintedWithColor:self.color];
    }
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    numberView.color = self.color;
    [speedUnitView setImageTintColor:self.color];
}
@end
