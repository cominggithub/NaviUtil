//
//  UIColor+category.m
//  NaviUtil
//
//  Created by Coming on 7/29/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "UIColor+category.h"

@implementation UIColor (category)

-(void) getRGBA:(float*) red green:(float*) green blue:(float*) blue alpha:(float*) alpha
{
    long numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents([self CGColor]);
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }
}

-(UIColor*) getOff05Color
{
    CGFloat r,g,b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
        
    return [UIColor colorWithRed:r green:g blue:b alpha:a*0.5];
}

-(UIColor*) getOff03Color
{
    CGFloat r,g,b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:0.3];
}

-(UIColor*) getColorByAlpha:(float) alpha
{
    CGFloat r,g,b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

-(NSString*) getRGBHexCode
{
    CGFloat r,g,b,a;

    [self getRed:&r green:&g blue:&b alpha:&a];
    int hexCode = (0xFF&(int)(r*255)) << 16 | (0xFF&(int)(g*255)) << 8 | (0xFF&(int)(b*255));
    return [NSString stringWithFormat:@"%06X", hexCode ];
}
+(UIColor*) colorWithRGBHexCode:(NSString*) rgbHexCode
{
    CGFloat r, g, b;
    UIColor *c = nil;
    unsigned result = 0;
    NSScanner *scanner;
    
    if ( rgbHexCode.length == 6)
    {
        scanner = [NSScanner scannerWithString:rgbHexCode];
        
        [scanner setScanLocation:0];
        
        if (YES == [scanner scanHexInt:&result])
        {
        
            r = ((result >> 16) & 0x000000FF)/255.0;
            g = ((result >> 8) & 0x000000FF)/255.0;
            b = ((result >> 0) & 0x000000FF)/255.0;
        
            c = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }
    }
    
    return c;

}
@end
