//
//  DigitalNumDrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DigitalNumDrawBlock.h"

#include "Log.h"

@implementation DigitalNumDrawBlock
{
    UIImage *num0;
    UIImage *num1;
    UIImage *num2;
    UIImage *num3;
    UIImage *num4;
    UIImage *num5;
    UIImage *num6;
    UIImage *num7;
    UIImage *num8;
    UIImage *num9;
    
}

+(id) digitalNumDrawBlockWithNumPrefix:(NSString*) numPrefix
{
    DigitalNumDrawBlock *digitalNumDrawBlock = [[DigitalNumDrawBlock alloc] init];
    digitalNumDrawBlock.numImagePrefix = numPrefix;
    return digitalNumDrawBlock;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        self.value = 0;
    }
    
    return self;
}


-(void) setNumImagePrefix:(NSString *)value
{
    self.numImagePrefix = value;
    num0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_0.png", self.numImagePrefix]];
    num1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1.png", self.numImagePrefix]];
    num2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_2.png", self.numImagePrefix]];
    num3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_3.png", self.numImagePrefix]];
    num4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_4.png", self.numImagePrefix]];
    num5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_5.png", self.numImagePrefix]];
    num6 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_6.png", self.numImagePrefix]];
    num7 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_7.png", self.numImagePrefix]];
    num8 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_8.png", self.numImagePrefix]];
    num9 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_9.png", self.numImagePrefix]];

    mlogAssertNotNil(num0);
    mlogAssertNotNil(num1);
    mlogAssertNotNil(num2);
    mlogAssertNotNil(num3);
    mlogAssertNotNil(num4);
    mlogAssertNotNil(num5);
    mlogAssertNotNil(num6);
    mlogAssertNotNil(num7);
    mlogAssertNotNil(num8);
    mlogAssertNotNil(num9);
    
}

-(void) drawRect:(CGRect)rect
{
    
}
@end
