//
//  UIColor+category.h
//  NaviUtil
//
//  Created by Coming on 7/29/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (category)
-(void) getRGBA:(float*) red green:(float*) green blue:(float*) blue alpha:(float*) alpha;
-(UIColor*) getOff05Color;
-(UIColor*) getOff03Color;
-(UIColor*) getColorByAlpha:(float) alpha;
-(NSString*) getRGBHexCode;
+(UIColor*) colorWithRGBHexCode:(NSString*) rgbHexCode;
@end
