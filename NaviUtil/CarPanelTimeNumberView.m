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
    numOfNumImage           = 13;
    self.numberGapPadding   = 10;
    maxNumberImageHeight    = 0;
    numberBlock[2]          = 12;
    [self initRawImage];
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


-(void) addNumberImage
{
    for (int i=0; i<numOfNumBlock; i++)
    {
        numberImage[i]                  = [[UIImageView alloc] init];
        numberImage[i].frame            = CGRectMake(0+i*50, 0, 50, 50);
        numberImage[i].contentMode      = UIViewContentModeScaleAspectFit;
        // set colon image
        if (i == 2)
        {
            numberImage[i].image        = rawImage[11];
        }
        [self addSubview:numberImage[i]];
    }
}
// 0 1 2 3 4
//     :
-(void) adjustNumberImagePosition
{
    int cumWidth = 0;
    for (int i=0; i<numOfNumBlock; i++)
    {
        if (i!=2)
        {
            numberImage[i].frame = CGRectMake(cumWidth, 0, self.numberBlockWidth, self.numberBlockHeight);
            cumWidth += self.numberBlockWidth + self.numberGapPadding;
        }
        else
        {
            numberImage[i].frame = CGRectMake(cumWidth, self.colonTopOffset, self.colonWidth, self.colonHeight);
            cumWidth += self.colonWidth + self.numberGapPadding;
        }
        
    }
}

-(void)refreshNumberImage
{
    for (int i=0; i<numOfNumBlock; i++)
    {
        numberImage[i].image = rawImage[numberBlock[i]];
        [numberImage[i] setImageTintColor:self.color];
    }
    
    numberImage[2].hidden = !numberImage[2].hidden;

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
    for (int i=0; i<numOfNumBlock; i++)
    {
        [numberImage[i] setImageTintColor:self.color];
    }
}

-(void)setDate:(NSDate *)date
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour;
    _date           = date;

    hour = [components hour];
    if (hour > 12)
    {
        hour -= 12;
    }
    
    numberBlock[0]  = (int)hour/10;
    numberBlock[1]  = (int)hour%10;
    numberBlock[2]  = 12;
    numberBlock[3]  = (int)[components minute]/10;
    numberBlock[4]  = (int)[components minute]%10;
    

    [self refreshNumberImage];
}

-(void)setElapsedTime:(NSTimeInterval)elapsedTime
{
    div_t h = div(elapsedTime, 3600);
    int hour = h.quot;
    div_t m = div(h.rem, 60);
    int minute = m.quot;

    numberBlock[0]  = (int)hour/10;
    numberBlock[1]  = (int)hour%10;
    numberBlock[2]  = 12;
    numberBlock[3]  = (int)minute/10;
    numberBlock[4]  = (int)minute%10;

    [self refreshNumberImage];
}

-(void) setImagePrefix:(NSString *)imagePrefix
{
    _imagePrefix = imagePrefix;
    [self initRawImage];
    [self refreshNumberImage];
}

@end
