//
//  BatteryLifeView.m
//  NaviUtil
//
//  Created by Coming on 7/31/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "BatteryLifeView.h"
#import "UIColor+category.h"
#import "SystemConfig.h"

#include "Log.h"

@implementation BatteryLifeView
{
    BOOL _firstDraw;
    int _width;
    UILabel *_lifeLabel;
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
    _lifeLabel                  = [[UILabel alloc] init];
    _lifeLabel.frame            = CGRectMake(0, 20, 30, 40);
    _lifeLabel.backgroundColor  = [UIColor clearColor];
    _lifeLabel.textColor        = [UIColor whiteColor];
    _firstDraw                  = FALSE;
    _width                      = 34;
    self.life                   = 100;


    if (YES == [SystemConfig getBoolValue:CONFIG_H_IS_DEBUG])
    {
//        [self addSubview:_lifeLabel];
    }
    
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

    _lifeLabel.text = [NSString stringWithFormat:@"%.0f", _life*100];
    [self setNeedsDisplay];
    
}
- (void)drawRect:(CGRect)rect
{
    // xcode 

    float lineWidth = 2;
    CGFloat r,g,b, a;
    

    CGSize headSize = CGSizeMake(rect.size.width/6, rect.size.height/2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [super drawRect:rect];

    [_color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGRect mainBody = CGRectMake(lineWidth, lineWidth, rect.size.width - lineWidth - headSize.width, rect.size.height - lineWidth*2);
    CGRect head = CGRectMake(
                             mainBody.origin.x + mainBody.size.width+0.5,
                             mainBody.origin.y + mainBody.size.height/4,
                             rect.size.width - mainBody.origin.x - mainBody.size.width - lineWidth,
                             mainBody.size.height/2
                             );
    
    CGRect batterLife = CGRectMake(lineWidth*2-1, lineWidth*2-1, _life * (mainBody.size.width - lineWidth*2)+2, mainBody.size.height - lineWidth*2+2);
    

    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextSetStrokeColorWithColor(context, _color.CGColor);

    
    CGContextSetLineWidth(context, lineWidth);
//    CGContextStrokeRect(context, mainBody);

    [self drawRoundRect:context rect:mainBody radius:3];

    CGContextStrokeRect(context, head);

    CGContextSetFillColorWithColor(context, [_color getOff05Color].CGColor);

    CGContextFillRect(context, batterLife);



}

-(void) drawRoundRect:(CGContextRef) context rect:(CGRect) rect radius:(int) radius
{
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.9].CGColor);
    CGContextFillPath(context);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    CGContextStrokePath(context);
}


@end
