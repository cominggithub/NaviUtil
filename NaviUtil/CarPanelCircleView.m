//
//  CarPanel2CircleView.m
//  NaviUtil
//
//  Created by Coming on 7/24/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelCircleView.h"
#import "UIImage+category.h"
#import "UIImageView+category.h"
#import "GeoUtil.h"


#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@implementation CarPanelCircleView
{
    NSTimer* timer;
    int count;
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
    count               = 0;
    self.inclinedAngle  = 0;
    [self addUIComponents];
/*
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod)
                                   userInfo:nil
                                    repeats:YES];
*/    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -- UI
-(void)addUIComponents
{

//    self.imageName = @"cp2_course";
}

#pragma mark -- Property

-(void)setImageName:(NSString *)imageName
{
    self.circleImage = [UIImage imageNamed:imageName];
}

-(void)setMaskImageName:(NSString *)maskImageName
{
    return;
    CALayer *mask = [CALayer layer];
    UIImage *maskImage = [UIImage imageNamed:maskImageName];
    mask.contents = (id)[maskImage CGImage];
    mask.frame = CGRectMake(0, 0, maskImage.size.width/2, maskImage.size.height/2);
    self.layer.mask = mask;
    self.layer.masksToBounds = YES;
    
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    self.image = [self.circleImage imageTintedWithColor:self.color];
}

-(void)setHeading:(double)heading
{
    [self rotate:self toAngle:heading];
    
}

-(void)targetMethod
{
    self.transform = CGAffineTransformMakeRotation(0.1*count++);
}

-(void)rotate:(UIView*) view toAngle:(double)angle
{
//    CGAffineTransform inclienTransform  = CGAffineTransformMake(1, 0, 2*sinf(self.inclinedAngle), 1, 0, 0);
//    CGAffineTransform rotationTransform = CGAffineTransformRotate(inclienTransform, angle);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angle);
    
    [UIView animateWithDuration:0.8
                     animations:^{
                         view.transform = rotationTransform;
                     }];
}


@end
