//
//  CarPanelNumberView.m
//  NaviUtil
//
//  Created by Coming on 9/20/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelNumberView.h"
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

// 2, 1, 0
@implementation CarPanelNumberView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initInternal];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initInternal];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self initInternal];
    }
    return self;
}

-(void) initInternal
{
   self.numberGapPadding = 10;
    maxNumberImageHeight = 0;
    
    [self addUIComponent];
}
-(void) initRawImage
{
    maxNumberImageHeight = 0;
    for (int i=0; i<10; i++)
    {
        rawImage[i] = [UIImage imageNamed:[self getImageNameByNumber:i]];
        if (rawImage[i].size.height > maxNumberImageHeight)
        {
            maxNumberImageHeight = rawImage[i].size.height;
        }
    }
}

-(void)addUIComponent
{
    [self addNumberImage];
}
// 2, 1, 0
-(void) addNumberImage
{
    for (int i=0; i<3; i++)
    {
        numberImage[i]                  = [[UIImageView alloc] init];
        numberImage[i].frame            = CGRectMake(0+i*50, 0, 50, 50);
        numberImage[i].contentMode      = UIViewContentModeScaleAspectFit;
        [self addSubview:numberImage[i]];
    }
}

-(void) adjustNumberImagePosition
{
    // three digital
    if (self.number >= 100)
    {
        for (int i=0; i<3; i++)
        {
            numberImage[i].frame = CGRectMake(self.numberBlockWidth*(2-i) + (2-i)*self.numberGapPadding, 0, self.numberBlockWidth, self.numberBlockHeight);
        }
    }
    // two digital
    else if (self.number < 100 && self.number >= 10)
    {
        numberImage[1].frame = CGRectMake(self.numberBlockWidth*(2-1) + (2-1)*self.numberGapPadding - (self.numberBlockWidth + self.numberGapPadding)/2
                                          ,
                                          0,
                                          self.numberBlockWidth,
                                          self.numberBlockHeight
                                          );
        
        numberImage[0].frame = CGRectMake(self.numberBlockWidth*(2-0) + (2-0)*self.numberGapPadding - (self.numberBlockWidth + self.numberGapPadding)/2
                                          ,
                                          0,
                                          self.numberBlockWidth,
                                          self.numberBlockHeight
                                          );
    }
    // one digital
    else
    {
        numberImage[0].frame = CGRectMake(self.numberBlockWidth*(2-1) + (2-1)*self.numberGapPadding, 0, self.numberBlockWidth, self.numberBlockHeight);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setImagePrefix:(NSString *)imagePrefix
{
    _imagePrefix = imagePrefix;
    [self initRawImage];
    [self refreshNumberImage];
}

-(void)setNumber:(int)number
{
    int quotient = 0;
    int remainder = 0;
    _number = number;
    
    for (int i=0; i<2; i++)
    {
        remainder = number%((int)pow(10, 2-i));
        quotient = (number - remainder)/(int)pow(10, 2-i);
        numberBlock[2-i] = quotient;
        numberBlock[2-i-1] = remainder;
        number = remainder;
    }
    
    [self refreshNumberImage];
}

-(void)refreshNumberImage
{
    for (int i=0; i<3; i++)
    {
        numberImage[i].hidden = NO;
        numberImage[i].image = [UIImage imageNamed:[self getImageNameByNumber:numberBlock[i]]];
        [numberImage[i] setImageTintColor:self.color];
    }
    
    if (self.number < 100)
    {
        numberImage[2].hidden = YES;
        if (self.number < 10)
        {
            numberImage[1].hidden = YES;
        }
    }
    
    [self adjustNumberImagePosition];
}

-(NSString*) getImageNameByNumber:(int) num
{
    return [NSString stringWithFormat:@"%@%d", self.imagePrefix, num];
}

#pragma mark -- property
-(void)setColor:(UIColor *)color
{
    _color = color;
    for (int i=0; i<3; i++)
    {
        [numberImage[i] setImageTintColor:self.color];
    }
}
@end
