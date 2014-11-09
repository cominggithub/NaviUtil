//
//  CarPanel4SpeedView.h
//  NaviUtil
//
//  Created by Coming on 10/18/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"
#import "CarPanelNumberView.h"

@interface CarPanel4SpeedView : UIView<CarPanelColorProtocol, CarPanelSpeedProtocol>

@property (nonatomic, strong) UIColor* color;
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (nonatomic) BOOL isSpeedUnitMph;

@end
