//
//  CarPanel2View.m
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2View.h"
#import "SystemStatusView.h"
#import "CarPanel2SpeedView.h"
#import "CarPanel2HeadingView.h"
#import "CarPanel2ClockView.h"
#import "CarPanel2ElapsedTimeView.h"
#import "CarPanel2CumulativeDistanceView.h"


#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@interface CarPanel2View ()
{
    SystemStatusView                *systemStatusView;
    CarPanel2SpeedView              *speedView;
    CarPanel2HeadingView            *headingView;
    CarPanel2ClockView              *clockView;
    CarPanel2ElapsedTimeView        *elapsedTimeView;
    CarPanel2CumulativeDistanceView *cumulativeDistanceView;

}
@end

@implementation CarPanel2View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    [self addUIComponents];
}

#pragma mark -- UI Component
-(void) addUIComponents
{
    int xOffset;
    xOffset                     = ([SystemManager lanscapeScreenRect].size.width - 480)/2;
    clockView                   = [[CarPanel2ClockView alloc] initWithFrame:CGRectMake(0, 70, 180, 50)];
    elapsedTimeView             = [[CarPanel2ElapsedTimeView alloc] initWithFrame:CGRectMake(-5, 145, 180, 50)];
    systemStatusView            = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    cumulativeDistanceView      = [[CarPanel2CumulativeDistanceView alloc] initWithFrame:CGRectMake(13, 210, 180, 50)];
    speedView                   = [[CarPanel2SpeedView alloc] initWithFrame:CGRectMake(210+xOffset, 50, 260, 300)];
    headingView                 = [[CarPanel2HeadingView alloc] initWithFrame:CGRectMake(210+xOffset, 50, 260, 260)];
    headingView.imageName       = @"cp2_heading";
    
    [self addSubview:systemStatusView];
    [self addSubview:clockView];
    [self addSubview:elapsedTimeView];
    [self addSubview:cumulativeDistanceView];
    [self addSubview:headingView];
    [self addSubview:speedView];
    

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -- Property

-(void)setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    
    if(TRUE == _isHud)
    {
        self.transform = CGAffineTransformMakeScale(1,-1);
    }
    else
    {
        self.transform = CGAffineTransformMakeScale(1,1);
    }
}
-(void)setColor:(UIColor *)color
{

    _color                          = color;
    systemStatusView.color          = self.color;
    speedView.color                 = self.color;
    headingView.color               = self.color;
    clockView.color                 = self.color;
    elapsedTimeView.color           = self.color;
    cumulativeDistanceView.color    = self.color;
}

-(void)setSpeed:(double)speed
{
    _speed          = speed;
    speedView.speed = self.speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    logBool(isSpeedUnitMph);
    _isSpeedUnitMph                         = isSpeedUnitMph;
    speedView.isSpeedUnitMph                = self.isSpeedUnitMph;
    cumulativeDistanceView.isSpeedUnitMph   = self.isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{
    headingView.heading = heading;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    cumulativeDistanceView.location = self.location;
}

#pragma -- operation
-(void)active
{
    [systemStatusView active];
    [clockView active];
    [elapsedTimeView active];
    [cumulativeDistanceView active];
}

-(void)inactive
{
    [systemStatusView inactive];
    [clockView inactive];
    [elapsedTimeView inactive];
    [cumulativeDistanceView inactive];
}

@end
