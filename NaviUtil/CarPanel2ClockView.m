//
//  CarPanel2ClockView.m
//  NaviUtil
//
//  Created by Coming on 8/2/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2ClockView.h"
#import "NSString+category.h"
#import "UIFont+category.h"

@implementation CarPanel2ClockView
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
    _hourLabel   = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 90, 80)];
    _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(78, 5, 10, 60)];
    _minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 90, 80)];

    _unitLabel   = [[UILabel alloc] initWithFrame:CGRectMake(170, -9, 40, 80)];
    
    [_hourLabel    setFont:[UIFont fontWithName:@"CordiaUPC" size:90]];
    [_secondLabel  setFont:[UIFont fontWithName:@"CordiaUPC" size:90]];
    [_minuteLabel  setFont:[UIFont fontWithName:@"CordiaUPC" size:90]];
    [_unitLabel    setFont:[UIFont fontWithName:@"IrisUPC" size:30]];
    
    
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
        _unitLabel.text = @"pm";
    }
    else
    {
        _unitLabel.text = @"am";
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
