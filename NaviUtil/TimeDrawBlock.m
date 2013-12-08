//
//  TimeDrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "TimeDrawBlock.h"
#import "UIImage+category.h"

#define FILE_DEBUG TRUE
#include "Log.h"

@implementation TimeDrawBlock
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
    
    UIImage *_imageH1ToDraw;
    UIImage *_imageH2ToDraw;
    UIImage *_imageM1ToDraw;
    UIImage *_imageM2ToDraw;
    
    CGSize contentSize;
    
    float _xOffset;
}

+(TimeDrawBlock*) timeDrawBlockWithNumImagePrefix:(NSString*) numPrefix origin:(CGPoint) origin size:(CGSize) size;
{
    TimeDrawBlock *timerDrawBlock    = [[TimeDrawBlock alloc] init];
    
    timerDrawBlock.origin                  = origin;
    timerDrawBlock.size                    = size;
    timerDrawBlock.numImagePrefix          = numPrefix;
    return timerDrawBlock;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        self.value = [NSDate date];
    }
    
    return self;
}


-(void) setNumImagePrefix:(NSString *)value
{
    _numImagePrefix = value;
    
    _num0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@0.png", _numImagePrefix] color:self.color];
    _num1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png", _numImagePrefix] color:self.color];
    _num2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@2.png", _numImagePrefix] color:self.color];
    _num3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@3.png", _numImagePrefix] color:self.color];
    _num4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@4.png", _numImagePrefix] color:self.color];
    _num5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@5.png", _numImagePrefix] color:self.color];
    _num6 = [UIImage imageNamed:[NSString stringWithFormat:@"%@6.png", _numImagePrefix] color:self.color];
    _num7 = [UIImage imageNamed:[NSString stringWithFormat:@"%@7.png", _numImagePrefix] color:self.color];
    _num8 = [UIImage imageNamed:[NSString stringWithFormat:@"%@8.png", _numImagePrefix] color:self.color];
    _num9 = [UIImage imageNamed:[NSString stringWithFormat:@"%@9.png", _numImagePrefix] color:self.color];
    
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
    
    contentSize = CGSizeMake(_xOffset*4, _num0.size.height);
    
    
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
    
    return nil;
}

-(void) updateDigitNumImageToDraw
{

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_value];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    
    _imageH1ToDraw = [self getImageByNumber:hour/10];
    _imageH2ToDraw = [self getImageByNumber:hour - (hour/10)*10];

    _imageM1ToDraw = [self getImageByNumber:minute/10];
    _imageM2ToDraw = [self getImageByNumber:minute - (minute/10)*10];
 
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
    

    CGContextDrawImage(bitmap, CGRectMake(0, 0, _imageH1ToDraw.size.width, _imageH1ToDraw.size.height), _imageH1ToDraw.CGImage);
    

    CGContextDrawImage(bitmap, CGRectMake(_xOffset, 0, _imageH2ToDraw.size.width, _imageH2ToDraw.size.height), _imageH2ToDraw.CGImage);

    CGContextDrawImage(bitmap, CGRectMake(_xOffset*2, 0, _imageM1ToDraw.size.width, _imageM1ToDraw.size.height), _imageM1ToDraw.CGImage);

    CGContextDrawImage(bitmap, CGRectMake(_xOffset*3, 0, _imageM2ToDraw.size.width, _imageM2ToDraw.size.height), _imageM2ToDraw.CGImage);
    
    _preDrawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}
@end
