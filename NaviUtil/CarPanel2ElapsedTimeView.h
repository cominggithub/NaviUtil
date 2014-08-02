//
//  CarPanel2ElapsedTime.h
//  NaviUtil
//
//  Created by Coming on 8/2/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanel2ElapsedTimeView : UIView<CarPanelColorProtocol, CarPanelActiveProtocol>
@property (weak, nonatomic) UIColor* color;

@end
