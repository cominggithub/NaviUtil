//
//  CarPanel2SpeedView.h
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanel2SpeedView : UIView<CarPanelColorProtocol, CarPanelSpeedProtocol>

@property (weak, nonatomic) UIColor* color;
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (nonatomic) BOOL isSpeedUnitMph;

@end
