//
//  ClockView.h
//  NaviUtil
//
//  Created by Coming on 8/17/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockView : UIView
@property (strong, nonatomic) UIColor *color;
-(void) update;
-(void) active;
-(void) deactive;
@end
