//
//  CarPanel2ElapsedTime.m
//  NaviUtil
//
//  Created by Coming on 8/2/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2ElapsedTimeView.h"
#import "NSString+category.h"
#import "UIFont+category.h"

#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@implementation CarPanel2ElapsedTimeView
{
    UILabel *_hourLabel;
    UILabel *_minuteLabel;
    UILabel *_secondLabel;
    
    NSTimer *_clockTimer;
    
    CGRect _unitLabelFrame;
    
    NSDate *startTime;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    _hourLabel   = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 90, 80)];
    _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 6, 15, 60)];
    _minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 90, 80)];
    
    
    [_hourLabel    setFont:[UIFont fontWithName:@"CordiaUPC" size:70]];
    [_secondLabel  setFont:[UIFont fontWithName:@"CordiaUPC" size:70]];
    [_minuteLabel  setFont:[UIFont fontWithName:@"CordiaUPC" size:70]];
    
    
    _hourLabel.backgroundColor      = [UIColor clearColor];
    _secondLabel.backgroundColor    = [UIColor clearColor];
    _minuteLabel.backgroundColor    = [UIColor clearColor];

    
    _secondLabel.text   = @":";
    _secondLabel.hidden = YES;

    
    [self addSubview:_hourLabel];
    [self addSubview:_secondLabel];
    [self addSubview:_minuteLabel];
 
    startTime = [NSDate date];
    
    [self update];
 
}

-(void) update
{
    logfn();
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:startTime];
    
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    
    _hourLabel.text        = [NSString stringFromLong:hours numOfDigits:2];
    _minuteLabel.text      = [NSString stringFromLong:minutes numOfDigits:2];
    _secondLabel.hidden    = !_secondLabel.hidden;
    
}

-(void) active
{
    if (_clockTimer != nil)
    {
        [_clockTimer invalidate];
        _clockTimer = nil;
    }
    startTime   = [NSDate date];
    _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
}

-(void) inactive
{
    [_clockTimer invalidate];
    _clockTimer = nil;
}

-(void) setColor:(UIColor *)color
{
    _color                  = color;
    _hourLabel.textColor    = _color;
    _minuteLabel.textColor  = _color;
    _secondLabel.textColor  = _color;
}

-(void) dealloc
{
    _hourLabel      = nil;
    _minuteLabel    = nil;
    _secondLabel    = nil;
    _clockTimer     = nil;
}
@end
