//
//  UIImageView+category.m
//  NaviUtil
//
//  Created by Coming on 7/11/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "UIImageView+category.h"
#import "UIImage+category.h"

@implementation UIImageView (category)

-(void) setImageTintColor:(UIColor*) color
{
    if (nil != self.image)
    {
        self.image = [self.image imageTintedWithColor:color];
    }
}
@end
