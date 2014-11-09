//
//  CarPanel4HeadingView.m
//  NaviUtil
//
//  Created by Coming on 10/18/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel4HeadingView.h"
#import "CarPanelCircleView.h"
#import "UIImage+category.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"

#define TO_RADIUS(a) (a/180.0)*M_PI


@interface CarPanel4HeadingView()
{
    CarPanelCircleView* circleView;
    UIImageView *arrow;
    UIImageView *blackMask;
    double angle;
}
@end

@implementation CarPanel4HeadingView

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
    angle = -TO_RADIUS(5);
    [self addUIComponents];
    
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
    // 582, 570, 291, 285
    // 36, 32, 18, 16
    arrow                       = [[UIImageView alloc] initWithFrame:CGRectMake(291/2-7, 60, 40, 51)];
    arrow.image                 = [[UIImage imageNamed:@"cp4_arrow"] imageTintedWithColor:[UIColor redColor]];
    
    circleView                  = [[CarPanelCircleView alloc] initWithFrame:CGRectMake(0, 0, 285, 285)];
//    circleView.transform        = CGAffineTransformMake(1, 0, 2*sinf(angle), 1, 0, 0);
    circleView.inclinedAngle    = angle;
    circleView.imageName        = @"cp4_heading";
//    circleView.maskImageName    = @"cp4_heading_mask";
    
    blackMask                   = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 285, 285)];
    blackMask.image             = [UIImage imageNamed:@"cp4_heading_mask"];
    blackMask.backgroundColor   = [UIColor clearColor];
    

    [self addSubview:circleView];
    [self addSubview:blackMask];
    [self addSubview:arrow];
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    arrow.image = [arrow.image  imageTintedWithColor:self.color];
    circleView.color = self.color;
}

-(void)setHeading:(double)heading
{
    _heading = heading;
    circleView.heading      = self.heading;

}



@end
