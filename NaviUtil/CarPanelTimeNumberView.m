//
//  CarPanelTimeNumberView.m
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelTimeNumberView.h"
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

@implementation CarPanelTimeNumberView
{
    int numOfNumBlock;
    int numOfNumImage;
}

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
    numOfNumBlock           = 5;
    numOfNumImage           = 11;
    self.numberGapPadding   = 10;
    maxNumberImageHeight    = 0;
    
    [self addNumberImage];
}
-(void) initRawImage
{
    maxNumberImageHeight = 0;
    for (int i=0; i<numOfNumImage; i++)
    {
        rawImage[i] = [UIImage imageNamed:[self getImageNameByNumber:i]];
        if (rawImage[i].size.height > maxNumberImageHeight)
        {
            maxNumberImageHeight = rawImage[i].size.height;
        }
    }
}

// 3, 2, 1, 0
-(void) addNumberImage
{
    for (int i=0; i<numOfNumBlock; i++)
    {
        numberImage[i]                  = [[UIImageView alloc] init];
        numberImage[i].frame            = CGRectMake(0+i*50, 0, 50, 50);
        numberImage[i].contentMode      = UIViewContentModeScaleAspectFit;
        [self addSubview:numberImage[i]];
    }
}

-(void) adjustNumberImage
{
    for (int i=0; i<numOfNumBlock; i++)
    {
        numberImage[i].frame = CGRectMake(self.numberBlockWidth*(2-i) + (2-i)*self.numberGapPadding, 0, self.numberBlockWidth, self.numberBlockHeight);
    }
}

-(void) setImagePrefix:(NSString *)imagePrefix
{
    _imagePrefix = imagePrefix;
    [self initRawImage];
    [self adjustNumberImage];
    [self refreshNumberImage];
}

-(void)setNumber:(int)number
{
    numberBlock[4] = (int)number/1000;
    numberBlock[3] = (int)number/100;
    numberBlock[1] = (int)number/10;
    numberBlock[0] = (int)number%10;

    [self refreshNumberImage];
}


-(void)refreshNumberImage
{
    for (int i=0; i<numOfNumBlock; i++)
    {
        numberImage[i].image = rawImage[i];
        [numberImage[i] setImageTintColor:self.color];
    }
    
    numberImage[2].hidden = !numberImage[2].hidden;
}

-(NSString*) getImageNameByNumber:(int) num
{
    return [NSString stringWithFormat:@"%@%d", self.imagePrefix, num];
}

#pragma mark -- property
-(void)setColor:(UIColor *)color
{
    _color = color;
    for (int i=0; i<numOfNumBlock; i++)
    {
        [numberImage[i] setImageTintColor:self.color];
    }
}

@end
