//
//  CarPanelFloatNumberView.m
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelFloatNumberView.h"
#import "UIImageView+category.h"
#import "UIView+category.h"


#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@implementation CarPanelFloatNumberView


-(void)setFloatNumber:(double) floatNumber
{
    int number;
    
    _floatNumber = floatNumber;
    self.number = floatNumber;
    number = (int)(floatNumber*10);
    
    if (floatNumber < 10)
    {
        numberBlock[0] = number%10; // floating part
        numberBlock[1] = 11; // floating part
        numberBlock[2] = number/10; // integer part
    }
    
    [self refreshNumberImage];
}

-(void) adjustNumberImagePosition
{
    float diff;

//    diff = (self.numberBlockWidth - self.dotWidth)/2;
    diff = 0;
    
    // x.x, three digits
    if (self.floatNumber < 10)
    {
        numberImage[2].frame = CGRectMake(diff, 0, self.numberBlockWidth, self.numberBlockHeight);
        numberImage[1].frame = CGRectMake(diff + self.numberBlockWidth + self.numberGapPadding, self.numberBlockHeight - self.dotHeight, self.dotWidth, self.dotHeight);
        numberImage[0].frame = CGRectMake(diff+self.numberBlockWidth+self.dotWidth+self.numberGapPadding*2, 0, self.numberBlockWidth, self.numberBlockHeight);
    }
    else
    {
        [super adjustNumberImagePosition];
    }
    
}

-(void)refreshNumberImage
{
    for (int i=0; i<3; i++)
    {
        numberImage[i].hidden = NO;
        numberImage[i].image = [UIImage imageNamed:[self getImageNameByNumber:numberBlock[i]]];
        [numberImage[i] setImageTintColor:self.color];
    }
    
    if (self.floatNumber < 100 && self.floatNumber >= 10)
    {
        numberImage[1].hidden = YES;
    }
    
    [self adjustNumberImagePosition];
}

@end
