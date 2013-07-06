//
//  UIImage+category.h
//  CarPanel
//
//  Created by Coming on 13/6/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (category)
- (UIImage *) imageRotatedByRadians:(CGFloat)radians;
- (UIImage *) changeColorForImage:(UIImage *)image toColor:(UIColor*)color;

- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end
