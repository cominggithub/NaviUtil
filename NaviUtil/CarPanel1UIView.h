//
//  CarPanel1UIView.h
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarPanel1UIView : UIView


@property (strong, nonatomic) UIImage *preDrawImage;

@property (strong, nonatomic) UIImageView* car_panel1_direction_panel_inner_circle;
@property (strong, nonatomic) UIImageView* car_panel1_direction_panel_outer_circle;

@property (strong, nonatomic) UIColor* color;
-(void) autoRedrawStart;
-(void) autoRedrawStop;
-(void) update;
-(void) start;

@end
