//
//  CarPanel3CumulativeDistanceView.h
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanel3CumulativeDistanceView : UIView<CarPanelColorProtocol>

@property (nonatomic, strong) UIColor* color;
@property (nonatomic) double cumulativeDistance;
@property (nonatomic) double isSpeedUnitMph;
@property (nonatomic) CLLocationCoordinate2D location;
@end
