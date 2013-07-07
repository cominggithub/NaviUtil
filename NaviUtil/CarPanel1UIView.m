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

#define FILE_DEBUG TRUE

#include "Log.h"
@implementation CarPanel1UIView
{
    NSMutableArray* _drawBlocks;
    DigitalNumDrawBlock *_speedNumDigitalNumDrawBlock;
    NSTimer *_redrawTimer;
    int _redrawInterval;
    
}


-(id) init
{
    self = [super init];
    
    if (self)
    {
        logfn();
        [self initSelf];
    }
    
    return self;
    
}


-(id) initWithFrame:(CGRect)frame
{

    logfn();
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    logfn();
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    
    return self;
}

-(void) initSelf
{

    _drawBlocks = [[NSMutableArray alloc] initWithCapacity:0];
    
    _speedNumDigitalNumDrawBlock = [DigitalNumDrawBlock digitalNumDrawBlockWithNumImagePrefix:@"car_panel_1_num_" origin:CGPointMake(0, 0) size:CGSizeMake(100, 100)];
    
    _speedNumDigitalNumDrawBlock.color          = [UIColor greenColor];
    _speedNumDigitalNumDrawBlock.isPaddingZero  = TRUE;
    [_drawBlocks addObject:[DrawBlock drawBlockWithImageName:@"car_panel1_direction_panel_outter_circle.png" origin:CGPointMake(0, 0) size:CGSizeMake(320, 320)]];

    [_drawBlocks addObject:_speedNumDigitalNumDrawBlock];
    
    _redrawInterval = 0.3;
}

- (void)drawRect:(CGRect)rect
{
    logfn();
    [super drawRect:rect];

    for(DrawBlock* db in _drawBlocks)
    {
        logo(db);
        [db drawRect:rect];
    }
        
}

-(void) autoRedrawStart
{
    if (nil == _redrawTimer)
    {
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

-(void) redrawTimeout
{
    _speedNumDigitalNumDrawBlock.value += 1;
    [self setNeedsDisplay];
    
}

-(void) update
{
    for(DrawBlock* db in _drawBlocks)
    {
        [db update];
    }
}
@end
