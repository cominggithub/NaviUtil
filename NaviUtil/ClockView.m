//
//  ClockView.m
//  NaviUtil
//
//  Created by Coming on 8/17/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "ClockView.h"
#import "SystemManager.h"
#import "NSString+category.h"
#import "UIFont+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"
@implementation ClockView
{
    UILabel *_hourLabel;
    UILabel *_minuteLabel;
    UILabel *_secondLabel;
    UILabel *_unitLabel;
    
    NSTimer *_clockTimer;
    
    CGRect _unitLabelFrame;
    
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
    _hourLabel   = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 51, 30)];
    _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, -2, 10, 32)];
    _minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(78, 0, 51, 30)];
    _unitLabel   = [[UILabel alloc] initWithFrame:CGRectMake(132, -5, 40, 24)];
    
    [_hourLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:50]];
    [_secondLabel  setFont:[UIFont fontWithName:@"JasmineUPC" size:50]];
    [_minuteLabel  setFont:[UIFont fontWithName:@"JasmineUPC" size:50]];
    [_unitLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:25]];

    
    _hourLabel.backgroundColor      = [UIColor clearColor];
    _secondLabel.backgroundColor    = [UIColor clearColor];
    _minuteLabel.backgroundColor    = [UIColor clearColor];
    _unitLabel.backgroundColor      = [UIColor clearColor];
    
    
    _secondLabel.text   = @":";
    _secondLabel.hidden = YES;
    _unitLabelFrame     = _unitLabel.frame;

    
    [self addSubview:_hourLabel];
    [self addSubview:_secondLabel];
    [self addSubview:_minuteLabel];
    [self addSubview:_unitLabel];
    

    [self updateUIByLanguage:[SystemManager getSystemLanguage]];
    [self update];
    
}

-(void) update
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSInteger hour      = [components hour];
    NSInteger minute    = [components minute];
    
    if (hour >= 12)
    {
        hour -= 12;
        _unitLabel.text = [SystemManager getLanguageString:@"pm"];
    }
    else
    {
        _unitLabel.text = [SystemManager getLanguageString:@"am"];
    }
    
    _hourLabel.text        = [NSString stringFromLong:hour numOfDigits:2];
    _minuteLabel.text      = [NSString stringFromLong:minute numOfDigits:2];
    _secondLabel.hidden    = !_secondLabel.hidden;
    
}

-(void) active
{
    if (_clockTimer != nil)
    {
        [_clockTimer invalidate];
        _clockTimer = nil;
    }
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
    _unitLabel.textColor    = _color;
}

-(void) updateUIByLanguage:(NSString*) language
{
    if ([language isEqualToString:@"zh-Hant"] || [language isEqualToString:@"zh-Hans"])
    {

        _unitLabel.font = [_unitLabel.font newFontsize:15];
        _unitLabel.frame = CGRectMake(_unitLabelFrame.origin.x, _unitLabelFrame.origin.y+5, _unitLabelFrame.size.width, _unitLabelFrame.size.height);
        
    }
}


-(void) dealloc
{
    _hourLabel      = nil;
    _minuteLabel    = nil;
    _secondLabel    = nil;
    _unitLabel      = nil;
    _clockTimer     = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
