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
#import "CarPanel2CircleView.h"


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
    SystemStatusView *systemStatusView;
    CarPanel2SpeedView *speedView;
    CarPanel2CircleView *circleView;
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
    systemStatusView            = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    speedView                   = [[CarPanel2SpeedView alloc] initWithFrame:CGRectMake(0, 100, 200, 200)];
    circleView                  = [[CarPanel2CircleView alloc] initWithFrame:CGRectMake(250, 100, 200, 200)];
    
    
    [self addSubview:systemStatusView];
    [self addSubview:speedView];
    [self addSubview:circleView];
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

-(void)setColor:(UIColor *)color
{

    _color                  = color;
    systemStatusView.color  = self.color;
    speedView.color         = self.color;
    circleView.color        = self.color;
}

-(void)setSpeed:(double)speed
{
    _speed          = speed;
    speedView.speed = self.speed;
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph             = isSpeedUnitMph;
    speedView.isSpeedUnitMph    = self.isSpeedUnitMph;
}

-(void)setHeading:(double)heading
{
    logfn();
    circleView.heading = heading;
}

#pragma -- operation
-(void)active
{
    [systemStatusView active];
}

-(void)inactive
{
    [systemStatusView inactive];
}

@end
