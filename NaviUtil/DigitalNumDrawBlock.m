//
//  DigitalNumDrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DigitalNumDrawBlock.h"
#import "UIImage+category.h"

#define FILE_DEBUG TRUE
#include "Log.h"

@implementation DigitalNumDrawBlock
{
    UIImage *_image_num0;
    UIImage *_image_num1;
    UIImage *_image_num2;
    UIImage *_image_num3;
    UIImage *_image_num4;
    UIImage *_image_num5;
    UIImage *_image_num6;
    UIImage *_image_num7;
    UIImage *_image_num8;
    UIImage *_image_num9;
    

    
    CGSize contentSize;
    
    float _xOffset;
}

+(DigitalNumDrawBlock*) digitalNumDrawBlockWithNumImagePrefix:(NSString*) numPrefix;
{
    DigitalNumDrawBlock *digitalNumDrawBlock    = [[DigitalNumDrawBlock alloc] init];
    
    digitalNumDrawBlock.numImagePrefix          = numPrefix;
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

    _numImagePrefix = value;

    _image_num0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@0", _numImagePrefix] color:self.color];
    _image_num1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@1", _numImagePrefix] color:self.color];
    _image_num2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@2", _numImagePrefix] color:self.color];
    _image_num3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@3", _numImagePrefix] color:self.color];
    _image_num4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@4", _numImagePrefix] color:self.color];
    _image_num5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@5", _numImagePrefix] color:self.color];
    _image_num6 = [UIImage imageNamed:[NSString stringWithFormat:@"%@6", _numImagePrefix] color:self.color];
    _image_num7 = [UIImage imageNamed:[NSString stringWithFormat:@"%@7", _numImagePrefix] color:self.color];
    _image_num8 = [UIImage imageNamed:[NSString stringWithFormat:@"%@8", _numImagePrefix] color:self.color];
    _image_num9 = [UIImage imageNamed:[NSString stringWithFormat:@"%@9", _numImagePrefix] color:self.color];

    mlogAssertNotNil(_image_num0);
    mlogAssertNotNil(_image_num1);
    mlogAssertNotNil(_image_num2);
    mlogAssertNotNil(_image_num3);
    mlogAssertNotNil(_image_num4);
    mlogAssertNotNil(_image_num5);
    mlogAssertNotNil(_image_num6);
    mlogAssertNotNil(_image_num7);
    mlogAssertNotNil(_image_num8);
    mlogAssertNotNil(_image_num9);
    
}


-(UIImage*) getImageByNumber:(int) number
{
    switch(number)
    {
        case 0:
            return _image_num0;
        case 1:
            return _image_num1;
        case 2:
            return _image_num2;
        case 3:
            return _image_num3;
        case 4:
            return _image_num4;
        case 5:
            return _image_num5;
        case 6:
            return _image_num6;
        case 7:
            return _image_num7;
        case 8:
            return _image_num8;
        case 9:
            return _image_num9;

    }

    return nil;
}

-(void) updateDigitNumImage
{
    int number;
    int tmpValue;
    
    if (self.value >= 1000)
        self.value = self.value % 1000;
    
    tmpValue    = self.value/100;
    number      = tmpValue;

    if (number > 0 || (number == 0 && TRUE == _isPaddingZero))
    {
        _num_2 = [[self getImageByNumber:number] imageTintedWithColor:self.color];
    }
    
    tmpValue = self.value - number * 100;
    number = tmpValue/10;

    if (number > 0 || (number == 0 && TRUE == _isPaddingZero))
    {
        _num_1 = [[self getImageByNumber:number] imageTintedWithColor:self.color];
    }

    tmpValue = tmpValue - number * 10;
    number = tmpValue;
    
    _num_0 = [[self getImageByNumber:number] imageTintedWithColor:self.color];
    
}

-(void) setValue:(int)value
{
    _value = value;
    [self updateDigitNumImage];
    
}

-(void) setColor:(UIColor *)color
{
    super.color = color;
    [self updateDigitNumImage];
}
@end
