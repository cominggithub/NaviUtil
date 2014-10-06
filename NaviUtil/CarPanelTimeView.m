//
//  CarPanel3TimeView.m
//  NaviUtil
//
//  Created by Coming on 9/28/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelTimeView.h"
#import "CarPanelTimeNumberView.h"
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

@implementation CarPanelTimeView
{
    CarPanelTimeNumberView *timeNumber;
    UIImageView *noonImage;
    UIImage *amImage;
    UIImage *pmImage;
    NSTimer *clockTimer;
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


-(void) initSelf
{
    self.backgroundColor            = [UIColor blackColor];

    timeNumber                      = [[CarPanelTimeNumberView alloc] init];
    timeNumber.numberBlockWidth     = 27;
    timeNumber.numberBlockHeight    = 44;
    timeNumber.colonWidth           = 6;
    timeNumber.colonHeight          = 22;
    noonImage                       = [[UIImageView alloc] initWithFrame:CGRectMake(152, 17, 27, 17)];
    
    self.imagePrefix                = @"cp3_time_";
    
    [self addSubview:timeNumber];
    [self addSubview:noonImage];
    clockTimer = nil;
}

-(void) active
{
    if (self.cumulativeTime)
    {
        self.startDate = [NSDate new];
    }
    
    if (clockTimer != nil)
    {
        [clockTimer invalidate];
        clockTimer = nil;
    }
    clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
}

-(void) inactive
{
    [clockTimer invalidate];
    clockTimer = nil;
}

-(void)update
{
    self.date = [NSDate new];
}
#pragma mark -- property
-(void)setImagePrefix:(NSString *)imagePrefix
{
    _imagePrefix = imagePrefix;
    amImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@am", self.imagePrefix]];
    pmImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@pm", self.imagePrefix]];
    timeNumber.imagePrefix = self.imagePrefix;
}

-(void) setColor:(UIColor *)color
{
    _color              = color;
    timeNumber.color    = self.color;
    [noonImage setImageTintColor:self.color];
}

-(void)setDate:(NSDate *)date
{
    NSCalendar *calendar;
    NSDateComponents *components;
    _date = date;
    if (self.cumulativeTime)
    {
        if (self.startDate != nil)
            timeNumber.elapsedTime = [date timeIntervalSinceDate:self.startDate];
    }
    else
    {
        timeNumber.date = self.date;
    }
    
    calendar = [NSCalendar currentCalendar];
    components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    if ([components hour] < 12)
    {
        noonImage.image = [amImage imageTintedWithColor:self.color];
    }
    else
    {
        noonImage.image = [pmImage imageTintedWithColor:self.color];
    }
}

-(void)setHideNoon:(BOOL)hideNoon
{
    noonImage.hidden = hideNoon;
}

-(void)setNumberBlockWidth:(int)numberBlockWidth
{
    _numberBlockWidth           = numberBlockWidth;
    timeNumber.numberBlockWidth = self.numberBlockWidth;
}

-(void)setNumberBlockHeight:(int)numberBlockHeight
{
    _numberBlockHeight              = numberBlockHeight;
    timeNumber.numberBlockHeight    = self.numberBlockHeight;
}

-(void)setNumberGapPadding:(int)numberGapPadding
{
    _numberGapPadding           = numberGapPadding;
    timeNumber.numberGapPadding = self.numberGapPadding;
}

-(void)setColonWidth:(int)colonWidth
{
    _colonWidth             = colonWidth;
    timeNumber.colonWidth   = self.colonWidth;
}

-(void)setColonHeight:(int)colonHeight
{
    _colonHeight            = colonHeight;
    timeNumber.colonHeight  = self.colonHeight;
}

-(void)setColonTopOffset:(int)colonTopOffset
{
    _colonTopOffset             = colonTopOffset;
    timeNumber.colonTopOffset   = self.colonTopOffset;
}
@end
