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
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@implementation CarPanelFloatNumberView


-(void)setNumber:(double) floatNumber
{
    
    
    int number;
    int quotient = 0;
    int remainder = 0;
    
    logF(floatNumber);

    number = (int)(floatNumber*10);
    
    // if float number > 10, display XX
    if (number > 99)
    {
        [super setNumber:number/10];
//        // remove floating part
//        number = number/10;
//        for (int i=0; i<2; i++)
//        {
//            remainder = number%((int)pow(10, 2-i));
//            quotient = (number - remainder)/(int)pow(10, 2-i);
//            numberBlock[2-i] = quotient;
//            numberBlock[2-i-1] = remainder;
//            number = remainder;
//        }
    }
    // float number < 10, display X.X
    else
    {
        numberBlock[0] = number%10; // floating part
        numberBlock[1] = 11; // use 11 to represent dot (.)
        numberBlock[2] = number/10; // integer part
    }
    
    logI(numberBlock[0]);
    logI(numberBlock[1]);
    logI(numberBlock[2]);
    
    [self refreshNumberImage];
}
-(void)refreshNumberImage
{
    for (int i=0; i<3; i++)
    {
        if (numberBlock[i] == 0 && i != 0)
        {
            // show 0.x, so we must read next numberBlock
            // the next number is not 11 (.)
            if (numberBlock[1] != 11)
            {
                numberImage[i].hidden = YES;
            }
            else
            {
                numberImage[i].hidden = NO;
            }
        }
        else
        {
            numberImage[i].hidden = NO;
        }
        
        numberImage[i].image = [UIImage imageNamed:[self getImageNameByNumber:numberBlock[i]]];
        [numberImage[i] setImageTintColor:self.color];
    }
}

@end
