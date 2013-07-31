//
//  BatteryLifeView.m
//  NaviUtil
//
//  Created by Coming on 7/31/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "BatteryLifeView.h"
#import "UIColor+category.h"
#include "Log.h"

@implementation BatteryLifeView
{
    BOOL _firstDraw;
    int _width;
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
    _life = 0;
    _firstDraw = FALSE;
    _width = 34;
}

-(void) setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

-(void) setLife:(float)life
{
    if (life > 1)
        life = 1;
    
    if (life < 0)
        life = 0;

    
    _life = life;

    [self setNeedsDisplay];
    
}
- (void)drawRect:(CGRect)rect
{
    float lineWidth = 2;
    float r,g,b, a;
    

    CGSize headSize = CGSizeMake(rect.size.width/6, rect.size.height/2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [super drawRect:rect];

    [_color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGRect mainBody = CGRectMake(lineWidth, lineWidth, rect.size.width - lineWidth - headSize.width, rect.size.height - lineWidth);
    CGRect head = CGRectMake(
                             mainBody.origin.x + mainBody.size.width,
                             mainBody.origin.y + mainBody.size.height/4,
                             rect.size.width - mainBody.origin.x - mainBody.size.width - lineWidth,
                             mainBody.size.height/2
                             );
    
    CGRect batterLife = CGRectMake(lineWidth*2, lineWidth*2, _life * (mainBody.size.width - lineWidth*2), mainBody.size.height - lineWidth*2);
    

    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextSetStrokeColorWithColor(context, _color.CGColor);

    
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeRect(context, mainBody);
    CGContextStrokeRect(context, head);

    CGContextSetFillColorWithColor(context, [_color getOffColor].CGColor);
    CGContextFillRect(context, batterLife);
    

}


@end
