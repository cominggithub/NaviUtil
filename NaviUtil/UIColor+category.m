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
    int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents([self CGColor]);
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }
}

-(UIColor*) getOffColor
{
    float r,g,b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
        
    return [UIColor colorWithRed:r green:g blue:b alpha:a*0.5];
}
@end
