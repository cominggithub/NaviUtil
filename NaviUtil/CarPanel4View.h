//
//  CarPanel4View.h
//  NaviUtil
//
//  Created by Coming on 10/7/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanel4View : UIView<CarPanelViewProtocol>

@property (weak, nonatomic) UIColor* color;
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (nonatomic) BOOL isSpeedUnitMph;
@property (nonatomic) BOOL isHud;
@property (nonatomic) CLLocationCoordinate2D location;

@end
