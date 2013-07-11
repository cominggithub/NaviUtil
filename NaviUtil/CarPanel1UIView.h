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

@property (strong, nonatomic) UIImageView* signal;
@property (strong, nonatomic) UIImageView* gps;
@property (strong, nonatomic) UIImageView* battery;
@property (strong, nonatomic) UIImageView* speed_num_0;
@property (strong, nonatomic) UIImageView* speed_num_1;
@property (strong, nonatomic) UIImageView* speed_num_2;


@property (strong, nonatomic) UIColor* color;
-(void) autoRedrawStart;
-(void) autoRedrawStop;
-(void) update;
-(void) start;
-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;

@end
