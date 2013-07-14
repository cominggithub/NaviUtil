//
//  UIAnimation.m
//  NaviUtil
//
//  Created by Coming on 7/10/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "UIAnimation.h"


@implementation UIAnimation

+ (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

+(void) flash:(UIView*) view
{
    [UIView animateWithDuration:1.0 delay:0.f options:(UIViewAnimationOptionAutoreverse| UIViewAnimationOptionRepeat)
                 animations:^{
                     view.alpha=1.f;
                 } completion:^(BOOL finished){
                     view.alpha=0.f;
                 }];

}
@end
