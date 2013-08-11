//
//  UIFont+category.m
//  NaviUtil
//
//  Created by Coming on 8/10/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "UIFont+category.h"

@implementation UIFont (category)


-(UIFont*) newFontsize:(float) fontSize
{
    return [UIFont fontWithName:self.fontName size:fontSize];
}

@end
