//
//  UIImage+category.m
//  CarPanel
//
//  Created by Coming on 13/6/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "UIImage+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation UIImage (category)

+(UIImage*) imageNamed:(NSString *)name color:(UIColor*) color
{
    UIImage *img = [UIImage imageNamed:name];
    return [img imageTintedWithColor:color];
}
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    //    float diameter;
    //    diameter = sqrtf(powf(self.size.width/2, 2) + powf(self.size.height/2, 2));
    //  diameter = diameter*2;
    

    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    //    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,diameter, diameter)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    //    CGSize rotatedSize = rotatedViewBox.frame.size;
    CGSize rotatedSize = self.size;

    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    //    CGContextTranslateCTM(bitmap, diameter/2, diameter/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextSetShouldAntialias(bitmap, YES);
    CGContextSetAllowsAntialiasing(bitmap, YES);
    
    // Now, draw the rotated/scaled image into the context
    //    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    //    CGContextDrawImage(bitmap, CGRectMake(-diameter/ 2, -diameter / 2, diameter, diameter), [self CGImage]);
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *) changeColorForImage:(UIImage *)image toColor:(UIColor*)color {
    UIGraphicsBeginImageContext(image.size);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [image size];
    // Retrieve source image and begin image context
    CGSize itemImageSize = [image size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContext(contextRect.size);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
    // Fill and end the transparency layer
    
    
    const CGFloat* colors = CGColorGetComponents( color.CGColor );
    CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], .75);
    
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageTintedWithColor:(UIColor *)color
{
	// This method is designed for use with template images, i.e. solid-coloured mask-like images.
	return [self imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}


- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
	if (color) {
		// Construct new image the same size as this one.
		UIImage *image;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
		if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
			UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
		} else {
			UIGraphicsBeginImageContext([self size]);
		}
#else
		UIGraphicsBeginImageContext([self size]);
#endif
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		// Composite tint color at its own opacity.
		[color set];
		UIRectFill(rect);
		
		// Mask tint color-swatch to this image's opaque mask.
		// We want behaviour like NSCompositeDestinationIn on Mac OS X.
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		// Finally, composite this image over the tinted mask at desired opacity.
		if (fraction > 0.0) {
			// We want behaviour like NSCompositeSourceOver on Mac OS X.
			[self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
		}
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
}

@end

