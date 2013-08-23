//
//  CarPanel1UIView.h
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface CarPanel1UIView : UIView<LocationManagerDelegate>


@property (strong, nonatomic) UIImage *preDrawImage;

@property (strong, nonatomic) UIImageView* direction_panel_inner_circle;
@property (strong, nonatomic) UIImageView* direction_panel_outer_circle;

@property (weak, nonatomic) UIImageView* signal;
@property (weak, nonatomic) UIImageView* gps;
@property (weak, nonatomic) UIImageView* battery;
@property (weak, nonatomic) UIImageView* speed_num_0;
@property (weak, nonatomic) UIImageView* speed_num_1;
@property (weak, nonatomic) UIImageView* speed_num_2;
@property (weak, nonatomic) UILabel *speedLabel;


@property (strong, nonatomic) UIColor* color;
-(void) start;
-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;

@end
