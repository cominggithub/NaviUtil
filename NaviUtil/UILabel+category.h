//
//  UILabel+category.h
//  NaviUtil
//
//  Created by Coming on 13/5/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (category)
-(void)resizeToStretch;
-(float)expectedWidth;
-(void) autoFontSize:(int) minFontSize maxWidth:(int)maxWidth;
@end
