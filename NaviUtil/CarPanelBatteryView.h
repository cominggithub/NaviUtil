//
//  CarPanelBatteryView.h
//  NaviUtil
//
//  Created by Coming on 10/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CarPanelBatteryView : UIView

@property (nonatomic, assign) CGRect batteryLifeRect;
@property (nonatomic, assign) int batteryPercentage;
@property (nonatomic, strong) UIColor *color;
@end
