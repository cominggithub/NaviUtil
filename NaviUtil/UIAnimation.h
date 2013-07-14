//
//  UIAnimation.h
//  NaviUtil
//
//  Created by Coming on 7/10/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIAnimation : NSObject
+(void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
+(void) flash:(UIView*) view;
@end
