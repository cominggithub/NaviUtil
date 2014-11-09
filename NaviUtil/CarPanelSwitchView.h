//
//  CarPanelSwitchView.h
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanelSwitchView : UIImageView<CarPanelColorProtocol>

@property (weak, nonatomic) UIColor* color;
@property (nonatomic) NSString *onImageName;
@property (nonatomic) NSString *offImageName;
@property (nonatomic, assign) BOOL enabled;

@end
