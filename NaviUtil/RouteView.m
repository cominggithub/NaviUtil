//
//  RouteUIView.m
//  NaviUtil
//
//  Created by Coming on 1/19/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "RouteView.h"

@implementation RouteView

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
    
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGPoint startPoint;
    CGPoint endPoint;
    CGRect endPointRect;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *_color = [UIColor greenColor];
    int circleSize = 8;
    [super drawRect:rect];
    
    // Drawing code
    
    
    startPoint.x = 120;
    startPoint.y = 250;
    
    endPoint.x = startPoint.x;
    endPoint.y = startPoint.y - 100;
    
    // draw line
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    
    
    // draw circle
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);

    
    endPointRect.origin.x = startPoint.x - circleSize;
    endPointRect.origin.y = startPoint.y - circleSize;
    endPointRect.size.width = circleSize*2;
    endPointRect.size.height = circleSize*2;
    CGContextFillEllipseInRect(context, endPointRect);
    CGContextStrokeEllipseInRect(context, endPointRect);
    
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextFillEllipseInRect(context, CGRectInset(endPointRect, 8, 8));
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context, endPointRect);
    CGContextStrokeRect(context, endPointRect);
    
}


@end
