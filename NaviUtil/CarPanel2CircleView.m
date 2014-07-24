//
//  CarPanel2CircleView.m
//  NaviUtil
//
//  Created by Coming on 7/24/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2CircleView.h"
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


@implementation CarPanel2CircleView
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
    count  = 0;
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

    self.imageName = @"cp2_course";
}

#pragma mark -- Property

-(void)setImageName:(NSString *)imageName
{
    self.circleImage = [UIImage imageNamed:imageName];
    self.color = self.color;
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    self.image = [self.circleImage imageTintedWithColor:self.color];
}

-(void)setHeading:(double)heading
{
    self.transform = CGAffineTransformMakeRotation(heading);
}

-(void)targetMethod
{
    self.transform = CGAffineTransformMakeRotation(0.1*count++);
}

@end
