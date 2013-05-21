//
//  UILabel+category.m
//  NaviUtil
//
//  Created by Coming on 13/5/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "UILabel+category.h"

@implementation UILabel (category)
-(void)resizeToStretch{
    float width = [self expectedWidth];
    CGRect newFrame = [self frame];
    logf(width);
    logf(newFrame.size.width);
    newFrame.size.width = width;
    [self setFrame:newFrame];
}

-(float)expectedWidth{
    [self setNumberOfLines:1];
    logf(self.frame.size.height);
    logf(self.frame.size.width);
    CGSize maximumLabelSize = CGSizeMake(9999, self.frame.size.height);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return expectedLabelSize.width;
}
@end
