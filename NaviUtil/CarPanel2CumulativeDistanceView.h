//
//  CarPanel2CumulativeDistanceView.h
//  NaviUtil
//
//  Created by Coming on 8/2/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanel2CumulativeDistanceView : UIView<CarPanelLocationProtocol, CarPanelActiveProtocol, CarPanelSpeedProtocol>

@property (weak, nonatomic) UIColor* color;
@property (nonatomic) double cumulativeDistance;
@property (nonatomic) double speed;
@property (nonatomic) double isSpeedUnitMph;
@property (nonatomic) CLLocationCoordinate2D location;
@end
