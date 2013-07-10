//
//  CarPanel1UIView.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "CarPanel1UIView.h"
#import "DrawBlock.h"
#import "DigitalNumDrawBlock.h"
#import "TimeDrawBlock.h"
#import "BatteryNormalDrawBlock.h"
#import "UIAnimation.h"
#import "UIImage+category.h"

#define FILE_DEBUG TRUE

#include "Log.h"
@implementation CarPanel1UIView
{
    NSMutableArray* _drawBlocks;
    DrawBlock *_compassOutterCircyle;
    DrawBlock *_compassInnerCircyle;
    BatteryNormalDrawBlock *_battery;
    DrawBlock *_signal;
    DrawBlock *_gps;
    
    DigitalNumDrawBlock *_speedNumDigitalNumDrawBlock;
    TimeDrawBlock *_currentTime;
    NSTimer *_redrawTimer;
    int _redrawInterval;
    

    
    CGSize _contentSize;
    BOOL _isPreDraw;
    dispatch_queue_t _backgroundQueue;
    

}


-(id) init
{
    self = [super init];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
    
}


-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    
    return self;
}


-(void) initSelf
{
    _car_panel1_direction_panel_inner_circle = (UIImageView *) [self viewWithTag:1  ];
    _car_panel1_direction_panel_outer_circle = (UIImageView *) [self viewWithTag:2  ];

    self.backgroundColor = [UIColor blackColor];
    self.color = [UIColor cyanColor];
}


-(void) setColor:(UIColor *)color
{
    _color = color;
    if (nil != _car_panel1_direction_panel_inner_circle)
    {
        _car_panel1_direction_panel_inner_circle.image =
            [_car_panel1_direction_panel_inner_circle.image imageTintedWithColor:_color];
    }
    
    if (nil != _car_panel1_direction_panel_outer_circle)
    {
        _car_panel1_direction_panel_outer_circle.image =
        [_car_panel1_direction_panel_outer_circle.image imageTintedWithColor:_color];
    }
    
}
-(void) start
{
    [UIAnimation runSpinAnimationOnView:_car_panel1_direction_panel_inner_circle duration:100 rotations:0.1 repeat:100];
    [UIAnimation runSpinAnimationOnView:_car_panel1_direction_panel_outer_circle duration:100 rotations:-0.1 repeat:100];
}
#if 0
-(void) initSelf
{

    _drawBlocks = [[NSMutableArray alloc] initWithCapacity:0];
    

    _battery    = [BatteryNormalDrawBlock batteryNormalDrawBlockWithOrigin:CGPointMake(20, 10) size:CGSizeMake(50, 30)];
    _signal     = [DrawBlock drawBlockWithImageName:@"signal" origin:CGPointMake(90, 10) size:CGSizeMake(50, 30)];
    _gps        = [DrawBlock drawBlockWithImageName:@"GPS" origin:CGPointMake(160, 10) size:CGSizeMake(50, 30)];


    
    _currentTime            = [TimeDrawBlock timeDrawBlockWithNumImagePrefix:@"car_panel_1_num_" origin:CGPointMake(20, 100) size:CGSizeMake(100, 30)];

    _speedNumDigitalNumDrawBlock = [DigitalNumDrawBlock digitalNumDrawBlockWithNumImagePrefix:@"car_panel_1_num_" origin:CGPointMake(260, 150) size:CGSizeMake(120, 50)];
    _compassOutterCircyle   = [DrawBlock drawBlockWithImageName:@"car_panel1_direction_panel_outter_circle.png" origin:CGPointMake(150, 0) size:CGSizeMake(340, 340)];
    _compassInnerCircyle    = [DrawBlock drawBlockWithImageName:@"car_panel1_direction_panel_inner_circle" origin:CGPointMake(225, 76) size:CGSizeMake(190, 188)];

    
    _battery.name = @"battery";
    _signal.name = @"_signal";
    _gps.name = @"_gps";
    _currentTime.name = @"_currentTime";
    _speedNumDigitalNumDrawBlock.name = @"_speedNumDigitalNumDrawBlock";
    _compassOutterCircyle.name = @"_compassOutterCircyle";
    _compassInnerCircyle.name = @"_compassInnerCircyle";    
    

    _speedNumDigitalNumDrawBlock.isPaddingZero  = TRUE;

    
    _compassOutterCircyle.rotateInfinite    = TRUE;
    _compassOutterCircyle.rotateSpeed       = 0.1;
    _compassInnerCircyle.rotateInfinite     = TRUE;
    _compassInnerCircyle.rotateSpeed        = 0.2;

    _gps.flashHideInterval = 0.1;
    _gps.flashShowInterval = 1;

    [_drawBlocks addObject:_compassOutterCircyle];
    [_drawBlocks addObject:_compassInnerCircyle];
    [_drawBlocks addObject:_speedNumDigitalNumDrawBlock];
    [_drawBlocks addObject:_currentTime];

    [_drawBlocks addObject:_battery];
    [_drawBlocks addObject:_signal];
//    [_drawBlocks addObject:_gps];
    
    
    _redrawInterval = 0.5;
    _preDrawImage = nil;
    _backgroundQueue = dispatch_queue_create("pre-draw thread", NULL);
    
    _contentSize = CGSizeMake(480, 320);
    
    

}

#endif
- (void) preDrawRect
{
    UIGraphicsBeginImageContext(_contentSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect preDrawRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
    
    for(DrawBlock* db in _drawBlocks)
    {
        [db drawRect:preDrawRect context:context];
    }
    
    _preDrawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

}

#if 0
- (void)drawRect:(CGRect)rect
{
    NSLog(@"draw\n");
    [super drawRect:rect];
    [_preDrawImage drawInRect:rect];
}

#endif

#if 0
-(void) autoRedrawStart
{
    logfn();
    if (nil == _redrawTimer)
    {
        logfn();
        _redrawTimer = [NSTimer scheduledTimerWithTimeInterval:_redrawInterval target:self selector:@selector(redrawTimeout) userInfo:nil repeats:YES];
    }
}

-(void) autoRedrawStop
{
    if (nil != _redrawTimer)
    {
        [_redrawTimer invalidate];
        _redrawTimer = nil;
    }
}

-(void) startPreDraw
{
    _isPreDraw = TRUE;
    logfn();
#if 0
    dispatch_async(_backgroundQueue, ^(void) {
        [self preDrawThread];
    });
#endif
}

-(void) stopPreDraw
{
    logfn();
    _isPreDraw = FALSE;
}

-(void) preDrawThread
{
    while (TRUE == _isPreDraw)
    {
    
        [self preDrawRect];
        NSLog(@"predraw\n");
        usleep(50);
    }
}

-(void) redrawTimeout
{
    _speedNumDigitalNumDrawBlock.value += 1;
    _currentTime.value = [_currentTime.value dateByAddingTimeInterval:60];
    
    if (_battery.life > 0)
        _battery.life -= 0.01;
    else
        _battery.life = 1;
    
    [self setNeedsDisplay];
    
}

-(void) update
{
    for(DrawBlock* db in _drawBlocks)
    {
        [db update];
    }
}

#endif
-(void) monitorBattery
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(batteryLevelUpdate)
     name:UIDeviceBatteryLevelDidChangeNotification
     object:nil];
}

- (void)batteryLevelUpdate:(NSNotification *)notification
{
    _battery.life = [[UIDevice currentDevice] batteryLevel];
}

@end
