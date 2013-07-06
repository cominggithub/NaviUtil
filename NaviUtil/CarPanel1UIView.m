//
//  CarPanel1UIView.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "CarPanel1UIView.h"
#import "DrawBlock.h"

#define FILE_DEBUG TRUE

#include "Log.h"
@implementation CarPanel1UIView
{
    NSMutableArray* _drawBlocks;
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
    _drawBlocks = [[NSMutableArray alloc] initWithCapacity:0];
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];

    for(DrawBlock* db in _drawBlocks)
    {
        [db drawRect:rect];
    }
        
}
@end
