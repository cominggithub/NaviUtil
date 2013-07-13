//
//  UILabel+category.m
//  NaviUtil
//
//  Created by Coming on 13/5/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "UILabel+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation UILabel (category)
-(void) resizeToStretch
{
    float width = [self expectedWidth];
    CGRect newFrame = [self frame];
    newFrame.size.width = width;
    [self setFrame:newFrame];
}

-(float) expectedWidth
{
    [self setNumberOfLines:1];
    CGSize maximumLabelSize = CGSizeMake(9999, self.frame.size.height);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return expectedLabelSize.width;
}

-(void) autoFontSize:(int) minFontSize maxWidth:(int)maxWidth
{
    [self setNumberOfLines:1];
    float expectedWidth = [self expectedWidth];
    
    while (expectedWidth > maxWidth && self.font.pointSize > minFontSize)
    {
        UIFont *f = [UIFont fontWithName:self.font.fontName size:self.font.pointSize-1];
        self.font = f;
    }
}
@end
