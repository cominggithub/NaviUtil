//
//  DigitalNumDrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DigitalNumDrawBlock.h"
#import "UIImage+category.h"

#include "Log.h"

@implementation DigitalNumDrawBlock
{
    UIImage *_num0;
    UIImage *_num1;
    UIImage *_num2;
    UIImage *_num3;
    UIImage *_num4;
    UIImage *_num5;
    UIImage *_num6;
    UIImage *_num7;
    UIImage *_num8;
    UIImage *_num9;
    
    UIImage *_image1ToDraw;
    UIImage *_image2ToDraw;
    UIImage *_image3ToDraw;
    
    CGSize contentSize;
    
    float _xOffset;
}

+(DigitalNumDrawBlock*) digitalNumDrawBlockWithNumImagePrefix:(NSString*) numPrefix origin:(CGPoint) origin size:(CGSize) size;
{
    DigitalNumDrawBlock *digitalNumDrawBlock    = [[DigitalNumDrawBlock alloc] init];
    
    digitalNumDrawBlock.origin                  = origin;
    digitalNumDrawBlock.size                    = size;
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

    _num0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@0.png", _numImagePrefix]];
    _num1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png", _numImagePrefix]];
    _num2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@2.png", _numImagePrefix]];
    _num3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@3.png", _numImagePrefix]];
    _num4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@4.png", _numImagePrefix]];
    _num5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@5.png", _numImagePrefix]];
    _num6 = [UIImage imageNamed:[NSString stringWithFormat:@"%@6.png", _numImagePrefix]];
    _num7 = [UIImage imageNamed:[NSString stringWithFormat:@"%@7.png", _numImagePrefix]];
    _num8 = [UIImage imageNamed:[NSString stringWithFormat:@"%@8.png", _numImagePrefix]];
    _num9 = [UIImage imageNamed:[NSString stringWithFormat:@"%@9.png", _numImagePrefix]];

    logfns("number0 :%s\n", [[NSString stringWithFormat:@"%@0.png", self.numImagePrefix] UTF8String]);
    mlogAssertNotNil(_num0);
    mlogAssertNotNil(_num1);
    mlogAssertNotNil(_num2);
    mlogAssertNotNil(_num3);
    mlogAssertNotNil(_num4);
    mlogAssertNotNil(_num5);
    mlogAssertNotNil(_num6);
    mlogAssertNotNil(_num7);
    mlogAssertNotNil(_num8);
    mlogAssertNotNil(_num9);
    
    _xOffset = _num0.size.width;
    
    contentSize = CGSizeMake(_xOffset*3, _num0.size.height);
    

}


-(UIImage*) getImageByNumber:(int) number
{
    switch(number)
    {
        case 0:
            return _num0;
        case 1:
            return _num1;
        case 2:
            return _num2;
        case 3:
            return _num3;
        case 4:
            return _num4;
        case 5:
            return _num5;
        case 6:
            return _num6;
        case 7:
            return _num7;
        case 8:
            return _num8;
        case 9:
            return _num9;

    }

    mlogError(@"Wrong number: %d\n", number);
    
    return nil;
}

-(void) updateDigitNumImageToDraw
{
    int number;
    int tmpValue;
    
    tmpValue    = self.value/100;
    number      = tmpValue;

    logfns("number3: %d\n", number);
    if (number > 0 || (number == 0 && TRUE == _isPaddingZero))
    {
        _image3ToDraw = [self getImageByNumber:number];
    }
    
    tmpValue = self.value - number * 100;
    number = tmpValue/10;

    logfns("number2: %d\n", number);
    if (number > 0 || (number == 0 && TRUE == _isPaddingZero))
    {
        _image2ToDraw = [self getImageByNumber:number];
    }

    tmpValue = tmpValue - number * 10;
    number = tmpValue;
    
    logfns("number1: %d\n", number);
    _image1ToDraw = [self getImageByNumber:number];
    

}

-(BOOL) isDrawable
{
    return self.visible;
}

-(void) preDrawImage
{

    [self updateDigitNumImageToDraw];

    UIGraphicsBeginImageContext(contentSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();


    CGContextTranslateCTM(bitmap, 0, _num0.size.height);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    
    if (nil != _image3ToDraw)
        CGContextDrawImage(bitmap, CGRectMake(0, 0, _image3ToDraw.size.width, _image3ToDraw.size.height), _image3ToDraw.CGImage);

    if (nil != _image2ToDraw)
        CGContextDrawImage(bitmap, CGRectMake(_xOffset, 0, _image2ToDraw.size.width, _image2ToDraw.size.height), _image2ToDraw.CGImage);
    
    if (nil != _image1ToDraw)
        CGContextDrawImage(bitmap, CGRectMake(_xOffset*2, 0, _image1ToDraw.size.width, _image1ToDraw.size.height), _image1ToDraw.CGImage);

    _preDrawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

@end
